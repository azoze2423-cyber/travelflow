import 'package:flutter/material.dart';
import '../models/models.dart';
import '../store/app_store.dart';
import '../widgets/common.dart';

class VisasPage extends StatefulWidget {
  const VisasPage({super.key, required this.store});
  final AppStore store;
  @override State<VisasPage> createState() => _VisasPageState();
}

class _VisasPageState extends State<VisasPage> {
  String query = '';
  @override Widget build(BuildContext context) {
    final rows = widget.store.visas.where((v) { final c = widget.store.customerById(v.customerId); return '${c?.name ?? ''} ${v.country} ${v.visaType} ${v.status}'.toLowerCase().contains(query.toLowerCase()); }).toList().reversed.toList();
    return Column(children: [
      PageHeader(title: 'Visa management', subtitle: 'Track applications, status, fees and expiry dates', action: FilledButton.icon(onPressed: widget.store.customers.isEmpty ? null : () => _edit(), icon: const Icon(Icons.add), label: const Text('New visa case'))),
      const SizedBox(height: 18),
      TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search visa cases'), onChanged: (v) => setState(() => query = v)),
      const SizedBox(height: 16),
      Expanded(child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))), child: rows.isEmpty ? const Center(child: Text('No visa cases')) : ListView.separated(padding: const EdgeInsets.all(12), itemCount: rows.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) {
        final v = rows[i]; final c = widget.store.customerById(v.customerId);
        return ListTile(leading: const CircleAvatar(child: Icon(Icons.description_outlined)), title: Row(children: [Expanded(child: Text(c?.name ?? 'Unknown customer', style: const TextStyle(fontWeight: FontWeight.w700))), StatusPill(v.status)]), subtitle: Text('${v.country} • ${v.visaType} • Applied: ${v.applicationDate}\nExpiry: ${v.expiryDate.isEmpty ? '-' : v.expiryDate} • Fee: ${money(v.fee, widget.store.currency)}'), isThreeLine: true, trailing: Wrap(children: [IconButton(onPressed: () => _edit(v), icon: const Icon(Icons.edit_outlined)), IconButton(onPressed: () => _delete(v), icon: const Icon(Icons.delete_outline, color: Colors.red))]));
      }))),
    ]);
  }

  Future<void> _delete(VisaCase v) async { final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete visa case?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))])) ?? false; if (ok) await widget.store.deleteVisa(v.id); }

  Future<void> _edit([VisaCase? current]) async {
    String customerId = current?.customerId ?? widget.store.customers.first.id;
    String visaType = current?.visaType ?? 'Tourist';
    String status = current?.status ?? 'New';
    final country = TextEditingController(text: current?.country ?? '');
    final application = TextEditingController(text: current?.applicationDate ?? DateTime.now().toIso8601String().substring(0,10));
    final expiry = TextEditingController(text: current?.expiryDate ?? '');
    final fee = TextEditingController(text: current?.fee.toString() ?? '0');
    final notes = TextEditingController(text: current?.notes ?? '');
    final result = await showDialog<VisaCase>(context: context, builder: (context) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
      title: Text(current == null ? 'New visa case' : 'Edit visa case'),
      content: SizedBox(width: 620, child: SingleChildScrollView(child: Column(children: [
        DropdownButtonFormField<String>(initialValue: customerId, decoration: const InputDecoration(labelText: 'Customer'), items: widget.store.customers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (v) => setLocal(() => customerId = v!)), const SizedBox(height: 10),
        Row(children: [Expanded(child: TextField(controller: country, decoration: const InputDecoration(labelText: 'Country'))), const SizedBox(width: 10), Expanded(child: DropdownButtonFormField<String>(initialValue: visaType, decoration: const InputDecoration(labelText: 'Visa type'), items: ['Tourist','Business','Transit','Visit','Work','Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setLocal(() => visaType = v!)))]), const SizedBox(height: 10),
        DropdownButtonFormField<String>(initialValue: status, decoration: const InputDecoration(labelText: 'Status'), items: ['New','Documents pending','Submitted','Processing','Approved','Rejected'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setLocal(() => status = v!)), const SizedBox(height: 10),
        Row(children: [Expanded(child: TextField(controller: application, readOnly: true, decoration: const InputDecoration(labelText: 'Application date'), onTap: () async { final x = await pickDateText(context, application.text); if (x != null) application.text = x; })), const SizedBox(width: 10), Expanded(child: TextField(controller: expiry, readOnly: true, decoration: const InputDecoration(labelText: 'Expiry date'), onTap: () async { final x = await pickDateText(context, expiry.text); if (x != null) expiry.text = x; }))]), const SizedBox(height: 10),
        TextField(controller: fee, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Fee (${widget.store.currency})')), const SizedBox(height: 10),
        TextField(controller: notes, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Notes')),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, VisaCase(id: current?.id ?? widget.store.newId(), customerId: customerId, country: country.text.trim(), visaType: visaType, status: status, applicationDate: application.text, expiryDate: expiry.text, fee: double.tryParse(fee.text) ?? 0, notes: notes.text.trim())), child: const Text('Save'))],
    )));
    if (result != null) current == null ? await widget.store.addVisa(result) : await widget.store.updateVisa(result);
  }
}

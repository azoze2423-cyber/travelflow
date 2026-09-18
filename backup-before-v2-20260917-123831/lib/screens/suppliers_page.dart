import 'package:flutter/material.dart';
import '../models/models.dart';
import '../store/app_store.dart';
import '../widgets/common.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key, required this.store});
  final AppStore store;
  @override State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  String query = '';
  @override Widget build(BuildContext context) {
    final rows = widget.store.suppliers.where((s) => '${s.name} ${s.type} ${s.contactPerson} ${s.email}'.toLowerCase().contains(query.toLowerCase())).toList();
    return Column(children: [
      PageHeader(title: 'Suppliers', subtitle: 'Airlines, hotels, visa providers and transfer partners', action: FilledButton.icon(onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('Add supplier'))),
      const SizedBox(height: 18),
      TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search suppliers'), onChanged: (v) => setState(() => query = v)),
      const SizedBox(height: 16),
      Expanded(child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))), child: rows.isEmpty ? const Center(child: Text('No suppliers')) : ListView.separated(padding: const EdgeInsets.all(12), itemCount: rows.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) {
        final s = rows[i];
        return ListTile(leading: const CircleAvatar(child: Icon(Icons.business_outlined)), title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${s.type} • ${s.contactPerson}\n${s.phone} • ${s.email}'), isThreeLine: true, trailing: Wrap(children: [IconButton(onPressed: () => _edit(s), icon: const Icon(Icons.edit_outlined)), IconButton(onPressed: () => _delete(s), icon: const Icon(Icons.delete_outline, color: Colors.red))]));
      }))),
    ]);
  }

  Future<void> _delete(Supplier s) async { final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete supplier?'), content: Text('Delete ${s.name}?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))])) ?? false; if (ok) await widget.store.deleteSupplier(s.id); }

  Future<void> _edit([Supplier? current]) async {
    String type = current?.type ?? 'Airline';
    final name = TextEditingController(text: current?.name ?? '');
    final phone = TextEditingController(text: current?.phone ?? '');
    final email = TextEditingController(text: current?.email ?? '');
    final contact = TextEditingController(text: current?.contactPerson ?? '');
    final notes = TextEditingController(text: current?.notes ?? '');
    final result = await showDialog<Supplier>(context: context, builder: (context) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
      title: Text(current == null ? 'Add supplier' : 'Edit supplier'),
      content: SizedBox(width: 600, child: SingleChildScrollView(child: Column(children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Supplier name *')), const SizedBox(height: 10),
        DropdownButtonFormField<String>(initialValue: type, decoration: const InputDecoration(labelText: 'Supplier type'), items: ['Airline','Hotel','Visa provider','Transfer','Insurance','Tour operator','Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setLocal(() => type = v!)), const SizedBox(height: 10),
        Row(children: [Expanded(child: TextField(controller: contact, decoration: const InputDecoration(labelText: 'Contact person'))), const SizedBox(width: 10), Expanded(child: TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')))]), const SizedBox(height: 10),
        TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')), const SizedBox(height: 10),
        TextField(controller: notes, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Notes')),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { if (name.text.trim().isEmpty) return; Navigator.pop(context, Supplier(id: current?.id ?? widget.store.newId(), name: name.text.trim(), type: type, phone: phone.text.trim(), email: email.text.trim(), contactPerson: contact.text.trim(), notes: notes.text.trim())); }, child: const Text('Save'))],
    )));
    if (result != null) current == null ? await widget.store.addSupplier(result) : await widget.store.updateSupplier(result);
  }
}

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../store/app_store.dart';
import '../widgets/common.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key, required this.store});
  final AppStore store;
  @override State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final rows = widget.store.customers.where((c) => '${c.name} ${c.phone} ${c.email} ${c.passportNumber}'.toLowerCase().contains(query.toLowerCase())).toList();
    return Column(children: [
      PageHeader(title: 'Customers', subtitle: 'Customer, passport and contact records', action: FilledButton.icon(onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('Add customer'))),
      const SizedBox(height: 18),
      TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by name, phone, email or passport'), onChanged: (v) => setState(() => query = v)),
      const SizedBox(height: 16),
      Expanded(child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))), child: rows.isEmpty ? const Center(child: Text('No customers found')) : ListView.separated(padding: const EdgeInsets.all(12), itemCount: rows.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (context, i) {
        final c = rows[i];
        return ListTile(
          leading: CircleAvatar(child: Text(c.name.isEmpty ? '?' : c.name[0].toUpperCase())),
          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${c.phone}  •  ${c.nationality}\nPassport: ${c.passportNumber.isEmpty ? '-' : c.passportNumber}  •  Exp: ${c.passportExpiry.isEmpty ? '-' : c.passportExpiry}'),
          isThreeLine: true,
          trailing: Wrap(spacing: 4, children: [IconButton(tooltip: 'Edit', onPressed: () => _edit(c), icon: const Icon(Icons.edit_outlined)), IconButton(tooltip: 'Delete', onPressed: () => _delete(c), icon: const Icon(Icons.delete_outline, color: Colors.red))]),
        );
      }))),
    ]);
  }

  Future<void> _delete(Customer c) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete customer?'), content: Text('Delete ${c.name}? Bookings will remain linked to an unknown customer.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))])) ?? false;
    if (ok) await widget.store.deleteCustomer(c.id);
  }

  Future<void> _edit([Customer? current]) async {
    final name = TextEditingController(text: current?.name ?? '');
    final phone = TextEditingController(text: current?.phone ?? '');
    final email = TextEditingController(text: current?.email ?? '');
    final nationality = TextEditingController(text: current?.nationality ?? '');
    final passport = TextEditingController(text: current?.passportNumber ?? '');
    final expiry = TextEditingController(text: current?.passportExpiry ?? '');
    final notes = TextEditingController(text: current?.notes ?? '');
    final result = await showDialog<Customer>(context: context, builder: (context) => AlertDialog(
      title: Text(current == null ? 'Add customer' : 'Edit customer'),
      content: SizedBox(width: 620, child: SingleChildScrollView(child: Column(children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name *')), const SizedBox(height: 10),
        Row(children: [Expanded(child: TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone'))), const SizedBox(width: 10), Expanded(child: TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')))]), const SizedBox(height: 10),
        TextField(controller: nationality, decoration: const InputDecoration(labelText: 'Nationality')), const SizedBox(height: 10),
        Row(children: [Expanded(child: TextField(controller: passport, decoration: const InputDecoration(labelText: 'Passport number'))), const SizedBox(width: 10), Expanded(child: TextField(controller: expiry, readOnly: true, decoration: const InputDecoration(labelText: 'Passport expiry', suffixIcon: Icon(Icons.calendar_today)), onTap: () async { final v = await pickDateText(context, expiry.text); if (v != null) expiry.text = v; }))]), const SizedBox(height: 10),
        TextField(controller: notes, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Notes')),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { if (name.text.trim().isEmpty) return; Navigator.pop(context, Customer(id: current?.id ?? widget.store.newId(), name: name.text.trim(), phone: phone.text.trim(), email: email.text.trim(), nationality: nationality.text.trim(), passportNumber: passport.text.trim(), passportExpiry: expiry.text.trim(), notes: notes.text.trim())); }, child: const Text('Save'))],
    ));
    if (result != null) current == null ? await widget.store.addCustomer(result) : await widget.store.updateCustomer(result);
  }
}

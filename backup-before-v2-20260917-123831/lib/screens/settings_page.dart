import 'package:flutter/material.dart';
import '../store/app_store.dart';
import '../widgets/common.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.store});
  final AppStore store;
  @override State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController name, currency, email, password, phone, address;
  @override void initState() { super.initState(); final s = widget.store; name = TextEditingController(text: s.agencyName); currency = TextEditingController(text: s.currency); email = TextEditingController(text: s.adminEmail); password = TextEditingController(text: s.adminPassword); phone = TextEditingController(text: s.phone); address = TextEditingController(text: s.address); }
  @override Widget build(BuildContext context) => SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const PageHeader(title: 'Settings', subtitle: 'Agency identity, currency and local administrator credentials'), const SizedBox(height: 20),
    Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Column(children: [
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Agency name')), const SizedBox(height: 12),
      Row(children: [Expanded(child: TextField(controller: currency, decoration: const InputDecoration(labelText: 'Currency (AED, USD...)'))), const SizedBox(width: 12), Expanded(child: TextField(controller: phone, decoration: const InputDecoration(labelText: 'Agency phone')))]), const SizedBox(height: 12),
      TextField(controller: address, decoration: const InputDecoration(labelText: 'Address')), const SizedBox(height: 12),
      const Divider(height: 30),
      TextField(controller: email, decoration: const InputDecoration(labelText: 'Admin email')), const SizedBox(height: 12),
      TextField(controller: password, decoration: const InputDecoration(labelText: 'Admin password')), const SizedBox(height: 18),
      Align(alignment: Alignment.centerLeft, child: FilledButton.icon(onPressed: () async { await widget.store.updateSettings(name: name.text.trim(), curr: currency.text.trim().isEmpty ? 'AED' : currency.text.trim().toUpperCase(), email: email.text.trim(), password: password.text, agencyPhone: phone.text.trim(), agencyAddress: address.text.trim()); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved'))); }, icon: const Icon(Icons.save_outlined), label: const Text('Save settings'))),
    ]))),
    const SizedBox(height: 18),
    Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Demo data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 8),
      const Text('Reset the app to the built-in demonstration customers, bookings, payments, visa case and suppliers.'), const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: () async { final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Reset demo data?'), content: const Text('All current local data will be deleted and replaced by demo data.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset'))])) ?? false; if (ok) await widget.store.resetDemo(); }, icon: const Icon(Icons.restart_alt), label: const Text('Reset demo data')),
    ])),
    const SizedBox(height: 16),
    Text('Storage note: this V1 stores data locally in this browser using shared_preferences. For a real multi-user agency deployment, move data and authentication to a server database before production use.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
  ]));
}

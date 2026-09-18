import 'package:flutter/material.dart';
import '../models/models.dart';
import '../store/app_store.dart';
import '../widgets/common.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final rows = store.payments.reversed.toList();
    return Column(children: [
      PageHeader(title: 'Payments', subtitle: 'Track deposits, settlements and remaining balances', action: FilledButton.icon(onPressed: store.bookings.isEmpty ? null : () => _add(context), icon: const Icon(Icons.add), label: const Text('Add payment'))),
      const SizedBox(height: 18),
      Wrap(spacing: 12, runSpacing: 12, children: [
        SizedBox(width: 250, child: KpiCard(label: 'Collected', value: money(store.totalPaid, store.currency), icon: Icons.account_balance_wallet_outlined)),
        SizedBox(width: 250, child: KpiCard(label: 'Outstanding', value: money(store.outstanding, store.currency), icon: Icons.schedule)),
      ]),
      const SizedBox(height: 16),
      Expanded(child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))), child: rows.isEmpty ? const Center(child: Text('No payments yet')) : ListView.separated(padding: const EdgeInsets.all(12), itemCount: rows.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) {
        final p = rows[i]; final b = store.bookingById(p.bookingId); final c = b == null ? null : store.customerById(b.customerId);
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
          title: Text(c?.name ?? 'Unknown customer', style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${b?.type ?? ''} • ${b?.reference ?? ''} • ${p.method} • ${p.date}${p.notes.isEmpty ? '' : '\n${p.notes}'}'),
          isThreeLine: p.notes.isNotEmpty,
          trailing: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [Text(money(p.amount, store.currency), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), IconButton(onPressed: () => _delete(context, p), icon: const Icon(Icons.delete_outline, color: Colors.red))]),
        );
      }))),
    ]);
  }

  Future<void> _delete(BuildContext context, Payment p) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete payment?'), content: Text('Delete payment of ${money(p.amount, store.currency)}?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))])) ?? false;
    if (ok) await store.deletePayment(p.id);
  }

  Future<void> _add(BuildContext context) async {
    String bookingId = store.bookings.first.id;
    String method = 'Cash';
    final amount = TextEditingController();
    final date = TextEditingController(text: DateTime.now().toIso8601String().substring(0, 10));
    final notes = TextEditingController();
    final result = await showDialog<Payment>(context: context, builder: (context) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
      title: const Text('Add payment'),
      content: SizedBox(width: 600, child: SingleChildScrollView(child: Column(children: [
        DropdownButtonFormField<String>(initialValue: bookingId, decoration: const InputDecoration(labelText: 'Booking'), items: store.bookings.map((b) { final c = store.customerById(b.customerId); return DropdownMenuItem(value: b.id, child: Text('${c?.name ?? 'Unknown'} — ${b.type} / ${b.destination}')); }).toList(), onChanged: (v) => setLocal(() => bookingId = v!)), const SizedBox(height: 10),
        Row(children: [Expanded(child: TextField(controller: amount, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Amount (${store.currency})'))), const SizedBox(width: 10), Expanded(child: DropdownButtonFormField<String>(initialValue: method, decoration: const InputDecoration(labelText: 'Method'), items: ['Cash','Card','Bank transfer','Online'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setLocal(() => method = v!)))]), const SizedBox(height: 10),
        TextField(controller: date, readOnly: true, decoration: const InputDecoration(labelText: 'Payment date', suffixIcon: Icon(Icons.calendar_today)), onTap: () async { final v = await pickDateText(context, date.text); if (v != null) date.text = v; }), const SizedBox(height: 10),
        TextField(controller: notes, minLines: 2, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { final a = double.tryParse(amount.text) ?? 0; if (a <= 0) return; Navigator.pop(context, Payment(id: store.newId(), bookingId: bookingId, amount: a, method: method, date: date.text, notes: notes.text.trim())); }, child: const Text('Save payment'))],
    )));
    if (result != null) await store.addPayment(result);
  }
}

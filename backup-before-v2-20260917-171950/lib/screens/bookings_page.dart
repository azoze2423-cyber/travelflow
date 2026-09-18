import 'package:flutter/material.dart';
import '../models/models.dart';
import '../store/app_store.dart';
import '../widgets/common.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key, required this.store});
  final AppStore store;
  @override State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  String query = '';
  String status = 'All';

  @override
  Widget build(BuildContext context) {
    final rows = widget.store.bookings.where((b) {
      final c = widget.store.customerById(b.customerId);
      final matchQuery = '${c?.name ?? ''} ${b.type} ${b.destination} ${b.reference}'.toLowerCase().contains(query.toLowerCase());
      return matchQuery && (status == 'All' || b.status == status);
    }).toList().reversed.toList();
    return Column(children: [
      PageHeader(title: 'Bookings', subtitle: 'Flights, hotels, packages, transfers and insurance', action: FilledButton.icon(onPressed: widget.store.customers.isEmpty ? null : () => _edit(), icon: const Icon(Icons.add), label: const Text('New booking'))),
      const SizedBox(height: 18),
      Row(children: [Expanded(child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search bookings'), onChanged: (v) => setState(() => query = v))), const SizedBox(width: 10), SizedBox(width: 170, child: DropdownButtonFormField<String>(initialValue: status, decoration: const InputDecoration(labelText: 'Status'), items: ['All','New','Processing','Confirmed','Completed','Cancelled'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => status = v!)))]),
      const SizedBox(height: 16),
      Expanded(child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))), child: rows.isEmpty ? const Center(child: Text('No bookings found')) : ListView.separated(padding: const EdgeInsets.all(12), itemCount: rows.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) {
        final b = rows[i]; final customer = widget.store.customerById(b.customerId);
        final paid = widget.store.paidForBooking(b.id); final balance = b.salePrice - paid;
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.luggage_outlined)),
          title: Row(children: [Expanded(child: Text(customer?.name ?? 'Unknown customer', style: const TextStyle(fontWeight: FontWeight.w700))), StatusPill(b.status)]),
          subtitle: Text('${b.type} • ${b.destination} • ${b.travelDate}\nSale: ${money(b.salePrice, widget.store.currency)} • Profit: ${money(b.profit, widget.store.currency)} • Balance: ${money(balance, widget.store.currency)}'),
          isThreeLine: true,
          trailing: Wrap(children: [IconButton(onPressed: () => _edit(b), icon: const Icon(Icons.edit_outlined)), IconButton(onPressed: () => _delete(b), icon: const Icon(Icons.delete_outline, color: Colors.red))]),
        );
      }))),
    ]);
  }

  Future<void> _delete(Booking b) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete booking?'), content: const Text('Related payments will also be deleted.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))])) ?? false;
    if (ok) await widget.store.deleteBooking(b.id);
  }

  Future<void> _edit([Booking? current]) async {
    String customerId = current?.customerId ?? widget.store.customers.first.id;
    String type = current?.type ?? 'Flight';
    String bookingStatus = current?.status ?? 'New';
    final destination = TextEditingController(text: current?.destination ?? '');
    final travelDate = TextEditingController(text: current?.travelDate ?? '');
    final cost = TextEditingController(text: current?.cost.toString() ?? '0');
    final sale = TextEditingController(text: current?.salePrice.toString() ?? '0');
    final reference = TextEditingController(text: current?.reference ?? '');
    final notes = TextEditingController(text: current?.notes ?? '');
    final result = await showDialog<Booking>(context: context, builder: (context) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
      title: Text(current == null ? 'New booking' : 'Edit booking'),
      content: SizedBox(width: 650, child: SingleChildScrollView(child: Column(children: [
        DropdownButtonFormField<String>(initialValue: customerId, decoration: const InputDecoration(labelText: 'Customer'), items: widget.store.customers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (v) => setLocal(() => customerId = v!)), const SizedBox(height: 10),
        Row(children: [Expanded(child: DropdownButtonFormField<String>(initialValue: type, decoration: const InputDecoration(labelText: 'Service'), items: ['Flight','Hotel','Visa','Package','Transfer','Insurance'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setLocal(() => type = v!))), const SizedBox(width: 10), Expanded(child: DropdownButtonFormField<String>(initialValue: bookingStatus, decoration: const InputDecoration(labelText: 'Status'), items: ['New','Processing','Confirmed','Completed','Cancelled'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setLocal(() => bookingStatus = v!)))]), const SizedBox(height: 10),
        Row(children: [Expanded(child: TextField(controller: destination, decoration: const InputDecoration(labelText: 'Destination'))), const SizedBox(width: 10), Expanded(child: TextField(controller: travelDate, readOnly: true, decoration: const InputDecoration(labelText: 'Travel date', suffixIcon: Icon(Icons.calendar_today)), onTap: () async { final v = await pickDateText(context, travelDate.text); if (v != null) travelDate.text = v; }))]), const SizedBox(height: 10),
        Row(children: [Expanded(child: TextField(controller: cost, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cost'))), const SizedBox(width: 10), Expanded(child: TextField(controller: sale, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sale price')))]), const SizedBox(height: 10),
        TextField(controller: reference, decoration: const InputDecoration(labelText: 'PNR / Booking reference')), const SizedBox(height: 10),
        TextField(controller: notes, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Notes')),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, Booking(id: current?.id ?? widget.store.newId(), customerId: customerId, type: type, destination: destination.text.trim(), travelDate: travelDate.text.trim(), status: bookingStatus, cost: double.tryParse(cost.text) ?? 0, salePrice: double.tryParse(sale.text) ?? 0, reference: reference.text.trim(), notes: notes.text.trim())), child: const Text('Save'))],
    )));
    if (result != null) current == null ? await widget.store.addBooking(result) : await widget.store.updateBooking(result);
  }
}

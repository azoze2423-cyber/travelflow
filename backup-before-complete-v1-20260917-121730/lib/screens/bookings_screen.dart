import 'package:flutter/material.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Bookings', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
          FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('New Booking')),
        ]),
        const SizedBox(height: 18),
        Wrap(spacing: 10, runSpacing: 10, children: const [
          _Filter('All', true), _Filter('Flights', false), _Filter('Hotels', false), _Filter('Visa', false), _Filter('Packages', false),
        ]),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Ref')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Service')),
                DataColumn(label: Text('Sale')),
                DataColumn(label: Text('Cost')),
                DataColumn(label: Text('Profit')),
                DataColumn(label: Text('Status')),
              ],
              rows: const [
                DataRow(cells: [DataCell(Text('TF-1001')), DataCell(Text('Ahmed Ali')), DataCell(Text('Flight')), DataCell(Text('2,300')), DataCell(Text('1,800')), DataCell(Text('500')), DataCell(Text('Confirmed'))]),
                DataRow(cells: [DataCell(Text('TF-1002')), DataCell(Text('Sara Omar')), DataCell(Text('Visa')), DataCell(Text('650')), DataCell(Text('420')), DataCell(Text('230')), DataCell(Text('Processing'))]),
                DataRow(cells: [DataCell(Text('TF-1003')), DataCell(Text('Mohammed Noor')), DataCell(Text('Hotel')), DataCell(Text('1,850')), DataCell(Text('1,500')), DataCell(Text('350')), DataCell(Text('Pending'))]),
              ],
            ),
          ),
        )
      ]),
    );
  }
}

class _Filter extends StatelessWidget {
  final String label;
  final bool selected;
  const _Filter(this.label, this.selected);

  @override
  Widget build(BuildContext context) => Chip(
        label: Text(label),
        backgroundColor: selected ? Colors.blue.shade50 : Colors.white,
        side: BorderSide(color: selected ? Colors.blue.shade200 : const Color(0xFFE5E7EB)),
      );
}

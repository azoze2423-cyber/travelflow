import 'package:flutter/material.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Payments', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        Wrap(spacing: 14, runSpacing: 14, children: const [
          _PayCard('Collected', 'AED 21,250', Icons.check_circle_outline),
          _PayCard('Outstanding', 'AED 7,200', Icons.schedule),
          _PayCard('This Month', 'AED 28,450', Icons.calendar_month_outlined),
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
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Booking')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Paid')),
                DataColumn(label: Text('Balance')),
                DataColumn(label: Text('Method')),
              ],
              rows: const [
                DataRow(cells: [DataCell(Text('Ahmed Ali')), DataCell(Text('TF-1001')), DataCell(Text('2,300')), DataCell(Text('2,300')), DataCell(Text('0')), DataCell(Text('Card'))]),
                DataRow(cells: [DataCell(Text('Sara Omar')), DataCell(Text('TF-1002')), DataCell(Text('650')), DataCell(Text('350')), DataCell(Text('300')), DataCell(Text('Cash'))]),
                DataRow(cells: [DataCell(Text('Mohammed Noor')), DataCell(Text('TF-1003')), DataCell(Text('1,850')), DataCell(Text('1,000')), DataCell(Text('850')), DataCell(Text('Transfer'))]),
              ],
            ),
          ),
        )
      ]),
    );
  }
}

class _PayCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _PayCard(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Container(
        width: 260,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Row(children: [
          CircleAvatar(child: Icon(icon)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: Colors.grey.shade600)), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))])
        ]),
      );
}

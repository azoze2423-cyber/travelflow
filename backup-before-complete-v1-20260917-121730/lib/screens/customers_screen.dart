import 'package:flutter/material.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Customers', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
          FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.person_add_alt_1), label: const Text('Add Customer')),
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
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('Nationality')),
                DataColumn(label: Text('Passport Expiry')),
                DataColumn(label: Text('Bookings')),
              ],
              rows: const [
                DataRow(cells: [DataCell(Text('Ahmed Ali')), DataCell(Text('+971 50 123 4567')), DataCell(Text('UAE')), DataCell(Text('12 Jun 2028')), DataCell(Text('4'))]),
                DataRow(cells: [DataCell(Text('Sara Omar')), DataCell(Text('+971 55 900 2233')), DataCell(Text('Egypt')), DataCell(Text('03 Feb 2027')), DataCell(Text('2'))]),
                DataRow(cells: [DataCell(Text('Mohammed Noor')), DataCell(Text('+971 52 777 1818')), DataCell(Text('Sudan')), DataCell(Text('19 Dec 2026')), DataCell(Text('6'))]),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

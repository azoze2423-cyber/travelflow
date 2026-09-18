import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 1200 ? 4 : c.maxWidth >= 650 ? 2 : 1;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dashboard', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Overview of bookings, revenue and customer activity.', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: columns == 1 ? 3.5 : 2.4,
                children: const [
                  StatCard(title: 'Today Bookings', value: '12', icon: Icons.luggage_outlined, note: '+3 since yesterday'),
                  StatCard(title: 'Total Sales', value: 'AED 28,450', icon: Icons.trending_up, note: 'This month'),
                  StatCard(title: 'Outstanding', value: 'AED 7,200', icon: Icons.schedule, note: 'Pending payments'),
                  StatCard(title: 'Profit', value: 'AED 6,380', icon: Icons.account_balance_wallet_outlined, note: 'Estimated'),
                ],
              ),
              const SizedBox(height: 22),
              _section(
                title: 'Recent Bookings',
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Service')),
                      DataColumn(label: Text('Travel Date')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: const [
                      DataRow(cells: [DataCell(Text('Ahmed Ali')), DataCell(Text('Flight')), DataCell(Text('22 Sep 2026')), DataCell(Text('AED 2,300')), DataCell(_Status('Confirmed'))]),
                      DataRow(cells: [DataCell(Text('Sara Omar')), DataCell(Text('Dubai Visa')), DataCell(Text('25 Sep 2026')), DataCell(Text('AED 650')), DataCell(_Status('Processing'))]),
                      DataRow(cells: [DataCell(Text('Mohammed Noor')), DataCell(Text('Hotel')), DataCell(Text('29 Sep 2026')), DataCell(Text('AED 1,850')), DataCell(_Status('Pending'))]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _miniPanel('Upcoming Trips', ['Ahmed Ali • Dubai → Istanbul • 22 Sep', 'Fatima Hassan • Dubai → Cairo • 24 Sep']),
                  _miniPanel('Pending Payments', ['Sara Omar • AED 300 remaining', 'Mohammed Noor • AED 850 remaining']),
                  _miniPanel('Document Alerts', ['Omar passport expires in 45 days', 'Lina visa expires in 19 days']),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _section({required String title, required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 12), child]),
      );

  Widget _miniPanel(String title, List<String> lines) => Container(
        width: 330,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...lines.map((e) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('• $e'))),
        ]),
      );
}

class _Status extends StatelessWidget {
  final String text;
  const _Status(this.text);

  @override
  Widget build(BuildContext context) {
    final color = switch (text) {
      'Confirmed' => Colors.green,
      'Processing' => Colors.orange,
      _ => Colors.blueGrey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

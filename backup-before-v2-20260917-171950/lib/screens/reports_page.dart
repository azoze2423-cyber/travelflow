import 'package:flutter/material.dart';
import '../store/app_store.dart';
import '../widgets/common.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final byType = <String, double>{};
    for (final b in store.bookings) { byType[b.type] = (byType[b.type] ?? 0) + b.salePrice; }
    final maxValue = byType.values.fold<double>(1, (a, b) => b > a ? b : a);
    final confirmed = store.bookings.where((b) => ['Confirmed','Completed'].contains(b.status)).length;
    final conversion = store.bookings.isEmpty ? 0.0 : confirmed / store.bookings.length * 100;
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const PageHeader(title: 'Reports', subtitle: 'Sales, profit, collection and booking performance'),
      const SizedBox(height: 20),
      Wrap(spacing: 12, runSpacing: 12, children: [
        SizedBox(width: 250, child: KpiCard(label: 'Sales', value: money(store.totalSales, store.currency), icon: Icons.trending_up)),
        SizedBox(width: 250, child: KpiCard(label: 'Gross profit', value: money(store.totalProfit, store.currency), icon: Icons.savings_outlined)),
        SizedBox(width: 250, child: KpiCard(label: 'Collected', value: money(store.totalPaid, store.currency), icon: Icons.payments_outlined)),
        SizedBox(width: 250, child: KpiCard(label: 'Confirmed rate', value: '${conversion.toStringAsFixed(1)}%', icon: Icons.check_circle_outline)),
      ]),
      const SizedBox(height: 20),
      Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Sales by service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 18),
        if (byType.isEmpty) const Text('No booking data yet.'),
        for (final e in byType.entries) Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600))), Text(money(e.value, store.currency))]), const SizedBox(height: 6),
          LayoutBuilder(builder: (_, c) => Stack(children: [Container(height: 10, width: c.maxWidth, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(99))), Container(height: 10, width: c.maxWidth * (e.value / maxValue), decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(99)))])),
        ])),
      ])),
      const SizedBox(height: 20),
      Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Financial summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 12),
        _line('Total booking cost', money(store.totalCost, store.currency)),
        _line('Total booking sales', money(store.totalSales, store.currency)),
        _line('Gross profit', money(store.totalProfit, store.currency)),
        _line('Payments collected', money(store.totalPaid, store.currency)),
        _line('Outstanding balance', money(store.outstanding, store.currency), bold: true),
      ])),
    ]));
  }

  Widget _line(String label, String value, {bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(label)), Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600))]));
}

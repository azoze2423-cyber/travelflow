import 'package:flutter/material.dart';
import '../store/app_store.dart';
import '../widgets/common.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width > 1250 ? 4 : width > 760 ? 2 : 1;
    final recent = store.bookings.reversed.take(5).toList();
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(title: 'Dashboard', subtitle: 'Overview of bookings, revenue, payments and travel activity'),
        const SizedBox(height: 22),
        GridView.count(
          crossAxisCount: cols,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 2.25,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            KpiCard(label: 'Total sales', value: money(store.totalSales, store.currency), icon: Icons.trending_up),
            KpiCard(label: 'Profit', value: money(store.totalProfit, store.currency), icon: Icons.savings_outlined),
            KpiCard(label: 'Outstanding', value: money(store.outstanding, store.currency), icon: Icons.schedule),
            KpiCard(label: 'Bookings', value: '${store.bookings.length}', icon: Icons.luggage_outlined, caption: '${store.customers.length} customers'),
          ],
        ),
        const SizedBox(height: 22),
        LayoutBuilder(builder: (context, c) {
          final vertical = c.maxWidth < 900;
          final recentCard = _recentBookings(recent);
          final alertsCard = _alerts();
          return vertical ? Column(children: [recentCard, const SizedBox(height: 16), alertsCard]) : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: recentCard), const SizedBox(width: 16), Expanded(child: alertsCard)]);
        }),
      ]),
    );
  }

  Widget _recentBookings(List recent) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Recent bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      if (recent.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('No bookings yet.')),
      for (final b in recent)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            const CircleAvatar(child: Icon(Icons.flight, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(store.customerById(b.customerId)?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700)), Text('${b.type} • ${b.destination} • ${b.travelDate}', style: const TextStyle(fontSize: 12, color: Colors.grey))])),
            StatusPill(b.status),
          ]),
        ),
    ]),
  );

  Widget _alerts() {
    final unpaid = store.bookings.where((b) => store.paidForBooking(b.id) < b.salePrice).length;
    final visaPending = store.visas.where((v) => !['Approved','Rejected'].contains(v.status)).length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Action center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        _alert(Icons.payments_outlined, '$unpaid bookings have pending balances'),
        _alert(Icons.description_outlined, '$visaPending visa applications need attention'),
        _alert(Icons.badge_outlined, '${store.customers.length} customer profiles in the system'),
      ]),
    );
  }

  Widget _alert(IconData icon, String text) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 20, color: const Color(0xFF2563EB)), const SizedBox(width: 10), Expanded(child: Text(text))]));
}

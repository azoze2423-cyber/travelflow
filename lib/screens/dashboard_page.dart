import 'package:flutter/material.dart';
import '../store/app_store.dart';
import '../widgets/common.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width > 1320 ? 4 : width > 760 ? 2 : 1;
    final recent = store.bookings.reversed.take(5).toList();
    final newOnline = store.portalRequests.where((e) => e.status == 'New').length;

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF071C33), Color(0xFF0D3559), Color(0xFF0F766E)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Welcome back, ${store.currentUserName.isEmpty ? 'Team' : store.currentUserName}',
                    style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Your agency operations, finances and online demand at a glance.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ]),
              ),
              if (width > 800)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    const Icon(Icons.public_rounded, color: Color(0xFF99F6E4)),
                    const SizedBox(width: 8),
                    Text('$newOnline new online', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ]),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        GridView.count(
          crossAxisCount: cols,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 2.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            KpiCard(label: 'Total sales', value: money(store.totalSales, store.currency), icon: Icons.trending_up_rounded),
            KpiCard(label: 'Profit', value: money(store.totalProfit, store.currency), icon: Icons.savings_outlined),
            KpiCard(label: 'Outstanding', value: money(store.outstanding, store.currency), icon: Icons.schedule_rounded),
            KpiCard(label: 'Online requests', value: '${store.portalRequests.length}', icon: Icons.public_outlined, caption: '$newOnline new'),
          ],
        ),
        const SizedBox(height: 22),
        LayoutBuilder(builder: (context, box) {
          final vertical = box.maxWidth < 900;
          final recentCard = _recentBookings(recent);
          final actionCard = _actionCenter();
          return vertical
              ? Column(children: [recentCard, const SizedBox(height: 16), actionCard])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: recentCard),
                    const SizedBox(width: 16),
                    Expanded(child: actionCard),
                  ],
                );
        }),
      ]),
    );
  }

  Widget _recentBookings(List recent) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.history_rounded, color: Color(0xFF0F766E)),
            SizedBox(width: 9),
            Text('Recent bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 14),
          if (recent.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('No bookings yet.')),
          for (final b in recent)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(13)),
                  child: const Icon(Icons.flight_rounded, size: 19, color: Color(0xFF0F766E)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(store.customerById(b.customerId)?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('${b.type} • ${b.destination} • ${b.travelDate}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ]),
                ),
                StatusPill(b.status),
              ]),
            ),
        ]),
      );

  Widget _actionCenter() {
    final unpaid = store.bookings.where((b) => store.paidForBooking(b.id) < b.salePrice).length;
    final visaPending = store.visas.where((v) => !['Approved', 'Rejected'].contains(v.status)).length;
    final newOnline = store.portalRequests.where((e) => e.status == 'New').length;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.bolt_rounded, color: Color(0xFF0F766E)),
          SizedBox(width: 9),
          Text('Action center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 18),
        _alert(Icons.public_outlined, '$newOnline online requests waiting'),
        _alert(Icons.payments_outlined, '$unpaid bookings with pending balances'),
        _alert(Icons.description_outlined, '$visaPending visa cases need attention'),
        _alert(Icons.people_outline, '${store.customers.length} customer profiles'),
      ]),
    );
  }

  Widget _alert(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: const Color(0xFFF0FDFA), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: const Color(0xFF0F766E)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Padding(padding: const EdgeInsets.only(top: 7), child: Text(text))),
          ],
        ),
      );
}

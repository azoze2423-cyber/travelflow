import 'package:flutter/material.dart';
import '../models/models.dart';
import '../store/app_store.dart';
import '../widgets/common.dart';

class OnlineRequestsPage extends StatefulWidget {
  const OnlineRequestsPage({super.key, required this.store});
  final AppStore store;

  @override
  State<OnlineRequestsPage> createState() => _OnlineRequestsPageState();
}

class _OnlineRequestsPageState extends State<OnlineRequestsPage> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final rows = widget.store.portalRequests
        .where((e) => filter == 'All' || e.status == filter)
        .toList();

    final newCount = widget.store.portalRequests.where((e) => e.status == 'New').length;

    return Column(
      children: [
        PageHeader(
          title: 'Online requests',
          subtitle: 'Booking leads sent from your public customer portal',
          action: FilledButton.icon(
            onPressed: widget.store.refresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 230,
              child: KpiCard(label: 'New requests', value: '$newCount', icon: Icons.mark_email_unread_outlined),
            ),
            SizedBox(
              width: 230,
              child: KpiCard(label: 'Total online', value: '${widget.store.portalRequests.length}', icon: Icons.public_outlined),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              initialValue: filter,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['All', 'New', 'Contacted', 'Quoted', 'Confirmed', 'Cancelled']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => filter = v ?? 'All'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: rows.isEmpty
                ? const Center(child: Text('No online booking requests yet'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final r = rows[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.flight_takeoff_rounded, color: Color(0xFF0F766E)),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(r.passengerName, style: const TextStyle(fontWeight: FontWeight.w800))),
                            StatusPill(r.status),
                          ],
                        ),
                        subtitle: Text(
                          '${r.origin} → ${r.destination} • ${r.travelDate}\n'
                          '${r.airline} ${r.flightNumber} • ${r.adults} traveler(s) • ${money(r.amount, r.currency)}\n'
                          '${r.phone}${r.email.isEmpty ? '' : ' • ${r.email}'}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          tooltip: 'Update status',
                          onSelected: (value) => widget.store.updatePortalRequestStatus(r.id, value),
                          itemBuilder: (_) => ['New', 'Contacted', 'Quoted', 'Confirmed', 'Cancelled']
                              .map((e) => PopupMenuItem(value: e, child: Text(e)))
                              .toList(),
                        ),
                        onTap: () => _details(r),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _details(PortalRequest r) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: Text(r.passengerName),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _line('Request', r.id),
              _line('Route', '${r.origin} → ${r.destination}'),
              _line('Travel date', r.travelDate),
              _line('Airline', '${r.airline} ${r.flightNumber}'),
              _line('Travelers', '${r.adults}'),
              _line('Fare shown', money(r.amount, r.currency)),
              _line('Phone', r.phone),
              if (r.email.isNotEmpty) _line('Email', r.email),
              _line('Status', r.status),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _line(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: Text(value)),
          ],
        ),
      );
}

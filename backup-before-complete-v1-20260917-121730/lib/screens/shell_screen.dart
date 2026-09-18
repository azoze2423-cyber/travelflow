import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'customers_screen.dart';
import 'bookings_screen.dart';
import 'payments_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int index = 0;

  final pages = const [
    DashboardScreen(),
    CustomersScreen(),
    BookingsScreen(),
    PaymentsScreen(),
  ];

  final items = const [
    (Icons.dashboard_outlined, 'Dashboard'),
    (Icons.people_outline, 'Customers'),
    (Icons.luggage_outlined, 'Bookings'),
    (Icons.payments_outlined, 'Payments'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: isWide
          ? null
          : AppBar(
              title: const Text('TravelFlow'),
              backgroundColor: Colors.white,
            ),
      drawer: isWide ? null : Drawer(child: _navContent()),
      body: Row(
        children: [
          if (isWide)
            SizedBox(
              width: 250,
              child: Material(
                color: const Color(0xFF111827),
                child: _navContent(dark: true),
              ),
            ),
          Expanded(child: pages[index]),
        ],
      ),
    );
  }

  Widget _navContent({bool dark = false}) {
    final fg = dark ? Colors.white : Colors.black87;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
            child: Row(
              children: [
                const CircleAvatar(child: Icon(Icons.flight_takeoff)),
                const SizedBox(width: 12),
                Text(
                  'TravelFlow',
                  style: TextStyle(color: fg, fontSize: 23, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                selected: index == i,
                selectedTileColor: dark ? Colors.white12 : Colors.blue.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(items[i].$1, color: index == i ? Colors.blue : (dark ? Colors.white70 : Colors.black54)),
                title: Text(items[i].$2, style: TextStyle(color: index == i ? (dark ? Colors.white : Colors.blue) : fg)),
                onTap: () {
                  setState(() => index = i);
                  if (!MediaQuery.of(context).size.width.isNaN && MediaQuery.of(context).size.width < 900) {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              'TravelFlow v1.0',
              style: TextStyle(color: dark ? Colors.white38 : Colors.black38, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

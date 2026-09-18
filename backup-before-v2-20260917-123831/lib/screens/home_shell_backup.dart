import 'package:flutter/material.dart';
import '../store/app_store.dart';
import 'bookings_page.dart';
import 'customers_page.dart';
import 'dashboard_page.dart';
import 'payments_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';
import 'suppliers_page.dart';
import 'visas_page.dart';
import 'login_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.store});
  final AppStore store;
  @override State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  final labels = const ['Dashboard','Customers','Bookings','Payments','Visas','Suppliers','Reports','Settings'];
  final icons = const [Icons.dashboard_outlined,Icons.people_outline,Icons.luggage_outlined,Icons.payments_outlined,Icons.description_outlined,Icons.business_outlined,Icons.bar_chart_outlined,Icons.settings_outlined];

  List<Widget> get pages => [
    DashboardPage(store: widget.store), CustomersPage(store: widget.store), BookingsPage(store: widget.store), PaymentsPage(store: widget.store), VisasPage(store: widget.store), SuppliersPage(store: widget.store), ReportsPage(store: widget.store), SettingsPage(store: widget.store),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: widget.store, builder: (context, _) {
      final wide = MediaQuery.of(context).size.width >= 980;
      return Scaffold(
        appBar: wide ? null : AppBar(title: Text(widget.store.agencyName), actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.logout))]),
        drawer: wide ? null : Drawer(child: SafeArea(child: _menu(true))),
        body: Row(children: [
          if (wide) SizedBox(width: 250, child: _menu(false)),
          Expanded(child: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: pages[index]))),
        ]),
      );
    });
  }

  Widget _menu(bool drawer) => Container(
    color: const Color(0xFF111827),
    child: Column(children: [
      Padding(padding: const EdgeInsets.all(22), child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.flight_takeoff, color: Colors.white)),
        const SizedBox(width: 12), Expanded(child: Text(widget.store.agencyName, maxLines: 2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
      ])),
      const Divider(color: Color(0xFF374151), height: 1),
      const SizedBox(height: 10),
      Expanded(child: ListView.builder(itemCount: labels.length, itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: ListTile(
          selected: index == i, selectedTileColor: const Color(0xFF1F2937), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Icon(icons[i], color: index == i ? Colors.white : Colors.white70),
          title: Text(labels[i], style: TextStyle(color: index == i ? Colors.white : Colors.white70, fontWeight: index == i ? FontWeight.w700 : FontWeight.w500)),
          onTap: () { setState(() => index = i); if (drawer) Navigator.pop(context); },
        ),
      ))),
      Padding(padding: const EdgeInsets.all(12), child: ListTile(leading: const Icon(Icons.logout, color: Colors.white70), title: const Text('Logout', style: TextStyle(color: Colors.white70)), onTap: _logout)),
    ]),
  );

  void _logout() => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => LoginScreen(store: widget.store)), (_) => false);
}

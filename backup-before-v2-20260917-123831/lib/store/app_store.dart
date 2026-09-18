import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppStore extends ChangeNotifier {
  static const _dataKey = 'travelflow_data_v1';
  static const _settingsKey = 'travelflow_settings_v1';

  final List<Customer> customers = [];
  final List<Booking> bookings = [];
  final List<Payment> payments = [];
  final List<VisaCase> visas = [];
  final List<Supplier> suppliers = [];

  String agencyName = 'TravelFlow Agency';
  String currency = 'AED';
  String adminEmail = 'admin@travelflow.ae';
  String adminPassword = 'admin123';
  String phone = '+971 50 000 0000';
  String address = 'United Arab Emirates';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsRaw = prefs.getString(_settingsKey);
    if (settingsRaw != null) {
      final s = jsonDecode(settingsRaw) as Map<String, dynamic>;
      agencyName = s['agencyName'] ?? agencyName;
      currency = s['currency'] ?? currency;
      adminEmail = s['adminEmail'] ?? adminEmail;
      adminPassword = s['adminPassword'] ?? adminPassword;
      phone = s['phone'] ?? phone;
      address = s['address'] ?? address;
    }

    final raw = prefs.getString(_dataKey);
    if (raw == null) {
      _seed();
      await save();
      return;
    }
    final data = jsonDecode(raw) as Map<String, dynamic>;
    customers.addAll((data['customers'] as List? ?? []).map((e) => Customer.fromJson(Map<String, dynamic>.from(e))));
    bookings.addAll((data['bookings'] as List? ?? []).map((e) => Booking.fromJson(Map<String, dynamic>.from(e))));
    payments.addAll((data['payments'] as List? ?? []).map((e) => Payment.fromJson(Map<String, dynamic>.from(e))));
    visas.addAll((data['visas'] as List? ?? []).map((e) => VisaCase.fromJson(Map<String, dynamic>.from(e))));
    suppliers.addAll((data['suppliers'] as List? ?? []).map((e) => Supplier.fromJson(Map<String, dynamic>.from(e))));
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey, jsonEncode({
      'customers': customers.map((e) => e.toJson()).toList(),
      'bookings': bookings.map((e) => e.toJson()).toList(),
      'payments': payments.map((e) => e.toJson()).toList(),
      'visas': visas.map((e) => e.toJson()).toList(),
      'suppliers': suppliers.map((e) => e.toJson()).toList(),
    }));
    await prefs.setString(_settingsKey, jsonEncode({
      'agencyName': agencyName,
      'currency': currency,
      'adminEmail': adminEmail,
      'adminPassword': adminPassword,
      'phone': phone,
      'address': address,
    }));
    notifyListeners();
  }

  String newId() => DateTime.now().microsecondsSinceEpoch.toString();
  Customer? customerById(String id) {
    for (final item in customers) {
      if (item.id == id) return item;
    }
    return null;
  }

  Booking? bookingById(String id) {
    for (final item in bookings) {
      if (item.id == id) return item;
    }
    return null;
  }

  double paidForBooking(String bookingId) => payments.where((e) => e.bookingId == bookingId).fold(0, (a, b) => a + b.amount);
  double get totalSales => bookings.fold(0, (a, b) => a + b.salePrice);
  double get totalCost => bookings.fold(0, (a, b) => a + b.cost);
  double get totalProfit => totalSales - totalCost;
  double get totalPaid => payments.fold(0, (a, b) => a + b.amount);
  double get outstanding => totalSales - totalPaid;

  Future<void> addCustomer(Customer c) async { customers.add(c); await save(); }
  Future<void> updateCustomer(Customer c) async { final i = customers.indexWhere((e) => e.id == c.id); if (i >= 0) customers[i] = c; await save(); }
  Future<void> deleteCustomer(String id) async { customers.removeWhere((e) => e.id == id); await save(); }
  Future<void> addBooking(Booking b) async { bookings.add(b); await save(); }
  Future<void> updateBooking(Booking b) async { final i = bookings.indexWhere((e) => e.id == b.id); if (i >= 0) bookings[i] = b; await save(); }
  Future<void> deleteBooking(String id) async { bookings.removeWhere((e) => e.id == id); payments.removeWhere((e) => e.bookingId == id); await save(); }
  Future<void> addPayment(Payment p) async { payments.add(p); await save(); }
  Future<void> deletePayment(String id) async { payments.removeWhere((e) => e.id == id); await save(); }
  Future<void> addVisa(VisaCase v) async { visas.add(v); await save(); }
  Future<void> updateVisa(VisaCase v) async { final i = visas.indexWhere((e) => e.id == v.id); if (i >= 0) visas[i] = v; await save(); }
  Future<void> deleteVisa(String id) async { visas.removeWhere((e) => e.id == id); await save(); }
  Future<void> addSupplier(Supplier s) async { suppliers.add(s); await save(); }
  Future<void> updateSupplier(Supplier s) async { final i = suppliers.indexWhere((e) => e.id == s.id); if (i >= 0) suppliers[i] = s; await save(); }
  Future<void> deleteSupplier(String id) async { suppliers.removeWhere((e) => e.id == id); await save(); }

  Future<void> updateSettings({required String name, required String curr, required String email, required String password, required String agencyPhone, required String agencyAddress}) async {
    agencyName = name; currency = curr; adminEmail = email; adminPassword = password; phone = agencyPhone; address = agencyAddress; await save();
  }

  Future<void> resetDemo() async {
    customers.clear(); bookings.clear(); payments.clear(); visas.clear(); suppliers.clear(); _seed(); await save();
  }

  void _seed() {
    final c1 = Customer(id: 'c1', name: 'Ahmed Ali', phone: '+971501112233', email: 'ahmed@example.com', nationality: 'Sudanese', passportNumber: 'P1234567', passportExpiry: '2028-05-20', notes: 'Prefers WhatsApp');
    final c2 = Customer(id: 'c2', name: 'Sara Omar', phone: '+971502223344', email: 'sara@example.com', nationality: 'Egyptian', passportNumber: 'A7654321', passportExpiry: '2027-11-10', notes: 'Family booking');
    final c3 = Customer(id: 'c3', name: 'Mohammed Hassan', phone: '+971503334455', email: 'mohammed@example.com', nationality: 'Emirati', passportNumber: 'UAE778899', passportExpiry: '2029-03-15', notes: 'Corporate client');
    customers.addAll([c1, c2, c3]);
    bookings.addAll([
      Booking(id: 'b1', customerId: 'c1', type: 'Flight', destination: 'Istanbul', travelDate: '2026-10-02', status: 'Confirmed', cost: 1450, salePrice: 1750, reference: 'TK-88321', notes: ''),
      Booking(id: 'b2', customerId: 'c2', type: 'Hotel', destination: 'Dubai', travelDate: '2026-09-25', status: 'Processing', cost: 900, salePrice: 1250, reference: 'HT-1045', notes: '3 nights'),
      Booking(id: 'b3', customerId: 'c3', type: 'Package', destination: 'Baku', travelDate: '2026-10-10', status: 'New', cost: 3200, salePrice: 4100, reference: 'PK-2201', notes: '2 adults'),
    ]);
    payments.addAll([
      Payment(id: 'p1', bookingId: 'b1', amount: 1750, method: 'Card', date: '2026-09-15', notes: 'Paid in full'),
      Payment(id: 'p2', bookingId: 'b2', amount: 500, method: 'Cash', date: '2026-09-16', notes: 'Deposit'),
    ]);
    visas.add(VisaCase(id: 'v1', customerId: 'c1', country: 'Turkey', visaType: 'Tourist', status: 'Approved', applicationDate: '2026-09-01', expiryDate: '2026-12-01', fee: 350, notes: 'E-visa'));
    suppliers.addAll([
      Supplier(id: 's1', name: 'Global Air Partner', type: 'Airline', phone: '+97140000001', email: 'sales@airpartner.test', contactPerson: 'Mona', notes: ''),
      Supplier(id: 's2', name: 'City Hotels Network', type: 'Hotel', phone: '+97140000002', email: 'booking@cityhotels.test', contactPerson: 'Karim', notes: ''),
    ]);
  }
}


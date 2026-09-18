import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_client.dart';

class AppStore extends ChangeNotifier {
  final ApiClient api = ApiClient();

  final List<Customer> customers = [];
  final List<Booking> bookings = [];
  final List<Payment> payments = [];
  final List<VisaCase> visas = [];
  final List<Supplier> suppliers = [];
  final List<UserAccount> users = [];

  String agencyName = 'TravelFlow Agency';
  String currency = 'AED';
  String phone = '';
  String address = '';
  String currentUserId = '';
  String currentUserName = '';
  String currentUserEmail = '';
  String currentUserRole = '';
  bool isAuthenticated = false;
  bool busy = false;
  String? lastError;

  bool get isAdmin => currentUserRole == 'admin';
  String get adminEmail => currentUserEmail;
  String get serverUrl => api.baseUrl;

  Future<void> load() async {
    await api.loadSession();
    if (api.token == null) return;
    try {
      await refresh();
      isAuthenticated = true;
    } catch (_) {
      await api.clearToken();
      isAuthenticated = false;
    }
  }

  Future<String?> login(String email, String password) async {
    busy = true; lastError = null; notifyListeners();
    try {
      final data = Map<String, dynamic>.from(await api.post('/auth/login', {'email': email.trim(), 'password': password}));
      await api.saveToken(data['accessToken'].toString());
      await refresh();
      isAuthenticated = true;
      return null;
    } on ApiException catch (e) {
      lastError = e.message;
      return e.message;
    } finally {
      busy = false; notifyListeners();
    }
  }

  Future<void> logout() async {
    await api.clearToken();
    isAuthenticated = false;
    customers.clear(); bookings.clear(); payments.clear(); visas.clear(); suppliers.clear(); users.clear();
    notifyListeners();
  }

  Future<void> refresh() async {
    final data = Map<String, dynamic>.from(await api.get('/bootstrap'));
    final agency = Map<String, dynamic>.from(data['agency'] ?? {});
    final user = Map<String, dynamic>.from(data['user'] ?? {});
    agencyName = agency['name'] ?? agencyName;
    currency = agency['currency'] ?? currency;
    phone = agency['phone'] ?? '';
    address = agency['address'] ?? '';
    currentUserId = user['id'] ?? '';
    currentUserName = user['name'] ?? '';
    currentUserEmail = user['email'] ?? '';
    currentUserRole = user['role'] ?? '';
    customers..clear()..addAll((data['customers'] as List? ?? []).map((e) => Customer.fromJson(Map<String, dynamic>.from(e))));
    bookings..clear()..addAll((data['bookings'] as List? ?? []).map((e) => Booking.fromJson(Map<String, dynamic>.from(e))));
    payments..clear()..addAll((data['payments'] as List? ?? []).map((e) => Payment.fromJson(Map<String, dynamic>.from(e))));
    visas..clear()..addAll((data['visas'] as List? ?? []).map((e) => VisaCase.fromJson(Map<String, dynamic>.from(e))));
    suppliers..clear()..addAll((data['suppliers'] as List? ?? []).map((e) => Supplier.fromJson(Map<String, dynamic>.from(e))));
    users..clear()..addAll((data['users'] as List? ?? []).map((e) => UserAccount.fromJson(Map<String, dynamic>.from(e))));
    notifyListeners();
  }

  String newId() => DateTime.now().microsecondsSinceEpoch.toString();
  Customer? customerById(String id) { for (final x in customers) { if (x.id == id) return x; } return null; }
  Booking? bookingById(String id) { for (final x in bookings) { if (x.id == id) return x; } return null; }
  double paidForBooking(String bookingId) => payments.where((e) => e.bookingId == bookingId).fold(0, (a, b) => a + b.amount);
  double get totalSales => bookings.fold(0, (a, b) => a + b.salePrice);
  double get totalCost => bookings.fold(0, (a, b) => a + b.cost);
  double get totalProfit => totalSales - totalCost;
  double get totalPaid => payments.fold(0, (a, b) => a + b.amount);
  double get outstanding => totalSales - totalPaid;

  Future<void> addCustomer(Customer c) async { final x=Customer.fromJson(Map<String,dynamic>.from(await api.post('/customers',c.toJson()))); customers.add(x); notifyListeners(); }
  Future<void> updateCustomer(Customer c) async { final x=Customer.fromJson(Map<String,dynamic>.from(await api.put('/customers/${c.id}',c.toJson()))); final i=customers.indexWhere((e)=>e.id==c.id); if(i>=0) customers[i]=x; notifyListeners(); }
  Future<void> deleteCustomer(String id) async { await api.delete('/customers/$id'); customers.removeWhere((e)=>e.id==id); notifyListeners(); }

  Future<void> addBooking(Booking b) async { final x=Booking.fromJson(Map<String,dynamic>.from(await api.post('/bookings',b.toJson()))); bookings.add(x); notifyListeners(); }
  Future<void> updateBooking(Booking b) async { final x=Booking.fromJson(Map<String,dynamic>.from(await api.put('/bookings/${b.id}',b.toJson()))); final i=bookings.indexWhere((e)=>e.id==b.id); if(i>=0) bookings[i]=x; notifyListeners(); }
  Future<void> deleteBooking(String id) async { await api.delete('/bookings/$id'); bookings.removeWhere((e)=>e.id==id); payments.removeWhere((e)=>e.bookingId==id); notifyListeners(); }

  Future<void> addPayment(Payment p) async { final x=Payment.fromJson(Map<String,dynamic>.from(await api.post('/payments',p.toJson()))); payments.add(x); notifyListeners(); }
  Future<void> deletePayment(String id) async { await api.delete('/payments/$id'); payments.removeWhere((e)=>e.id==id); notifyListeners(); }

  Future<void> addVisa(VisaCase v) async { final x=VisaCase.fromJson(Map<String,dynamic>.from(await api.post('/visas',v.toJson()))); visas.add(x); notifyListeners(); }
  Future<void> updateVisa(VisaCase v) async { final x=VisaCase.fromJson(Map<String,dynamic>.from(await api.put('/visas/${v.id}',v.toJson()))); final i=visas.indexWhere((e)=>e.id==v.id); if(i>=0) visas[i]=x; notifyListeners(); }
  Future<void> deleteVisa(String id) async { await api.delete('/visas/$id'); visas.removeWhere((e)=>e.id==id); notifyListeners(); }

  Future<void> addSupplier(Supplier s) async { final x=Supplier.fromJson(Map<String,dynamic>.from(await api.post('/suppliers',s.toJson()))); suppliers.add(x); notifyListeners(); }
  Future<void> updateSupplier(Supplier s) async { final x=Supplier.fromJson(Map<String,dynamic>.from(await api.put('/suppliers/${s.id}',s.toJson()))); final i=suppliers.indexWhere((e)=>e.id==s.id); if(i>=0) suppliers[i]=x; notifyListeners(); }
  Future<void> deleteSupplier(String id) async { await api.delete('/suppliers/$id'); suppliers.removeWhere((e)=>e.id==id); notifyListeners(); }

  Future<void> updateSettings({required String name, required String curr, required String email, required String password, required String agencyPhone, required String agencyAddress, String? userName}) async {
    if (isAdmin) {
      final a=Map<String,dynamic>.from(await api.put('/settings',{'name':name,'currency':curr,'phone':agencyPhone,'address':agencyAddress}));
      agencyName=a['name']??name;currency=a['currency']??curr;phone=a['phone']??agencyPhone;address=a['address']??agencyAddress;
    }
    final account=Map<String,dynamic>.from(await api.put('/account',{'name':userName ?? currentUserName,'email':email,'password':password.isEmpty?null:password}));
    currentUserName=account['name']??currentUserName;currentUserEmail=account['email']??currentUserEmail;currentUserRole=account['role']??currentUserRole;
    notifyListeners();
  }

  Future<void> addUser({required String name, required String email, required String password, required String role}) async {
    final x=UserAccount.fromJson(Map<String,dynamic>.from(await api.post('/users',{'name':name,'email':email,'password':password,'role':role}))); users.add(x); notifyListeners();
  }
  Future<void> deleteUser(String id) async { await api.delete('/users/$id'); users.removeWhere((e)=>e.id==id); notifyListeners(); }
}

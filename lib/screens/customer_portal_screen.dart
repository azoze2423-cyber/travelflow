import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../store/app_store.dart';
import 'login_screen.dart';

class CustomerPortalScreen extends StatefulWidget {
  const CustomerPortalScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<CustomerPortalScreen> createState() => _CustomerPortalScreenState();
}

class _CustomerPortalScreenState extends State<CustomerPortalScreen> {
  final ApiClient api = ApiClient();
  final origin = TextEditingController(text: 'SHJ');
  final destination = TextEditingController(text: 'PZU');
  final travelDate = TextEditingController(text: DateTime.now().add(const Duration(days: 14)).toIso8601String().substring(0, 10));
  int adults = 1;
  bool loading = false;
  bool searched = false;
  String? error;
  String agencyName = 'TravelFlow';
  String agencyPhone = '';
  String agencyAddress = '';
  List<Map<String, dynamic>> offers = [];
  String inventoryMode = '';
  String providerNotice = '';

  @override
  void initState() {
    super.initState();
    _loadAgency();
  }

  Future<void> _loadAgency() async {
    try {
      final data = Map<String, dynamic>.from(await api.get('/public/agency'));
      if (!mounted) return;
      setState(() {
        agencyName = data['name']?.toString() ?? agencyName;
        agencyPhone = data['phone']?.toString() ?? '';
        agencyAddress = data['address']?.toString() ?? '';
      });
    } catch (_) {}
  }

  Future<void> _search() async {
    setState(() { loading = true; searched = true; error = null; offers = []; providerNotice = ''; });
    try {
      final data = Map<String, dynamic>.from(await api.post('/public/flights/search', {
        'origin': origin.text.trim(), 'destination': destination.text.trim(),
        'travelDate': travelDate.text.trim(), 'adults': adults,
      }));
      if (!mounted) return;
      setState(() {
        inventoryMode = data['inventoryMode']?.toString() ?? '';
        providerNotice = data['notice']?.toString() ?? '';
        offers = (data['offers'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(travelDate.text) ?? DateTime.now().add(const Duration(days: 7));
    final value = await showDatePicker(
      context: context, initialDate: initial, firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (value != null) {
      travelDate.text = '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _book(Map<String, dynamic> offer) async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final email = TextEditingController();
    bool sending = false;
    String? dialogError;

    await showDialog<void>(
      context: context,
      barrierDismissible: !sending,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Complete your request'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _offerSummary(offer, compact: true),
                const SizedBox(height: 18),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Passenger full name', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 12),
                TextField(controller: phone, decoration: const InputDecoration(labelText: 'WhatsApp / phone', hintText: '+971...', prefixIcon: Icon(Icons.phone_outlined))),
                const SizedBox(height: 12),
                TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email (optional)', prefixIcon: Icon(Icons.email_outlined))),
                if (dialogError != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(dialogError!, style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 10),
                Text(inventoryMode == 'duffel_test' ? 'Duffel Test Mode is active. No live order or money movement will happen yet.' : 'The agency will confirm availability and fare before ticketing.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: sending ? null : () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton.icon(
              onPressed: sending ? null : () async {
                if (name.text.trim().length < 2 || phone.text.trim().length < 7) {
                  setLocal(() => dialogError = 'Enter the passenger name and a valid phone number.');
                  return;
                }
                setLocal(() { sending = true; dialogError = null; });
                try {
                  final result = Map<String, dynamic>.from(await api.post('/public/booking-requests', {
                    'offerId': offer['id']?.toString() ?? '',
                    'airline': offer['airline']?.toString() ?? '',
                    'flightNumber': offer['flightNumber']?.toString() ?? '',
                    'origin': offer['origin']?.toString() ?? '',
                    'destination': offer['destination']?.toString() ?? '',
                    'travelDate': offer['travelDate']?.toString() ?? '',
                    'passengerName': name.text.trim(), 'phone': phone.text.trim(), 'email': email.text.trim(),
                    'adults': adults, 'amount': (offer['amount'] ?? 0).toDouble(),
                    'currency': offer['currency']?.toString() ?? 'AED',
                  }));
                  if (!mounted) return;
                  Navigator.pop(dialogContext);
                  _success(result['requestNumber']?.toString() ?? '');
                } on ApiException catch (e) {
                  setLocal(() { dialogError = e.message; sending = false; });
                }
              },
              icon: sending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_outlined),
              label: Text(sending ? 'Sending...' : 'Request booking'),
            ),
          ],
        ),
      ),
    );
  }

  void _success(String requestNumber) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 56),
        title: const Text('Request received'),
        content: Text('Your request number is $requestNumber. The agency can now see it in TravelFlow and contact you to confirm the live fare and ticket.', textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 760;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SelectionArea(
        child: SingleChildScrollView(
          child: Column(children: [
            _topBar(mobile), _hero(mobile), _trustStrip(),
            if (searched || error != null || loading) _resultsSection(mobile),
            _services(mobile), _footer(),
          ]),
        ),
      ),
    );
  }

  Widget _topBar(bool mobile) => Container(
    color: const Color(0xFF071C33),
    padding: EdgeInsets.symmetric(horizontal: mobile ? 18 : 54, vertical: 15),
    child: Row(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2DD4BF), Color(0xFF3B82F6)]), borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(agencyName, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900))),
      if (!mobile && agencyPhone.isNotEmpty) Padding(padding: const EdgeInsets.only(right: 18), child: Text(agencyPhone, style: const TextStyle(color: Colors.white70))),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24)),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(store: widget.store))),
        icon: const Icon(Icons.lock_outline, size: 18),
        label: Text(mobile ? 'Staff' : 'Staff sign in'),
      ),
    ]),
  );

  Widget _hero(bool mobile) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF071C33), Color(0xFF0D3559), Color(0xFF0F5A72)]),
    ),
    padding: EdgeInsets.fromLTRB(mobile ? 18 : 54, mobile ? 42 : 68, mobile ? 18 : 54, mobile ? 50 : 76),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .09), borderRadius: BorderRadius.circular(99), border: Border.all(color: Colors.white12)),
            child: const Text('FLIGHTS • SUPPORT • TRAVEL SERVICES', style: TextStyle(color: Color(0xFF99F6E4), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1)),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text('Your journey, handled with confidence.', style: TextStyle(color: Colors.white, fontSize: mobile ? 38 : 58, height: 1.04, fontWeight: FontWeight.w900, letterSpacing: -1.8)),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 690),
            child: const Text('Search flights, compare fare options and send your booking request directly to our travel team.', style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.55)),
          ),
          const SizedBox(height: 32),
          _searchCard(mobile),
        ]),
      ),
    ),
  );

  Widget _searchCard(bool mobile) => Container(
    padding: EdgeInsets.all(mobile ? 18 : 24),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 18))]),
    child: Column(children: [
      Row(children: [
        const Icon(Icons.flight_rounded, color: Color(0xFF0F5A72)), const SizedBox(width: 8),
        const Text('Find your flight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const Spacer(),
        if (!mobile) Text('One way • Economy', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ]),
      const SizedBox(height: 18),
      if (mobile)
        Column(children: [
          _airportField(origin, 'From', 'SHJ'), const SizedBox(height: 12),
          _airportField(destination, 'To', 'PZU'), const SizedBox(height: 12),
          _dateField(), const SizedBox(height: 12), _adultsField(), const SizedBox(height: 14),
          SizedBox(width: double.infinity, height: 52, child: _searchButton()),
        ])
      else
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: _airportField(origin, 'From', 'SHJ')), const SizedBox(width: 10),
          Expanded(child: _airportField(destination, 'To', 'PZU')), const SizedBox(width: 10),
          Expanded(child: _dateField()), const SizedBox(width: 10),
          SizedBox(width: 155, child: _adultsField()), const SizedBox(width: 12),
          SizedBox(width: 165, height: 56, child: _searchButton()),
        ]),
    ]),
  );

  Widget _airportField(TextEditingController controller, String label, String hint) => TextField(
    controller: controller, textCapitalization: TextCapitalization.characters, maxLength: 3,
    decoration: InputDecoration(counterText: '', labelText: label, hintText: hint, prefixIcon: Icon(label == 'From' ? Icons.flight_takeoff_outlined : Icons.flight_land_outlined)),
  );

  Widget _dateField() => TextField(
    controller: travelDate, readOnly: true, onTap: _pickDate,
    decoration: const InputDecoration(labelText: 'Departure', prefixIcon: Icon(Icons.calendar_month_outlined)),
  );

  Widget _adultsField() => DropdownButtonFormField<int>(
    initialValue: adults,
    decoration: const InputDecoration(labelText: 'Travelers', prefixIcon: Icon(Icons.people_outline)),
    items: List.generate(9, (i) => i + 1).map((n) => DropdownMenuItem(value: n, child: Text('$n adult${n == 1 ? '' : 's'}'))).toList(),
    onChanged: (v) => setState(() => adults = v ?? 1),
  );

  Widget _searchButton() => FilledButton.icon(
    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
    onPressed: loading ? null : _search,
    icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.search_rounded),
    label: Text(loading ? 'Searching...' : 'Search flights'),
  );

  Widget _trustStrip() => Container(
    width: double.infinity, color: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    child: const Wrap(alignment: WrapAlignment.center, spacing: 34, runSpacing: 12, children: [
      _TrustItem(Icons.support_agent, 'Agency support'), _TrustItem(Icons.receipt_long_outlined, 'Digital invoices'),
      _TrustItem(Icons.chat_outlined, 'WhatsApp service'), _TrustItem(Icons.shield_outlined, 'Secure workflow'),
    ]),
  );

  Widget _resultsSection(bool mobile) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: mobile ? 18 : 54, vertical: 44),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Flight options', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900))),
            if (inventoryMode == 'duffel_test')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(99)),
                child: const Text('DUFFEL TEST MODE', style: TextStyle(color: Color(0xFFC2410C), fontWeight: FontWeight.w900, fontSize: 11)),
              ),
          ]),
          const SizedBox(height: 6),
          Text(inventoryMode == 'duffel_test' ? (providerNotice.isEmpty ? 'Duffel test inventory is active. No live orders or money movement.' : providerNotice) : 'Choose the option that works for your trip.', style: TextStyle(color: Colors.grey.shade600)),
          if (error != null)
            Container(
              margin: const EdgeInsets.only(top: 18), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [const Icon(Icons.error_outline, color: Colors.red), const SizedBox(width: 10), Expanded(child: Text(error!))]),
            ),
          const SizedBox(height: 18),
          if (!loading && error == null && offers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: const Text('No flight offers were returned for this route/date in the current test inventory. Try another route or date.'),
            ),
          for (final offer in offers) ...[_offerSummary(offer), const SizedBox(height: 14)],
        ]),
      ),
    ),
  );

  Widget _offerSummary(Map<String, dynamic> offer, {bool compact = false}) {
    final amount = (offer['amount'] ?? 0).toDouble();
    final currency = offer['currency']?.toString() ?? 'AED';
    return Container(
      padding: EdgeInsets.all(compact ? 15 : 20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: compact ? null : const [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: LayoutBuilder(builder: (context, c) {
        final narrow = c.maxWidth < 700;
        final details = Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.flight_rounded, color: Color(0xFF0F766E))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(offer['airline']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 3),
            Text('${offer['flightNumber'] ?? ''} • ${offer['fareName'] ?? ''} • ${offer['cabin'] ?? ''}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ])),
        ]);
        final route = Row(mainAxisSize: MainAxisSize.min, children: [
          _routePoint(offer['origin']?.toString() ?? '', offer['departureTime']?.toString() ?? ''),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF94A3B8))),
          _routePoint(offer['destination']?.toString() ?? '', offer['arrivalTime']?.toString() ?? ''),
        ]);
        final price = Column(crossAxisAlignment: narrow ? CrossAxisAlignment.start : CrossAxisAlignment.end, children: [
          Text('$currency ${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
          Text('${offer['baggage'] ?? ''} baggage', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ]);
        if (compact) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [details, const SizedBox(height: 12), route, const SizedBox(height: 12), price]);
        if (narrow) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            details, const SizedBox(height: 18), route, const SizedBox(height: 18),
            Row(children: [Expanded(child: price), FilledButton(onPressed: () => _book(offer), child: const Text('Select'))]),
          ]);
        }
        return Row(children: [
          Expanded(flex: 3, child: details), Expanded(flex: 2, child: route), Expanded(flex: 2, child: price),
          const SizedBox(width: 18),
          FilledButton(style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18)), onPressed: () => _book(offer), child: const Text('Select')),
        ]);
      }),
    );
  }

  Widget _routePoint(String code, String time) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(time, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
    Text(code, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
  ]);

  Widget _services(bool mobile) => Container(
    color: const Color(0xFFEFF6FF), width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: mobile ? 18 : 54, vertical: 52),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Column(children: [
          const Text('More than a flight booking', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Your travel team can manage the rest of the journey from the same platform.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 28),
          const Wrap(spacing: 16, runSpacing: 16, children: [
            _ServiceCard(icon: Icons.flight_outlined, title: 'Flights', text: 'Search, request and manage airline bookings.'),
            _ServiceCard(icon: Icons.hotel_outlined, title: 'Hotels & packages', text: 'Add accommodation and packaged travel services.'),
            _ServiceCard(icon: Icons.description_outlined, title: 'Visa support', text: 'Track visa applications and customer documents.'),
            _ServiceCard(icon: Icons.receipt_long_outlined, title: 'Invoices', text: 'Receive professional invoices and payment records.'),
          ]),
        ]),
      ),
    ),
  );

  Widget _footer() => Container(
    width: double.infinity, color: const Color(0xFF071C33), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
    child: Column(children: [
      Text(agencyName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
      const SizedBox(height: 6),
      Text([agencyPhone, agencyAddress].where((e) => e.isNotEmpty).join(' • '), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
      const SizedBox(height: 12),
      const Text('Powered by TravelFlow', style: TextStyle(color: Colors.white38, fontSize: 11)),
    ]),
  );
}

class _TrustItem extends StatelessWidget {
  const _TrustItem(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 19, color: const Color(0xFF0F766E)), const SizedBox(width: 8),
    Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155))),
  ]);
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    width: 252, padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFF0F766E))),
      const SizedBox(height: 16),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      const SizedBox(height: 6),
      Text(text, style: const TextStyle(color: Color(0xFF64748B), height: 1.5)),
    ]),
  );
}

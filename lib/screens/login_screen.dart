import 'package:flutter/material.dart';
import '../store/app_store.dart';
import 'home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.store});
  final AppStore store;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(text: 'admin@travelflow.ae');
  final password = TextEditingController();
  bool obscure = true;
  String? error;

  Future<void> _login() async {
    setState(() => error = null);
    final result = await widget.store.login(email.text, password.text);
    if (!mounted) return;
    if (result == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeShell(store: widget.store)),
        (_) => false,
      );
    } else {
      setState(() => error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 820;
    return Scaffold(
      body: Row(
        children: [
          if (!mobile)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF071C33), Color(0xFF0D3559), Color(0xFF0F766E)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF2DD4BF), Color(0xFF3B82F6)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white),
                      ),
                      const Spacer(),
                      const Text(
                        'Run your agency\nfrom one elegant workspace.',
                        style: TextStyle(color: Colors.white, fontSize: 42, height: 1.08, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Bookings, customers, invoices, payments, visas and online requests — connected in one place.',
                        style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.55),
                      ),
                      const Spacer(),
                      const Text('TravelFlow Agency OS', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (mobile)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                      const SizedBox(height: 10),
                      const Text('Staff sign in', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(
                        'Secure access to the TravelFlow agency dashboard.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: password,
                        obscureText: obscure,
                        onSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => obscure = !obscure),
                            icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                        ),
                      ),
                      if (error != null)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
                          child: Text(error!, style: const TextStyle(color: Color(0xFFB91C1C))),
                        ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: widget.store.busy ? null : _login,
                          icon: widget.store.busy
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.login_rounded),
                          label: Text(widget.store.busy ? 'Connecting...' : 'Open dashboard'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton.icon(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.public_outlined),
                        label: const Text('Back to customer portal'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

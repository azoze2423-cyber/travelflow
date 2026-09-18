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
  late final TextEditingController email;
  late final TextEditingController password;
  bool obscure = true;
  String? error;

  @override
  void initState() {
    super.initState();
    email = TextEditingController(text: widget.store.adminEmail);
    password = TextEditingController(text: 'admin123');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 30, offset: Offset(0, 12))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(width: 58, height: 58, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 30)),
                const SizedBox(height: 22),
                Text(widget.store.agencyName, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('Travel agency management system', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 26),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 14),
                TextField(controller: password, obscureText: obscure, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility : Icons.visibility_off)))),
                if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () {
                    if (email.text.trim() == widget.store.adminEmail && password.text == widget.store.adminPassword) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeShell(store: widget.store)));
                    } else {
                      setState(() => error = 'Invalid email or password');
                    }
                  },
                  icon: const Icon(Icons.login), label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Sign in')),
                ),
                const SizedBox(height: 12),
                Text('Default: admin@travelflow.ae / admin123', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

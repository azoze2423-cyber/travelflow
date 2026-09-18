import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const TravelFlowApp());
}

class TravelFlowApp extends StatelessWidget {
  const TravelFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TravelFlow',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        fontFamily: 'Arial',
      ),
      home: const LoginScreen(),
    );
  }
}

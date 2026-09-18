import 'package:flutter/material.dart';
import 'screens/customer_portal_screen.dart';
import 'screens/home_shell.dart';
import 'store/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.load();
  runApp(TravelFlowApp(store: store));
}

class TravelFlowApp extends StatelessWidget {
  const TravelFlowApp({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0F766E);
    const ink = Color(0xFF0F172A);
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: store.agencyName,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Arial',
          colorScheme: ColorScheme.fromSeed(
            seedColor: primary,
            brightness: Brightness.light,
            primary: primary,
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F7FB),
          textTheme: ThemeData.light().textTheme.apply(bodyColor: ink, displayColor: ink),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDCE3EC))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDCE3EC))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 1.5)),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          dividerColor: const Color(0xFFE7ECF2),
        ),
        home: store.isAuthenticated ? HomeShell(store: store) : CustomerPortalScreen(store: store),
      ),
    );
  }
}

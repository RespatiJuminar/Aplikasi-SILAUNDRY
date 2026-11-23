import 'package:flutter/material.dart';
import 'shared/auth/login_page.dart';
import 'shared/data/app_state.dart';
import 'shared/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Membuka database dan memuat data sebelum aplikasi tampil.
  await appState.init();
  runApp(const SiLaundryApp());
}

class SiLaundryApp extends StatelessWidget {
  const SiLaundryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiLaundry',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const LoginPage(),
    );
  }
}

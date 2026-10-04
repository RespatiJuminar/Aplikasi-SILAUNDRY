import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'theme.dart';

void main() {
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

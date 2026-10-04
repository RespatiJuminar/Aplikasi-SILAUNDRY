import 'package:flutter/material.dart';
import '../theme.dart';

/// Layout dua kolom untuk Login dan Register:
/// kiri = form, kanan = panel biru dengan logo.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            flex: 64,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: form,
                ),
              ),
            ),
          ),
          const Expanded(flex: 36, child: _BrandPanel()),
        ],
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(80),
          bottomLeft: Radius.circular(80),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
          const SizedBox(height: 28),
          for (final w in const ['CLEAN', 'FAST', 'FRESH'])
            Text(
              w,
              style: TextStyle(
                fontSize: 40,
                height: 1.2,
                letterSpacing: 1,
                color: Colors.white.withAlpha(150),
              ),
            ),
        ],
      ),
    );
  }
}

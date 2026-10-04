import 'package:flutter/material.dart';

/// Warna-warna diambil dari desain Figma.
class AppColors {
  static const primary = Color(0xFF1877F2);
  static const tile = Color(0xFF63A4FF);
  static const cardHeader = Color(0xFF4FB8E8);
  static const danger = Color(0xFFF5136B);
  static const dangerSoft = Color(0xFFFF5A5F);
  static const sidebar = Color(0xFFF9F9F9);
  static const panel = Color(0xFFF3F3F3);
  static const field = Color(0xFFE4E4E4);
  static const detailBlue = Color(0xFF5B9BEB);
  static const text = Color(0xFF222222);
  static const muted = Color(0xFF7A7A7A);
  static const dialogBorder = Color(0xFF7DD3FC);
}

const List<String> _monoFallback = ['Consolas', 'Courier New', 'monospace'];

class AppText {
  /// Judul panel (gaya monospace seperti di Figma).
  static const heading = TextStyle(
    fontFamily: 'Consolas',
    fontFamilyFallback: _monoFallback,
    fontSize: 22,
    color: AppColors.primary,
    letterSpacing: 1,
  );

  static const pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  static const label = TextStyle(fontSize: 14, color: AppColors.text);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Segoe UI',
    fontFamilyFallback: const ['Roboto', 'Arial'],
  );
}

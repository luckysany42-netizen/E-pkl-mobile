import 'package:flutter/material.dart';

/// Palet warna gaya "KyPay" (dark navy + accent biru terang) yang dipakai
/// khusus di halaman auth (login/register). Halaman lain (Beranda, dst)
/// tetap pakai tema terang normal.
class AppColors {
  AppColors._();

  static const authBackground = Color(0xFF0F1B33);
  static const authFieldBackground = Color(0xFF1B2942);
  static const authAccent = Color(0xFF3D7BFF);
  static const authTextSecondary = Color(0xFFAAB4C6);
}

class AppTheme {
  AppTheme._();

  // TODO: samakan warna dengan branding utama E-PKL (di luar halaman auth)
  static const Color primaryColor = Color(0xFF2563EB);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryColor,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}

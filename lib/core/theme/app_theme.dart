import 'package:flutter/material.dart';

class AppTheme {
  static const Color q1Color = Color(0xFFD7263D);
  static const Color q2Color = Color(0xFF1B998B);
  static const Color q3Color = Color(0xFFF4A261);
  static const Color q4Color = Color(0xFF457B9D);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B998B),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF6F9FB),
      cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B998B),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      snackBarTheme: const SnackBarThemeData(
        actionTextColor: Colors.red,
        backgroundColor: Colors.black87,
        contentTextStyle: TextStyle(color: Colors.white),
        elevation: 20,
      ),
    );
  }
}

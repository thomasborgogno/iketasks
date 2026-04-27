import 'package:flutter/material.dart';

const _fontFamily = 'GoogleSansFlex';
const _fontVariations = [
  FontVariation('ROND', 100.0),
  FontVariation('wdth', 95.0),
];

TextTheme _buildTextTheme(TextTheme base) => base.copyWith(
  displayLarge: base.displayLarge?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  displayMedium: base.displayMedium?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  displaySmall: base.displaySmall?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  headlineLarge: base.headlineLarge?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  headlineMedium: base.headlineMedium?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  headlineSmall: base.headlineSmall?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  titleLarge: base.titleLarge?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  titleMedium: base.titleMedium?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  titleSmall: base.titleSmall?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  bodyLarge: base.bodyLarge?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  bodyMedium: base.bodyMedium?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  bodySmall: base.bodySmall?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  labelLarge: base.labelLarge?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  labelMedium: base.labelMedium?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
  labelSmall: base.labelSmall?.copyWith(
    fontFamily: _fontFamily,
    fontVariations: _fontVariations,
  ),
);

class AppTheme {
  static const Color q1Color = Color(0xFFD7263D);
  static const Color q2Color = Color(0xFF1B998B);
  static const Color q3Color = Color(0xFFF4A261);
  static const Color q4Color = Color(0xFF457B9D);
  static const Color appSeedColor = Color(0xFF1B998B);

  static ThemeData light({Color? systemPrimary}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: systemPrimary ?? appSeedColor,
      brightness: Brightness.light,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(elevation: 0, margin: EdgeInsets.zero),
    );

    return base.copyWith(textTheme: _buildTextTheme(base.textTheme));
  }

  static ThemeData dark({Color? systemPrimary}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: systemPrimary ?? appSeedColor,
      brightness: Brightness.dark,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        // color: colorScheme.surfaceContainerHighest,
      ),
      snackBarTheme: const SnackBarThemeData(
        actionTextColor: Colors.red,
        backgroundColor: Colors.black87,
        contentTextStyle: TextStyle(color: Colors.white),
        elevation: 20,
      ),
    );

    return base.copyWith(textTheme: _buildTextTheme(base.textTheme));
  }
}

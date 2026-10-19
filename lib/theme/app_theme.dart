import 'package:flutter/material.dart';
import '../services/customization_service.dart';

class AppTheme {
  static const Color background = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFF1B2838);
  static const Color surfaceLight = Color(0xFF243447);
  static const Color primary = Color(0xFF4A7C9B);
  static const Color accent = Color(0xFF7EB8D4);
  static const Color textPrimary = Color(0xFFE8F1F5);
  static const Color textSecondary = Color(0xFFA0B4C0);
  static const Color danger = Color(0xFFB85C5C);
  static const Color success = Color(0xFF5C9B7A);

  static ThemeData darkGlassTheme(CustomizationService custom) {
    final accentColor = custom.accentColor;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accentColor,
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        secondary: primary,
        surface: surface,
        background: background,
        onPrimary: textPrimary,
        onSurface: textPrimary,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentColor,
        inactiveTrackColor: surfaceLight,
        thumbColor: accentColor,
        overlayColor: accentColor.withOpacity(0.2),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

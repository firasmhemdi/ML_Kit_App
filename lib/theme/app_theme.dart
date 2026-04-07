import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1565C0); // Bleu foncé
  static const Color secondary = Color(0xFF00897B); // Vert teal
  static const Color accent = Color(0xFFC62828); // Rouge
  static const Color warning = Color(0xFFF57C00); // Orange
  static const Color background = Color(0xFFF0F4FF); // Fond bleu très clair
  static const Color surface = Color.fromARGB(255, 255, 253, 253); // Blanc
  static const Color cardColor = Color(0xFFE8EFF8); // Bleu gris clair

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: const Color.fromARGB(255, 207, 207, 207),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

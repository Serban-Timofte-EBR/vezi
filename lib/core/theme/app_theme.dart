import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 3,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
  );
}

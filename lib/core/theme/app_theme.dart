import 'package:flutter/material.dart';


class AppTheme {
  AppTheme._();

  // --- Light theme 
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F9D58), 
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      );

  // --- Dark theme 
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F9D58),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF1E1E1E),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      );
}

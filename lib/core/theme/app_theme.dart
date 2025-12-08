import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: '.SF Pro Text',
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontFamily: '.SF Pro Text',
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontFamily: '.SF Pro Text',
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(fontFamily: '.SF Pro Text'),
      bodyMedium: TextStyle(fontFamily: '.SF Pro Text'),
      bodySmall: TextStyle(fontFamily: '.SF Pro Text'),
      labelLarge: TextStyle(
        fontFamily: '.SF Pro Text',
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        fontFamily: '.SF Pro Text',
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontFamily: '.SF Pro Text',
        fontWeight: FontWeight.w500,
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFD0BCFF),
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontFamily: '.SF Pro Display',
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: '.SF Pro Text',
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontFamily: '.SF Pro Text',
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontFamily: '.SF Pro Text',
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(fontFamily: '.SF Pro Text'),
      bodyMedium: TextStyle(fontFamily: '.SF Pro Text'),
      bodySmall: TextStyle(fontFamily: '.SF Pro Text'),
      labelLarge: TextStyle(
        fontFamily: '.SF Pro Text',
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        fontFamily: '.SF Pro Text',
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontFamily: '.SF Pro Text',
        fontWeight: FontWeight.w500,
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
  );
}

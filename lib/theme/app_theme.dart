import 'package:flutter/material.dart';

enum AppThemeMode {
  kineticDiscipline, // Giao diện tối, xanh lá dạ quang
  sereneBlue,        // Giao diện sáng, xanh lam
}

class AppTheme {
  // Theme 1: Kinetic Discipline (Dark / Neon Green)
  static final ThemeData kineticDisciplineTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF000000), // Pure black
    primaryColor: const Color(0xFF39FF14), // Neon green
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF39FF14),
      onPrimary: Colors.black,
      secondary: Color(0xFFFF3131), // Red
      onSecondary: Colors.white,
      surface: Color(0xFF121212), // Card surface
      onSurface: Colors.white,
      error: Color(0xFFFF3131),
      onError: Colors.white,
    ),
    cardColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(centerTitle: false),
    dividerColor: const Color(0xFF262626),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontFamily: 'Inter', color: Colors.white),
      bodyMedium: TextStyle(fontFamily: 'Inter', color: Colors.white70),
    ),
  );

  // Theme 2: Serene Blue (Light / Pure White & Blue)
  static final ThemeData sereneBlueTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white, // Pure white
    primaryColor: const Color(0xFF2196F3), // Solid Blue
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2196F3),
      onPrimary: Colors.white,
      secondary: Color(0xFF1976D2), // Darker Blue
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF1C1B1F),
      error: Color(0xFFFF6B6B),
      onError: Colors.white,
    ),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(centerTitle: false),
    dividerColor: const Color(0xFFE0E0E0),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Color(0xFF1C1B1F)),
      headlineMedium: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Color(0xFF1C1B1F)),
      bodyLarge: TextStyle(fontFamily: 'Inter', color: Color(0xFF1C1B1F)),
      bodyMedium: TextStyle(fontFamily: 'Inter', color: Color(0xFF49454F)),
    ),
  );
}

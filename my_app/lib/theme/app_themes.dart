import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData light(Color seed) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData dark(Color seed) {
    // Dark theme tuned to be neutral, while accents still derive from seed
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0E0E0E),
      cardColor: const Color(0xFF1B1B1B),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF111111),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      listTileTheme: const ListTileThemeData(iconColor: Colors.white),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          foregroundColor: Colors.black,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) return Colors.tealAccent;
          return Colors.white70;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) return Colors.tealAccent.withOpacity(0.45);
          return Colors.white24;
        }),
      ),
    );
  }
}

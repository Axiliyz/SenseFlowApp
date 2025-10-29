import 'package:flutter/material.dart';
import 'neon_colors.dart';

ThemeData neonLightTheme(BuildContext ctx) {
  final base = ThemeData.light();
  return base.copyWith(
    colorScheme: const ColorScheme.light(
      surface: Color(0xFFF7FAFF),
      surfaceContainerHighest: Color(0xFFEFF4FB),
      primary: kNeonBlue,
      secondary: kNeonMint,
      tertiary: kNeonPurple,
      onSurface: Color(0xFF0F1A2B),
    ),
    scaffoldBackgroundColor: const Color(0xFFF7FAFF),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Color(0xFF0F1A2B),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: const Color(0xFF0F1A2B).withOpacity(0.06)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: const Color(0xFF0F1A2B).withOpacity(0.08)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF2F6FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kNeonBlue, width: 1.2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: kNeonMint, // всегда аквамариновая
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kNeonMint,
        side: const BorderSide(color: kNeonMint),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFFEFF5FF),
      selectedColor: kNeonMint,
      labelStyle: TextStyle(color: Color(0xFF0F1A2B)),
      shape: StadiumBorder(),
    ),
    dividerTheme: DividerThemeData(color: Colors.black.withOpacity(0.06)),
  );
}

ThemeData neonDarkTheme(BuildContext ctx) {
  final base = ThemeData.dark();
  return base.copyWith(
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF0B1020),
      surfaceContainerHighest: Color(0xFF101935),
      primary: kNeonBlue,
      secondary: kNeonMint,
      tertiary: kNeonPurple,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF0B1020),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF12162A),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF12162A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0E1430),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kNeonBlue, width: 1.2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: kNeonMint, // тоже фиксированно мятная
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kNeonMint,
        side: const BorderSide(color: kNeonMint),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withOpacity(0.08),
      selectedColor: kNeonMint,
      labelStyle: const TextStyle(color: Colors.white),
      shape: const StadiumBorder(),
    ),
    dividerTheme: DividerThemeData(color: Colors.white.withOpacity(0.06)),
  );
}

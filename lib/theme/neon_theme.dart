import 'package:flutter/material.dart';
import 'neon_colors.dart';

// ===== DARK =====
ThemeData neonDarkTheme(BuildContext ctx) {
  final base = ThemeData.dark();
  return base.copyWith(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: kNeonCyan,
      secondary: kNeonMint,
      tertiary: kNeonBlue,
      surface: kPanelDark,
      surfaceContainerHighest: kPanelDarkHi,
      surfaceVariant: kPanelDark,
      onSurface: kOnSurfaceDark,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
    ),
    scaffoldBackgroundColor: kBgDark,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      color: kPanelDark.withOpacity(0.72),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: kPanelDark.withOpacity(0.92),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.035),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kNeonCyan, width: 1.2),
      ),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.52)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: kNeonMint,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kNeonCyan,
        side: const BorderSide(color: kNeonCyan),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withOpacity(0.06),
      selectedColor: kNeonMint,
      labelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    dividerColor: Colors.white.withOpacity(0.06),
  );
}

// ===== LIGHT (обновлённый) =====
ThemeData neonLightTheme(BuildContext ctx) {
  final base = ThemeData.light();

  return base.copyWith(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: kNeonBlue,            // акцент (НЕ кнопки)
      secondary: kNeonMint,          // фирменные кнопки
      tertiary: kNeonPurple,
      surface: kLightSurface,
      surfaceContainerHighest: kLightSurfaceHi,
      surfaceVariant: kLightSurfaceHi,
      background: kLightScaffold,
      onSurface: kOnSurfaceLight,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),
    scaffoldBackgroundColor: kLightScaffold,
    canvasColor: Colors.white,

    textTheme: base.textTheme.apply(
      bodyColor: kOnSurfaceLight,
      displayColor: kOnSurfaceLight,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: kOnSurfaceLight,
      centerTitle: false,
    ),

    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: kOnSurfaceLight.withOpacity(0.06)),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: kOnSurfaceLight.withOpacity(0.08)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF2F6FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kNeonBlue, width: 1.2),
      ),
      hintStyle: TextStyle(color: kOnSurfaceLight.withOpacity(0.45)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: kNeonMint, // всегда мятные
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
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kNeonMint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFFEFF5FF),
      selectedColor: kNeonMint,
      labelStyle: TextStyle(color: kOnSurfaceLight),
      shape: StadiumBorder(),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: kNeonBlue,
      textColor: kOnSurfaceLight.withOpacity(0.80),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    ),
    iconTheme: const IconThemeData(color: kOnSurfaceLight),
    dividerColor: Colors.black.withOpacity(0.06),

    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide(color: kOnSurfaceLight.withOpacity(0.35)),
      fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? kNeonMint : Colors.transparent),
      checkColor: const WidgetStatePropertyAll(Colors.black),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? kNeonMint : kOnSurfaceLight.withOpacity(0.45)),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? kNeonMint.withOpacity(0.35) : kOnSurfaceLight.withOpacity(0.20)),
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? kNeonMint : Colors.white),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(color: kOnSurfaceLight),
      elevation: 8,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      textStyle: const TextStyle(color: kOnSurfaceLight),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: kOnSurfaceLight,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(kOnSurfaceLight.withOpacity(0.22)),
      radius: const Radius.circular(8),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: kNeonMint,
    ),
  );
}

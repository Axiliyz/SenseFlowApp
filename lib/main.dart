import 'package:flutter/material.dart';
import 'theme/neon_theme.dart';
import 'features/dashboard/dashboard_page.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

void main() => runApp(
  ValueListenableBuilder<ThemeMode>(
    valueListenable: themeNotifier,
    builder: (context, mode, __) => MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: neonLightTheme(context),
      darkTheme: neonDarkTheme(context),
      home: DashboardPage(themeNotifier: themeNotifier),
    ),
  ),
);

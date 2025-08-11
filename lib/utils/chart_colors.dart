import 'package:flutter/material.dart';
import '../theme/neon_colors.dart';

Color axisTextColor(BuildContext context) =>
  Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withOpacity(0.58)
      : const Color(0xFF5A6B85);

Color gridLineColor(BuildContext context) =>
  Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withOpacity(0.07)
      : const Color(0xFFB8C7DD).withOpacity(0.35);

Color chartBgColor(BuildContext context) =>
  Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.65)
      : const Color(0xFFF2F6FC);

Color pulse1Color(BuildContext context) =>
  Theme.of(context).brightness == Brightness.dark ? kNeonCyan : kNeonBlue;

Color pulse2Color(BuildContext context) =>
  Theme.of(context).brightness == Brightness.dark ? kNeonPurple : const Color(0xFFFF7A7A);

Color resistanceColor(BuildContext context) =>
  Theme.of(context).brightness == Brightness.dark ? kNeonBlue : kNeonMint;

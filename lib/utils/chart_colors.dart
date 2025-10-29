import 'package:flutter/material.dart';

class ChartColors {
  Color pulse1(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF00E5FF)  // cyan for dark
      : const Color(0xFF2C7BE5); // blue for light

  Color pulse2(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF7A5CFF)  // purple for dark
      : const Color(0xFFFF7A7A); // coral for light

  Color resistance(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFFFB74D)  // orange for dark
      : const Color(0xFFFF9800); // deep orange for light

  Color dPulse1(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF4CAF50)  // green for dark
      : const Color(0xFF2E7D32); // dark green for light

  Color dPulse2(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFE91E63)  // pink for dark
      : const Color(0xFFC2185B); // dark pink for light
}

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

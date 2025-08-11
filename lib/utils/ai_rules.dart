import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/session.dart';
import 'stats.dart';

enum AiLevel { ok, warn, danger }

class AiAnalysis {
  final AiLevel level;
  final String title;
  final String subtitle;
  final List<String> reasons;
  final List<String> suggestions;

  const AiAnalysis({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.reasons,
    required this.suggestions,
  });
}

double _slope(List<FlSpot> data) {
  if (data.length < 2) return 0;
  final first = data.first.y;
  final last = data.last.y;
  return (last - first) / (data.length - 1);
}

double _pctChange(List<FlSpot> data) {
  if (data.length < 2) return 0;
  final first = data.first.y;
  final last = data.last.y;
  if (first == 0) return 0;
  return ((last - first) / first) * 100.0;
}

int _peaks(List<FlSpot> data, {double threshold=15}) {
  // грубый детектор «скачков»: считаем локальные приращения > threshold
  int count = 0;
  for (int i=1; i<data.length; i++) {
    if ((data[i].y - data[i-1].y).abs() >= threshold) count++;
  }
  return count;
}

AiAnalysis analyzeSession(Session s) {
  final st1 = Statistics.calculate(s.pulse1);
  final st2 = Statistics.calculate(s.pulse2);
  final stR = Statistics.calculate(s.resistance);

  final meanPulse = (st1.mean + st2.mean) / 2.0;
  final rmssd     = (st1.rmssd + st2.rmssd) / 2.0;
  final sdnn      = (st1.sdnn  + st2.sdnn)  / 2.0;

  final trendPulse     = (_slope(s.pulse1) + _slope(s.pulse2)) / 2.0;
  final resistanceDrop = -_pctChange(s.resistance); // позитивное число = падение
  final peaksCount     = (_peaks(s.pulse1) + _peaks(s.pulse2)) ~/ 2;

  final reasons = <String>[];
  final tips    = <String>[];

  // эвристики
  bool highPulse = meanPulse >= 110;
  bool midPulse  = meanPulse >= 90 && meanPulse < 110;
  bool rising    = trendPulse > 0.05;           // линия пульса растёт
  bool lowHRV    = rmssd < 20 || sdnn < 30;     // низкая вариабельность
  bool dropRes   = resistanceDrop > 8;          // падение сопротивления > 8%
  bool manyPeaks = peaksCount >= 3;

  if (highPulse) reasons.add('Высокий средний пульс (${meanPulse.toStringAsFixed(0)})');
  if (midPulse)  reasons.add('Повышенный средний пульс (${meanPulse.toStringAsFixed(0)})');
  if (rising)    reasons.add('Растущий тренд пульса');
  if (lowHRV)    reasons.add('Низкая вариабельность (RMSSD ${rmssd.toStringAsFixed(0)}, SDNN ${sdnn.toStringAsFixed(0)})');
  if (dropRes)   reasons.add('Падение сопротивления ${resistanceDrop.toStringAsFixed(1)}%');
  if (manyPeaks) reasons.add('Много пиков/скачков ($peaksCount)');

  // рекомендации
  if (highPulse || rising) tips.add('Снизить темп, сделать паузу 3–5 мин');
  if (lowHRV)             tips.add('Дыхательные упражнения 2–3 мин');
  if (dropRes)            tips.add('Пить воду, отдохнуть, проверить стресс‑факторы');
  if (manyPeaks)          tips.add('Проверить датчик/контакт, зафиксировать руку');

  // уровень
  AiLevel level = AiLevel.ok;
  String title = 'В пределах нормы';
  String subtitle = 'Пульс и сопротивление стабильны';

  if (highPulse || (midPulse && (lowHRV || dropRes || manyPeaks))) {
    level = AiLevel.danger;
    title = 'Серьёзные проблемы';
    subtitle = 'Рекомендуется посетить врача';
  } else if (midPulse || rising || lowHRV || dropRes || manyPeaks) {
    level = AiLevel.warn;
    title = 'Некоторые проблемы';
    subtitle = 'Следите за состоянием, возможен стресс/усталость';
  }

  // если вообще нет причин, добавим краткую
  if (reasons.isEmpty) reasons.add('Существенных отклонений не выявлено');

  return AiAnalysis(
    level: level,
    title: title,
    subtitle: subtitle,
    reasons: reasons,
    suggestions: tips.isEmpty ? ['Сохранить режим, наблюдать динамику'] : tips,
  );
}

// Цвет/иконка для уровня
IconData aiIcon(AiLevel l) {
  switch (l) {
    case AiLevel.ok:    return Icons.check_circle;
    case AiLevel.warn:  return Icons.error_outline;
    case AiLevel.danger:return Icons.warning_amber_rounded;
  }
}

Color aiColor(BuildContext context, AiLevel l) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  switch (l) {
    case AiLevel.ok:     return dark ? const Color(0xFF25D366) : const Color(0xFF2BAC5A);
    case AiLevel.warn:   return dark ? const Color(0xFFFFC107) : const Color(0xFFB8860B);
    case AiLevel.danger: return dark ? const Color(0xFFFF6B6B) : const Color(0xFFD64545);
  }
}

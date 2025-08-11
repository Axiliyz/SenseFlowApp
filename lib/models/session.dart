import 'package:fl_chart/fl_chart.dart';

class Session {
  final String name;
  final DateTime date;
  final List<FlSpot> pulse1;
  final List<FlSpot> pulse2;
  final List<FlSpot> resistance;
  final List<FlSpot> dPulse1;
  final List<FlSpot> dPulse2;
  final int durationInSeconds;
  List<String> notes;

  Session({
    required this.name,
    required this.date,
    required this.pulse1,
    required this.pulse2,
    required this.resistance,
    required this.dPulse1,
    required this.dPulse2,
    required this.durationInSeconds,
    this.notes = const [],
  });
}

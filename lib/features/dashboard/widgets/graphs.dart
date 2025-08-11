import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../utils/chart_colors.dart';
import '../../../utils/stats.dart';
import '../../../models/session.dart';
import 'stats_expander.dart';

LineChartBarData neonLine(List<FlSpot> data, Color base, {double width = 2}) {
  return LineChartBarData(
    spots: data,
    isCurved: true,
    color: base,
    barWidth: width,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(
      show: true,
      gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [base.withOpacity(0.12), base.withOpacity(0.0)],
      ),
    ),
  );
}

class SingleGraphCard extends StatelessWidget {
  final String title;
  final List<FlSpot> data;
  final Color color;
  final bool isResistance;
  final Session? currentSession;

  const SingleGraphCard({
    super.key,
    required this.title,
    required this.data,
    required this.color,
    required this.isResistance,
    required this.currentSession,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxY = data.map((e)=>e.y).reduce((a,b)=>a>b?a:b) + (isResistance ? 50 : 10);
    final minVal = data.map((e)=>e.y).reduce((a,b)=>a<b?a:b);
    final minY = (isResistance ? (minVal > 50 ? minVal - 50 : 0) : (minVal > 10 ? minVal - 10 : 0)).toDouble();
    final stats = Statistics.calculate(data);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tooltipBg = isDark ? const Color(0xFF0E1420) : Colors.white;
    final tooltipText = isDark ? Colors.white : const Color(0xFF0F1A2B);
    final tooltipBorder = isDark ? Colors.black.withOpacity(0.12) : Colors.black.withOpacity(0.08);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: chartBgColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY.toDouble(),
                backgroundColor: Colors.transparent,
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipColor: (_) => tooltipBg,
                    tooltipBorder: BorderSide(color: tooltipBorder),
                    getTooltipItems: (spots) {
                      return spots.map((s) {
                        if (currentSession == null || currentSession!.durationInSeconds == 0) return null;
                        final seconds = (currentSession!.durationInSeconds * s.x / (s.bar.spots.length - 1)).round();
                        return LineTooltipItem('${seconds}с\n ${s.y.toStringAsFixed(1)}',
                          TextStyle(color: tooltipText));
                      }).whereType<LineTooltipItem>().toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true, drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: gridLineColor(context), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0),
                        style: TextStyle(color: axisTextColor(context), fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 24, interval: 2,
                      getTitlesWidget: (value, meta) {
                        if (value % 2 != 0 || currentSession == null || data.isEmpty) return const SizedBox.shrink();
                        final seconds = (currentSession!.durationInSeconds * value / (data.length - 1)).round();
                        return Text('$secondsс', style: TextStyle(color: axisTextColor(context), fontSize: 11, fontWeight: FontWeight.w600));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [neonLine(data, color)],
              ),
            ),
          ),
          const SizedBox(height: 8),
          StatsExpander(stats: stats, title: 'Статистика $title'),
        ],
      ),
    );
  }
}

class DoubleGraphCard extends StatelessWidget {
  final String title;
  final List<FlSpot> data1;
  final List<FlSpot> data2;
  final Color color1;
  final Color color2;
  final Session? currentSession;

  const DoubleGraphCard({
    super.key,
    required this.title,
    required this.data1,
    required this.data2,
    required this.color1,
    required this.color2,
    required this.currentSession,
  });

  @override
  Widget build(BuildContext context) {
    if (data1.isEmpty || data2.isEmpty) return const SizedBox.shrink();
    final all = [...data1, ...data2];
    final maxY = all.map((e)=>e.y).reduce((a,b)=>a>b?a:b) + 50;
    final minVal = all.map((e)=>e.y).reduce((a,b)=>a<b?a:b);
    final minY = minVal > 50 ? (minVal - 50) : 0.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tooltipBg = isDark ? const Color(0xFF0E1420) : Colors.white;
    final tooltipMain = isDark ? Colors.white : const Color(0xFF0F1A2B);
    final tooltipSub  = isDark ? Colors.white70 : const Color(0xFF3A4A63);
    final tooltipBorder = isDark ? Colors.black.withOpacity(0.12) : Colors.black.withOpacity(0.08);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: chartBgColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: minY, maxY: maxY,
                backgroundColor: Colors.transparent,
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipColor: (_) => tooltipBg,
                    tooltipBorder: BorderSide(color: tooltipBorder),
                    getTooltipItems: (spots) {
                      if (spots.isEmpty || currentSession == null || currentSession!.durationInSeconds == 0) return [];
                      final seconds = (currentSession!.durationInSeconds * spots.first.x / (spots.first.bar.spots.length - 1)).toStringAsFixed(1);
                      return List.generate(spots.length, (i) {
                        final isMain = i == 0;
                        final txt = isMain ? '${seconds}с\n${spots[i].y.toStringAsFixed(1)}' : spots[i].y.toStringAsFixed(1);
                        return LineTooltipItem(txt, TextStyle(color: isMain ? tooltipMain : tooltipSub));
                      });
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true, drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: gridLineColor(context), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0), style: TextStyle(color: axisTextColor(context), fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 24, interval: 12,
                      getTitlesWidget: (value, meta) {
                        if (value % 12 != 0 || currentSession == null || data1.isEmpty) return const SizedBox.shrink();
                        final seconds = (currentSession!.durationInSeconds * value / (data1.length - 1)).round();
                        return Text('$secondsс', style: TextStyle(color: axisTextColor(context), fontSize: 11, fontWeight: FontWeight.w600));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  neonLine(data1, color1),
                  neonLine(data2, color2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCompact extends StatelessWidget {
  final Statistics stats;
  final String title;
  const _StatsCompact({required this.stats, required this.title});
  @override
  Widget build(BuildContext context) {
    Text row(String k, double v, {String s=''}) => Text('$k: ${v.toStringAsFixed(2)}$s');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        row('Среднее', stats.mean),
        row('Станд. откл.', stats.stdDev),
        row('Мин', stats.min),
        row('Макс', stats.max),
        row('Медиана', stats.median),
      ],
    );
  }
}

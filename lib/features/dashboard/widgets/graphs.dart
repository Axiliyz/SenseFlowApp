import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../utils/chart_colors.dart';
import '../../../utils/stats.dart';
import '../../../models/session.dart';
import '../../../utils/filters.dart';
import 'stats_expander.dart';

Color lighten(Color c, [double amount = 0.22]) {
  final hsl = HSLColor.fromColor(c);
  final h = hsl.hue, s_ = hsl.saturation, l = (hsl.lightness + amount).clamp(0.0, 1.0);
  return HSLColor.fromAHSL(hsl.alpha, h, s_, l).toColor();
}

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

class SingleGraphCard extends StatefulWidget {
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
  State<SingleGraphCard> createState() => _SingleGraphCardState();
}

class _SingleGraphCardState extends State<SingleGraphCard> {
  ChartFilter _currentFilter = ChartFilter.none;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();
    
    final filteredData = _currentFilter.apply(widget.data);
    final maxY = filteredData.map((e) => e.y).reduce((a,b) => a > b ? a : b) + (widget.isResistance ? 50 : 10);
    final minVal = filteredData.map((e) => e.y).reduce((a,b) => a < b ? a : b);
    final minY = (widget.isResistance ? (minVal > 50 ? minVal - 50 : 0) : (minVal > 10 ? minVal - 10 : 0)).toDouble();
    final stats = Statistics.calculate(filteredData);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold
                )
              ),
              PopupMenuButton<ChartFilter>(
                initialValue: _currentFilter,
                onSelected: (filter) => setState(() => _currentFilter = filter),
                itemBuilder: (context) => ChartFilter.values.map((f) => 
                  PopupMenuItem(
                    value: f,
                    child: Text(f.name),
                  )
                ).toList(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_currentFilter.name),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
          getTooltipItems: (spots) {
            // Всегда столько же элементов, сколько touchedSpots
            if (spots.isEmpty) return const <LineTooltipItem>[];

            final hasDur = widget.currentSession != null &&
                widget.currentSession!.durationInSeconds > 0;
            final total = (spots.first.bar.spots.length <= 1)
                ? 1
                : (spots.first.bar.spots.length - 1);

            return List<LineTooltipItem>.generate(spots.length, (i) {
              final s = spots[i];
              final buf = StringBuffer();
              if (hasDur) {
                final seconds =
                    (widget.currentSession!.durationInSeconds * s.x / total)
                        .round();
                buf.writeln('${seconds}с');
              }
              buf.write(s.y.toStringAsFixed(1));
              return LineTooltipItem(
                buf.toString(),
                TextStyle(color: tooltipText, fontWeight: FontWeight.w700),
              );
            });
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: gridLineColor(context), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (v, _) => Text(
              v.toStringAsFixed(0),
              style: TextStyle(
                color: axisTextColor(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 2,
            getTitlesWidget: (value, meta) {
              if (value % 2 != 0 ||
                  widget.currentSession == null ||
                  filteredData.isEmpty) {
                return const SizedBox.shrink();
              }
              final seconds = (widget.currentSession!.durationInSeconds *
                      value /
                      (filteredData.length - 1))
                  .round();
              return Text(
                '$secondsс',
                style: TextStyle(
                  color: axisTextColor(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [neonLine(filteredData, widget.color)],
    ),
  ),
),

          const SizedBox(height: 8),
          StatsExpander(
            stats: Statistics.calculate(filteredData),
            title: widget.title,
          ),
          ],
      ),
    );
  }
}

class DoubleGraphCard extends StatefulWidget {
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
    this.currentSession,
  });

  @override
  State<DoubleGraphCard> createState() => _DoubleGraphCardState();
}

class _DoubleGraphCardState extends State<DoubleGraphCard> {
  ChartFilter _filter1 = ChartFilter.none;
  ChartFilter _filter2 = ChartFilter.none;

  @override
  Widget build(BuildContext context) {
    if (widget.data1.isEmpty && widget.data2.isEmpty) return const SizedBox.shrink();

    final filteredData1 = _filter1.apply(widget.data1);
    final filteredData2 = _filter2.apply(widget.data2);

    final allPoints = [...filteredData1, ...filteredData2];
    final maxY = (allPoints.isEmpty ? 10 : allPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10).toDouble();
    final minVal = allPoints.isEmpty ? 0 : allPoints.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final minY = (minVal > 10 ? minVal - 10 : 0).toDouble();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tooltipBg   = isDark ? const Color(0xFF0E1420) : Colors.white;
    final tooltipText = isDark ? Colors.white : const Color(0xFF0F1A2B);
    final tooltipBorder = isDark ? Colors.black.withOpacity(0.12)
                                : Colors.black.withOpacity(0.08);
        

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  PopupMenuButton<ChartFilter>(
                    initialValue: _filter1,
                    onSelected: (filter) => setState(() => _filter1 = filter),
                    itemBuilder: (context) => ChartFilter.values
                        .map(
                          (f) => PopupMenuItem(
                            value: f,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(color: widget.color1, shape: BoxShape.circle),
                                ),
                                Text(f.name),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(color: widget.color1, shape: BoxShape.circle),
                          ),
                          Text(_filter1.name),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<ChartFilter>(
                    initialValue: _filter2,
                    onSelected: (filter) => setState(() => _filter2 = filter),
                    itemBuilder: (context) => ChartFilter.values
                        .map(
                          (f) => PopupMenuItem(
                            value: f,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(color: widget.color2, shape: BoxShape.circle),
                                ),
                                Text(f.name),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(color: widget.color2, shape: BoxShape.circle),
                          ),
                          Text(_filter2.name),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  if (widget.data1.isNotEmpty) neonLine(filteredData1, isDark ? widget.color1 : lighten(widget.color1)),
                  if (widget.data2.isNotEmpty) neonLine(filteredData2, isDark ? widget.color2 : lighten(widget.color2)),
                ],
                gridData: FlGridData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipColor: (_) => tooltipBg,
                    getTooltipItems: (spots) {
                      if (spots.isEmpty) return const <LineTooltipItem>[];
                      // Compute seconds from first spot's x and longest series length
                      final double xIndex = spots.first.x;
                      int maxLen = 1;
                      for (final s in spots) {
                        if (s.bar.spots.length > maxLen) maxLen = s.bar.spots.length;
                      }
                      int? seconds;
                      try {
                        if (widget.currentSession != null && widget.currentSession!.durationInSeconds > 0) {
                          final total = (maxLen <= 1) ? 1 : (maxLen - 1);
                          seconds = (widget.currentSession!.durationInSeconds * xIndex / total).round();
                        }
                      } catch (_) {}
                      final secLine = seconds != null ? '${seconds}с' : null;
                      // One tooltip per touched spot (native fl_chart expectation)
                      return List<LineTooltipItem>.generate(
                        spots.length,
                        (i) {
                          final s = spots[i];
                          final val = s.y.toStringAsFixed(1);
                          final text = secLine == null ? val : (i == 0 ? (secLine + '\n' + val) : val);
                          return LineTooltipItem(
                            text,
                            TextStyle(fontWeight: FontWeight.w700, color: tooltipText),
                          );
                        },
                        growable: false,
                      );
    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StatsExpander(
                  stats: Statistics.calculate(filteredData1),
                  title: 'Пульс 1',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsExpander(
                  stats: Statistics.calculate(filteredData2),
                  title: 'Пульс 2',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final Color color;
  final String filterName;

  const _FilterButton({
    required this.color,
    required this.filterName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Text(filterName),
          const Icon(Icons.arrow_drop_down),
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

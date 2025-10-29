import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/session.dart';
import '../../utils/chart_colors.dart';
import '../../widgets/neon_card.dart';
import '../../utils/filters.dart';

class ComparePage extends StatefulWidget {
  final List<Session> sessions;
  const ComparePage({super.key, required this.sessions});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  Session? a;
  Session? b;
  final chartColors = ChartColors();  // Add this line

  @override
  void initState() {
    super.initState();
    if (widget.sessions.length >= 2) {
      a = widget.sessions[0];
      b = widget.sessions[1];
    } else if (widget.sessions.length == 1) {
      a = widget.sessions[0];
      b = widget.sessions[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final on = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Сравнение сессий')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Выберите две сессии', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _sessionDropdown(context, isFirst: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _sessionDropdown(context, isFirst: false)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (a != null && b != null)
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _LegendDot(color: _lineColorA(context), label: _labelOf(a!)),
                        _LegendDot(color: _lineColorB(context), label: _labelOf(b!)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (a != null && b != null) ...[
              _CompareLineCard(
                title: 'Пульс 1',
                dataA: a!.pulse1,
                dataB: b!.pulse1,
                durA: a!.durationInSeconds,
                durB: b!.durationInSeconds,
                colorA: _lineColorA(context),
                colorB: _altColorA(context),
              ),
              _CompareLineCard(
                title: 'Пульс 2',
                dataA: a!.pulse2,
                dataB: b!.pulse2,
                durA: a!.durationInSeconds,
                durB: b!.durationInSeconds,
                colorA: _lineColorB(context),
                colorB: _altColorB(context),
              ),
              _CompareLineCard(
                title: 'Сопротивление',
                dataA: a!.resistance,
                dataB: b!.resistance,
                durA: a!.durationInSeconds,
                durB: b!.durationInSeconds,
                colorA: chartColors.resistance(context),  // Changed this line
                colorB: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFFFD166) // янтарь в дарке
                    : const Color(0xFF9C6B00), // тёплый тёмно‑янтарный в лайте
              ),
            ]
            else
              NeonCard(
                child: Text(
                  'Недостаточно сессий для сравнения. Загрузите хотя бы две.',
                  style: TextStyle(color: on.withOpacity(0.7)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sessionDropdown(BuildContext context, {required bool isFirst}) {
    final value = isFirst ? a : b;
    return DropdownButtonFormField<Session>(
      value: value,
      items: widget.sessions.map((s) {
        return DropdownMenuItem(
          value: s,
          child: Text(_labelOf(s), overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (val) => setState(() {
        if (isFirst) {
          a = val;
        } else {
          b = val;
        }
      }),
      decoration: const InputDecoration(
        hintText: 'Выбрать сессию',
      ),
    );
  }

  String _labelOf(Session s) =>
      '${s.date.day.toString().padLeft(2,'0')}.'
      '${s.date.month.toString().padLeft(2,'0')}.'
      '${s.date.year} '
      '${s.date.hour.toString().padLeft(2,'0')}:'
      '${s.date.minute.toString().padLeft(2,'0')}:'
      '${s.date.second.toString().padLeft(2,'0')}';

  // Базовые пары цветов (контрастные и согласованные с твоей палитрой)
  Color _lineColorA(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF00E5FF) // яркий циан
      : const Color(0xFF2C7BE5); // насыщенно‑синий

  Color _lineColorB(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF7A5CFF) // фиолет
      : const Color(0xFFFF7A7A); // коралл

  // Дополнительные оттенки, чтобы «Пульс 1» и «Пульс 2» в паре не конфликтовали
  Color _altColorA(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF00BFA5) // бирюза
      : const Color(0xFF4FC3F7); // голубой

  Color _altColorB(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFB388FF) // светлее фиолет
      : const Color(0xFFFFA6A6); // светлее коралл
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final on = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: on.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: on)),
        ],
      ),
    );
  }
}

class _CompareLineCard extends StatefulWidget {
  final String title;
  final List<FlSpot> dataA;
  final List<FlSpot> dataB;
  final int durA;
  final int durB;
  final Color colorA;
  final Color colorB;

  const _CompareLineCard({
    required this.title,
    required this.dataA,
    required this.dataB,
    required this.durA,
    required this.durB,
    required this.colorA,
    required this.colorB,
  });

  @override
  State<_CompareLineCard> createState() => _CompareLineCardState();
}

class _CompareLineCardState extends State<_CompareLineCard> {
  ChartFilter _filterA = ChartFilter.none;
  ChartFilter _filterB = ChartFilter.none;

  @override
  Widget build(BuildContext context) {
    if (widget.dataA.isEmpty && widget.dataB.isEmpty) return const SizedBox.shrink();

    final filteredDataA = _filterA.apply(widget.dataA);
    final filteredDataB = _filterB.apply(widget.dataB);

    // Fix data references
    final durA = widget.durA;
    final durB = widget.durB;
    final dataA = widget.dataA;
    final dataB = widget.dataB;

    // Диапазон Y общий по двум наборам
    final all = [...filteredDataA, ...filteredDataB];
    final maxY = all.map((e) => e.y).reduce((a,b)=>a>b?a:b);
    final minY = all.map((e) => e.y).reduce((a,b)=>a<b?a:b);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tooltipBg = isDark ? const Color(0xFF0E1420) : Colors.white;
    final tooltipMain = isDark ? Colors.white : const Color(0xFF0F1A2B);
    final tooltipSub  = isDark ? Colors.white70 : const Color(0xFF3A4A63);
    final tooltipBorder = isDark ? Colors.black.withOpacity(0.12) : Colors.black.withOpacity(0.08);

    // Вспомогалки
    LineChartBarData line(List<FlSpot> data, Color base) => LineChartBarData(
      spots: data,
      isCurved: true,
      color: base,
      barWidth: 2,
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

    String secLabel(double x, int dur, int len) {
      if (dur == 0 || len <= 1) return x.toStringAsFixed(0);
      final seconds = (dur * x / (len - 1)).round();
      return '$secondsс';
    }

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
              Row(
                children: [
                  _FilterButton(
                    currentFilter: _filterA,
                    onChanged: (f) => setState(() => _filterA = f),
                    color: widget.colorA,
                    label: 'A',
                  ),
                  const SizedBox(width: 8),
                  _FilterButton(
                    currentFilter: _filterB,
                    onChanged: (f) => setState(() => _filterB = f),
                    color: widget.colorB,
                    label: 'B',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
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
                      // Покажем для каждой линии свою метку времени и значение
                      return List.generate(spots.length, (i) {
                        final s = spots[i];
                        final bool isA = s.barIndex == 0; // первая линия
                        final int dur = isA ? widget.durA : widget.durB;
                        final int len = isA ? (dataA.isEmpty ? 0 : dataA.length) : (dataB.isEmpty ? 0 : dataB.length);
                        final secs = secLabel(s.x, dur, len);
                        final color = i == 0 ? tooltipMain : tooltipSub;
                        final prefix = isA ? 'A' : 'B';
                        return LineTooltipItem('$prefix: $secs\n${s.y.toStringAsFixed(1)}', TextStyle(color: color));
                      });
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: gridLineColor(context), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(
                        v.toStringAsFixed(0),
                        style: TextStyle(color: axisTextColor(context), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 24, interval: 2,
                      getTitlesWidget: (value, meta) {
                        // нижняя ось — секунды для A, если она есть; если нет, покажем индекс
                        if (dataA.isEmpty) {
                          return Text(value.toStringAsFixed(0),
                              style: TextStyle(color: axisTextColor(context), fontSize: 11, fontWeight: FontWeight.w600));
                        }
                        final secs = secLabel(value, durA, dataA.length);
                        return Text(secs, style: TextStyle(color: axisTextColor(context), fontSize: 11, fontWeight: FontWeight.w600));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  line(filteredDataA, widget.colorA),
                  line(filteredDataB, widget.colorB),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ...existing helper methods...
}

// Add new widget for filter button
class _FilterButton extends StatelessWidget {
  final ChartFilter currentFilter;
  final void Function(ChartFilter) onChanged;
  final Color color;
  final String label;

  const _FilterButton({
    required this.currentFilter,
    required this.onChanged,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ChartFilter>(
      initialValue: currentFilter,
      onSelected: onChanged,
      itemBuilder: (context) => ChartFilter.values.map((f) => 
        PopupMenuItem(
          value: f,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Text('$label: ${f.name}'),
            ],
          ),
        )
      ).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            Text('${currentFilter.name}'),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}

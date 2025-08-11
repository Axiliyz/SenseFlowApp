import 'package:flutter/material.dart';
import '../../../../utils/stats.dart';

class StatsExpander extends StatefulWidget {
  final Statistics stats;
  final String title;
  const StatsExpander({super.key, required this.stats, required this.title});

  @override
  State<StatsExpander> createState() => _StatsExpanderState();
}

class _StatsExpanderState extends State<StatsExpander> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    Text _row(String k, double v, {String s=''}) =>
      Text('$k: ${v.toStringAsFixed(2)}$s');

    final s = widget.stats;

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.title),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onTap: ()=> setState(()=> _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Основные:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _row('Среднее', s.mean),
                  _row('Медиана', s.median),
                  _row('Мода', s.mode),
                  _row('Мин', s.min),
                  _row('Макс', s.max),
                  _row('Размах', s.range),
                  const Divider(),
                  const Text('Разброс:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _row('Станд. откл.', s.stdDev),
                  _row('Дисперсия', s.variance),
                  _row('Станд. ошибка', s.sem),
                  _row('Коэф. вариации', s.cv, s: '%'),
                  _row('Отн. ст. откл.', s.rsd, s: '%'),
                  const Divider(),
                  const Text('Квартили/процентили:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _row('Q1 (25%)', s.q1),
                  _row('Q3 (75%)', s.q3),
                  _row('IQR', s.iqr),
                  _row('P10', s.p10),
                  _row('P90', s.p90),
                  const Divider(),
                  const Text('Форма распределения:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _row('Асимметрия', s.skewness),
                  _row('Эксцесс', s.kurtosis),
                  const Divider(),
                  const Text('ВСР:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _row('SDNN', s.sdnn),
                  _row('RMSSD', s.rmssd),
                  _row('pNN50', s.pnn50, s: '%'),
                  const Divider(),
                  const Text('Стабильность:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _row('Коэф. стабильности', s.stabilityCoeff),
                  _row('Индекс стабильности', s.stabilityIndex),
                  const Divider(),
                  const Text('Тренды:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _row('Линейный тренд', s.linearTrend),
                  _row('Квадратичный тренд', s.quadraticTrend),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

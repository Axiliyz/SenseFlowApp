import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar/src/shared/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

void main() => runApp(ValueListenableBuilder<ThemeMode>(
  valueListenable: themeNotifier,
  builder: (_, mode, __) => MaterialApp(
    debugShowCheckedModeBanner: false,
    themeMode: mode,
    theme: ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      cardColor: Colors.white,
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
    ),
    darkTheme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF121417),
      cardColor: const Color(0xFF1E1F23),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3CE6BE)),
      ),
    ),
    home: const DashboardPage(),
  ),
));

class SenseFlowApp extends StatelessWidget {
  const SenseFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121417),
        cardColor: const Color(0xFF1E1F23),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3CE6BE)),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  List<FlSpot> pulse1 = [];
  List<FlSpot> pulse2 = [];
  List<FlSpot> resistance = [];
  List<FlSpot> dPulse1 = [];
  List<FlSpot> dPulse2 = [];

  String? currentSessionName;
  List<_Session> sessions = [];

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  List<_Session> sessionsForSelectedDay = [];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late TextEditingController _noteInputController;

  @override
  void initState() {
    super.initState();
    _noteInputController = TextEditingController();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _noteInputController.dispose();
    _fadeController.dispose();
    super.dispose();
  }


  Future<void> loadData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      allowMultiple: true,
      withData: true,
    );

    if (result == null) return;

    final filesMap = {for (var f in result.files) f.name: f};

    for (var file in result.files) {
      if (file.name.startsWith('D')) continue;

      final content = utf8.decode(file.bytes!);
      final lines = const LineSplitter().convert(content);
      String lastLine = lines.isNotEmpty ? lines.last : '';

      final durationMatch = RegExp(r'(\d+)\s*сек').firstMatch(lastLine);
      int durationInSeconds = 0;
      if (durationMatch != null) {
        durationInSeconds = int.parse(durationMatch.group(1)!);
      }

      final session = _Session(
        name: file.name.replaceAll('.txt', ''),
        date: _parseSessionDate(file.name),
        pulse1: [],
        pulse2: [],
        resistance: [],
        dPulse1: [],
        dPulse2: [],
        durationInSeconds: durationInSeconds,
      );

      for (var i = 0; i < lines.length; i++) {
        final parts = lines[i].trim().split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          session.pulse1.add(FlSpot(i.toDouble(), double.parse(parts[0])));
          session.pulse2.add(FlSpot(i.toDouble(), double.parse(parts[1])));
          session.resistance.add(FlSpot(i.toDouble(), double.parse(parts[2])));
        }
      }

      final dFileName = 'D${file.name.replaceAll('.txt', '')}.txt';
      if (filesMap.containsKey(dFileName)) {
        final dContent = utf8.decode(filesMap[dFileName]!.bytes!);
        final dLines = const LineSplitter().convert(dContent);

        for (var i = 0; i < dLines.length; i++) {
          final parts = dLines[i].trim().split(' ');
          if (parts.length >= 2) {
            final first = double.tryParse(parts[0]);
            final second = double.tryParse(parts[1]);
            if (first != null && second != null) {
              session.dPulse1.add(FlSpot(i.toDouble(), first));
              session.dPulse2.add(FlSpot(i.toDouble(), second));
            }
          }
        }
      }

      if (!sessions.any((s) => s.name == session.name)) {
        sessions.add(session);
      }
    }

    sessions.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _selectSession(sessions.first);
      _fadeController.forward(from: 0);
    });
  }

  _Session _emptySession() {
    return _Session(
      name: '',
      date: DateTime.now(),
      pulse1: [],
      pulse2: [],
      resistance: [],
      dPulse1: [],
      dPulse2: [],
      durationInSeconds: 0,
    );
  }

  void _selectSession(_Session session) {
    setState(() {
      currentSessionName = session.name;
      pulse1 = session.pulse1;
      pulse2 = session.pulse2;
      resistance = session.resistance;
      dPulse1 = session.dPulse1;
      dPulse2 = session.dPulse2;
      _noteInputController.clear();
    });
    _fadeController.forward(from: 0);
  }


  void _filterSessionsByDay(DateTime day) {
    final filtered = sessions.where((s) =>
    s.date.year == day.year &&
        s.date.month == day.month &&
        s.date.day == day.day
    ).toList();
    setState(() {
      sessionsForSelectedDay = filtered;
    });
  }

  DateTime _parseSessionDate(String filename) {
    final parts = filename.split('_');
    if (parts.length != 2) return DateTime.now();
    final datePart = parts[0];
    final timePart = parts[1].replaceAll('.txt', '');

    final day = int.parse(datePart.substring(0, 2));
    final month = int.parse(datePart.substring(2, 4));
    final year = 2000 + int.parse(datePart.substring(4, 6));
    final hour = int.parse(timePart.substring(0, 2));
    final minute = int.parse(timePart.substring(2, 4));
    final second = int.parse(timePart.substring(4, 6));

    return DateTime(year, month, day, hour, minute, second);
  }

  Widget _notesBlock() {
    final session = sessions.firstWhere(
      (s) => s.name == currentSessionName,
      orElse: () => _emptySession(),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Заметки', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _noteInputController,
              decoration: const InputDecoration(
                hintText: 'Введите заметку и нажмите Enter...',
                border: OutlineInputBorder(),
                hintStyle: TextStyle(color: Colors.white54),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (text) {
                if (text.trim().isEmpty) return;
                setState(() {
                  session.notes = [...session.notes, text.trim()];
                  _noteInputController.clear();
                });
              },
            ),
            const SizedBox(height: 12),
            if (session.notes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ваши заметки:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (int i = 0; i < session.notes.length; i++)
                    ListTile(
                      title: Text(session.notes[i], style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            session.notes.removeAt(i);
                          });
                        },
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text('Экспорт в PDF', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    exportToPdf(context, session);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Как пользоваться SenseFlow'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Нажмите на иконку загрузки, чтобы выбрать .txt файл с измерениями.'),
            SizedBox(height: 8),
            Text('2. Используйте выпадающее меню "Сеансы" для переключения между загруженными файлами.'),
            SizedBox(height: 8),
            Text('3. В левом меню вы увидите календарь, недавние сессии и выбранный день.'),
            SizedBox(height: 8),
            Text('4. Нажмите на любой день в календаре, чтобы отфильтровать сеансы.'),
            SizedBox(height: 8),
            Text('5. Добавьте заметку для каждого сеанса в нижней части экрана.'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Понятно')),
      ],
    ),
  );
}

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Личный кабинет'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Имя пользователя: Пользователь'),
              SizedBox(height: 8),
              Text('Всего сеансов: 0'),
              SizedBox(height: 8),
              Text('Последний вход: Сегодня'),
              SizedBox(height: 8),
              Text('Версия приложения: 1.0.0'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Настройки'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Сменить тему'),
              onTap: () {
                Navigator.pop(context);
                themeNotifier.value = themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Обучение'),
              onTap: () {
                Navigator.pop(context);
                _showHelpDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _statisticsWidget(Statistics stats) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Статистика:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Среднее: ${stats.mean.toStringAsFixed(2)}'),
          Text('Станд. откл.: ${stats.stdDev.toStringAsFixed(2)}'),
          Text('Мин: ${stats.min.toStringAsFixed(2)}'),
          Text('Макс: ${stats.max.toStringAsFixed(2)}'),
          Text('Медиана: ${stats.median.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _graph(String title, List<FlSpot> data, Color color, bool isResistance) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxY = data.map((e) => e.y).reduce(max) + (isResistance ? 50 : 10);
    final minVal = data.map((e) => e.y).reduce(min);
    final minY = (isResistance ? (minVal > 50 ? minVal - 50 : 0) : (minVal > 10 ? minVal - 10 : 0));
    final stats = Statistics.calculate(data);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: LineChart(
                  LineChartData(
                    minY: minY.toDouble(),
                    maxY: maxY.toDouble(),
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final session = sessions.firstWhere((s) => s.name == currentSessionName!, orElse: () => _emptySession());
                            if (session.durationInSeconds == 0) return null;
                            final seconds = (session.durationInSeconds * spot.x / (spot.bar.spots.length - 1)).round();
                            return LineTooltipItem(
                              '${seconds}с\n ${spot.y.toStringAsFixed(1)}',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                    ),

                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white12, strokeWidth: 1)),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (v, meta) => Text(v.toStringAsFixed(0), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 2,
                          getTitlesWidget: (value, meta) {
                            if (value % 2 != 0) {
                              return const SizedBox.shrink(); // Пропускаем не кратные 3 секунды
                            }
                            final session = sessions.firstWhere((s) => s.name == currentSessionName!, orElse: () => _emptySession());
                            if (session.durationInSeconds == 0 || data.isEmpty) return const SizedBox.shrink();
                            final seconds = (session.durationInSeconds * value / (data.length - 1)).round();
                            return Text('$secondsс', style: const TextStyle(color: Colors.white70, fontSize: 10));
                          },
                        ),
                      ),

                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(spots: data, isCurved: true, color: color, barWidth: 2, dotData: FlDotData(show: false)),
                    ],
                  ),
                ),
              ),
              _StatisticsWidget(stats: stats, title: 'Статистика $title'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _doubleGraph(String title, List<FlSpot> data1, List<FlSpot> data2) {
    if (data1.isEmpty || data2.isEmpty) return const SizedBox.shrink();
    final allData = [...data1, ...data2];
    final maxY = allData.map((e) => e.y).reduce(max) + 50;
    final minVal = allData.map((e) => e.y).reduce(min);
    final minY = minVal > 50 ? (minVal - 50) : 0.0;
    final stats1 = Statistics.calculate(data1);
    final stats2 = Statistics.calculate(data2);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (touchedSpots) {
                          if (touchedSpots.isEmpty) return [];

                          final session = sessions.firstWhere((s) => s.name == currentSessionName!, orElse: () => _emptySession());
                          if (session.durationInSeconds == 0) return [];

                          final seconds = (session.durationInSeconds * touchedSpots.first.x / (touchedSpots.first.bar.spots.length - 1)).toStringAsFixed(1);

                          return List.generate(touchedSpots.length, (index) {
                            if (index == 0) {
                              return LineTooltipItem(
                                '${seconds}с\n${touchedSpots[index].y.toStringAsFixed(1)}',
                                const TextStyle(color: Colors.white),
                              );
                            } else {
                              return LineTooltipItem(
                                '${touchedSpots[index].y.toStringAsFixed(1)}',
                                const TextStyle(color: Colors.white70),
                              );
                            }
                          });
                        },
                      ),
                      touchSpotThreshold: 10,
                    ),

                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white12, strokeWidth: 1)),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (v, meta) => Text(v.toStringAsFixed(0), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 12,
                          getTitlesWidget: (value, meta) {
                            if (value % 12 != 0) {
                              return const SizedBox.shrink(); // Пропускаем не кратные 3 секунды
                            }
                            final session = sessions.firstWhere((s) => s.name == currentSessionName!, orElse: () => _emptySession());
                            if (session.durationInSeconds == 0 || data1.isEmpty) return const SizedBox.shrink();
                            final seconds = (session.durationInSeconds * value / (data1.length - 1)).round();
                            return Text('$secondsс', style: const TextStyle(color: Colors.white70, fontSize: 10));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(spots: data1, isCurved: true, color: Colors.lightGreenAccent, barWidth: 2, dotData: FlDotData(show: false)),
                      LineChartBarData(spots: data2, isCurved: true, color: Colors.pinkAccent, barWidth: 2, dotData: FlDotData(show: false)),
                    ],
                  ),
                ),
              ),
              _StatisticsWidget(stats: stats1, title: 'Статистика Показания 1'),
              const SizedBox(height: 8),
              _StatisticsWidget(stats: stats2, title: 'Статистика Показания 2'),
            ],
          ),
        ),
      ),
    );
  }
  Widget _calendar() => SizedBox(
    width: 260,
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (d) => isSameDay(selectedDay, d),
        onDaySelected: (sel, foc) {
          setState(() {
            selectedDay = sel;
            focusedDay = foc;
            _filterSessionsByDay(sel);
          });
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle),
          todayDecoration: const BoxDecoration(color: Colors.deepPurpleAccent, shape: BoxShape.circle),
          weekendTextStyle: const TextStyle(color: Colors.white70),
          defaultTextStyle: const TextStyle(color: Colors.white),
          outsideTextStyle: const TextStyle(color: Colors.white38),
          defaultDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          selectedTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          weekendDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          holidayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          markerDecoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          cellMargin: const EdgeInsets.all(4),
          cellPadding: const EdgeInsets.all(0),
          isTodayHighlighted: true,
          markersMaxCount: 3,
          markerSize: 6,
          markerMargin: const EdgeInsets.symmetric(horizontal: 0.3),
          markersAlignment: Alignment.bottomCenter,
          markerDecoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.white),
          weekendStyle: TextStyle(color: Colors.white70),
        ),
        headerStyle: const HeaderStyle(
          titleTextStyle: TextStyle(color: Colors.white),
          formatButtonVisible: false,
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.cyanAccent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.deepPurpleAccent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );

  Widget _recentSessions() => SizedBox(
    width: 260,
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Недавние сеансы', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (var session in sessions.take(5))
              ListTile(
                title: Text(
                  '${session.date.day.toString().padLeft(2, '0')}.${session.date.month.toString().padLeft(2, '0')}.${session.date.year} ${session.date.hour.toString().padLeft(2, '0')}:${session.date.minute.toString().padLeft(2, '0')}:${session.date.second.toString().padLeft(2, '0')}',
                  style: TextStyle(color: currentSessionName == session.name ? const Color(0xFF3CE6BE) : Colors.white70),
                ),
                onTap: () => _selectSession(session),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _daySessions() => sessionsForSelectedDay.isEmpty
      ? const SizedBox.shrink()
      : SizedBox(
    width: 260,
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Выбранный день', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (var session in sessionsForSelectedDay)
              ListTile(
                title: Text(
                  '${session.date.hour.toString().padLeft(2, '0')}:${session.date.minute.toString().padLeft(2, '0')}:${session.date.second.toString().padLeft(2, '0')}',
                  style: TextStyle(color: currentSessionName == session.name ? const Color.fromARGB(255, 2, 189, 145) : Colors.white70),
                ),
                onTap: () => _selectSession(session),
              ),
          ],
        ),
      ),
    ),
  );

  // --- Продолжение ---

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final hasData = pulse1.isNotEmpty || pulse2.isNotEmpty || resistance.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SenseFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Личный кабинет',
            onPressed: _showProfileDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Настройки',
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: isWide
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: loadData,
                    icon: const Icon(Icons.file_upload, color: Colors.white),
                    label: const Text('Добавить файлы', style: TextStyle(color: Colors.white)),
                  ),
                  if (currentSessionName != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        currentSessionName!,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  if (hasData) ...[
                    _graph('Пульс 1', pulse1, Colors.cyanAccent, false),
                    _graph('Пульс 2', pulse2, Colors.deepPurpleAccent, false),
                    _graph('Сопротивление', resistance, Colors.orangeAccent, true),
                    _doubleGraph('Дополнительные Показания', dPulse1, dPulse2),
                    _notesBlock(),
                  ]
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                _calendar(),
                const SizedBox(height: 12),
                _recentSessions(),
                const SizedBox(height: 12),
                _daySessions(),
              ],
            ),
          ],
        )
            : Column(
          children: [
            ElevatedButton.icon(
              onPressed: loadData,
              icon: const Icon(Icons.upload_file),
              label: const Text('Добавить файлы'),
            ),
            if (currentSessionName != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  currentSessionName!,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
              ),
            if (hasData) ...[
              _graph('Пульс 1', pulse1, Colors.cyanAccent, false),
              _graph('Пульс 2', pulse2, Colors.deepPurpleAccent, false),
              _graph('Сопротивление', resistance, Colors.orangeAccent, true),
              _doubleGraph('Дополнительные Показания', dPulse1, dPulse2),
              _notesBlock(),
            ],
            _calendar(),
            _recentSessions(),
            _daySessions(),
          ],
        ),
      ),
    );
  }
}

class _Session {
  final String name;
  final DateTime date;
  final List<FlSpot> pulse1;
  final List<FlSpot> pulse2;
  final List<FlSpot> resistance;
  final List<FlSpot> dPulse1;
  final List<FlSpot> dPulse2;
  final int durationInSeconds;
  List<String> notes;

  _Session({
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

// Экспорт PDF
Future<void> exportToPdf(BuildContext context, _Session session) async {
  final fontData = await rootBundle.load("assets/fonts/Roboto.ttf");
  final ttf = pw.Font.ttf(fontData);

  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text('SenseFlow, сессия: ${session.date}',
              style: pw.TextStyle(font: ttf, fontSize: 20)),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Пульс 1', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.Bullet(text: 'Среднее: ${Statistics.calculate(session.pulse1).mean.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
        pw.Bullet(text: 'Макс: ${Statistics.calculate(session.pulse1).max.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
        pw.Bullet(text: 'Мин: ${Statistics.calculate(session.pulse1).min.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
        pw.SizedBox(height: 12),
        pw.Text('Пульс 2', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.Bullet(text: 'Среднее: ${Statistics.calculate(session.pulse2).mean.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
        pw.Bullet(text: 'Макс: ${Statistics.calculate(session.pulse2).max.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
        pw.Bullet(text: 'Мин: ${Statistics.calculate(session.pulse2).min.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
        pw.SizedBox(height: 12),
        pw.Text('Сопротивление', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.Bullet(text: 'Среднее: ${Statistics.calculate(session.resistance).mean.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
        pw.Bullet(text: 'Макс: ${Statistics.calculate(session.resistance).max.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
        pw.Bullet(text: 'Мин: ${Statistics.calculate(session.resistance).min.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
        pw.SizedBox(height: 20),
        if (session.notes.isNotEmpty)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Заметки:', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
              ...session.notes.map((n) => pw.Bullet(text: n, style: pw.TextStyle(font: ttf))),
            ],
          ),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}

class Statistics {
  final double mean;
  final double stdDev;
  final double min;
  final double max;
  final double median;
  final double variance;
  final double range;
  final double mode;
  final double q1;
  final double q3;
  final double cv;
  final double skewness;
  final double kurtosis;
  final double iqr;
  final double sem;
  final double rsd;
  final double p10;
  final double p90;
  final List<double> outliers;
  final double sdnn;
  final double rmssd;
  final double pnn50;
  final double stabilityCoeff;
  final double stabilityIndex;
  final double linearTrend;
  final double quadraticTrend;

  Statistics({
    required this.mean,
    required this.stdDev,
    required this.min,
    required this.max,
    required this.median,
    required this.variance,
    required this.range,
    required this.mode,
    required this.q1,
    required this.q3,
    required this.cv,
    required this.skewness,
    required this.kurtosis,
    required this.iqr,
    required this.sem,
    required this.rsd,
    required this.p10,
    required this.p90,
    required this.outliers,
    required this.sdnn,
    required this.rmssd,
    required this.pnn50,
    required this.stabilityCoeff,
    required this.stabilityIndex,
    required this.linearTrend,
    required this.quadraticTrend,
  });

  static Statistics calculate(List<FlSpot> data) {
    if (data.isEmpty) {
      return Statistics(
        mean: 0, stdDev: 0, min: 0, max: 0, median: 0,
        variance: 0, range: 0, mode: 0, q1: 0, q3: 0, cv: 0,
        skewness: 0, kurtosis: 0, iqr: 0, sem: 0, rsd: 0,
        p10: 0, p90: 0, outliers: [],
        sdnn: 0, rmssd: 0, pnn50: 0, stabilityCoeff: 0,
        stabilityIndex: 0, linearTrend: 0, quadraticTrend: 0
      );
    }

    final values = data.map((e) => e.y).toList()..sort();
    
    final sum = values.reduce((a, b) => a + b);
    final mean = sum / values.length;
    
    final squaredDiffs = values.map((x) => pow(x - mean, 2)).toList();
    final variance = squaredDiffs.reduce((a, b) => a + b) / values.length;
    final stdDev = sqrt(variance);
    
    final min = values.first;
    final max = values.last;
    final range = max - min;
    
    final median = values.length % 2 == 0
        ? (values[values.length ~/ 2 - 1] + values[values.length ~/ 2]) / 2
        : values[values.length ~/ 2];

    // Calculate quartiles and percentiles
    final q1 = values[values.length ~/ 4];
    final q3 = values[(3 * values.length) ~/ 4];
    final p10 = values[values.length ~/ 10];
    final p90 = values[(9 * values.length) ~/ 10];
    final iqr = q3 - q1;

    // Calculate mode
    final valueCounts = <double, int>{};
    for (var value in values) {
      valueCounts[value] = (valueCounts[value] ?? 0) + 1;
    }
    final mode = valueCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Calculate coefficient of variation
    final cv = mean != 0 ? (stdDev / mean) * 100 : 0.0;

    // Calculate skewness
    final cubedDiffs = values.map((x) => pow(x - mean, 3)).toList();
    final skewness = (cubedDiffs.reduce((a, b) => a + b) / values.length) / pow(stdDev, 3);

    // Calculate kurtosis
    final fourthDiffs = values.map((x) => pow(x - mean, 4)).toList();
    final kurtosis = (fourthDiffs.reduce((a, b) => a + b) / values.length) / pow(variance, 2) - 3;

    // Calculate standard error of mean
    final sem = stdDev / sqrt(values.length);

    // Calculate relative standard deviation
    final rsd = stdDev / mean * 100;

    // Find outliers using z-score method
    final outliers = values.where((x) => (x - mean).abs() > 2 * stdDev).toList();

    // Расчет SDNN (стандартное отклонение NN интервалов)
    final sdnn = stdDev;

    // Расчет RMSSD
    double sumSquaredDiffs = 0;
    for (int i = 1; i < values.length; i++) {
      sumSquaredDiffs += pow(values[i] - values[i-1], 2);
    }
    final rmssd = sqrt(sumSquaredDiffs / (values.length - 1));

    // Расчет pNN50
    int nn50Count = 0;
    for (int i = 1; i < values.length; i++) {
      if ((values[i] - values[i-1]).abs() > 50) {
        nn50Count++;
      }
    }
    final pnn50 = (nn50Count / (values.length - 1)) * 100;

    // Расчет коэффициента стабильности
    final stabilityCoeff = min / max;

    // Расчет индекса стабильности
    final stabilityIndex = mean / stdDev;

    // Расчет линейного тренда
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < values.length; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumX2 += i * i;
    }
    final n = values.length.toDouble();
    final linearTrend = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);

    // Расчет квадратичного тренда
    double sumX3 = 0, sumX4 = 0, sumX2Y = 0;
    for (int i = 0; i < values.length; i++) {
      sumX3 += i * i * i;
      sumX4 += i * i * i * i;
      sumX2Y += i * i * values[i];
    }
    final quadraticTrend = (n * sumX2Y - sumX2 * sumY) / (n * sumX4 - sumX2 * sumX2);

    return Statistics(
      mean: mean,
      stdDev: stdDev,
      min: min,
      max: max,
      median: median,
      variance: variance,
      range: range,
      mode: mode,
      q1: q1,
      q3: q3,
      cv: cv.toDouble(),
      skewness: skewness.toDouble(),
      kurtosis: kurtosis.toDouble(),
      iqr: iqr,
      sem: sem,
      rsd: rsd,
      p10: p10,
      p90: p90,
      outliers: outliers,
      sdnn: sdnn,
      rmssd: rmssd,
      pnn50: pnn50,
      stabilityCoeff: stabilityCoeff,
      stabilityIndex: stabilityIndex,
      linearTrend: linearTrend,
      quadraticTrend: quadraticTrend,
    );
  }
}

class _StatisticsWidget extends StatefulWidget {
  final Statistics stats;
  final String? title;

  const _StatisticsWidget({
    required this.stats,
    this.title,
  });

  @override
  State<_StatisticsWidget> createState() => _StatisticsWidgetState();
}

class _StatisticsWidgetState extends State<_StatisticsWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.title ?? 'Статистика'),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Основные показатели:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildStatRow('Среднее', widget.stats.mean),
                  _buildStatRow('Медиана', widget.stats.median),
                  _buildStatRow('Мода', widget.stats.mode),
                  _buildStatRow('Мин', widget.stats.min),
                  _buildStatRow('Макс', widget.stats.max),
                  _buildStatRow('Размах', widget.stats.range),
                  const Divider(),
                  const Text('Меры разброса:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildStatRow('Станд. откл.', widget.stats.stdDev),
                  _buildStatRow('Дисперсия', widget.stats.variance),
                  _buildStatRow('Станд. ошибка', widget.stats.sem),
                  _buildStatRow('Коэф. вариации', widget.stats.cv, suffix: '%'),
                  _buildStatRow('Отн. ст. откл.', widget.stats.rsd, suffix: '%'),
                  const Divider(),
                  const Text('Квартили и процентили:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildStatRow('Q1 (25%)', widget.stats.q1),
                  _buildStatRow('Q3 (75%)', widget.stats.q3),
                  _buildStatRow('IQR', widget.stats.iqr),
                  _buildStatRow('P10', widget.stats.p10),
                  _buildStatRow('P90', widget.stats.p90),
                  const Divider(),
                  const Text('Форма распределения:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildStatRow('Асимметрия', widget.stats.skewness),
                  _buildStatRow('Эксцесс', widget.stats.kurtosis),
                  const Divider(),
                  const Text('Показатели ВСР:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildStatRow('SDNN', widget.stats.sdnn),
                  _buildStatRow('RMSSD', widget.stats.rmssd),
                  _buildStatRow('pNN50', widget.stats.pnn50, suffix: '%'),
                  const Divider(),
                  const Text('Показатели стабильности:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildStatRow('Коэф. стабильности', widget.stats.stabilityCoeff),
                  _buildStatRow('Индекс стабильности', widget.stats.stabilityIndex),
                  const Divider(),
                  const Text('Показатели тренда:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildStatRow('Линейный тренд', widget.stats.linearTrend),
                  _buildStatRow('Квадратичный тренд', widget.stats.quadraticTrend),
                  if (widget.stats.outliers.isNotEmpty) ...[
                    const Divider(),
                    const Text('Выбросы:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Найдено выбросов: ${widget.stats.outliers.length}'),
                    Text('Значения: ${widget.stats.outliers.map((e) => e.toStringAsFixed(2)).join(", ")}'),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double value, {String? suffix}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${value.toStringAsFixed(2)}${suffix ?? ''}',
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}


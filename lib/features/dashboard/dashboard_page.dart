import 'package:flutter/material.dart';
import '../../services/data_loader.dart';
import '../../models/session.dart';
import '../../theme/neon_colors.dart';
import '../../utils/chart_colors.dart';
import 'widgets/graphs.dart';
import 'widgets/calendar_panel.dart';
import 'widgets/recent_sessions.dart';
import 'widgets/day_sessions.dart';
import 'widgets/notes_block.dart';
import '../profile/profile_page.dart';
import '../compare/compare_page.dart';
import '../settings/settings_page.dart';
import 'widgets/ai_summary.dart';


class DashboardPage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  const DashboardPage({super.key, required this.themeNotifier});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final repo = SessionRepository();
  List<Session> sessions = [];
  Session? current;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  List<Session> sessionsForSelectedDay = [];
  final chartColors = ChartColors();  // This should work now with the proper import

  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final loaded = await repo.pickAndLoadSessions();
    if (loaded.isEmpty) return;

    setState(() {
      sessions = loaded;
      current = sessions.first;
      _filterSessionsByDay(selectedDay);
    });
  }

  void _filterSessionsByDay(DateTime day) {
    setState(() {
      selectedDay = day;
      focusedDay = day;
      sessionsForSelectedDay = sessions.where((s) =>
        s.date.year == day.year && 
        s.date.month == day.month && 
        s.date.day == day.day
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 800;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0C1320),
        title: const Text('SenseFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Загрузить файлы',
            onPressed: _loadSessions,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Руководство пользователя',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Руководство пользователя'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('1. Нажмите кнопку "Загрузить файлы" для выбора файлов сессий'),
                        SizedBox(height: 8),
                        Text('2. Выберите сессию в правой панели для просмотра графиков'),
                        SizedBox(height: 8),
                        Text('3. Используйте календарь для фильтрации сессий по дате'),
                        SizedBox(height: 8),
                        Text('4. Добавляйте заметки к сессиям'),
                        SizedBox(height: 8),
                        Text('5. Используйте фильтры для анализа графиков'),
                        SizedBox(height: 8),
                        Text('6. Экспортируйте отчет в PDF'),
                        SizedBox(height: 8),
                        Text('7. Сравнивайте сессии в режиме сравнения'),
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
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Личный кабинет',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ProfilePage(
                  themeNotifier: widget.themeNotifier,
                  totalSessions: sessions.length,
                  lastSessionDate: sessions.isNotEmpty ? sessions.first.date : null,
                ),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: 'Сравнить сессии',
            onPressed: () {
              if (sessions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Сначала загрузите сессии')),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ComparePage(sessions: sessions)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Настройки',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SettingsPage(themeNotifier: widget.themeNotifier)),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (current != null) ...[
                    // AI Summary
                    AiSummaryCard(session: current),
                    const SizedBox(height: 16),
                    // Graphs
                    SessionGraphs(session: current!, colors: chartColors),
                    const SizedBox(height: 16),
                    // Notes
                    NotesBlock(
                      session: current,
                      onChanged: (notes) {
                        setState(() {
                          // Create new session with updated notes
                          current = Session(
                            name: current!.name,
                            date: current!.date,
                            pulse1: current!.pulse1,
                            pulse2: current!.pulse2,
                            resistance: current!.resistance,
                            dPulse1: current!.dPulse1,
                            dPulse2: current!.dPulse2,
                            durationInSeconds: current!.durationInSeconds,
                            notes: notes,
                          );
                          
                          // Update session in the list
                          final idx = sessions.indexWhere((s) => s.name == current!.name);
                          if (idx != -1) {
                            sessions[idx] = current!;
                            // Update filtered sessions if needed
                            if (sessionsForSelectedDay.isNotEmpty) {
                              final dayIdx = sessionsForSelectedDay.indexWhere(
                                (s) => s.name == current!.name
                              );
                              if (dayIdx != -1) {
                                sessionsForSelectedDay[dayIdx] = current!;
                              }
                            }
                          }
                        });
                      },
                    ),
                  ] else
                    const Center(
                      child: Text('Выберите сессию для просмотра'),
                    ),
                ],
              ),
            ),
          ),
          if (isWide)
            SizedBox(
              width: 300,
              child: Card(
                margin: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(),
                child: Column(
                  children: [
                    CalendarPanel(
                      focusedDay: focusedDay,
                      selectedDay: selectedDay,
                      onDaySelected: (sel, foc) {
                        setState(() {
                          selectedDay = sel;
                          focusedDay = foc;
                          _filterSessionsByDay(sel);
                        });
                      },
                    ),
                    Expanded(
                      child: sessionsForSelectedDay.isEmpty
                          ? RecentSessions(
                              sessions: sessions,
                              currentSessionName: current?.name,
                              onTap: (s) => setState(() => current = s),
                            )
                          : DaySessions(
                              sessionsForDay: sessionsForSelectedDay,
                              currentSessionName: current?.name,
                              onTap: (s) => setState(() => current = s),
                            ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}


class SessionGraphs extends StatelessWidget {
  final Session session;
  final ChartColors colors;

  const SessionGraphs({
    Key? key,
    required this.session,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (session.pulse1.isNotEmpty)
          SingleGraphCard(
            title: 'Пульс 1',
            data: session.pulse1,
            color: colors.pulse1(context),
            isResistance: false,
            currentSession: session,
          ),
        if (session.pulse2.isNotEmpty)
          SingleGraphCard(
            title: 'Пульс 2',
            data: session.pulse2,
            color: colors.pulse2(context),
            isResistance: false,
            currentSession: session,
          ),
        if (session.resistance.isNotEmpty)
          SingleGraphCard(
            title: 'Сопротивление',
            data: session.resistance,
            color: colors.resistance(context),
            isResistance: true,
            currentSession: session,
          ),
        if (session.dPulse1.isNotEmpty && session.dPulse2.isNotEmpty)
          DoubleGraphCard(
            title: 'Дополнительные показания',
            data1: session.dPulse1,
            data2: session.dPulse2,
            color1: colors.dPulse1(context),
            color2: colors.dPulse2(context),
            currentSession: session,
          ),
      ],
    );
  }
}

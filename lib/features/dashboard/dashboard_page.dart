import 'package:flutter/material.dart';
import '../../services/data_loader.dart';
import '../../models/session.dart';
import '../../widgets/neon_hover_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 800;
    final hasData = current != null && (current!.pulse1.isNotEmpty || current!.pulse2.isNotEmpty || current!.resistance.isNotEmpty);

    final darkBg = const RadialGradient(
      center: Alignment(-0.6, -0.8), radius: 1.2,
      colors: [kBgDark, kBgDark, Color(0xFF0C1320)], stops: [0.0, 0.7, 1.0],
    );
    final lightBg = const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFFF9FBFF), Color(0xFFF0F5FE)],
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color( 0xFF0C1320),
        title: const Text('SenseFlow'),
        actions: [
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
              if (sessions.length < 1) {
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
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(gradient: isDark ? darkBg : lightBg),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 100, 12, 24),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              NeonHoverButton(
                                onPressed: () async {
                                  final loaded = await repo.pickAndLoadSessions();
                                  if (loaded.isEmpty) return;
                                  setState(() {
                                    sessions = loaded;
                                    current = sessions.first;
                                    _filterSessionsByDay(selectedDay);
                                  });
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [Icon(Icons.file_upload, color: Colors.white), SizedBox(width: 8), Text('Добавить файлы', style: TextStyle(color: Colors.white))],
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () => _showHelpDialog(context),
                                child: const Text('Как пользоваться'),
                              ),
                            ],
                          ),
                          if (current != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                current!.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (hasData) ...[
                            AiSummaryCard(session: current),
                            const SizedBox(height: 12),
                            SingleGraphCard(
                              title: 'Пульс 1',
                              data: current!.pulse1,
                              color: pulse1Color(context),
                              isResistance: false,
                              currentSession: current,
                            ),
                            SingleGraphCard(
                              title: 'Пульс 2',
                              data: current!.pulse2,
                              color: pulse2Color(context),
                              isResistance: false,
                              currentSession: current,
                            ),
                            SingleGraphCard(
                              title: 'Сопротивление',
                              data: current!.resistance,
                              color: resistanceColor(context),
                              isResistance: true,
                              currentSession: current,
                            ),
                            DoubleGraphCard(
                              title: 'Дополнительные Показания',
                              data1: current!.dPulse1,
                              data2: current!.dPulse2,
                              color1: pulse1Color(context),
                              color2: pulse2Color(context),
                              currentSession: current,
                            ),
                            NotesBlock(
                              session: current,
                              onChanged: (_) => setState((){}),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        CalendarPanel(
                          focusedDay: focusedDay,
                          selectedDay: selectedDay,
                          onDaySelected: (sel, foc) {
                            setState(() {
                              selectedDay = sel; focusedDay = foc; _filterSessionsByDay(sel);
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        RecentSessions(
                          sessions: sessions,
                          currentSessionName: current?.name,
                          onTap: (s) => setState(()=> current = s),
                        ),
                        const SizedBox(height: 12),
                        DaySessions(
                          sessionsForDay: sessionsForSelectedDay,
                          currentSessionName: current?.name,
                          onTap: (s) => setState(()=> current = s),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: NeonHoverButton(
                            onPressed: () async {
                              final loaded = await repo.pickAndLoadSessions();
                              if (loaded.isEmpty) return;
                              setState(() {
                                sessions = loaded;
                                current = sessions.first;
                                _filterSessionsByDay(selectedDay);
                              });
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [Icon(Icons.upload_file, color: Colors.white), SizedBox(width: 8), Text('Добавить файлы', style: TextStyle(color: Colors.white))],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(onPressed: () => _showHelpDialog(context), child: const Text('Как пользоваться')),
                      ],
                    ),
                    if (current != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          current!.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (hasData) ...[
                      AiSummaryCard(session: current),
                      const SizedBox(height: 12),
                    ],
                    if (hasData) ...[
                      SingleGraphCard(title: 'Пульс 1', data: current!.pulse1, color: pulse1Color(context), isResistance: false, currentSession: current),
                      SingleGraphCard(title: 'Пульс 2', data: current!.pulse2, color: pulse2Color(context), isResistance: false, currentSession: current),
                      SingleGraphCard(title: 'Сопротивление', data: current!.resistance, color: resistanceColor(context), isResistance: true, currentSession: current),
                      DoubleGraphCard(title: 'Дополнительные Показания', data1: current!.dPulse1, data2: current!.dPulse2, color1: pulse1Color(context), color2: pulse2Color(context), currentSession: current),
                      NotesBlock(session: current, onChanged: (_)=>setState((){})),
                    ],
                    CalendarPanel(focusedDay: focusedDay, selectedDay: selectedDay, onDaySelected: (sel,foc){ setState(()=>{selectedDay=sel, focusedDay=foc}); _filterSessionsByDay(sel); }),
                    RecentSessions(sessions: sessions, currentSessionName: current?.name, onTap: (s)=>setState(()=> current=s)),
                    DaySessions(sessionsForDay: sessionsForSelectedDay, currentSessionName: current?.name, onTap: (s)=>setState(()=> current=s)),
                  ],
                ),
        ),
      ),
    );
  }

  void _filterSessionsByDay(DateTime day) {
    sessionsForSelectedDay = sessions.where((s)=>
      s.date.year==day.year && s.date.month==day.month && s.date.day==day.day
    ).toList();
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Как пользоваться SenseFlow'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Нажмите на «Добавить файлы» и выберите .txt с измерениями.'),
              SizedBox(height: 8),
              Text('2. Переключайтесь между сеансами в боковых панелях.'),
              SizedBox(height: 8),
              Text('3. Выбирайте день в календаре для фильтра.'),
              SizedBox(height: 8),
              Text('4. Добавляйте заметки и экспортируйте PDF.'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Понятно'))],
      ),
    );
  }
}

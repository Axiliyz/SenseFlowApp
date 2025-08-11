import 'package:flutter/material.dart';
import '../../widgets/neon_card.dart';

class ProfilePage extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  final int totalSessions;
  final DateTime? lastSessionDate;

  const ProfilePage({
    super.key,
    required this.themeNotifier,
    required this.totalSessions,
    required this.lastSessionDate,
  });

  @override
  Widget build(BuildContext context) {
    final on = Theme.of(context).colorScheme.onSurface;

    String lastStr = lastSessionDate != null
        ? '${lastSessionDate!.day.toString().padLeft(2,'0')}.'
          '${lastSessionDate!.month.toString().padLeft(2,'0')}.'
          '${lastSessionDate!.year} '
          '${lastSessionDate!.hour.toString().padLeft(2,'0')}:'
          '${lastSessionDate!.minute.toString().padLeft(2,'0')}'
        : 'Нет данных';

    return Scaffold(
      appBar: AppBar(title: const Text('Личный кабинет')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        child: Column(
          children: [
            NeonCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.25),
                    child: Text('SF', style: TextStyle(color: on, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Пользователь SenseFlow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: on)),
                        const SizedBox(height: 6),
                        Text('user@senseflow.app', style: TextStyle(color: on.withOpacity(0.7))),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Редактировать'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            NeonCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: _StatTile(label: 'Всего сеансов', value: '$totalSessions')),
                    const SizedBox(width: 12),
                    Expanded(child: _StatTile(label: 'Последний сеанс', value: lastStr)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            NeonCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Тема и интерфейс', style: TextStyle(fontWeight: FontWeight.w700, color: on)),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.brightness_6),
                      title: const Text('Переключить светлую/тёмную тему'),
                      trailing: Switch(
                        value: Theme.of(context).brightness == Brightness.dark,
                        onChanged: (_) {
                          themeNotifier.value =
                            themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            NeonCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Аккаунт', style: TextStyle(fontWeight: FontWeight.w700, color: on)),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.logout),
                      title: const Text('Выйти из аккаунта'),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final on = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: on.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: on.withOpacity(0.7))),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: on)),
        ],
      ),
    );
  }
}

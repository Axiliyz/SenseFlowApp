import 'package:flutter/material.dart';
import '../../widgets/neon_card.dart';

class SettingsPage extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  const SettingsPage({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    final on = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        child: Column(
          children: [
            NeonCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Тема', style: TextStyle(fontWeight: FontWeight.w700, color: on)),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.brightness_6),
                      title: const Text('Тёмная тема'),
                      trailing: Switch(
                        value: themeNotifier.value == ThemeMode.dark,
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
                    Text('Обучение', style: TextStyle(fontWeight: FontWeight.w700, color: on)),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Как пользоваться приложением'),
                      onTap: () => _showHelpDialog(context),
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Как пользоваться SenseFlow'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Нажмите «Добавить файлы» и выберите .txt с измерениями.'),
              SizedBox(height: 8),
              Text('2. Переключайтесь между сеансами в боковых панелях.'),
              SizedBox(height: 8),
              Text('3. Выберите день в календаре, чтобы отфильтровать сессии.'),
              SizedBox(height: 8),
              Text('4. Добавляйте заметки и экспортируйте PDF.'),
              SizedBox(height: 8),
              Text('5. Откройте «Сравнение» для наложения двух сессий.'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Понятно'))],
      ),
    );
  }
}

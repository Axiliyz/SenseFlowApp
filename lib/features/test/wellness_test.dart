import 'package:flutter/material.dart';
import '../../models/session.dart';

Future<void> showWellnessTestDialog({
  required BuildContext context,
  required Session session,
  required ValueChanged<List<String>> onSaved,
}) async {
  final questions = <Map<String, dynamic>>[
    {'q':'Общее состояние:','o':['Отлично','Хорошо','Нормально','Плохо','Очень плохо']},
    {'q':'Стресс:','o':['Отсутствует','Лёгкий','Умеренный','Высокий','Критический']},
    {'q':'Сон:','o':['Отличный','Хороший','Нормальный','Плохой','Бессонница']},
    {'q':'Физическая активность:','o':['Высокая','Умеренная','Низкая','Сидячая','Постельный режим']},
    {'q':'Лекарства:','o':['Нет','Витамины','Обезболивающие','Рецептурные','Другое']},
    {'q':'Кофеин:','o':['Нет','1 чашка','2–3 чашки','4–5 чашек','>5 чашек']},
    {'q':'Последний приём пищи:','o':['<1 часа','1–2 часа','2–4 часа','4–6 часов','>6 часов']},
    {'q':'Нагрузки:','o':['Нет','Лёгкая','Умеренная','Интенсивная','Тяжёлая']},
  ];
  final answers = List<String>.filled(questions.length, '');

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Тест самочувствия', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < questions.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${i + 1}. ${questions[i]['q']}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8, runSpacing: 6,
                          children: [
                            for (final opt in (questions[i]['o'] as List<String>))
                              ChoiceChip(
                                label: Text(opt, style: const TextStyle(fontSize: 12)),
                                selected: answers[i] == opt,
                                onSelected: (sel) => setDialogState(()=> answers[i] = sel ? opt : ''),
                                backgroundColor: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800] : const Color(0xFFEFF5FF),
                                selectedColor: Theme.of(context).colorScheme.secondary,
                                labelStyle: TextStyle(
                                  color: answers[i] == opt
                                      ? Colors.black
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: Text('Отмена',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)))),
          ElevatedButton(
            onPressed: answers.every((a)=>a.isNotEmpty) ? () {
              final lines = <String>[];
              for (int i=0;i<questions.length;i++) {
                lines.add('${questions[i]['q']} ${answers[i]}');
              }
              session.notes = [...session.notes, ...lines];
              onSaved(session.notes);
              Navigator.pop(context);
            } : null,
            child: const Text('Сохранить'),
          ),
        ],
      ),
    ),
  );
}

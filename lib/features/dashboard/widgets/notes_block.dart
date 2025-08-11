import 'package:flutter/material.dart';
import '../../../../models/session.dart';
import '../../../../widgets/neon_card.dart';
import '../../../../services/pdf_export.dart';
import '../../../../widgets/neon_hover_button.dart';
import '../../test/wellness_test.dart';

class NotesBlock extends StatefulWidget {
  final Session? session;
  final void Function(List<String> notes) onChanged;
  const NotesBlock({super.key, required this.session, required this.onChanged});

  @override
  State<NotesBlock> createState() => _NotesBlockState();
}

class _NotesBlockState extends State<NotesBlock> {
  final _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    if (s == null) return const SizedBox.shrink();

    Widget chip(String t) => ActionChip(
      label: Text(t, style: const TextStyle(fontSize: 12)),
      onPressed: () { setState(() { s.notes = [...s.notes, t]; }); widget.onChanged(s.notes); },
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.06)
          : const Color(0xFFEFF5FF),
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );

    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Заметки', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Быстрые заметки:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              chip('До нагрузки'), chip('После нагрузки'), chip('Перед сном'), chip('После сна'),
              chip('Усталость'), chip('Хорошее самочувствие'), chip('Стресс'), chip('Отдых'),
              chip('Дождь'), chip('Пасмурно'), chip('Хорошая погода'), 
              chip('Перед едой'), chip('После еды'), 
            ],
          ),
          const SizedBox(height: 20),
          Text('Система тестирования:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.quiz, color: Colors.white),
            label: const Text('Пройти тест', style: TextStyle(color: Colors.white)),
            onPressed: () => showWellnessTestDialog(
              context: context,
              session: s,
              onSaved: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 16),
          Text('Добавить заметку:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Введите заметку и нажмите Enter...'),
            onSubmitted: (text) {
              if (text.trim().isEmpty) return;
              setState(() {
                s.notes = [...s.notes, text.trim()];
                _controller.clear();
              });
              widget.onChanged(s.notes);
            },
          ),
          const SizedBox(height: 12),
          if (s.notes.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ваши заметки:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (int i=0;i<s.notes.length;i++)
                  ListTile(
                    title: Text(s.notes[i]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        setState(()=> s.notes.removeAt(i));
                        widget.onChanged(s.notes);
                      },
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          NeonHoverButton(
            onPressed: () => exportToPdf(context, s),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.picture_as_pdf, color: Colors.white), SizedBox(width: 8), Text('Экспорт в PDF', style: TextStyle(color: Colors.white))],
            ),
          ),
        ],
      ),
    );
  }
}

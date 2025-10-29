import 'package:flutter/material.dart';
import '../../../../models/session.dart';
import '../../../../widgets/neon_card.dart';
import '../../../../services/pdf_export.dart';
import '../../../../services/txt_table_export.dart';
import '../../../../services/raw_files_store.dart';
import '../../../../services/export_service.dart';
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
  final _export = const ExportService();

  List<List<dynamic>> _buildRowsForExport(Session s) {
    // синхронизируем по индексу, время в секундах по длительности сессии
    final p1 = s.pulse1;
    final p2 = s.pulse2;
    final n = [p1.length, p2.length].reduce((a,b)=> a>b?a:b);
    if (n == 0) return [];
    final dur = s.durationInSeconds <= 0 ? n - 1 : s.durationInSeconds;
    double secAt(int i, int len) {
      if (len <= 1) return 0;
      return dur * i / (len - 1);
    }
    final rows = <List<dynamic>>[];
    for (var i=0; i<n; i++) {
      final t = secAt(i, n).round();
      final v1 = i < p1.length ? p1[i].y : null;
      final v2 = i < p2.length ? p2[i].y : null;
      rows.add([t, v1, v2]);
    }
    return rows;
  }

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.session == null) return const SizedBox.shrink();

    return NeonCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Заметки', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () => exportToPdf(context, widget.session!),
                      tooltip: 'Экспорт в PDF',
                    ),
                    SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.table_view),
                      tooltip: 'Экспорт в CSV',
                      onPressed: widget.session == null ? null : () async {
                        final name = widget.session!.name;
                        final bytes = RawFilesStore.get('$name') ?? RawFilesStore.get('$name.txt');
                        if (bytes != null) {
                          await const TxtTableExport().exportBytesToCsv(
                            bytes: bytes,
                            fileBase: 'session_${name}_from_txt',
                          );
                        } else {
                          // fallback: build from Session rows
                          final headers = ['Time (s)','Pulse1','Pulse2'];
                          final rows = _buildRowsForExport(widget.session!);
                          await _export.exportCsv(
                            fileNameWithoutExt: 'session_${name}',
                            headers: headers,
                            rows: rows,
                          );
                        }
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV сохранён')));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.grid_on),
                      tooltip: 'Экспорт в XLSX',
                      onPressed: widget.session == null ? null : () async {
                        final name = widget.session!.name;
                        final bytes = RawFilesStore.get('$name') ?? RawFilesStore.get('$name.txt');
                        if (bytes != null) {
                          await const TxtTableExport().exportBytesToXlsx(
                            bytes: bytes,
                            fileBase: 'session_${name}_from_txt',
                          );
                        } else {
                          final headers = ['Time (s)','Pulse1','Pulse2'];
                          final rows = _buildRowsForExport(widget.session!);
                          await _export.exportXlsx(
                            fileNameWithoutExt: 'session_${name}',
                            headers: headers,
                            rows: rows,
                            sheetName: 'Session',
                          );
                        }
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('XLSX сохранён')));
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.session!.notes.isNotEmpty) ...[
              ...widget.session!.notes.map((note) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text('• $note')),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        final notes = List<String>.from(widget.session!.notes);
                        notes.remove(note);
                        widget.onChanged(notes);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 16),
            ],
            // Quick note buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                NeonHoverButton(
                  onPressed: () => _addNote('Хорошее самочувствие'),
                  child: const Text('👍 Хорошо'),
                ),
                NeonHoverButton(
                  onPressed: () => _addNote('Среднее самочувствие'),
                  child: const Text('😐 Средне'),
                ),
                NeonHoverButton(
                  onPressed: () => _addNote('Плохое самочувствие'),
                  child: const Text('👎 Плохо'),
                ),
                NeonHoverButton(
                  onPressed: () => _addNote('Был стресс'),
                  child: const Text('😰 Стресс'),
                ),
                NeonHoverButton(
                  onPressed: () => _addNote('После тренировки'),
                  child: const Text('🏃 Тренировка'),
                ),
                NeonHoverButton(
                  onPressed: () => _addNote('После еды'),
                  child: const Text('🍽️ После еды'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Wellness test button
            NeonHoverButton(
              onPressed: () {
                showWellnessTestDialog(
                  context: context,
                  session: widget.session!,
                  onSaved: widget.onChanged,
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.quiz),
                  SizedBox(width: 8),
                  Text('Пройти тест самочувствия'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Add note input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Добавить заметку...',
                      isDense: true,
                    ),
                    onSubmitted: (text) {
                      if (text.isNotEmpty) {
                        _addNote(text);
                        _controller.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _addNote(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addNote(String note) {
    if (widget.session != null) {
      final notes = List<String>.from(widget.session!.notes);
      if (!notes.contains(note)) {
        setState(() {
          notes.add(note);
          widget.onChanged(notes);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// GENERATED: Reusable export buttons (CSV/XLSX + optional PDF)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/export_service.dart';

typedef PdfExportCallback = Future<void> Function();

class ExportButtons extends StatelessWidget {
  final List<String> headers;
  final List<List<dynamic>> rows;
  final String fileNamePrefix;
  final String sheetName;
  final bool openAfterSave;
  final PdfExportCallback? onExportPdf; // проброс существующей логики PDF

  const ExportButtons({
    super.key,
    required this.headers,
    required this.rows,
    this.fileNamePrefix = 'export',
    this.sheetName = 'Data',
    this.openAfterSave = true,
    this.onExportPdf,
  });

  String _timestamp() {
    final now = DateTime.now();
    return DateFormat("yyyy-MM-dd'T'HH-mm-ss").format(now); // безопасно для имён файлов
  }

  @override
  Widget build(BuildContext context) {
    final export = const ExportService();
    final base = '${fileNamePrefix}_' + _timestamp();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.table_view),
          label: const Text('CSV'),
          onPressed: () async {
            await export.exportCsv(
              fileNameWithoutExt: base,
              headers: headers,
              rows: rows,
              openAfterSave: openAfterSave,
            );
            _snack(context, 'CSV сохранён');
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.grid_on),
          label: const Text('XLSX'),
          onPressed: () async {
            await export.exportXlsx(
              fileNameWithoutExt: base,
              headers: headers,
              rows: rows,
              sheetName: sheetName,
              openAfterSave: openAfterSave,
            );
            _snack(context, 'XLSX сохранён');
          },
        ),
        if (onExportPdf != null)
          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('PDF'),
            onPressed: () async {
              await onExportPdf!();
              _snack(context, 'PDF сохранён');
            },
          ),
        PopupMenuButton<String>(
          tooltip: 'Экспорт...',
          onSelected: (v) async {
            switch (v) {
              case 'csv':
                await export.exportCsv(
                  fileNameWithoutExt: base,
                  headers: headers,
                  rows: rows,
                  openAfterSave: openAfterSave,
                );
                _snack(context, 'CSV сохранён');
                break;
              case 'xlsx':
                await export.exportXlsx(
                  fileNameWithoutExt: base,
                  headers: headers,
                  rows: rows,
                  sheetName: sheetName,
                  openAfterSave: openAfterSave,
                );
                _snack(context, 'XLSX сохранён');
                break;
              case 'pdf':
                if (onExportPdf != null) {
                  await onExportPdf!();
                  _snack(context, 'PDF сохранён');
                }
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'csv', child: Text('Экспорт в CSV')),
            const PopupMenuItem(value: 'xlsx', child: Text('Экспорт в XLSX')),
            if (onExportPdf != null)
              const PopupMenuItem(value: 'pdf', child: Text('Экспорт в PDF')),
          ],
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Icon(Icons.more_vert),
          ),
        ),
      ],
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

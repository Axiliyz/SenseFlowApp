// GENERATED: TXT → CSV/XLSX converter (preserves all original columns/rows)
import 'dart:convert';
import 'dart:typed_data';

import 'export_service.dart';

/// Converts a plain-text table (.txt) into CSV/XLSX without losing columns.
/// - Auto-detects delimiter: tab, semicolon, comma or multiple spaces.
/// - Keeps header row if present (first line).
/// - Pads short rows with empty strings so all lines have equal column count.
class TxtTableExport {
  const TxtTableExport();

  /// Convert bytes (as read from file picker) to CSV.
  Future<void> exportBytesToCsv({
    required Uint8List bytes,
    required String fileBase,
    String? overrideDelimiter,
    bool openAfterSave = true,
  }) async {
    final parsed = _parse(bytes, overrideDelimiter: overrideDelimiter);
    await const ExportService().exportCsv(
      fileNameWithoutExt: fileBase,
      headers: parsed.headers,
      rows: parsed.rows,
      openAfterSave: openAfterSave,
    );
  }

  /// Convert bytes (as read from file picker) to XLSX.
  Future<void> exportBytesToXlsx({
    required Uint8List bytes,
    required String fileBase,
    String? overrideDelimiter,
    bool openAfterSave = true,
  }) async {
    final parsed = _parse(bytes, overrideDelimiter: overrideDelimiter);
    await const ExportService().exportXlsx(
      fileNameWithoutExt: fileBase,
      headers: parsed.headers,
      rows: parsed.rows,
      sheetName: 'FromTXT',
      openAfterSave: openAfterSave,
    );
  }

  /// Convert a raw string to CSV/XLSX (if ты уже прочитал файл как строку).
  Future<void> exportStringToCsv({
    required String content,
    required String fileBase,
    String? overrideDelimiter,
    bool openAfterSave = true,
  }) async {
    final parsed = _parse(utf8.encode(content) as Uint8List, overrideDelimiter: overrideDelimiter);
    await const ExportService().exportCsv(
      fileNameWithoutExt: fileBase,
      headers: parsed.headers,
      rows: parsed.rows,
      openAfterSave: openAfterSave,
    );
  }

  Future<void> exportStringToXlsx({
    required String content,
    required String fileBase,
    String? overrideDelimiter,
    bool openAfterSave = true,
  }) async {
    final parsed = _parse(utf8.encode(content) as Uint8List, overrideDelimiter: overrideDelimiter);
    await const ExportService().exportXlsx(
      fileNameWithoutExt: fileBase,
      headers: parsed.headers,
      rows: parsed.rows,
      sheetName: 'FromTXT',
      openAfterSave: openAfterSave,
    );
  }

  // ---- Internal parsing ----

  _ParsedTable _parse(Uint8List bytes, {String? overrideDelimiter}) {
    // Try UTF-8 with BOM; fallback to latin1 (Windows-1252-ish) if needed.
    String text;
    try {
      text = utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      text = const Latin1Codec().decode(bytes);
    }

    // Normalize newlines
    text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) {
      return const _ParsedTable(headers: <String>[], rows: <List<dynamic>>[]);
    }

    final delimiter = overrideDelimiter ?? _detectDelimiter(lines);

    List<List<String>> rows = [];
    for (final raw in lines) {
      final line = raw.trimRight(); // keep left spaces inside cells if needed
      List<String> cells;
      if (delimiter == r'\s{2,}') {
        // Split by 2+ spaces (preserve single spaces in values)
        cells = line.split(RegExp(r'\s{2,}'));
      } else {
        cells = line.split(delimiter);
      }
      rows.add(cells.map((c) => c.trim()).toList());
    }

    // Normalize column count
    int maxCols = 0;
    for (final r in rows) {
      if (r.length > maxCols) maxCols = r.length;
    }
    for (final r in rows) {
      while (r.length < maxCols) {
        r.add('');
      }
    }

    // Assume first row is header if all cells are non-numeric (heuristic)
    final first = rows.first;
    final isHeader = first.any((c) => !_looksNumeric(c));
    final headers = isHeader
        ? first
        : List<String>.generate(maxCols, (i) => 'Col${i + 1}');

    final dataRows = isHeader ? rows.sublist(1) : rows;

    // Keep as dynamic strings; don't coerce types to avoid data loss
    return _ParsedTable(
      headers: headers,
      rows: dataRows.map((r) => r.cast<dynamic>()).toList(),
    );
  }

  String _detectDelimiter(List<String> lines) {
    // Inspect first 20 non-empty lines
    final sample = lines.take(20).toList();

    Map<String, int> counts = {
      '\t': 0,
      ';': 0,
      ',': 0,
    };
    int spacedHits = 0;

    for (final l in sample) {
      counts.update('\t', (v) => v + _count(l, '\t'), ifAbsent: () => _count(l, '\t'));
      counts.update(';', (v) => v + _count(l, ';'), ifAbsent: () => _count(l, ';'));
      counts.update(',', (v) => v + _count(l, ','), ifAbsent: () => _count(l, ','));
      if (RegExp(r'\S\s{2,}\S').hasMatch(l)) spacedHits++;
    }

    // Prefer tabs, then semicolons, then commas
    final best = [
      ('\t', counts['\t'] ?? 0),
      (';', counts[';'] ?? 0),
      (',', counts[','] ?? 0),
    ]..sort((a, b) => b.$2.compareTo(a.$2));

    if (best.first.$2 > 0) return best.first.$1;
    if (spacedHits > sample.length / 2) return r'\s{2,}';
    // Fallback: single space but beware values with spaces; last resort only
    return r'\s{2,}';
  }

  int _count(String s, String sub) {
    var i = 0, count = 0;
    while (true) {
      final idx = s.indexOf(sub, i);
      if (idx == -1) break;
      count++;
      i = idx + sub.length;
    }
    return count;
  }

  bool _looksNumeric(String s) {
    if (s.isEmpty) return false;
    return double.tryParse(s.replaceAll(',', '.')) != null;
  }
}

class _ParsedTable {
  final List<String> headers;
  final List<List<dynamic>> rows;
  const _ParsedTable({required this.headers, required this.rows});
}

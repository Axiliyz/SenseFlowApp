// GENERATED: Export service for CSV and XLSX
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';

class ExportService {
  const ExportService();

  Future<void> exportCsv({
    required String fileNameWithoutExt,
    required List<String> headers,
    required List<List<dynamic>> rows,
    bool openAfterSave = true,
  }) async {
    final data = <List<dynamic>>[headers, ...rows];

    final converter = const ListToCsvConverter(
      fieldDelimiter: ',',
      textDelimiter: '"',
      textEndDelimiter: '"',
      eol: '\n',
    );

    final csv = converter.convert(data);
    final bom = Uint8List.fromList([0xEF, 0xBB, 0xBF]);
    final bytes = Uint8List.fromList([...bom, ...csv.codeUnits]);

    final path = await _saveBytes(
      bytes: bytes,
      fileName: '$fileNameWithoutExt.csv',
      mimeType: MimeType.other,
    );

    if (openAfterSave && !_isWeb) {
      await OpenFilex.open(path);
    }
  }

  Future<void> exportXlsx({
    required String fileNameWithoutExt,
    required List<String> headers,
    required List<List<dynamic>> rows,
    String sheetName = 'Data',
    bool openAfterSave = true,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel[sheetName];
    sheet.appendRow(headers);
    for (final r in rows) {
      sheet.appendRow(r.map((v) => v ?? '').toList());
    }

    final headerStyle = CellStyle(bold: true);
    for (var c = 0; c < headers.length; c++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.cellStyle = headerStyle;
      _autosizeColumn(sheet, c, [headers, ...rows]);
    }

    final bytes = Uint8List.fromList(excel.encode()!);

    final path = await _saveBytes(
      bytes: bytes,
      fileName: '$fileNameWithoutExt.xlsx',
      mimeType: MimeType.other,
    );

    if (openAfterSave && !_isWeb) {
      await OpenFilex.open(path);
    }
  }

  bool get _isWeb => kIsWeb;

  Future<String> _saveBytes({
    required Uint8List bytes,
    required String fileName,
    required MimeType mimeType,
  }) async {
    final savedPath = await FileSaver.instance.saveFile(
      name: fileName,
      bytes: bytes,
      ext: fileName.split('.').last,
      mimeType: mimeType,
    );
    return savedPath ?? '';
  }

  void _autosizeColumn(Sheet sheet, int colIndex, List<List<dynamic>> table) {
    int maxLen = 0;
    for (var r = 0; r < table.length; r++) {
      final val = (table[r].length > colIndex ? table[r][colIndex] : '').toString();
      if (val.length > maxLen) maxLen = val.length;
    }
    final width = (maxLen * 1.2 + 2).clamp(10, 80).toDouble();
    sheet.setColWidth(colIndex, width);
  }
}

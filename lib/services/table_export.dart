// GENERATED: Export tables directly from parsed .txt (Session)
import 'package:fl_chart/fl_chart.dart';
import '../models/session.dart';
import 'export_service.dart';

class TableExport {
  const TableExport();

  List<String> headers({bool includeResistance = true}) =>
      includeResistance ? const ['Time (s)','Pulse1','Pulse2','Resistance'] : const ['Time (s)','Pulse1','Pulse2'];

  /// Build rows aligned by max length; time based on durationInSeconds (uniform spacing by index).
  List<List<dynamic>> buildRows(Session s, {bool includeResistance = true}) {
    final p1 = s.pulse1;
    final p2 = s.pulse2;
    final r  = s.resistance;
    final n = [p1.length, p2.length, includeResistance ? r.length : 0].reduce((a,b)=> a>b?a:b);
    if (n <= 0) return const [];
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
      if (includeResistance) {
        final rv = i < r.length ? r[i].y : null;
        rows.add([t, v1, v2, rv]);
      } else {
        rows.add([t, v1, v2]);
      }
    }
    return rows;
  }

  Future<void> exportSessionCsv(Session s, {required String fileBase, bool includeResistance = true}) async {
    final rows = buildRows(s, includeResistance: includeResistance);
    await const ExportService().exportCsv(
      fileNameWithoutExt: fileBase,
      headers: headers(includeResistance: includeResistance),
      rows: rows,
    );
  }

  Future<void> exportSessionXlsx(Session s, {required String fileBase, bool includeResistance = true}) async {
    final rows = buildRows(s, includeResistance: includeResistance);
    await const ExportService().exportXlsx(
      fileNameWithoutExt: fileBase,
      headers: headers(includeResistance: includeResistance),
      rows: rows,
      sheetName: 'Session',
    );
  }
}

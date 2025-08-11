import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/session.dart';

class SessionRepository {
  Future<List<Session>> pickAndLoadSessions() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['txt'], allowMultiple: true, withData: true,
    );
    if (result == null) return [];

    final filesMap = {for (var f in result.files) f.name: f};
    final sessions = <Session>[];

    for (var file in result.files) {
      if (file.name.startsWith('D')) continue;

      final content = utf8.decode(file.bytes!);
      final lines = const LineSplitter().convert(content);
      final lastLine = lines.isNotEmpty ? lines.last : '';
      final durationMatch = RegExp(r'(\d+)\s*сек').firstMatch(lastLine);
      final durationInSeconds = durationMatch != null ? int.parse(durationMatch.group(1)!) : 0;

      final session = Session(
        name: file.name.replaceAll('.txt',''),
        date: _parseSessionDate(file.name),
        pulse1: [], pulse2: [], resistance: [], dPulse1: [], dPulse2: [],
        durationInSeconds: durationInSeconds,
      );

      for (var i=0;i<lines.length;i++) {
        final parts = lines[i].trim().split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          session.pulse1.add(FlSpot(i.toDouble(), double.parse(parts[0])));
          session.pulse2.add(FlSpot(i.toDouble(), double.parse(parts[1])));
          session.resistance.add(FlSpot(i.toDouble(), double.parse(parts[2])));
        }
      }

      final dFileName = 'D${file.name.replaceAll('.txt','')}.txt';
      if (filesMap.containsKey(dFileName)) {
        final dContent = utf8.decode(filesMap[dFileName]!.bytes!);
        final dLines = const LineSplitter().convert(dContent);
        for (var i=0;i<dLines.length;i++) {
          final parts = dLines[i].trim().split(' ');
          if (parts.length >= 2) {
            final first = double.tryParse(parts[0]);
            final second = double.tryParse(parts[1]);
            if (first != null && second != null) {
              session.dPulse1.add(FlSpot(i.toDouble(), first));
              session.dPulse2.add(FlSpot(i.toDouble(), second));
            }
          }
        }
      }

      if (!sessions.any((s)=>s.name==session.name)) sessions.add(session);
    }

    sessions.sort((a,b)=>b.date.compareTo(a.date));
    return sessions;
  }

  DateTime _parseSessionDate(String filename) {
    final parts = filename.split('_');
    if (parts.length != 2) return DateTime.now();
    final datePart = parts[0];
    final timePart = parts[1].replaceAll('.txt','');

    final day = int.parse(datePart.substring(0,2));
    final month = int.parse(datePart.substring(2,4));
    final year = 2000 + int.parse(datePart.substring(4,6));
    final hour = int.parse(timePart.substring(0,2));
    final minute = int.parse(timePart.substring(2,4));
    final second = int.parse(timePart.substring(4,6));

    return DateTime(year, month, day, hour, minute, second);
  }
}

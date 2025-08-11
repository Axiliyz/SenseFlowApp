import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/session.dart';
import '../utils/stats.dart';

Future<void> exportToPdf(BuildContext context, Session session) async {
  final fontData = await rootBundle.load("assets/fonts/Roboto.ttf");
  final ttf = pw.Font.ttf(fontData);
  final pdf = pw.Document();

  pw.Widget section(String title, double mean, double max, double min) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.Bullet(text: 'Среднее: ${mean.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
      pw.Bullet(text: 'Макс: ${max.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
      pw.Bullet(text: 'Мин: ${min.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
      pw.SizedBox(height: 12),
    ],
  );

  final s1 = Statistics.calculate(session.pulse1);
  final s2 = Statistics.calculate(session.pulse2);
  final sr = Statistics.calculate(session.resistance);

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Header(level: 0, child: pw.Text('SenseFlow, сессия: ${session.date}', style: pw.TextStyle(font: ttf, fontSize: 20))),
        pw.SizedBox(height: 10),
        section('Пульс 1', s1.mean, s1.max, s1.min),
        section('Пульс 2', s2.mean, s2.max, s2.min),
        section('Сопротивление', sr.mean, sr.max, sr.min),
        pw.SizedBox(height: 20),
        if (session.notes.isNotEmpty)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Заметки:', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
              ...session.notes.map((n)=>pw.Bullet(text: n, style: pw.TextStyle(font: ttf))),
            ],
          ),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

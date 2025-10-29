import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../models/session.dart';
import '../utils/stats.dart';
import '../utils/chart_colors.dart';

Future<void> exportToPdf(BuildContext context, Session session) async {
  final fontData = await rootBundle.load("assets/fonts/Roboto.ttf");
  final ttf = pw.Font.ttf(fontData);
  final pdf = pw.Document();
  final chartColors = ChartColors();

  // Создаем графики
  final pulse1Image = await _createChartImage(context, session.pulse1, 'Пульс 1', chartColors.pulse1(context), session.durationInSeconds);
  final pulse2Image = await _createChartImage(context, session.pulse2, 'Пульс 2', chartColors.pulse2(context), session.durationInSeconds);
  final resistanceImage = await _createChartImage(context, session.resistance, 'Сопротивление', chartColors.resistance(context), session.durationInSeconds);

  pw.Widget sectionWithChart(String title, double mean, double max, double min, pw.ImageProvider? chartImage) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (chartImage != null) ...[
        pw.Center(child: pw.Image(chartImage, width: 500, height: 300)),
        pw.SizedBox(height: 12),
      ],
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Среднее: ${mean.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 12)),
              pw.Text('Макс: ${max.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 12)),
              pw.Text('Мин: ${min.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 12)),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 20),
    ],
  );

  final s1 = Statistics.calculate(session.pulse1);
  final s2 = Statistics.calculate(session.pulse2);
  final sr = Statistics.calculate(session.resistance);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Header(
          level: 0, 
          child: pw.Text(
            'SenseFlow - Отчет по сессии', 
            style: pw.TextStyle(font: ttf, fontSize: 24, fontWeight: pw.FontWeight.bold)
          )
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Дата: ${session.date.day.toString().padLeft(2, '0')}.${session.date.month.toString().padLeft(2, '0')}.${session.date.year} ${session.date.hour.toString().padLeft(2, '0')}:${session.date.minute.toString().padLeft(2, '0')}:${session.date.second.toString().padLeft(2, '0')}',
          style: pw.TextStyle(font: ttf, fontSize: 14)
        ),
        pw.SizedBox(height: 20),
        
        // Графики и статистика
        if (session.pulse1.isNotEmpty)
          sectionWithChart('Пульс 1', s1.mean, s1.max, s1.min, pulse1Image),
        
        if (session.pulse2.isNotEmpty)
          sectionWithChart('Пульс 2', s2.mean, s2.max, s2.min, pulse2Image),
        
        if (session.resistance.isNotEmpty)
          sectionWithChart('Сопротивление', sr.mean, sr.max, sr.min, resistanceImage),
        
        // Дополнительная статистика
        pw.Text('Дополнительная статистика', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Показатель', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Пульс 1', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Пульс 2', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Сопротивление', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Среднее', style: pw.TextStyle(font: ttf)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(s1.mean.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(s2.mean.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(sr.mean.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Станд. откл.', style: pw.TextStyle(font: ttf)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(s1.stdDev.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(s2.stdDev.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(sr.stdDev.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Медиана', style: pw.TextStyle(font: ttf)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(s1.median.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(s2.median.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(sr.median.toStringAsFixed(2), style: pw.TextStyle(font: ttf)),
                ),
              ],
            ),
          ],
        ),
        
        pw.SizedBox(height: 20),
        
        // Заметки
        if (session.notes.isNotEmpty) ...[
          pw.Text('Заметки:', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 16)),
          pw.SizedBox(height: 8),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: session.notes.map((note) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text('• $note', style: pw.TextStyle(font: ttf)),
            )).toList(),
          ),
        ],
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

Future<pw.ImageProvider?> _createChartImage(BuildContext context, List<FlSpot> data, String title, Color color, int durationInSeconds) async {
  if (data.isEmpty) return null;

  try {
    // Создаем красивый график используя Canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(500, 300);
    
    // Градиентный фон
    final backgroundPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, size.height),
        [Colors.white, const Color(0xFFF8F9FA)],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    
    if (data.length < 2) return null;
    
    // Находим диапазоны
    final yValues = data.map((e) => e.y).toList();
    final minY = yValues.reduce((a, b) => a < b ? a : b);
    final maxY = yValues.reduce((a, b) => a > b ? a : b);
    final yRange = maxY - minY;
    final yPadding = yRange * 0.15;
    
    // Область графика
    const chartPadding = 60.0;
    final chartWidth = size.width - chartPadding * 2;
    final chartHeight = size.height - chartPadding * 2;
    
    // Масштабируем данные
    final scaledData = data.map((point) {
      final x = chartPadding + (point.x / (data.length - 1)) * chartWidth;
      final y = chartPadding + chartHeight - ((point.y - minY + yPadding) / (yRange + 2 * yPadding)) * chartHeight;
      return Offset(x, y);
    }).toList();
    
    // Рисуем область графика с тенью
    final chartRect = Rect.fromLTWH(chartPadding - 5, chartPadding - 5, chartWidth + 10, chartHeight + 10);
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3);
    canvas.drawRRect(RRect.fromRectAndRadius(chartRect, const Radius.circular(8)), shadowPaint);
    
    final chartBgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(chartPadding, chartPadding, chartWidth, chartHeight), 
      const Radius.circular(8)
    ), chartBgPaint);
    
    // Рисуем линии сетки
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;
    
    // Горизонтальные линии (5 линий)
    for (int i = 0; i <= 5; i++) {
      final y = chartPadding + (chartHeight * i / 5);
      canvas.drawLine(
        Offset(chartPadding, y), 
        Offset(chartPadding + chartWidth, y), 
        gridPaint
      );
    }
    
    // Вертикальные линии (6 линий)
    for (int i = 0; i <= 6; i++) {
      final x = chartPadding + (chartWidth * i / 6);
      canvas.drawLine(
        Offset(x, chartPadding), 
        Offset(x, chartPadding + chartHeight), 
        gridPaint
      );
    }
    
    // Рисуем график с градиентом
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Основная линия
    for (int i = 0; i < scaledData.length - 1; i++) {
      canvas.drawLine(scaledData[i], scaledData[i + 1], linePaint);
    }
    
    // Рисуем точки с градиентом
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i < scaledData.length; i += (scaledData.length / 20).ceil()) {
      final point = scaledData[i];
      canvas.drawCircle(point, 4, dotBorderPaint);
      canvas.drawCircle(point, 3, dotPaint);
    }
    
    // Заголовок
    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Color(0xFF2C3E50),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, Offset(chartPadding, 15));
    
    // Подписи осей
    final axisLabelStyle = const TextStyle(
      color: Color(0xFF7F8C8D),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    
    // Y ось (значения)
    for (int i = 0; i <= 5; i++) {
      final value = minY + (yRange * i / 5);
      final y = chartPadding + chartHeight - (chartHeight * i / 5);
      
      final valuePainter = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(0),
          style: axisLabelStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      valuePainter.layout();
      valuePainter.paint(canvas, Offset(5, y - 6));
    }
    
    // X ось (время)
    for (int i = 0; i <= 6; i++) {
      final timeValue = (durationInSeconds * i / 6);
      final x = chartPadding + (chartWidth * i / 6);
      
      final timePainter = TextPainter(
        text: TextSpan(
          text: '${timeValue.toStringAsFixed(0)}с',
          style: axisLabelStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      timePainter.layout();
      timePainter.paint(canvas, Offset(x - 15, chartPadding + chartHeight + 10));
    }
    
    // Подписи осей
    final yAxisLabel = TextPainter(
      text: const TextSpan(
        text: 'Значение',
        style: TextStyle(
          color: Color(0xFF34495E),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    yAxisLabel.layout();
    canvas.save();
    canvas.translate(15, chartPadding + chartHeight / 2);
    canvas.rotate(-1.5708); // -90 градусов
    yAxisLabel.paint(canvas, Offset.zero);
    canvas.restore();
    
    final xAxisLabel = TextPainter(
      text: const TextSpan(
        text: 'Время (секунды)',
        style: TextStyle(
          color: Color(0xFF34495E),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    xAxisLabel.layout();
    xAxisLabel.paint(canvas, Offset(chartPadding + chartWidth / 2 - 50, chartPadding + chartHeight + 35));
    
    // Оси
    final axisPaint = Paint()
      ..color = const Color(0xFF34495E)
      ..strokeWidth = 2;
    
    // Y ось
    canvas.drawLine(
      Offset(chartPadding, chartPadding), 
      Offset(chartPadding, chartPadding + chartHeight), 
      axisPaint
    );
    // X ось
    canvas.drawLine(
      Offset(chartPadding, chartPadding + chartHeight), 
      Offset(chartPadding + chartWidth, chartPadding + chartHeight), 
      axisPaint
    );
    
    // Стрелки на осях
    final arrowPaint = Paint()
      ..color = const Color(0xFF34495E)
      ..style = PaintingStyle.fill;
    
    // Стрелка Y оси
    canvas.drawPath(
      Path()
        ..moveTo(chartPadding - 5, chartPadding + 10)
        ..lineTo(chartPadding + 5, chartPadding + 10)
        ..lineTo(chartPadding, chartPadding)
        ..close(),
      arrowPaint
    );
    
    // Стрелка X оси
    canvas.drawPath(
      Path()
        ..moveTo(chartPadding + chartWidth - 10, chartPadding + chartHeight - 5)
        ..lineTo(chartPadding + chartWidth - 10, chartPadding + chartHeight + 5)
        ..lineTo(chartPadding + chartWidth, chartPadding + chartHeight)
        ..close(),
      arrowPaint
    );
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData != null) {
      return pw.MemoryImage(byteData.buffer.asUint8List());
    }
  } catch (e) {
    print('Ошибка создания графика: $e');
  }
  
  return null;
}

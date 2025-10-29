import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

enum ChartFilter {
  none,
  movingAverage2,
  movingAverage3,
  movingAverage5,
  movingAverage10,
  lowPass,
  kalman,
  exponential,
  gaussian,
  median,
  butterworth,
}

extension ChartFilterExt on ChartFilter {
  String get name {
    switch (this) {
      case ChartFilter.none:
        return 'Без фильтров';
      case ChartFilter.movingAverage2:
        return 'Скользящее среднее (2)';
      case ChartFilter.movingAverage3:
        return 'Скользящее среднее (3)';
      case ChartFilter.movingAverage5:
        return 'Скользящее среднее (5)';
      case ChartFilter.movingAverage10:
        return 'Скользящее среднее (10)';
      case ChartFilter.lowPass:
        return 'Низкочастотный фильтр';
      case ChartFilter.kalman:
        return 'Фильтр Калмана';
      case ChartFilter.exponential:
        return 'Экспоненциальный фильтр';
      case ChartFilter.gaussian:
        return 'Гауссовский фильтр';
      case ChartFilter.median:
        return 'Медианный фильтр';
      case ChartFilter.butterworth:
        return 'Баттерворт';
    }
  }

  List<FlSpot> apply(List<FlSpot> data) {
    switch (this) {
      case ChartFilter.none:
        return data;
      case ChartFilter.movingAverage2:
        return _applyMovingAverage(data, window: 2);
      case ChartFilter.movingAverage3:
        return _applyMovingAverage(data, window: 3);
      case ChartFilter.movingAverage5:
        return _applyMovingAverage(data, window: 5);
      case ChartFilter.movingAverage10:
        return _applyMovingAverage(data, window: 10);
      case ChartFilter.lowPass:
        return _applyLowPass(data);
      case ChartFilter.kalman:
        return _applyKalman(data);
      case ChartFilter.exponential:
        return _applyExponential(data);
      case ChartFilter.gaussian:
        return _applyGaussian(data);
      case ChartFilter.median:
        return _applyMedian(data);
      case ChartFilter.butterworth:
        return _applyButterworth(data);
    }
  }

  List<FlSpot> _applyMovingAverage(List<FlSpot> data, {required int window}) {
    if (data.length < window) return data;
    final result = <FlSpot>[];
    
    for (var i = 0; i < data.length; i++) {
      var sum = 0.0;
      var count = 0;
      
      for (var j = -window ~/ 2; j <= window ~/ 2; j++) {
        final idx = i + j;
        if (idx >= 0 && idx < data.length) {
          sum += data[idx].y;
          count++;
        }
      }
      
      result.add(FlSpot(data[i].x, sum / count));
    }
    
    return result;
  }

  List<FlSpot> _applyLowPass(List<FlSpot> data, {double alpha = 0.1}) {
    if (data.isEmpty) return data;
    final result = <FlSpot>[];
    var filtered = data.first.y;
    
    for (var spot in data) {
      filtered = alpha * spot.y + (1 - alpha) * filtered;
      result.add(FlSpot(spot.x, filtered));
    }
    
    return result;
  }

  List<FlSpot> _applyKalman(List<FlSpot> data, {
    double q = 0.1,  // Process noise
    double r = 1.0,  // Measurement noise
  }) {
    if (data.isEmpty) return data;
    final result = <FlSpot>[];
    
    var x = data.first.y;  // State estimate
    var p = 1.0;          // Estimation error covariance
    
    for (var spot in data) {
      // Predict
      var p_pred = p + q;
      
      // Update
      var k = p_pred / (p_pred + r);  // Kalman gain
      x = x + k * (spot.y - x);
      p = (1 - k) * p_pred;
      
      result.add(FlSpot(spot.x, x));
    }
    
    return result;
  }

  List<FlSpot> _applyExponential(List<FlSpot> data, {double alpha = 0.2}) {
    if (data.isEmpty) return data;
    final result = <FlSpot>[];
    var smoothed = data.first.y;
    
    for (var spot in data) {
      smoothed = alpha * spot.y + (1 - alpha) * smoothed;
      result.add(FlSpot(spot.x, smoothed));
    }
    
    return result;
  }

  List<FlSpot> _applyGaussian(List<FlSpot> data, {double sigma = 1.0}) {
    if (data.isEmpty) return data;
    final windowSize = (6 * sigma).ceil();
    final result = <FlSpot>[];
    
    for (var i = 0; i < data.length; i++) {
      var sum = 0.0;
      var weightSum = 0.0;
      
      for (var j = -windowSize ~/ 2; j <= windowSize ~/ 2; j++) {
        final idx = i + j;
        if (idx >= 0 && idx < data.length) {
          final weight = math.exp(-(j * j) / (2 * sigma * sigma));
          sum += data[idx].y * weight;
          weightSum += weight;
        }
      }
      
      result.add(FlSpot(data[i].x, sum / weightSum));
    }
    
    return result;
  }

  List<FlSpot> _applyMedian(List<FlSpot> data, {int window = 5}) {
    if (data.length < window) return data;
    final result = <FlSpot>[];
    
    for (var i = 0; i < data.length; i++) {
      final values = <double>[];
      
      for (var j = -window ~/ 2; j <= window ~/ 2; j++) {
        final idx = i + j;
        if (idx >= 0 && idx < data.length) {
          values.add(data[idx].y);
        }
      }
      
      values.sort();
      final median = values.length.isOdd 
          ? values[values.length ~/ 2]
          : (values[values.length ~/ 2 - 1] + values[values.length ~/ 2]) / 2;
      
      result.add(FlSpot(data[i].x, median));
    }
    
    return result;
  }

  List<FlSpot> _applyButterworth(List<FlSpot> data, {
    double cutoff = 0.1,  // Normalized cutoff frequency (0 to 1)
    int order = 2,        // Filter order
  }) {
    if (data.length < 3) return data;
    final result = <FlSpot>[];
    
    // Compute filter coefficients
    final double omega = 2.0 * math.pi * cutoff;
    final double alpha = math.sin(omega) / 2.0;
    final double cosw = math.cos(omega);
    final double a0 = 1.0 + alpha;
    
    final List<double> b = [
      (1.0 - cosw) / 2.0 / a0,
      (1.0 - cosw) / a0,
      (1.0 - cosw) / 2.0 / a0,
    ];
    
    final List<double> a = [
      1.0,
      -2.0 * cosw / a0,
      (1.0 - alpha) / a0,
    ];
    
    // Apply filter
    final List<double> x = [data[0].y, data[0].y];  // Input buffer
    final List<double> y = [data[0].y, data[0].y];  // Output buffer
    
    for (var spot in data) {
      // Shift input and output buffers
      x[0] = x[1];
      x[1] = spot.y;
      y[0] = y[1];
      
      // Apply filter
      y[1] = b[0] * x[1] + b[1] * x[0] + b[2] * x[0]
           - a[1] * y[0] - a[2] * y[0];
      
      result.add(FlSpot(spot.x, y[1]));
    }
    
    return result;
  }
}
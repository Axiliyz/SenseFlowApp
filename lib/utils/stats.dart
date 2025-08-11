import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

class Statistics {
  final double mean,stdDev,min,max,median,variance,range,mode,q1,q3,cv,skewness,kurtosis,iqr,sem,rsd,p10,p90,sdnn,rmssd,pnn50,stabilityCoeff,stabilityIndex,linearTrend,quadraticTrend;
  final List<double> outliers;
  Statistics({
    required this.mean, required this.stdDev, required this.min, required this.max,
    required this.median, required this.variance, required this.range, required this.mode,
    required this.q1, required this.q3, required this.cv, required this.skewness, required this.kurtosis,
    required this.iqr, required this.sem, required this.rsd, required this.p10, required this.p90,
    required this.outliers, required this.sdnn, required this.rmssd, required this.pnn50,
    required this.stabilityCoeff, required this.stabilityIndex,
    required this.linearTrend, required this.quadraticTrend,
  });

  static Statistics calculate(List<FlSpot> data) {
    if (data.isEmpty) {
      return Statistics(
        mean:0,stdDev:0,min:0,max:0,median:0,variance:0,range:0,mode:0,q1:0,q3:0,cv:0,
        skewness:0,kurtosis:0,iqr:0,sem:0,rsd:0,p10:0,p90:0,outliers:[],
        sdnn:0,rmssd:0,pnn50:0,stabilityCoeff:0,stabilityIndex:0,linearTrend:0,quadraticTrend:0,
      );
    }
    final values = data.map((e)=>e.y).toList()..sort();
    final sum = values.reduce((a,b)=>a+b);
    final mean = sum / values.length;
    final variance = values.map((x)=>pow(x-mean,2)).reduce((a,b)=>a+b) / values.length;
    final stdDev = sqrt(variance);
    final min = values.first, max = values.last, range = max - min;
    final median = values.length.isEven
      ? (values[values.length~/2 -1] + values[values.length~/2]) / 2
      : values[values.length~/2];
    final q1 = values[values.length~/4];
    final q3 = values[(3*values.length)~/4];
    final p10 = values[values.length~/10];
    final p90 = values[(9*values.length)~/10];
    final iqr = q3 - q1;

    final counts = <double,int>{};
    for (var v in values) { counts[v] = (counts[v] ?? 0) + 1; }
    final mode = counts.entries.reduce((a,b)=>a.value>b.value?a:b).key;

    final cv = mean!=0 ? (stdDev/mean)*100 : 0.0;
    final skewness = (values.map((x)=>pow(x-mean,3)).reduce((a,b)=>a+b)/values.length) / pow(stdDev,3);
    final kurtosis = (values.map((x)=>pow(x-mean,4)).reduce((a,b)=>a+b)/values.length) / pow(variance,2) - 3;
    final sem = stdDev / sqrt(values.length);
    final rsd = stdDev / mean * 100;
    final outliers = values.where((x)=>(x-mean).abs()>2*stdDev).toList();

    final sdnn = stdDev;
    double ssd = 0; for (int i=1;i<values.length;i++) { ssd += pow(values[i]-values[i-1],2); }
    final rmssd = sqrt(ssd / (values.length-1));
    int nn50=0; for (int i=1;i<values.length;i++) if ((values[i]-values[i-1]).abs()>50) nn50++;
    final pnn50 = (nn50 / (values.length-1)) * 100;

    final stabilityCoeff = min / max;
    final stabilityIndex = mean / stdDev;

    double sumX=0,sumY=0,sumXY=0,sumX2=0,sumX3=0,sumX4=0,sumX2Y=0;
    for (int i=0;i<values.length;i++) { sumX+=i; sumY+=values[i]; sumXY+=i*values[i]; sumX2+=i*i; sumX3+=i*i*i; sumX4+=i*i*i*i; sumX2Y+=i*i*values[i]; }
    final n=values.length.toDouble();
    final linearTrend = (n*sumXY - sumX*sumY) / (n*sumX2 - sumX*sumX);
    final quadraticTrend = (n*sumX2Y - sumX2*sumY) / (n*sumX4 - sumX2*sumX2);

    return Statistics(
      mean:mean,stdDev:stdDev,min:min,max:max,median:median,variance:variance,range:range,mode:mode,
      q1:q1,q3:q3,cv:cv.toDouble(),skewness:skewness.toDouble(),kurtosis:kurtosis.toDouble(),
      iqr:iqr,sem:sem,rsd:rsd,p10:p10,p90:p90,outliers:outliers,sdnn:sdnn,rmssd:rmssd,pnn50:pnn50,
      stabilityCoeff:stabilityCoeff,stabilityIndex:stabilityIndex,linearTrend:linearTrend,quadraticTrend:quadraticTrend,
    );
  }
}

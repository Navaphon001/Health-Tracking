import 'package:my_app/shared/date_key.dart';
import 'chart_point.dart';

/// เติม 0 ให้ทุกวันระหว่าง [start..end]
List<ChartPoint> fillMissingDaysWithZero({
  required DateTime start,
  required DateTime end,
  required Map<String, double> valueByDateKey, // key = yyyy-MM-dd
}) {
  final out = <ChartPoint>[];
  var d = startOfDay(start);
  final last = startOfDay(end);
  while (!d.isAfter(last)) {
    final k = dateKeyOf(d);
    out.add(ChartPoint(d, valueByDateKey[k] ?? 0.0));
    d = d.add(const Duration(days: 1));
  }
  return out;
}

/// ช่วง N วันล่าสุด (ตัดเวลาเป็นต้นวัน)
({DateTime start, DateTime end}) lastNDays(int n) {
  final today = startOfDay(DateTime.now());
  return (start: today.subtract(Duration(days: n - 1)), end: today);
}

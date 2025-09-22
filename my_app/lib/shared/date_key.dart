// lib/shared/date_key.dart
import 'package:intl/intl.dart';

/// ฟอร์แมตคงที่ทั้งแอป
final DateFormat _keyFmt = DateFormat('yyyy-MM-dd'); // สำหรับ date_key (local day)


/// สร้างคีย์รายวันจาก DateTime (อิงเวลาเครื่องผู้ใช้)
String dateKeyOf(DateTime dt) => _keyFmt.format(dt);

/// แปลง "yyyy-MM-dd" -> DateTime (เวลา 00:00:00 ของวันนั้น)
DateTime dateFromKey(String key) {
  final p = key.split('-');
  if (p.length != 3) {
    throw FormatException('Bad dateKey: $key (expected yyyy-MM-dd)');
  }
  final y = int.parse(p[0]), m = int.parse(p[1]), d = int.parse(p[2]);
  return DateTime(y, m, d); // local
}

/// ต้นวัน/ท้ายวัน (local)
DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
DateTime endOfDay(DateTime dt)   => DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

/// epoch millis (ตั้ง created_at/updated_at ให้สอดคล้องกันทั้งแอป)
int nowEpochMillis() => DateTime.now().millisecondsSinceEpoch;

/// แปลง/ตรวจค่าชั่วโมง–นาที สำหรับ sleep แบบ “ยอดรวมต่อวัน”
int clampMinutes(int minutes, {int min = 0, int max = 24 * 60}) {
  if (minutes < min) return min;
  if (minutes > max) return max;
  return minutes;
}

/// นอร์มัลไลซ์ h/m -> ภายใน 0..24h และคืนค่ารูปแบบใช้งานง่าย
Map<String, int> normalizeHM(int hours, int minutes) {
  var total = hours * 60 + minutes;
  total = clampMinutes(total);
  return {
    'hours': total ~/ 60,
    'minutes': total % 60,
    'total': total,
  };
}

/// (ทางเลือก) parse "HH:mm" -> นาทีตั้งแต่ 00:00
int parseHMToMinutes(String hhmm) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(hhmm);
  if (m == null) throw FormatException('Bad HH:mm: $hhmm');
  final h = int.parse(m.group(1)!);
  final min = int.parse(m.group(2)!);
  if (h < 0 || h > 23 || min < 0 || min > 59) {
    throw FormatException('Out of range HH:mm: $hhmm');
  }
  return h * 60 + min;
}

/// (ทางเลือก) นาที -> สตริง "HH:mm"
String formatMinutesAsHM(int minutes) {
  minutes = clampMinutes(minutes);
  final h = (minutes ~/ 60).toString().padLeft(2, '0');
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

/// (ทางเลือก) รวม date_key + "HH:mm" เป็น DateTime (local)
DateTime combineDateKeyAndHM(String dateKey, String hhmm, {bool nextDay = false}) {
  final base = dateFromKey(dateKey);
  final mins = parseHMToMinutes(hhmm);
  final dayOffset = nextDay ? const Duration(days: 1) : Duration.zero;
  return base.add(dayOffset).add(Duration(minutes: mins));
}

/// (ทางเลือก) ตรวจว่าข้ามเที่ยงคืนไหม ระหว่าง bed และ wake (HH:mm)
bool isCrossMidnight(String bed, String wake) => parseHMToMinutes(wake) < parseHMToMinutes(bed);

/// (ทางเลือก) คำนวณนาทีที่นอนจากคู่เวลา HH:mm (รองรับข้ามวัน)
int sleepMinutesFromHM(String bed, String wake, {int maxHours = 16}) {
  final b = parseHMToMinutes(bed);
  final w = parseHMToMinutes(wake);
  final day = 24 * 60;
  final raw = w >= b ? (w - b) : (day - b + w);
  return clampMinutes(raw, max: maxHours * 60);
}

import 'package:flutter/material.dart';

class SleepLog {
  final String id;         // แนะนำใช้ yyyy-MM-dd ของคืนเริ่มนอน
  final TimeOfDay bedTime; // "HH:mm"
  final TimeOfDay wakeTime;// "HH:mm"
  final int starCount;     // 0..5
  final String startedOn;  // yyyy-MM-dd

  SleepLog({
    required this.id,
    required this.bedTime,
    required this.wakeTime,
    required this.starCount,
    required this.startedOn,
  });

  static String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  static TimeOfDay _toTod(String hhmm) {
    final p = hhmm.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  factory SleepLog.fromJson(Map<String, dynamic> json) => SleepLog(
        id: (json['id'] ?? json['startedOn']).toString(),
        bedTime: _toTod(json['bedTime'] ?? '22:00'),
        wakeTime: _toTod(json['wakeTime'] ?? '06:00'),
        starCount: (json['starCount'] ?? 0) as int,
        startedOn: json['startedOn'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'bedTime': _hhmm(bedTime),
        'wakeTime': _hhmm(wakeTime),
        'starCount': starCount,
        'startedOn': startedOn,
      };
}

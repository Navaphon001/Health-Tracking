import 'dart:async';
import 'package:flutter/material.dart';

class ExerciseActivity {
  String id;                 // ใช้ String ก็พอ (timestamp/uuid)
  String name;
  TimeOfDay scheduledTime;   // เก็บ/ส่งเป็น "HH:mm"
  Duration goalDuration;     // เก็บ/ส่งเป็น seconds

  // (ไม่จำเป็นกับ local) ติดไว้เผื่ออนาคต
  DateTime? createdAt;
  DateTime? updatedAt;

  // ---- runtime only ----
  Duration remainingDuration;
  bool isRunning = false;
  Timer? timer;

  ExerciseActivity({
    required this.id,
    required this.name,
    required this.scheduledTime,
    required this.goalDuration,
    this.createdAt,
    this.updatedAt,
  }) : remainingDuration = goalDuration;

  // mapping
  static String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay _toTod(String hhmm) {
    final p = hhmm.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  factory ExerciseActivity.fromJson(Map<String, dynamic> json) {
    return ExerciseActivity(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '-',
      scheduledTime: _toTod(json['scheduledTime'] ?? '00:00'),
      goalDuration: Duration(seconds: (json['goalDurationInSeconds'] ?? 0) as int),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scheduledTime': _hhmm(scheduledTime),
        'goalDurationInSeconds': goalDuration.inSeconds,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  ExerciseActivity copyWith({
    String? id,
    String? name,
    TimeOfDay? scheduledTime,
    Duration? goalDuration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final c = ExerciseActivity(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      goalDuration: goalDuration ?? this.goalDuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
    c.remainingDuration = remainingDuration;
    c.isRunning = isRunning;
    c.timer = timer;
    return c;
  }
}

import 'dart:async';
import 'package:flutter/material.dart';

enum ActivityType { walk, run, bike, swim, sport }

class ExerciseActivity {
  String id;
  String name;
  TimeOfDay scheduledTime;              // "HH:mm"
  Duration goalDuration;                // Duration (วินาที/นาทีอะไรก็ได้)

  /// ประเภทของกิจกรรม
  ActivityType activityType;

  /// แคลอรี่ที่คำนวณไว้ล่าสุด (อาจเป็น null ถ้ายังไม่คำนวณ)
  double? caloriesBurned;

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
    this.activityType = ActivityType.walk,
    this.caloriesBurned,
    this.createdAt,
    this.updatedAt,
  }) : remainingDuration = goalDuration;

  // ---------- Compatibility helpers ----------

  /// สำหรับโค้ดเดิมที่เรียก a.type (String)
  String get type => typeToString(activityType);
  set type(String v) => activityType = _typeFrom(v);

  // ---------- MET helper (ถ้าจะใช้คำนวณ) ----------
  static double metOf(ActivityType t) {
    switch (t) {
      case ActivityType.walk: return 3.8;
      case ActivityType.run:  return 8.0;
      case ActivityType.bike: return 8.0;
      case ActivityType.swim: return 6.0;
      case ActivityType.sport:return 6.0;
    }
  }

  // ---------- utils ----------
  static String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay _toTod(String hhmm) {
    final p = hhmm.split(':');
    final h = int.tryParse(p.elementAt(0)) ?? 0;
    final m = int.tryParse(p.elementAt(1)) ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  static ActivityType _typeFrom(dynamic v) {
    if (v == null) return ActivityType.walk;
    if (v is int) {
      final idx = v.clamp(0, ActivityType.values.length - 1);
      return ActivityType.values[idx];
    }
    if (v is String) {
      switch (v.toLowerCase()) {
        case 'walk': return ActivityType.walk;
        case 'run':  return ActivityType.run;
        case 'bike': return ActivityType.bike;
        case 'swim': return ActivityType.swim;
        case 'sport':return ActivityType.sport;
      }
    }
    return ActivityType.walk;
  }

  static String typeToString(ActivityType t) {
    switch (t) {
      case ActivityType.walk: return 'walk';
      case ActivityType.run:  return 'run';
      case ActivityType.bike: return 'bike';
      case ActivityType.swim: return 'swim';
      case ActivityType.sport:return 'sport';
    }
  }

  factory ExerciseActivity.fromJson(Map<String, dynamic> json) {
    // รองรับข้อมูลเก่าที่เคยเก็บ goalDuration (นาที) กับของใหม่ goalDurationInSeconds
    final secsNew = (json['goalDurationInSeconds'] as num?)?.toInt();
    final minsOld = (json['goalDuration'] as num?)?.toInt();
    final duration = secsNew != null
        ? Duration(seconds: secsNew)
        : Duration(minutes: minsOld ?? 0);

    // รองรับ key เดิม 'type' (String) และ key ใหม่ 'activityType'
    final dynamic rawType = json.containsKey('activityType')
        ? json['activityType']
        : json['type'];

    return ExerciseActivity(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '-') as String,
      scheduledTime: _toTod((json['scheduledTime'] ?? '00:00').toString()),
      goalDuration: duration,
      activityType: _typeFrom(rawType),
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble(),
      createdAt: (json['createdAt'] is String) ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: (json['updatedAt'] is String) ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scheduledTime': _hhmm(scheduledTime),
        // เก็บรูปแบบใหม่เป็นวินาที
        'goalDurationInSeconds': goalDuration.inSeconds,
        // และเก็บชื่อประเภทเป็น string
        'activityType': typeToString(activityType),
        if (caloriesBurned != null) 'caloriesBurned': caloriesBurned,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  ExerciseActivity copyWith({
    String? id,
    String? name,
    TimeOfDay? scheduledTime,
    Duration? goalDuration,
    ActivityType? activityType,
    double? caloriesBurned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final c = ExerciseActivity(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      goalDuration: goalDuration ?? this.goalDuration,
      activityType: activityType ?? this.activityType,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
    c.remainingDuration = remainingDuration;
    c.isRunning = isRunning;
    c.timer = timer;
    return c;
  }
}

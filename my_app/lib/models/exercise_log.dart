import 'package:flutter/foundation.dart';

enum ActivityTypeEnum { walking, running, cycling, swimming, yoga, other }

class ExerciseLog {
  String id;
  String userId;
  DateTime date; // date only (YYYY-MM-DD)
  ActivityTypeEnum activityType;
  int duration; // seconds
  double caloriesBurned;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;

  ExerciseLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.activityType,
    required this.duration,
    required this.caloriesBurned,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    ActivityTypeEnum act;
    final raw = (json['activity_type'] ?? json['activityType'] ?? '') as String;
    switch (raw.toLowerCase()) {
      case 'walking': act = ActivityTypeEnum.walking; break;
      case 'running': act = ActivityTypeEnum.running; break;
      case 'cycling': act = ActivityTypeEnum.cycling; break;
      case 'swimming': act = ActivityTypeEnum.swimming; break;
      case 'yoga': act = ActivityTypeEnum.yoga; break;
      default: act = ActivityTypeEnum.other; break;
    }

    return ExerciseLog(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      date: DateTime.parse((json['date'] ?? '').toString()),
      activityType: act,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      caloriesBurned: (json['calories_burned'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'date': date.toIso8601String(),
        'activity_type': describeEnum(activityType),
        'duration': duration,
        'calories_burned': caloriesBurned,
        if (notes != null) 'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

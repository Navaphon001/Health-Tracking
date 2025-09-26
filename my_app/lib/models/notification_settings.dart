/// Model สำหรับ Notification Settings
/// ตาม database schema ที่มีใน notification_settings table
class NotificationSettings {
  final String? id;
  final String? userId;
  final bool waterReminderEnabled;
  final bool exerciseReminderEnabled;
  final bool mealLoggingEnabled;
  final bool sleepReminderEnabled;
  final DateTime? updatedAt;

  NotificationSettings({
    this.id,
    this.userId,
    required this.waterReminderEnabled,
    required this.exerciseReminderEnabled,
    required this.mealLoggingEnabled,
    required this.sleepReminderEnabled,
    this.updatedAt,
  });

  /// Create from database row
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString(),
      waterReminderEnabled: (map['water_reminder_enabled'] as int?) == 1,
      exerciseReminderEnabled: (map['exercise_reminder_enabled'] as int?) == 1,
      mealLoggingEnabled: (map['meal_logging_enabled'] as int?) == 1,
      sleepReminderEnabled: (map['sleep_reminder_enabled'] as int?) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'water_reminder_enabled': waterReminderEnabled ? 1 : 0,
      'exercise_reminder_enabled': exerciseReminderEnabled ? 1 : 0,
      'meal_logging_enabled': mealLoggingEnabled ? 1 : 0,
      'sleep_reminder_enabled': sleepReminderEnabled ? 1 : 0,
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Create a copy with updated values
  NotificationSettings copyWith({
    String? id,
    String? userId,
    bool? waterReminderEnabled,
    bool? exerciseReminderEnabled,
    bool? mealLoggingEnabled,
    bool? sleepReminderEnabled,
    DateTime? updatedAt,
  }) {
    return NotificationSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      waterReminderEnabled: waterReminderEnabled ?? this.waterReminderEnabled,
      exerciseReminderEnabled: exerciseReminderEnabled ?? this.exerciseReminderEnabled,
      mealLoggingEnabled: mealLoggingEnabled ?? this.mealLoggingEnabled,
      sleepReminderEnabled: sleepReminderEnabled ?? this.sleepReminderEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings{'
        'id: $id, '
        'userId: $userId, '
        'waterReminderEnabled: $waterReminderEnabled, '
        'exerciseReminderEnabled: $exerciseReminderEnabled, '
        'mealLoggingEnabled: $mealLoggingEnabled, '
        'sleepReminderEnabled: $sleepReminderEnabled, '
        'updatedAt: $updatedAt'
        '}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationSettings &&
        other.id == id &&
        other.userId == userId &&
        other.waterReminderEnabled == waterReminderEnabled &&
        other.exerciseReminderEnabled == exerciseReminderEnabled &&
        other.mealLoggingEnabled == mealLoggingEnabled &&
        other.sleepReminderEnabled == sleepReminderEnabled &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        waterReminderEnabled.hashCode ^
        exerciseReminderEnabled.hashCode ^
        mealLoggingEnabled.hashCode ^
        sleepReminderEnabled.hashCode ^
        updatedAt.hashCode;
  }
}
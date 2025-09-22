class FoodLog {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime lastModified;
  final int mealCount;

  const FoodLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.lastModified,
    this.mealCount = 0,
  });

  factory FoodLog.fromMap(Map<String, dynamic> map) {
    return FoodLog(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      lastModified: DateTime.fromMillisecondsSinceEpoch(map['last_modified'] as int),
      mealCount: map['meal_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // yyyy-MM-dd format
      'last_modified': lastModified.millisecondsSinceEpoch,
      'meal_count': mealCount,
    };
  }

  FoodLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    DateTime? lastModified,
    int? mealCount,
  }) {
    return FoodLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      lastModified: lastModified ?? this.lastModified,
      mealCount: mealCount ?? this.mealCount,
    );
  }

  @override
  String toString() {
    return 'FoodLog(id: $id, userId: $userId, date: $date, mealCount: $mealCount)';
  }
}
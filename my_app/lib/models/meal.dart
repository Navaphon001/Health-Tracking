enum MealType {
  breakfast('breakfast', 'เช้า'),
  lunch('lunch', 'เที่ยง'),
  dinner('dinner', 'เย็น'),
  snack('snack', 'ของว่าง');

  const MealType(this.value, this.displayName);
  final String value;
  final String displayName;

  static MealType fromString(String value) {
    return MealType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MealType.breakfast,
    );
  }
}

class Meal {
  final String id;
  final String? foodLogId;
  final String? userId;
  final String foodName;
  final MealType mealType;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Meal({
    required this.id,
    this.foodLogId,
    this.userId,
    required this.foodName,
    required this.mealType,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as String,
      foodLogId: map['food_log_id'] as String?,
      userId: map['user_id'] as String?,
      foodName: map['food_name'] as String,
      mealType: MealType.fromString(map['meal_type'] as String),
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_log_id': foodLogId,
      'user_id': userId,
      'food_name': foodName,
      'meal_type': mealType.value,
      'image_url': imageUrl,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  Meal copyWith({
    String? id,
    String? foodLogId,
    String? userId,
    String? foodName,
    MealType? mealType,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Meal(
      id: id ?? this.id,
      foodLogId: foodLogId ?? this.foodLogId,
      userId: userId ?? this.userId,
      foodName: foodName ?? this.foodName,
      mealType: mealType ?? this.mealType,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Meal(id: $id, foodName: $foodName, mealType: $mealType)';
  }
}
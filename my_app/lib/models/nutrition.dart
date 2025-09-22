class Nutrition {
  final String id;
  final String foodName;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? fiber;
  final double? sugar;
  final DateTime? lastUpdated;

  const Nutrition({
    required this.id,
    required this.foodName,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.sugar,
    this.lastUpdated,
  });

  factory Nutrition.fromMap(Map<String, dynamic> map) {
    return Nutrition(
      id: map['id'] as String,
      foodName: map['food_name'] as String,
      calories: map['calories'] as double?,
      protein: map['protein'] as double?,
      carbs: map['carbs'] as double?,
      fat: map['fat'] as double?,
      fiber: map['fiber'] as double?,
      sugar: map['sugar'] as double?,
      lastUpdated: map['last_updated'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['last_updated'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_name': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'last_updated': lastUpdated?.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'Nutrition(id: $id, foodName: $foodName, calories: $calories)';
  }
}
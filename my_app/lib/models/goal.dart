class Goal {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? targetDate;
  final bool isCompleted;
  final String category; // 'water', 'exercise', 'sleep', 'weight', 'general'
  final double? targetValue;
  final String? unit; // 'glasses', 'minutes', 'hours', 'kg', etc.

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.targetDate,
    this.isCompleted = false,
    required this.category,
    this.targetValue,
    this.unit,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? targetDate,
    bool? isCompleted,
    String? category,
    double? targetValue,
    String? unit,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'category': category,
      'targetValue': targetValue,
      'unit': unit,
    };
  }

  static Goal fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetDate: json['targetDate'] != null 
          ? DateTime.parse(json['targetDate'] as String) 
          : null,
      isCompleted: json['isCompleted'] as bool,
      category: json['category'] as String,
      targetValue: json['targetValue'] as double?,
      unit: json['unit'] as String?,
    );
  }
}
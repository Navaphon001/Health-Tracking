enum AchievementType {
  water,        // ดื่มน้ำ
  exercise,     // ออกกำลังกาย
  sleep,        // นอนหลับ
  weight,       // น้ำหนัก
  streak,       // ความต่อเนื่อง
  milestone,    // เป้าหมายสำคัญ
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconPath; // path to icon or emoji
  final AchievementType type;
  final int maxProgress;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String reward; // คำอธิบายรางวัลหรือข้อความยินดี

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.maxProgress,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.reward,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconPath,
    AchievementType? type,
    int? maxProgress,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? reward,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      type: type ?? this.type,
      maxProgress: maxProgress ?? this.maxProgress,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      reward: reward ?? this.reward,
    );
  }

  double get progressPercentage {
    if (maxProgress == 0) return 0.0;
    return (currentProgress / maxProgress).clamp(0.0, 1.0);
  }

  bool get isInProgress {
    return currentProgress > 0 && currentProgress < maxProgress;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'type': type.name,
      'maxProgress': maxProgress,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'reward': reward,
    };
  }

  static Achievement fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconPath: json['iconPath'] as String,
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.milestone,
      ),
      maxProgress: json['maxProgress'] as int,
      currentProgress: json['currentProgress'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'] as String) 
          : null,
      reward: json['reward'] as String,
    );
  }
}
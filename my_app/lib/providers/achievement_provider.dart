import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementProvider extends ChangeNotifier {
  List<Achievement> _achievements = [];
  
  List<Achievement> get achievements => _achievements;
  
  List<Achievement> get unlockedAchievements => 
      _achievements.where((achievement) => achievement.isUnlocked).toList();
  
  List<Achievement> get lockedAchievements => 
      _achievements.where((achievement) => !achievement.isUnlocked).toList();

  List<Achievement> get inProgressAchievements => 
      _achievements.where((achievement) => achievement.isInProgress).toList();

  AchievementProvider() {
    _initializeMockAchievements();
  }

  void _initializeMockAchievements() {
    _achievements = [
      // Water achievements
      Achievement(
        id: 'water_beginner',
        title: 'นักดื่มน้ำมือใหม่',
        description: 'ดื่มน้ำครบ 8 แก้วใน 1 วัน',
        iconPath: '💧',
        type: AchievementType.water,
        maxProgress: 1,
        currentProgress: 1,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
        reward: 'ยินดีด้วย! คุณดื่มน้ำครบตามเป้าหมายแล้ว',
      ),
      Achievement(
        id: 'water_week',
        title: 'ดื่มน้ำ 7 วัน',
        description: 'ดื่มน้ำครบเป้าหมายต่อเนื่อง 7 วัน',
        iconPath: '🏆',
        type: AchievementType.water,
        maxProgress: 7,
        currentProgress: 4,
        reward: 'เก่งมาก! คุณดื่มน้ำสม่ำเสมอ',
      ),

      // Exercise achievements
      Achievement(
        id: 'exercise_first',
        title: 'ออกกำลังกายครั้งแรก',
        description: 'ออกกำลังกาย 30 นาทีใน 1 วัน',
        iconPath: '🏃‍♂️',
        type: AchievementType.exercise,
        maxProgress: 1,
        currentProgress: 1,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 1)),
        reward: 'ยอดเยี่ยม! เริ่มต้นที่ดี',
      ),
      Achievement(
        id: 'exercise_week',
        title: 'นักกีฬาสัปดาห์',
        description: 'ออกกำลังกายต่อเนื่อง 7 วัน',
        iconPath: '🎯',
        type: AchievementType.exercise,
        maxProgress: 7,
        currentProgress: 3,
        reward: 'คุณกำลังสร้างนิสัยที่ดี!',
      ),

      // Sleep achievements
      Achievement(
        id: 'sleep_good',
        title: 'นอนหลับเพียงพอ',
        description: 'นอนหลับครบ 8 ชั่วโมงใน 1 คืน',
        iconPath: '😴',
        type: AchievementType.sleep,
        maxProgress: 1,
        currentProgress: 0,
        reward: 'การพักผ่อนเพียงพอคือกุญแจสู่สุขภาพดี',
      ),
      Achievement(
        id: 'sleep_week',
        title: 'นอนดีทั้งสัปดาห์',
        description: 'นอนหลับเพียงพอต่อเนื่อง 7 วัน',
        iconPath: '🌙',
        type: AchievementType.sleep,
        maxProgress: 7,
        currentProgress: 2,
        reward: 'รูปแบบการนอนของคุณยอดเยี่ยม!',
      ),

      // Streak achievements
      Achievement(
        id: 'streak_3days',
        title: 'มุ่งมั่น 3 วัน',
        description: 'บันทึกกิจกรรมต่อเนื่อง 3 วัน',
        iconPath: '🔥',
        type: AchievementType.streak,
        maxProgress: 3,
        currentProgress: 3,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 1)),
        reward: 'ความต่อเนื่องนำไปสู่ความสำเร็จ!',
      ),
      Achievement(
        id: 'streak_week',
        title: 'อุทิศ 1 สัปดาห์',
        description: 'บันทึกกิจกรรมต่อเนื่อง 7 วัน',
        iconPath: '⭐',
        type: AchievementType.streak,
        maxProgress: 7,
        currentProgress: 5,
        reward: 'คุณกำลังสร้างนิสัยใหม่!',
      ),

      // Milestone achievements
      Achievement(
        id: 'first_week',
        title: 'สมาชิกใหม่',
        description: 'ใช้แอพครบ 1 สัปดาห์',
        iconPath: '🎉',
        type: AchievementType.milestone,
        maxProgress: 7,
        currentProgress: 7,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 3)),
        reward: 'ยินดีต้อนรับสู่ชุมชนสุขภาพดี!',
      ),
      Achievement(
        id: 'first_month',
        title: 'สมาชิกประจำ',
        description: 'ใช้แอพครบ 1 เดือน',
        iconPath: '🏅',
        type: AchievementType.milestone,
        maxProgress: 30,
        currentProgress: 12,
        reward: 'คุณคือแรงบันดาลใจให้คนอื่น!',
      ),

      // Weight achievements
      Achievement(
        id: 'weight_first',
        title: 'บันทึกน้ำหนักครั้งแรก',
        description: 'บันทึกน้ำหนักครั้งแรก',
        iconPath: '⚖️',
        type: AchievementType.weight,
        maxProgress: 1,
        currentProgress: 0,
        reward: 'การติดตามน้ำหนักเป็นก้าวแรกสู่เป้าหมาย!',
      ),
      Achievement(
        id: 'weight_consistency',
        title: 'ควบคุมน้ำหนักสม่ำเสมอ',
        description: 'บันทึกน้ำหนักต่อเนื่อง 7 วัน',
        iconPath: '📊',
        type: AchievementType.weight,
        maxProgress: 7,
        currentProgress: 1,
        reward: 'การติดตามสม่ำเสมอคือกุญแจสำคัญ!',
      ),
    ];
  }

  void updateAchievementProgress(String achievementId, int newProgress) {
    final index = _achievements.indexWhere((achievement) => achievement.id == achievementId);
    if (index != -1) {
      final achievement = _achievements[index];
      final updatedAchievement = achievement.copyWith(
        currentProgress: newProgress,
        isUnlocked: newProgress >= achievement.maxProgress,
        unlockedAt: newProgress >= achievement.maxProgress ? DateTime.now() : achievement.unlockedAt,
      );
      _achievements[index] = updatedAchievement;
      notifyListeners();
    }
  }

  void unlockAchievement(String achievementId) {
    final index = _achievements.indexWhere((achievement) => achievement.id == achievementId);
    if (index != -1) {
      _achievements[index] = _achievements[index].copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        currentProgress: _achievements[index].maxProgress,
      );
      notifyListeners();
    }
  }

  Achievement? getAchievementById(String achievementId) {
    try {
      return _achievements.firstWhere((achievement) => achievement.id == achievementId);
    } catch (e) {
      return null;
    }
  }

  List<Achievement> getAchievementsByType(AchievementType type) {
    return _achievements.where((achievement) => achievement.type == type).toList();
  }

  // Simulate progress based on user activities
  void checkWaterAchievements(int dailyWaterCount) {
    if (dailyWaterCount >= 8) {
      updateAchievementProgress('water_beginner', 1);
    }
    // You can add more complex logic for streak achievements
  }

  void checkExerciseAchievements(int dailyExerciseMinutes) {
    if (dailyExerciseMinutes >= 30) {
      updateAchievementProgress('exercise_first', 1);
    }
  }

  void checkSleepAchievements(double dailySleepHours) {
    if (dailySleepHours >= 8.0) {
      updateAchievementProgress('sleep_good', 1);
    }
  }

  // Method to simulate checking achievements based on app usage
  void checkMilestoneAchievements(int daysUsed) {
    if (daysUsed >= 7) {
      updateAchievementProgress('first_week', 7);
    }
    if (daysUsed >= 30) {
      updateAchievementProgress('first_month', 30);
    }
  }
}
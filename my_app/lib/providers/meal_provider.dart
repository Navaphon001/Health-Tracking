import 'package:flutter/foundation.dart';
import '../services/meal_service.dart';
import '../models/meal.dart';

class MealProvider with ChangeNotifier {
  // Legacy meal string (เก็บไว้เพื่อความเข้ากันได้)
  String _meal = '';
  
  // New meal tracking features
  int _todayMealCount = 0;
  Map<String, int> _dailyMealSummary = {};
  bool _isLoading = false;
  String? _error;

  // Legacy getter (เก็บไว้เพื่อความเข้ากันได้)
  String get meal => _meal;

  // New getters
  int get todayMealCount => _todayMealCount;
  Map<String, int> get dailyMealSummary => Map.unmodifiable(_dailyMealSummary);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // สำหรับแสดงใน Dashboard (X/3)
  String get mealProgressText => '$_todayMealCount/3';
  double get mealProgress => (_todayMealCount / 3).clamp(0.0, 1.0);

  // Legacy setter (เก็บไว้เพื่อความเข้ากันได้)
  void setMeal(String newMeal) {
    _meal = newMeal;
    notifyListeners();
  }

  /// โหลดจำนวนมื้ออาหารของวันนี้
  Future<void> loadTodayMealCount({String userId = 'default_user'}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final summary = await MealService.instance.getDailyMealSummary(userId, DateTime.now());
      final totalMeals = summary.values.fold(0, (sum, count) => sum + count);

      _todayMealCount = totalMeals;
      _dailyMealSummary = Map.from(summary);
      _isLoading = false;
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      
      // Log error for debugging
      if (kDebugMode) {
        print('Error loading meal count: $e');
      }
    }
  }

  /// บันทึกมื้ออาหารใหม่และอัปเดต count
  Future<void> saveMeal(Meal meal, {String userId = 'default_user'}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await MealService.instance.saveMealWithLog(meal, userId);
      
      // รีเฟรชข้อมูลหลังบันทึก
      await loadTodayMealCount(userId: userId);
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow; // ส่งต่อ error ไปยัง UI
    }
  }

  /// รีเซ็ตสถานะ error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// รีเฟรชข้อมูล
  Future<void> refresh({String userId = 'default_user'}) async {
    await loadTodayMealCount(userId: userId);
  }

  /// ดึงข้อมูลมื้ออาหารตามวันที่
  Future<List<Meal>> getMealsByDate(DateTime date, {String userId = 'default_user'}) async {
    try {
      return await MealService.instance.getMealsByDate(userId, date);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting meals by date: $e');
      }
      return [];
    }
  }

  /// ดึงข้อมูลมื้ออาหารตามประเภท
  Future<List<Meal>> getMealsByType(DateTime date, MealType mealType, {String userId = 'default_user'}) async {
    try {
      return await MealService.instance.getMealsByType(userId, date, mealType);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting meals by type: $e');
      }
      return [];
    }
  }

  /// ดึงจำนวนมื้ออาหารแต่ละประเภท
  int getMealCountByType(MealType mealType) {
    return _dailyMealSummary[mealType.value] ?? 0;
  }
}

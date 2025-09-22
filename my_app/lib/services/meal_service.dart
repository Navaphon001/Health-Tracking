import 'package:sqflite/sqflite.dart';
import '../models/meal.dart';
import '../models/food_log.dart';
import '../models/nutrition.dart';
import 'app_db.dart';

class MealService {
  static final MealService instance = MealService._();
  MealService._();

  Future<Database> get _db async => AppDb.instance.database;

  // CRUD Operations for Meals
  Future<String> insertMeal(Meal meal) async {
    final db = await _db;
    await db.insert('meals', meal.toMap());
    return meal.id;
  }

  Future<List<Meal>> getMealsByDate(String userId, DateTime date) async {
    final db = await _db;
    final dateStr = date.toIso8601String().split('T')[0]; // yyyy-MM-dd

    final maps = await db.query(
      'meals',
      where: 'user_id = ? AND date(created_at / 1000, "unixepoch") = ?',
      whereArgs: [userId, dateStr],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => Meal.fromMap(map)).toList();
  }

  Future<List<Meal>> getMealsByType(String userId, DateTime date, MealType mealType) async {
    final db = await _db;
    final dateStr = date.toIso8601String().split('T')[0]; // yyyy-MM-dd

    final maps = await db.query(
      'meals',
      where: 'user_id = ? AND meal_type = ? AND date(created_at / 1000, "unixepoch") = ?',
      whereArgs: [userId, mealType.value, dateStr],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => Meal.fromMap(map)).toList();
  }

  Future<int> updateMeal(Meal meal) async {
    final db = await _db;
    return await db.update(
      'meals',
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  Future<int> deleteMeal(String mealId) async {
    final db = await _db;
    return await db.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [mealId],
    );
  }

  // CRUD Operations for Food Logs
  Future<String> insertFoodLog(FoodLog foodLog) async {
    final db = await _db;
    await db.insert('food_logs', foodLog.toMap());
    return foodLog.id;
  }

  Future<FoodLog?> getFoodLogByDate(String userId, DateTime date) async {
    final db = await _db;
    final dateStr = date.toIso8601String().split('T')[0]; // yyyy-MM-dd

    final maps = await db.query(
      'food_logs',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateStr],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return FoodLog.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateFoodLog(FoodLog foodLog) async {
    final db = await _db;
    return await db.update(
      'food_logs',
      foodLog.toMap(),
      where: 'id = ?',
      whereArgs: [foodLog.id],
    );
  }

  // CRUD Operations for Nutrition Database
  Future<String> insertNutrition(Nutrition nutrition) async {
    final db = await _db;
    await db.insert('nutrition_database', nutrition.toMap());
    return nutrition.id;
  }

  Future<List<Nutrition>> searchNutrition(String query) async {
    final db = await _db;
    final maps = await db.query(
      'nutrition_database',
      where: 'food_name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'food_name ASC',
      limit: 50,
    );

    return maps.map((map) => Nutrition.fromMap(map)).toList();
  }

  Future<Nutrition?> getNutritionById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'nutrition_database',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Nutrition.fromMap(maps.first);
    }
    return null;
  }

  // Helper Methods
  Future<FoodLog> getOrCreateFoodLog(String userId, DateTime date) async {
    FoodLog? existing = await getFoodLogByDate(userId, date);
    
    if (existing != null) {
      return existing;
    }

    // Create new food log
    final newFoodLog = FoodLog(
      id: '${userId}_${date.toIso8601String().split('T')[0]}',
      userId: userId,
      date: date,
      lastModified: DateTime.now(),
      mealCount: 0,
    );

    await insertFoodLog(newFoodLog);
    return newFoodLog;
  }

  Future<void> saveMealWithLog(Meal meal, String userId) async {
    final db = await _db;

    await db.transaction((txn) async {
      // 1. Get or create food log for today
      final date = DateTime.now();
      final foodLog = await getOrCreateFoodLog(userId, date);

      // 2. Update meal with food_log_id
      final updatedMeal = meal.copyWith(
        foodLogId: foodLog.id,
        userId: userId,
      );

      // 3. Insert meal
      await txn.insert('meals', updatedMeal.toMap());

      // 4. Update food log meal count
      final currentMealCount = await txn.rawQuery('''
        SELECT COUNT(*) as count 
        FROM meals 
        WHERE food_log_id = ?
      ''', [foodLog.id]);

      final newCount = (currentMealCount.first['count'] as int? ?? 0);
      
      final updatedFoodLog = foodLog.copyWith(
        mealCount: newCount,
        lastModified: DateTime.now(),
      );

      await txn.update(
        'food_logs',
        updatedFoodLog.toMap(),
        where: 'id = ?',
        whereArgs: [foodLog.id],
      );
    });
  }

  // Get daily meal summary
  Future<Map<String, int>> getDailyMealSummary(String userId, DateTime date) async {
    final db = await _db;
    final dateStr = date.toIso8601String().split('T')[0];

    final maps = await db.rawQuery('''
      SELECT meal_type, COUNT(*) as count
      FROM meals
      WHERE user_id = ? AND date(created_at / 1000, "unixepoch") = ?
      GROUP BY meal_type
    ''', [userId, dateStr]);

    final summary = <String, int>{};
    for (final mealType in MealType.values) {
      summary[mealType.value] = 0;
    }

    for (final map in maps) {
      summary[map['meal_type'] as String] = map['count'] as int;
    }

    return summary;
  }
}
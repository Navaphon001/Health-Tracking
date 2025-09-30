import 'dart:convert';
import 'package:http/http.dart' as http;
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
    // Use transaction to insert meal and update food_log atomically
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

      // After local insertion, attempt to sync to remote backend (best-effort)
      try {
        await createMealRemote(updatedMeal);
        // Optionally, we could update local record with returned remote fields
      } catch (e) {
        // ignore remote errors for offline-first (offline-first) flow
      }
    });
  }

  // -------------------- Remote API integration --------------------
  // Replace with your actual backend base URL
  static const String _baseUrl = 'http://10.0.2.2:8000';

  Future<List<Meal>> getMealsRemote() async {
    final resp = await http.get(Uri.parse('$_baseUrl/meals'));
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch meals: ${resp.statusCode}');
  }

  Future<Meal> createMealRemote(Meal meal) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/meals'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(meal.toJson()),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final Map<String, dynamic> json = jsonDecode(resp.body) as Map<String, dynamic>;
      return Meal.fromJson(json);
    }

    throw Exception('Failed to create remote meal: ${resp.statusCode} ${resp.body}');
  }

  Future<Meal> updateMealRemote(Meal meal) async {
    final resp = await http.put(
      Uri.parse('$_baseUrl/meals/${meal.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(meal.toJson()),
    );

    if (resp.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(resp.body) as Map<String, dynamic>;
      return Meal.fromJson(json);
    }

    throw Exception('Failed to update remote meal: ${resp.statusCode}');
  }

  Future<void> deleteMealRemote(String mealId) async {
    final resp = await http.delete(Uri.parse('$_baseUrl/meals/$mealId'));
    if (resp.statusCode != 200) {
      throw Exception('Failed to delete remote meal: ${resp.statusCode}');
    }
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
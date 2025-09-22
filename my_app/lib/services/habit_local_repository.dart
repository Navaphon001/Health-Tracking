// lib/services/habit_local_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


import '../shared/date_key.dart';
import 'app_db.dart';

// (ยังใช้โมเดลเดิมของคุณได้ ถ้าต้องการ)
import '../models/water_day.dart';
import '../models/exercise_activity.dart';
import '../models/sleep_log.dart';

class HabitLocalRepository {
  // ---------- SharedPreferences keys (ยังใช้แค่ "รายการประเภทกิจกรรม") ----------
  static const _kExercisesKey = 'exercises'; // JSON list (ExerciseActivity catalog)

  // =========================
  // WATER (SQLite: water_intake_logs)
  // =========================

  Future<Map<String, dynamic>?> getWaterDaily(DateTime day) async {
    final db = await AppDb.instance.database;
    final key = dateKeyOf(day);
    final rows = await db.query(
      'water_intake_logs',
      where: 'date_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  Future<void> upsertWater({
    required DateTime day,
    int deltaCount = 1,
    int deltaMl = 0,
    int? goalCount,
    int? goalMl,
  }) async {
    final db = await AppDb.instance.database;
    final key = dateKeyOf(day);
    final now = nowEpochMillis();

    await db.rawInsert('''
      INSERT INTO water_intake_logs(date_key, count, ml, goal_count, goal_ml, created_at, updated_at)
      VALUES(?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(date_key) DO UPDATE SET
        count       = water_intake_logs.count + excluded.count,
        ml          = water_intake_logs.ml    + excluded.ml,
        goal_count  = COALESCE(excluded.goal_count, water_intake_logs.goal_count),
        goal_ml     = COALESCE(excluded.goal_ml,    water_intake_logs.goal_ml),
        updated_at  = excluded.updated_at;
    ''', [key, deltaCount, deltaMl, goalCount, goalMl, now, now]);
  }

  Future<WaterDay> getWaterToday({int defaultGoal = 8}) async {
    final row = await getWaterDaily(DateTime.now());
    final key = dateKeyOf(DateTime.now());
    final count = row?['count'] as int? ?? 0;
    final goal = row?['goal_count'] as int? ?? defaultGoal;
    return WaterDay(date: key, count: count, goal: goal);
  }

  Future<WaterDay> incrementWater([int step = 1]) async {
    await upsertWater(day: DateTime.now(), deltaCount: step);
    return getWaterToday();
  }

  // =========================
  // SLEEP (SQLite: sleep_daily) — เก็บชั่วโมง/นาทีรวมต่อวัน
  // =========================

  Future<Map<String, dynamic>?> getSleepDaily(DateTime day) async {
    final db = await AppDb.instance.database;
    final key = dateKeyOf(day);
    final rows = await db.query(
      'sleep_daily',
      where: 'date_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  Future<void> setSleepHM({
    required DateTime day,
    required int hours,
    required int minutes,
    int? quality,
    String? note,
  }) async {
    final db = await AppDb.instance.database;
    final key = dateKeyOf(day);
    final hm = normalizeHM(hours, minutes); // แคป 0..24h + แตก h/m
    final now = nowEpochMillis();

    await db.rawInsert('''
      INSERT INTO sleep_daily(date_key, hours, minutes, quality, note, created_at, updated_at)
      VALUES(?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(date_key) DO UPDATE SET
        hours      = excluded.hours,
        minutes    = excluded.minutes,
        quality    = COALESCE(excluded.quality, sleep_daily.quality),
        note       = COALESCE(excluded.note,    sleep_daily.note),
        updated_at = excluded.updated_at;
    ''', [key, hm['hours'], hm['minutes'], quality, note, now, now]);
  }

  Future<void> addSleepMinutes({
    required DateTime day,
    required int deltaMinutes,
  }) async {
    final row = await getSleepDaily(day);
    final curH = (row?['hours'] as int?) ?? 0;
    final curM = (row?['minutes'] as int?) ?? 0;
    final hm = normalizeHM(curH, curM + deltaMinutes);

    final db = await AppDb.instance.database;
    final key = dateKeyOf(day);
    final now = nowEpochMillis();

    await db.rawInsert('''
      INSERT INTO sleep_daily(date_key, hours, minutes, created_at, updated_at)
      VALUES(?, ?, ?, ?, ?)
      ON CONFLICT(date_key) DO UPDATE SET
        hours      = ?,
        minutes    = ?,
        updated_at = ?;
    ''', [key, hm['hours'], hm['minutes'], now, now, hm['hours'], hm['minutes'], now]);
  }

  // =========================
  // EXERCISE (SQLite: exercise_daily) — รวมเวลาต่อ "วัน"
  // =========================

  Future<void> addExerciseMinutes({
    required DateTime day,
    required int deltaMinutes,
    double? calories,
    String? notes,
  }) async {
    final db  = await AppDb.instance.database;
    final key = dateKeyOf(day);
    final now = nowEpochMillis();

    await db.rawInsert('''
      INSERT INTO exercise_daily(date_key, duration_min, calories_burned, notes, created_at, updated_at)
      VALUES(?, ?, ?, ?, ?, ?)
      ON CONFLICT(date_key) DO UPDATE SET
        duration_min    = exercise_daily.duration_min + excluded.duration_min,
        calories_burned = COALESCE(exercise_daily.calories_burned,0) + COALESCE(excluded.calories_burned,0),
        notes           = COALESCE(excluded.notes, exercise_daily.notes),
        updated_at      = excluded.updated_at;
    ''', [key, deltaMinutes, calories, notes, now, now]);
  }

  Future<Map<String, dynamic>?> getExerciseDaily(DateTime day) async {
    final db  = await AppDb.instance.database;
    final key = dateKeyOf(day);
    final rows = await db.query('exercise_daily', where: 'date_key = ?', whereArgs: [key], limit: 1);
    return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first);
  }

  // =========================
  // สรุปรายวันรวม (สำหรับ Dashboard)
  // =========================

  Future<Map<String, dynamic>> dailySummary(DateTime day) async {
    final db  = await AppDb.instance.database;
    final key = dateKeyOf(day);

    // sleep
    final s = await getSleepDaily(day);
    final sleepMinutes = s == null ? 0 : ((s['hours'] as int) * 60 + (s['minutes'] as int));

    // water
    final w = await getWaterDaily(day);
    final waterCount = w?['count'] as int? ?? 0;
    final waterMl    = w?['ml'] as int? ?? 0;

    // exercise (อ่านจาก exercise_daily โดยตรง)
    final e = await db.rawQuery(
      'SELECT duration_min AS mins FROM exercise_daily WHERE date_key = ?',
      [key],
    );
    final exerciseMinutes = e.isEmpty ? 0 : ((e.first['mins'] as int?) ?? 0);

    return {
      'date_key'        : key,
      'sleep_minutes'   : sleepMinutes,
      'water_count'     : waterCount,
      'water_ml'        : waterMl,
      'exercise_minutes': exerciseMinutes,
    };
  }

  // =========================
  // Exercise "Catalog" (ชื่อ/สี/ไอคอน) — เก็บด้วย SharedPreferences ต่อไปก่อน
  // =========================

  Future<List<ExerciseActivity>> getExercises() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kExercisesKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List)
        .map((e) => ExerciseActivity.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return list;
  }

  Future<ExerciseActivity> upsertExercise(ExerciseActivity a) async {
    final sp = await SharedPreferences.getInstance();
    final list = await getExercises();

    if (a.id.isEmpty) {
      a = a.copyWith(id: DateTime.now().microsecondsSinceEpoch.toString());
    }

    final i = list.indexWhere((e) => e.id == a.id);
    if (i == -1) list.add(a); else list[i] = a;

    await sp.setString(
      _kExercisesKey,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
    return a;
  }

  Future<void> deleteExercise(String id) async {
    final sp = await SharedPreferences.getInstance();
    final list = await getExercises();
    list.removeWhere((e) => e.id == id);
    await sp.setString(_kExercisesKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  // =========================
  // (OPTIONAL) ของเดิมที่ใช้ SleepLog ผ่าน SP
  // =========================

  @Deprecated('Use sleep_daily via setSleepHM/getSleepDaily instead.')
  Future<SleepLog?> getLatestSleep() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('sleep:latest');
    if (raw == null || raw.isEmpty) return null;
    return SleepLog.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  @Deprecated('Use sleep_daily via setSleepHM/getSleepDaily instead.')
  Future<SleepLog> saveSleep(SleepLog log) async {
    final sp = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(log.toJson());
    await sp.setString('sleep:latest', jsonStr);
    await sp.setString('sleep:${log.startedOn}', jsonStr);
    return log;
  }
}

// lib/services/habit_local_repository.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../shared/date_key.dart';

// โมเดลที่มีใช้งาน
import '../models/water_day.dart';
import '../models/exercise_activity.dart';
import '../models/sleep_log.dart';

import '../charts/chart_point.dart';
import '../charts/fill_daily_series.dart';
import '../models/exercise_log.dart';

class HabitLocalRepository {
  final Database db;
  HabitLocalRepository(this.db);

  // ---------- SharedPreferences keys ----------
  static const _kExercisesKey = 'exercises';          // แคตตาล็อกกิจกรรม
  static const _kExerciseRatesKey = 'exercise:rates'; // { type: calPerMinute }

  // ค่าเริ่มต้น ถ้ายังไม่เคยตั้งค่า
  static const Map<String, double> _kDefaultExerciseRates = {
    // Values are kcal per minute (midpoints from your specifications)
    // run: 0.22 kcal/sec -> 0.22*60 = 13.2 kcal/min
    'run': 13.2,
    // walk: 30 min -> 75-150 kcal => ~2.5 - 5.0 kcal/min -> midpoint 3.75
    'walk': 3.75,
    // bike/general defaults: 10 min -> 40-50 kcal => 4.0-5.0 kcal/min -> midpoint 4.5
    'bike': 4.5,
    // swim: 0.006-0.02 kcal/sec -> 0.36 - 1.2 kcal/min -> midpoint 0.78
    'swim': 0.78,
    // sport: 330 kcal in 10 min -> 33 kcal/min
    'sport': 33.0,
    'general': 0.0,
  };

  // =========================
  // WATER (SQLite: water_intake_logs)
  // =========================

  Future<Map<String, dynamic>?> getWaterDaily(DateTime day) async {
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
  // SLEEP (SQLite: sleep_daily)
  // =========================

  Future<Map<String, dynamic>?> getSleepDaily(DateTime day) async {
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
    final key = dateKeyOf(day);
    final hm = normalizeHM(hours, minutes);
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
  // EXERCISE (SQLite: exercise_daily)
  // =========================
  // EXERCISE LOGS (SQLite: exercise_logs)
  // table schema (example):
  // CREATE TABLE exercise_logs (
  //   id TEXT PRIMARY KEY,
  //   user_id TEXT NOT NULL,
  //   date TEXT NOT NULL, -- YYYY-MM-DD
  //   activity_type TEXT NOT NULL,
  //   duration INTEGER NOT NULL, -- seconds
  //   calories_burned REAL,
  //   notes TEXT,
  //   created_at INTEGER,
  //   updated_at INTEGER
  // );

  Future<void> addExerciseLog(ExerciseLog log) async {
    await db.insert(
      'exercise_logs',
      {
        'id': log.id,
        'user_id': log.userId,
        'date': log.date.toIso8601String(),
        'activity_type': describeEnum(log.activityType),
        'duration': log.duration,
        'calories_burned': log.caloriesBurned,
        'notes': log.notes,
        'created_at': log.createdAt.millisecondsSinceEpoch,
        'updated_at': log.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExerciseLog>> getExerciseLogsForUserByDate(String userId, DateTime date) async {
    final dayStr = DateTime(date.year, date.month, date.day).toIso8601String();
    final rows = await db.query('exercise_logs', where: 'user_id = ? AND date = ?', whereArgs: [userId, dayStr]);
    return rows.map((r) {
      return ExerciseLog.fromJson(Map<String, dynamic>.from(r));
    }).toList();
  }

  Future<void> deleteExerciseLog(String id) async {
    await db.delete('exercise_logs', where: 'id = ?', whereArgs: [id]);
  }
  // กติกา: แคล = (cal/นาที ของประเภทนั้น) × นาที
  // เก็บอัตรา (cal/นาที) ตาม type ไว้ใน SharedPreferences หรือส่งมาจาก UI ตอนบันทึก

  Future<void> setExerciseRate(String type, double calPerMinute) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kExerciseRatesKey);
    final Map<String, dynamic> map =
        raw == null || raw.isEmpty ? {} : Map<String, dynamic>.from(jsonDecode(raw));
    map[type.toLowerCase()] = calPerMinute; // เก็บเป็นตัวพิมพ์เล็กเสมอ
    await sp.setString(_kExerciseRatesKey, jsonEncode(map));
  }

  Future<double?> getExerciseRate(String type) async {
    final lower = type.toLowerCase();
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kExerciseRatesKey);

    if (raw != null && raw.isNotEmpty) {
      final map = Map<String, dynamic>.from(jsonDecode(raw));
      final v = map[lower] ?? map[type]; // เผื่อเคยเก็บแบบไม่ lower
      if (v != null) {
        return (v is num) ? v.toDouble() : double.tryParse(v.toString());
      }
    }
    // ถ้ายังไม่เคยตั้งค่า -> ใช้ค่า default
    return _kDefaultExerciseRates[lower];
  }

  Future<Map<String, double>> getAllExerciseRates() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kExerciseRatesKey);

    // เริ่มจากค่า default
    final out = Map<String, double>.from(_kDefaultExerciseRates);

    if (raw != null && raw.isNotEmpty) {
      final map = Map<String, dynamic>.from(jsonDecode(raw));
      for (final e in map.entries) {
        final k = e.key.toString().toLowerCase();
        final v = (e.value is num)
            ? (e.value as num).toDouble()
            : double.tryParse(e.value.toString()) ?? 0.0;
        out[k] = v; // override ค่า default
      }
    }
    return out;
  }

  /// เพิ่มเวลาการออกกำลังแบบใช้ "อัตรา/นาที × นาที"
  /// - ถ้า [caloriesPerMinute] ถูกส่งมา จะใช้ค่านั้น
  /// - ถ้าไม่ส่ง จะอ่านจาก SharedPreferences (มี default ให้)
  Future<void> addExerciseMinutes({
    required DateTime day,
    required int deltaMinutes,
    String type = 'general',
    double? caloriesPerMinute,
    String? notes,
  }) async {
    final key = dateKeyOf(day);
    final now = nowEpochMillis();

    final rate = caloriesPerMinute ?? (await getExerciseRate(type)) ?? 0.0;
  final double cal = rate * deltaMinutes;

    await db.rawInsert('''
      INSERT INTO exercise_daily(date_key, type, duration_min, calories_burned, notes, created_at, updated_at)
      VALUES(?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(date_key, type) DO UPDATE SET
        duration_min    = exercise_daily.duration_min + excluded.duration_min,
        calories_burned = COALESCE(exercise_daily.calories_burned,0) + excluded.calories_burned,
        notes           = COALESCE(excluded.notes, exercise_daily.notes),
        updated_at      = excluded.updated_at;
  ''', [key, type, deltaMinutes, cal, notes, now, now]);
  }

  /// รวมทุกชนิดของวันนั้น
  Future<Map<String, dynamic>?> getExerciseDaily(DateTime day) async {
    final key = dateKeyOf(day);
    final rows = await db.rawQuery(
      '''
      SELECT
        ? AS date_key,
        COALESCE(SUM(duration_min), 0)                 AS duration_min,
        COALESCE(SUM(COALESCE(calories_burned,0)), 0)  AS calories_burned
      FROM exercise_daily
      WHERE date_key = ?
      ''',
      [key, key],
    );
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  Future<Map<String, dynamic>?> getExerciseDailyByType(DateTime day, String type) async {
    final key = dateKeyOf(day);
    final rows = await db.query(
      'exercise_daily',
      columns: ['date_key', 'type', 'duration_min', 'calories_burned', 'notes', 'created_at', 'updated_at'],
      where: 'date_key = ? AND type = ?',
      whereArgs: [key, type],
      limit: 1,
    );
    return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first);
  }

  /// ไล่คำนวณย้อนหลังให้แถวที่ calories_burned เป็น 0/NULL โดยใช้อัตรา (kcal/นาที) ปัจจุบัน
  Future<int> backfillExerciseCalories() async {
    final rows = await db.query(
      'exercise_daily',
      columns: ['date_key', 'type', 'duration_min', 'calories_burned'],
    );

    final now = nowEpochMillis();
    var updated = 0;

    for (final r in rows) {
      final mins = (r['duration_min'] as int?) ?? 0;
      final cur  = (r['calories_burned'] as num?)?.toDouble() ?? 0.0;
      if (mins > 0 && cur == 0.0) {
        final type = (r['type'] as String?) ?? 'general';
        final rate = (await getExerciseRate(type)) ?? 0.0;
        await db.update(
          'exercise_daily',
          {'calories_burned': rate * mins, 'updated_at': now},
          where: 'date_key = ? AND type = ?',
          whereArgs: [r['date_key'], type],
        );
        updated++;
      }
    }
    return updated;
  }

  // =========================
  // SUMMARY (สำหรับ Dashboard)
  // =========================

  Future<Map<String, dynamic>> dailySummary(DateTime day) async {
    final key = dateKeyOf(day);

    final s = await getSleepDaily(day);
    final sleepMinutes = s == null ? 0 : (((s['hours'] as int?) ?? 0) * 60 + ((s['minutes'] as int?) ?? 0));

    final w = await getWaterDaily(day);
    final waterCount = w?['count'] as int? ?? 0;
    final waterMl    = w?['ml'] as int? ?? 0;

    final e = await db.rawQuery(
      '''
      SELECT
        COALESCE(SUM(duration_min), 0)                AS mins,
        COALESCE(SUM(COALESCE(calories_burned,0)),0) AS kcal
      FROM exercise_daily
      WHERE date_key = ?
      ''',
      [key],
    );
    final exerciseMinutes  = e.isEmpty ? 0   : ((e.first['mins'] as int?) ?? 0);
    final exerciseCalories = e.isEmpty ? 0.0 : ((e.first['kcal'] as num?) ?? 0).toDouble();

    return {
      'date_key'          : key,
      'sleep_minutes'     : sleepMinutes,
      'water_count'       : waterCount,
      'water_ml'          : waterMl,
      'exercise_minutes'  : exerciseMinutes,
      'exercise_calories' : exerciseCalories,
    };
  }

  // =========================
  // Exercise "Catalog" (ผ่าน SharedPreferences)
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
    if (i == -1) {
      list.add(a);
    } else {
      list[i] = a;
    }

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
  // (LEGACY) Sleep ผ่าน SharedPreferences เพื่อรองรับ HabitNotifier เดิม
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

  // =========================
  // CHART SERIES
  // =========================

  Future<List<ChartPoint>> fetchSleepHoursSeries({int days = 14}) async {
    final range = lastNDays(days);
    final rows = await db.query(
      'sleep_daily',
      columns: ['date_key', 'hours', 'minutes'],
      where: 'date_key BETWEEN ? AND ?',
      whereArgs: [dateKeyOf(range.start), dateKeyOf(range.end)],
      orderBy: 'date_key',
    );

    final map = <String, double>{};
    for (final r in rows) {
      final h = (r['hours'] as int?) ?? 0;
      final m = (r['minutes'] as int?) ?? 0;
      map[r['date_key'] as String] = h + (m / 60.0);
    }

    return fillMissingDaysWithZero(
      start: range.start,
      end: range.end,
      valueByDateKey: map,
    );
  }

  @Deprecated('Use fetchWaterMlSeries instead.')
  Future<List<ChartPoint>> fetchWaterCountSeries({int days = 14}) async {
    final range = lastNDays(days);
    final rows = await db.query(
      'water_intake_logs',
      columns: ['date_key', 'count'],
      where: 'date_key BETWEEN ? AND ?',
      whereArgs: [dateKeyOf(range.start), dateKeyOf(range.end)],
      orderBy: 'date_key',
    );

    final map = <String, double>{};
    for (final r in rows) {
      map[r['date_key'] as String] = ((r['count'] as int?) ?? 0).toDouble();
    }

    return fillMissingDaysWithZero(
      start: range.start,
      end: range.end,
      valueByDateKey: map,
    );
  }

  Future<List<ChartPoint>> fetchWaterMlSeries({int days = 14}) async {
    final range = lastNDays(days);
    final rows = await db.query(
      'water_intake_logs',
      columns: ['date_key', 'ml'],
      where: 'date_key BETWEEN ? AND ?',
      whereArgs: [dateKeyOf(range.start), dateKeyOf(range.end)],
      orderBy: 'date_key',
    );

    final map = <String, double>{};
    for (final r in rows) {
      map[r['date_key'] as String] = ((r['ml'] as int?) ?? 0).toDouble();
    }

    return fillMissingDaysWithZero(
      start: range.start,
      end: range.end,
      valueByDateKey: map,
    );
  }

  @Deprecated('Use fetchExerciseCaloriesSeries instead.')
  Future<List<ChartPoint>> fetchExerciseDurationSeries({int days = 14}) async {
    final range = lastNDays(days);
    final rows = await db.rawQuery(
      '''
      SELECT date_key, COALESCE(SUM(duration_min), 0) AS duration_min
      FROM exercise_daily
      WHERE date_key BETWEEN ? AND ?
      GROUP BY date_key
      ORDER BY date_key
      ''',
      [dateKeyOf(range.start), dateKeyOf(range.end)],
    );

    final map = <String, double>{};
    for (final r in rows) {
      map[r['date_key'] as String] =
          ((r['duration_min'] as int?) ?? 0).toDouble();
    }

    return fillMissingDaysWithZero(
      start: range.start,
      end: range.end,
      valueByDateKey: map,
    );
  }

  Future<List<ChartPoint>> fetchExerciseCaloriesSeries({int days = 14}) async {
    final range = lastNDays(days);
    final rows = await db.rawQuery(
      '''
      SELECT date_key,
             COALESCE(SUM(COALESCE(calories_burned, 0)), 0) AS kcal
      FROM exercise_daily
      WHERE date_key BETWEEN ? AND ?
      GROUP BY date_key
      ORDER BY date_key
      ''',
      [dateKeyOf(range.start), dateKeyOf(range.end)],
    );

    final map = <String, double>{};
    for (final r in rows) {
      final v = (r['kcal'] as num?) ?? 0;
      map[r['date_key'] as String] = v.toDouble();
    }

    return fillMissingDaysWithZero(
      start: range.start,
      end: range.end,
      valueByDateKey: map,
    );
  }

  Future<List<ChartPoint>> fetchExerciseDurationSeriesByType({
    required String type,
    int days = 14,
  }) async {
    final range = lastNDays(days);
    final rows = await db.query(
      'exercise_daily',
      columns: ['date_key', 'duration_min'],
      where: 'type = ? AND date_key BETWEEN ? AND ?',
      whereArgs: [type, dateKeyOf(range.start), dateKeyOf(range.end)],
      orderBy: 'date_key',
    );

    final map = <String, double>{};
    for (final r in rows) {
      map[r['date_key'] as String] =
          ((r['duration_min'] as int?) ?? 0).toDouble();
    }

    return fillMissingDaysWithZero(
      start: range.start,
      end: range.end,
      valueByDateKey: map,
    );
  }
}

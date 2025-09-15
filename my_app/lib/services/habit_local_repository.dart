import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/water_day.dart';
import '../models/exercise_activity.dart';
import '../models/sleep_log.dart';

class HabitLocalRepository {
  static const _kWaterGoalKey = 'water:goal';   // int (default 8)
  static const _kWaterPrefix = 'water:';        // 'water:yyyy-MM-dd' => int count
  static const _kExercisesKey = 'exercises';    // JSON list
  static const _kSleepLatest = 'sleep:latest';  // JSON object
  static const _kSleepPrefix = 'sleep:';        // 'sleep:yyyy-MM-dd' => JSON (history)

  // ===== Water =====
  Future<WaterDay> getWaterToday() async {
    final sp = await SharedPreferences.getInstance();
    final date = WaterDay.keyFromDate(DateTime.now());
    final count = sp.getInt('$_kWaterPrefix$date') ?? 0;
    final goal = sp.getInt(_kWaterGoalKey) ?? 8;
    return WaterDay(date: date, count: count, goal: goal);
  }

  Future<WaterDay> incrementWater([int step = 1]) async {
    final sp = await SharedPreferences.getInstance();
    final date = WaterDay.keyFromDate(DateTime.now());
    final key = '$_kWaterPrefix$date';
    final newCount = (sp.getInt(key) ?? 0) + step;
    await sp.setInt(key, newCount);
    final goal = sp.getInt(_kWaterGoalKey) ?? 8;
    return WaterDay(date: date, count: newCount, goal: goal);
  }

  // ===== Exercise =====
  Future<List<ExerciseActivity>> getExercises() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kExercisesKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(ExerciseActivity.fromJson).toList();
  }

  Future<ExerciseActivity> upsertExercise(ExerciseActivity a) async {
    final sp = await SharedPreferences.getInstance();
    final list = await getExercises();
    if (a.id.isEmpty) {
      a = a.copyWith(id: DateTime.now().microsecondsSinceEpoch.toString());
    }
    final i = list.indexWhere((e) => e.id == a.id);
    if (i == -1) list.add(a); else list[i] = a;
    await sp.setString(_kExercisesKey, jsonEncode(list.map((e) => e.toJson()).toList()));
    return a;
  }

  Future<void> deleteExercise(String id) async {
    final sp = await SharedPreferences.getInstance();
    final list = await getExercises();
    list.removeWhere((e) => e.id == id);
    await sp.setString(_kExercisesKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  // ===== Sleep =====
  Future<SleepLog?> getLatestSleep() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kSleepLatest);
    if (raw == null || raw.isEmpty) return null;
    return SleepLog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<SleepLog> saveSleep(SleepLog log) async {
    final sp = await SharedPreferences.getInstance();
    final json = jsonEncode(log.toJson());
    await sp.setString(_kSleepLatest, json);
    await sp.setString('$_kSleepPrefix${log.startedOn}', json); // เก็บย้อนหลัง
    return log;
  }
}

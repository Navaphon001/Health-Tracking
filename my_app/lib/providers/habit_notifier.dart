// lib/providers/habit_notifier.dart
import 'package:flutter/material.dart';
import '../models/water_day.dart';
import '../models/exercise_activity.dart';
import '../models/sleep_log.dart';
import '../services/habit_local_repository.dart';
import '../shared/snack_fn.dart';

class HabitNotifier extends ChangeNotifier {
  final _local = HabitLocalRepository();

  // Snack callback (เลือกใช้)
  SnackFn? _snackFn;
  void setSnackBarCallback(SnackFn fn) => _snackFn = fn;

  // ===== STATES =====
  int dailyWaterCount = 0;
  int dailyWaterGoal = 8;
  List<ExerciseActivity> exerciseActivities = [];
  Map<String, dynamic>? latestSleepLog; // เข้ากับ UI เดิม

  // ===== Water =====
  Future<void> fetchDailyWaterIntake() async {
    try {
      final day = await _local.getWaterToday();
      dailyWaterCount = day.count;
      dailyWaterGoal = day.goal;
      notifyListeners();
    } catch (_) {
      _snackFn?.call('โหลดข้อมูลน้ำดื่มล้มเหลว', isError: true);
    }
  }

  Future<void> incrementWaterIntake([int step = 1]) async {
    try {
      final day = await _local.incrementWater(step);
      dailyWaterCount = day.count;
      dailyWaterGoal = day.goal;
      notifyListeners();
    } catch (_) {
      _snackFn?.call('บันทึกน้ำดื่มล้มเหลว', isError: true);
    }
  }

  // ===== Exercise =====
  Future<void> fetchExerciseActivities() async {
    try {
      exerciseActivities = await _local.getExercises();
      notifyListeners();
    } catch (_) {
      _snackFn?.call('โหลดกิจกรรมล้มเหลว', isError: true);
    }
  }

  Future<void> saveExerciseActivity(ExerciseActivity a) async {
    try {
      final saved = await _local.upsertExercise(a);
      final i = exerciseActivities.indexWhere((e) => e.id == saved.id);
      if (i == -1) exerciseActivities.add(saved); else exerciseActivities[i] = saved;
      notifyListeners();
      _snackFn?.call('บันทึกกิจกรรมสำเร็จ');
    } catch (_) {
      _snackFn?.call('บันทึกกิจกรรมล้มเหลว', isError: true);
    }
  }

  Future<void> deleteExerciseActivity(String id) async {
    try {
      await _local.deleteExercise(id);
      exerciseActivities.removeWhere((e) => e.id == id);
      notifyListeners();
      _snackFn?.call('ลบกิจกรรมแล้ว');
    } catch (_) {
      _snackFn?.call('ลบกิจกรรมล้มเหลว', isError: true);
    }
  }

  // ===== Sleep =====
  Future<void> fetchLatestSleepLog() async {
    try {
      final s = await _local.getLatestSleep();
      latestSleepLog = (s == null)
          ? null
          : {
              'bedTime': _hhmm(s.bedTime),
              'wakeTime': _hhmm(s.wakeTime),
              'starCount': s.starCount,
            };
      notifyListeners();
    } catch (_) {
      _snackFn?.call('โหลดข้อมูลการนอนล้มเหลว', isError: true);
    }
  }

  Future<void> saveSleepLog({
    required TimeOfDay bedTime,
    required TimeOfDay wakeTime,
    required int starCount,
  }) async {
    try {
      final startedOn = _dateKey(DateTime.now());
      final saved = await _local.saveSleep(SleepLog(
        id: startedOn, bedTime: bedTime, wakeTime: wakeTime, starCount: starCount, startedOn: startedOn,
      ));
      latestSleepLog = {
        'bedTime': _hhmm(saved.bedTime),
        'wakeTime': _hhmm(saved.wakeTime),
        'starCount': saved.starCount,
      };
      notifyListeners();
      _snackFn?.call('บันทึกการนอนแล้ว');
    } catch (_) {
      _snackFn?.call('บันทึกการนอนล้มเหลว', isError: true);
    }
  }

  // helpers
  String _hhmm(TimeOfDay t) => '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  String _dateKey(DateTime dt) => '${dt.year.toString().padLeft(4,'0')}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
}

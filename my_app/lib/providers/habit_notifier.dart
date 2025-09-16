// lib/providers/habit_notifier.dart
import 'dart:async'; // ให้ Timer ใช้งานได้
import 'package:flutter/material.dart';

import '../models/water_day.dart';            // (ไม่จำเป็นต้องใช้ตรง ๆ ก็ได้ แต่เผื่อ type checking)
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
  Map<String, dynamic>? latestSleepLog; // สำหรับ preload หน้า Sleep

  // ===== Exercise timers (ทำงานต่อเนื่องข้ามหน้า) =====
  final Map<String, Timer> _exerciseTimers = {};
  final Map<String, Duration> _startRemaining = {}; // id -> remaining ตอนเริ่มรอบล่าสุด

  // ---------------- Exercise: Timer controls ----------------
  Future<void> startExerciseTimer(ExerciseActivity a) async {
    // กันซ้อนและกัน race
    await stopExerciseTimer(a.id, persist: false);

    a.isRunning = true;
    if (a.remainingDuration.inSeconds <= 0) {
      a.remainingDuration = a.goalDuration;
    }
    _startRemaining[a.id] = a.remainingDuration;
    notifyListeners();

    _exerciseTimers[a.id] = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (a.remainingDuration.inSeconds > 0) {
        a.remainingDuration -= const Duration(seconds: 1);
        notifyListeners(); // แจ้ง UI ทุกวินาที
      } else {
        t.cancel();
        _exerciseTimers.remove(a.id);
        await stopExerciseTimer(a.id, persist: true); // บันทึกนาทีของรอบนี้
      }
    });
  }

  Future<void> stopExerciseTimer(String id, {bool persist = true}) async {
    // ปิด timer ถ้ามี
    _exerciseTimers.remove(id)?.cancel();

    final i = exerciseActivities.indexWhere((e) => e.id == id);
    if (i == -1) return;
    final a = exerciseActivities[i];

    // คำนวณนาทีของ "รอบนี้" เท่านั้น
    final startRem = _startRemaining.remove(id) ?? a.goalDuration;
    final curRem   = a.remainingDuration;
    final delta    = startRem - curRem;          // Duration ที่ทำไปรอบนี้
    final deltaMin = (delta.inSeconds ~/ 60);    // ปัดลงเป็นนาทีเต็ม

    // อัปเดตสถานะ
    a.isRunning = false;
    notifyListeners();

    // Persist เฉพาะกรณีต้องการและมีเวลา > 0 นาที
    if (persist && deltaMin > 0) {
      await _local.addExerciseMinutes(
        day: DateTime.now(),
        deltaMinutes: deltaMin,
      );
      _snackFn?.call('บันทึกออกกำลังกาย +$deltaMin นาที');
    }
  }

  Future<void> resetExerciseTimer(String id) async {
    await stopExerciseTimer(id, persist: false); // หยุดรอบนี้แต่ไม่บันทึก
    final i = exerciseActivities.indexWhere((e) => e.id == id);
    if (i != -1) {
      final a = exerciseActivities[i];
      a.remainingDuration = a.goalDuration;
      a.isRunning = false;
      notifyListeners();
    }
  }

  // ---------------- Water ----------------
  Future<void> fetchDailyWaterIntake() async {
    try {
      final day = await _local.getWaterToday();
      dailyWaterCount = day.count;
      dailyWaterGoal  = day.goal;
      notifyListeners();
    } catch (_) {
      _snackFn?.call('โหลดข้อมูลน้ำดื่มล้มเหลว', isError: true);
    }
  }

  Future<void> incrementWaterIntake([int step = 1]) async {
    try {
      final day = await _local.incrementWater(step);
      dailyWaterCount = day.count;
      dailyWaterGoal  = day.goal;
      notifyListeners();
    } catch (_) {
      _snackFn?.call('บันทึกน้ำดื่มล้มเหลว', isError: true);
    }
  }

  // ---------------- Exercise: Catalog (ชื่อ/เวลา/เป้าหมาย) ----------------
  Future<void> fetchExerciseActivities() async {
    try {
      final fetched = await _local.getExercises();

      // map ของของเดิมเพื่อถือ instance เดิมไว้ (รักษา timer/สถานะ runtime)
      final byId = { for (final e in exerciseActivities) e.id: e };

      final merged = <ExerciseActivity>[];
      for (final f in fetched) {
        final exist = byId[f.id];
        if (exist != null) {
          // อัปเดตเฉพาะข้อมูลจาก storage แต่คง runtime เดิม
          exist.name = f.name;
          exist.goalDuration = f.goalDuration;
          exist.scheduledTime = f.scheduledTime;
          // ไม่แตะ: exist.remainingDuration / exist.isRunning
          merged.add(exist);
        } else {
          // รายการใหม่ → ตั้งค่า runtime defaults
          f.remainingDuration ??= f.goalDuration;
          f.isRunning ??= false;
          merged.add(f);
        }
      }

      // ถ้ามีของเดิมบางตัวไม่อยู่ใน fetched แล้ว ถือว่าถูกลบออก
      exerciseActivities = merged;
      notifyListeners();
    } catch (_) {
      _snackFn?.call('โหลดกิจกรรมล้มเหลว', isError: true);
    }
  }

  Future<void> saveExerciseActivity(ExerciseActivity a) async {
    try {
      final saved = await _local.upsertExercise(a);
      final i = exerciseActivities.indexWhere((e) => e.id == saved.id);
      if (i == -1) {
        // รายการใหม่ → ตั้ง runtime default ถ้ายังไม่มี
        saved.remainingDuration ??= saved.goalDuration;
        saved.isRunning ??= false;
        exerciseActivities.add(saved);
      } else {
        // คงค่า runtime เดิมไว้
        final keep = exerciseActivities[i];
        saved.remainingDuration ??= keep.remainingDuration ?? saved.goalDuration;
        saved.isRunning ??= keep.isRunning ?? false;
        exerciseActivities[i] = saved;
      }
      notifyListeners();
      _snackFn?.call('บันทึกกิจกรรมสำเร็จ');
    } catch (_) {
      _snackFn?.call('บันทึกกิจกรรมล้มเหลว', isError: true);
    }
  }

  Future<void> deleteExerciseActivity(String id) async {
    try {
      await stopExerciseTimer(id, persist: false); // หยุดก่อนลบ
      await _local.deleteExercise(id);
      exerciseActivities.removeWhere((e) => e.id == id);
      notifyListeners();
      _snackFn?.call('ลบกิจกรรมแล้ว');
    } catch (_) {
      _snackFn?.call('ลบกิจกรรมล้มเหลว', isError: true);
    }
  }

  // ---------------- Sleep ----------------
  Future<void> fetchLatestSleepLog() async {
    try {
      final s = await _local.getLatestSleep(); // preload จาก SP (ของเดิม)
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
    String? note,
  }) async {
    try {
      // 1) เก็บเวลาล่าสุดไว้ใน SP (ของเดิม)
      final startedOn = _dateKey(DateTime.now());
      final saved = await _local.saveSleep(SleepLog(
        id: startedOn,
        bedTime: bedTime,
        wakeTime: wakeTime,
        starCount: starCount,
        startedOn: startedOn,
      ));

      // 2) คำนวณยอดนอนรวม แล้วบันทึกลง SQLite (sleep_daily)
      final mins = _durationMinutes(bedTime, wakeTime);
      await _local.setSleepHM(
        day: DateTime.now(),              // ถ้าจะนับเข้า "วันตื่น" ให้เปลี่ยนเป็นวันที่ของ wake
        hours: mins ~/ 60,
        minutes: mins % 60,
        quality: starCount,               // ใช้จำนวนดาวเป็น quality
        note: note,
      );

      // 3) อัปเดต state ให้ UI
      latestSleepLog = {
        'bedTime'  : _hhmm(saved.bedTime),
        'wakeTime' : _hhmm(saved.wakeTime),
        'starCount': saved.starCount,
      };
      notifyListeners();
      _snackFn?.call('บันทึกการนอนแล้ว');
    } catch (_) {
      _snackFn?.call('บันทึกการนอนล้มเหลว', isError: true);
    }
  }

  // ===== lifecycle =====
  @override
  void dispose() {
    // ปิด timer ทั้งหมดเมื่อ provider ถูกทำลาย
    for (final t in _exerciseTimers.values) {
      t.cancel();
    }
    _exerciseTimers.clear();
    super.dispose();
  }

  // ===== helpers =====
  int _durationMinutes(TimeOfDay bed, TimeOfDay wake) {
    final now = DateTime.now();
    var b = DateTime(now.year, now.month, now.day, bed.hour, bed.minute);
    var w = DateTime(now.year, now.month, now.day, wake.hour, wake.minute);
    if (!w.isAfter(b)) w = w.add(const Duration(days: 1)); // ข้ามวัน
    final mins = w.difference(b).inMinutes;
    return mins.clamp(0, 16 * 60).toInt(); // แคป 0..16 ชม. แล้วแปลงเป็น int
  }

  String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

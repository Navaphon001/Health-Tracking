// lib/providers/habit_notifier.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/water_day.dart';
import '../models/exercise_activity.dart';
import '../models/sleep_log.dart';
import '../services/habit_local_repository.dart';
import '../services/app_db.dart';
import '../shared/snack_fn.dart';
import '../charts/chart_point.dart';

class DrinkPreset {
  final String id;
  String name;
  int ml;
  DrinkPreset({required this.id, required this.name, required this.ml});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'ml': ml};
  static DrinkPreset fromJson(Map<String, dynamic> j) =>
      DrinkPreset(id: j['id'], name: j['name'], ml: j['ml']);
}

class HabitNotifier extends ChangeNotifier {
  HabitNotifier() {
    _initRepo();
  }
  
  late final HabitLocalRepository _local;
  
  Future<void> _initRepo() async {
    final db = await AppDb.instance.database;
    _local = HabitLocalRepository(db);
  }

  HabitLocalRepository get repo => _local;

  SnackFn? _snackFn;
  void setSnackBarCallback(SnackFn fn) => _snackFn = fn;

  // ===== WATER (SQLite) =====
  int dailyWaterCount = 0; // จาก SQLite
  int dailyWaterGoal  = 8; // จาก SQLite (จำนวนแก้ว/วัน เก็บแบบเดิม)
  int dailyWaterMl    = 0; // จาก SQLite (ml/วัน)

  // เผื่อจุดอื่น ๆ ยังอ้างอิง target ml
  int get dailyWaterTargetMl => dailyWaterGoal * baseGlassMl;

  // ===== WATER (UI/SharedPrefs สำหรับ preset) =====
  static const int baseGlassMl = 250;
  final List<DrinkPreset> drinkPresets = [
    DrinkPreset(id: 'water_default', name: 'น้ำเปล่า', ml: baseGlassMl),
  ];
  final Map<String, int> dailyDrinkCounts = {};

  // ===== EXERCISE =====
  List<ExerciseActivity> exerciseActivities = [];
  final Map<String, Timer> _exerciseTimers = {};
  final Map<String, Duration> _startRemaining = {};

  // ===== SLEEP =====
  Map<String, dynamic>? latestSleepLog;

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _kDrinkCountsKey(String dk) => 'water/dailyDrinkCounts/$dk';
  String get _kPresetsKey => 'water/drinkPresets';

  // ---------------- Water ----------------
  Future<void> fetchDailyWaterIntake() async {
    try {
      // 1) โหลดแก้ว/เป้า (ยังใช้โครงเดิม)
      final WaterDay day = await _local.getWaterToday();
      dailyWaterCount = day.count;
      dailyWaterGoal  = day.goal;

      // 2) โหลด ml วันนี้จาก SQLite (ถ้าไม่มีให้ประมาณจากแก้ว)
      final todayRow = await _local.getWaterDaily(DateTime.now());
      dailyWaterMl = (todayRow?['ml'] as int?) ?? (dailyWaterCount * baseGlassMl);

      // 3) โหลด preset และนับจำนวนต่อ drink จาก SharedPreferences (UI-only)
      final p  = await _prefs;
      _loadPresetsFromPrefs(p);

      final dk = _dateKey(DateTime.now());
      dailyDrinkCounts.clear();
      final countsJson = p.getString(_kDrinkCountsKey(dk));
      if (countsJson != null) {
        final map = (jsonDecode(countsJson) as Map).cast<String, dynamic>();
        map.forEach((k, v) => dailyDrinkCounts[k] = (v as num).toInt());
      }

      notifyListeners();
    } catch (_) {
      _snackFn?.call('โหลดข้อมูลน้ำดื่มล้มเหลว', isError: true);
    }
  }

  /// เพิ่ม “แก้ว” แบบเดิม แต่จะ +ml ไปที่ SQLite ด้วยตาม baseGlassMl
  Future<void> incrementWaterIntake([int step = 1]) async {
    try {
      final now = DateTime.now();
      await _local.upsertWater(
        day: now,
        deltaCount: step,
        deltaMl: baseGlassMl * step,
      );

      final WaterDay day = await _local.getWaterToday();
      dailyWaterCount = day.count;

      final row = await _local.getWaterDaily(now);
      dailyWaterMl = (row?['ml'] as int?) ?? dailyWaterMl;

      dailyWaterGoal = day.goal;
      notifyListeners();
    } catch (_) {
      _snackFn?.call('บันทึกน้ำดื่มล้มเหลว', isError: true);
    }
  }

  /// กดการ์ด drink เฉพาะชนิด (จะ +1 แก้ว และ +ml ตาม preset)
  Future<void> logDrink(DrinkPreset d) async {
    return logDrinkWithMl(d, d.ml);
  }

  /// ระบุ ml เอง แล้ว +แก้ว +ml ลง SQLite พร้อมเก็บนับต่อ drink (UI)
  Future<void> logDrinkWithMl(DrinkPreset d, int ml) async {
    try {
      final now = DateTime.now();

      // 1) DB: +1 แก้ว และ +ml ตามที่เลือก
      await _local.upsertWater(day: now, deltaCount: 1, deltaMl: ml);

      // 2) อัปเดตสถานะในแอปจาก DB
      final WaterDay day = await _local.getWaterToday();
      dailyWaterCount = day.count;
      final row = await _local.getWaterDaily(now);
      dailyWaterMl = (row?['ml'] as int?) ?? (dailyWaterMl + ml);

      // 3) นับจำนวนต่อ drink (UI-only)
      final p  = await _prefs;
      final dk = _dateKey(now);
      dailyDrinkCounts[d.id] = (dailyDrinkCounts[d.id] ?? 0) + 1;
      await p.setString(_kDrinkCountsKey(dk), jsonEncode(dailyDrinkCounts));

      _snackFn?.call('เพิ่ม ${d.name} +$ml ml');
      notifyListeners();
    } catch (_) {
      _snackFn?.call('บันทึกน้ำดื่มล้มเหลว', isError: true);
    }
  }

  Future<void> addDrinkPreset(String name, [int ml = baseGlassMl]) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    drinkPresets.insert(0, DrinkPreset(id: id, name: name, ml: ml));
    final p = await _prefs;
    await _savePresetsToPrefs(p);
    notifyListeners();
  }

  void _loadPresetsFromPrefs(SharedPreferences p) {
    final s = p.getString(_kPresetsKey);
    if (s == null || s.isEmpty) return;
    try {
      final arr = jsonDecode(s) as List;
      final list = arr.map((e) => DrinkPreset.fromJson((e as Map).cast<String, dynamic>())).toList();

      final ids = {for (final d in drinkPresets) d.id};
      for (final d in list) {
        if (!ids.contains(d.id)) {
          drinkPresets.add(d);
        }
      }
    } catch (_) {/* ignore */}
  }

  Future<void> _savePresetsToPrefs(SharedPreferences p) async {
    final arr = drinkPresets.map((e) => e.toJson()).toList();
    await p.setString(_kPresetsKey, jsonEncode(arr));
  }

  // ---------------- Exercise: Timer controls ----------------
  Future<void> startExerciseTimer(ExerciseActivity a) async {
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
        notifyListeners();
      } else {
        t.cancel();
        _exerciseTimers.remove(a.id);
        await stopExerciseTimer(a.id, persist: true);
      }
    });
  }

  Future<void> stopExerciseTimer(String id, {bool persist = true}) async {
    _exerciseTimers.remove(id)?.cancel();

    final i = exerciseActivities.indexWhere((e) => e.id == id);
    if (i == -1) return;
    final a = exerciseActivities[i];

    final startRem = _startRemaining.remove(id) ?? a.goalDuration;
    final curRem   = a.remainingDuration;

    final delta    = startRem - curRem;
    final deltaMin = (delta.inSeconds ~/ 60);

    a.isRunning = false;
    notifyListeners();

    if (persist && deltaMin > 0) {
      // ส่งชนิดกิจกรรมเป็น string (เช่น 'walk', 'run', ...)
      final type = a.type.toLowerCase().replaceAll(' ', '_');
      await _local.addExerciseMinutes(
        day: DateTime.now(),
        deltaMinutes: deltaMin,
        type: type,
        // ให้รีโปไปอ่านอัตรา kcal/นาที ของแต่ละ type เอง
      );
      _snackFn?.call('บันทึกออกกำลังกาย +$deltaMin นาที');
    }
  }

  Future<void> resetExerciseTimer(String id) async {
    await stopExerciseTimer(id, persist: false);
    final i = exerciseActivities.indexWhere((e) => e.id == id);
    if (i != -1) {
      final a = exerciseActivities[i];
      a.remainingDuration = a.goalDuration;
      a.isRunning = false;
      notifyListeners();
    }
  }

  // ---------------- Exercise: Catalog ----------------
  Future<void> fetchExerciseActivities() async {
    try {
      final fetched = await _local.getExercises();

      final byId = { for (final e in exerciseActivities) e.id: e };
      final merged = <ExerciseActivity>[];

      for (final f in fetched) {
        final exist = byId[f.id];
        if (exist != null) {
          exist.name = f.name;
          exist.goalDuration = f.goalDuration;
          exist.scheduledTime = f.scheduledTime;
          exist.type = f.type; // คงค่า type
          merged.add(exist);
        } else {
          // รายการใหม่ → ตั้งค่า runtime defaults
          f.remainingDuration = f.goalDuration;
          f.isRunning = false;
          merged.add(f);
        }
      }

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
        saved.remainingDuration = saved.goalDuration;
        saved.isRunning = false;
        exerciseActivities.add(saved);
      } else {
        final keep = exerciseActivities[i];
        saved.remainingDuration = keep.remainingDuration;
        saved.isRunning = keep.isRunning;
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
      await stopExerciseTimer(id, persist: false);
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
    String? note,
  }) async {
    try {
      final startedOn = _dateKey(DateTime.now());
      final saved = await _local.saveSleep(SleepLog(
        id: startedOn,
        bedTime: bedTime,
        wakeTime: wakeTime,
        starCount: starCount,
        startedOn: startedOn,
      ));

      final mins = _durationMinutes(bedTime, wakeTime);
      await _local.setSleepHM(
        day: DateTime.now(),
        hours: mins ~/ 60,
        minutes: mins % 60,
        quality: starCount,
        note: note,
      );

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
    if (!w.isAfter(b)) w = w.add(const Duration(days: 1));
    final mins = w.difference(b).inMinutes;
    return mins.clamp(0, 16 * 60).toInt();
  }

  String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // -------- Charts (อัปเดตให้ตรงกับ ml/kcal) --------
  Future<List<ChartPoint>> fetchSleepSeries({int days = 14}) =>
      _local.fetchSleepHoursSeries(days: days);

  /// ml/วัน
  Future<List<ChartPoint>> fetchWaterSeries({int days = 14}) =>
      _local.fetchWaterMlSeries(days: days);

  /// kcal/วัน (รวมทุกประเภท)
  Future<List<ChartPoint>> fetchExerciseSeries({int days = 14}) =>
      _local.fetchExerciseCaloriesSeries(days: days);
}

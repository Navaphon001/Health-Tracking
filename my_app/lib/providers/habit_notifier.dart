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
import '../shared/date_key.dart';
import '../shared/snack_fn.dart';
import '../shared/app_messages.dart';
import '../charts/chart_point.dart';
import '../theme/app_colors.dart';

class DrinkPreset {
  final String id;
  String name;
  int ml;
  int color; // เก็บเป็น int (Color value)
  DrinkPreset({required this.id, required this.name, required this.ml, this.color = 0xFF0ABAB5}); // Default เป็นสี primary

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'ml': ml, 'color': color};
  static DrinkPreset fromJson(Map<String, dynamic> j) =>
      DrinkPreset(id: j['id'], name: j['name'], ml: j['ml'], color: j['color'] ?? 0xFF0ABAB5);
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
  AppMessages? _messages;
  
  void setSnackBarCallback(SnackFn fn) => _snackFn = fn;
  void setMessages(AppMessages messages) => _messages = messages;

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
      _snackFn?.call(_messages?.waterLogFailed ?? 'Failed to log water intake', isError: true);
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
      dailyWaterMl = (row?['ml'] as int?) ?? 0;

      // 3) นับจำนวนต่อ drink (UI-only)
      final p  = await _prefs;
      final dk = _dateKey(now);
      dailyDrinkCounts[d.id] = (dailyDrinkCounts[d.id] ?? 0) + 1;
      await p.setString(_kDrinkCountsKey(dk), jsonEncode(dailyDrinkCounts));

      _snackFn?.call(_messages?.waterLogSuccess(d.name, ml) ?? 'Added ${d.name} +$ml ml');
      notifyListeners();
    } catch (_) {
      _snackFn?.call(_messages?.waterLogFailed ?? 'Failed to log water intake', isError: true);
    }
  }

  Future<void> addDrinkPreset(String name, [int ml = baseGlassMl, Color? color]) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final colorValue = color?.value ?? AppColors.tagColors[0].value;
    drinkPresets.insert(0, DrinkPreset(id: id, name: name, ml: ml, color: colorValue));
    final p = await _prefs;
    await _savePresetsToPrefs(p);
    notifyListeners();
  }

  Future<void> deleteDrinkPreset(String id) async {
    drinkPresets.removeWhere((preset) => preset.id == id);
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
      _snackFn?.call(_messages?.exerciseLogSuccess(deltaMin) ?? 'Logged exercise +$deltaMin minutes');
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
      _snackFn?.call(_messages?.activitySavedSuccess ?? 'Activity saved successfully');
    } catch (_) {
      _snackFn?.call(_messages?.activitySaveFailed ?? 'Failed to save activity', isError: true);
    }
  }

  Future<void> deleteExerciseActivity(String id) async {
    try {
      await stopExerciseTimer(id, persist: false);
      await _local.deleteExercise(id);
      exerciseActivities.removeWhere((e) => e.id == id);
      notifyListeners();
      _snackFn?.call(_messages?.activityDeletedSuccess ?? 'Activity deleted');
    } catch (_) {
      _snackFn?.call(_messages?.activityDeleteFailed ?? 'Failed to delete activity', isError: true);
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
      _snackFn?.call(_messages?.sleepLoggedSuccess ?? 'Sleep logged');
    } catch (_) {
      _snackFn?.call(_messages?.sleepLogFailed ?? 'Failed to log sleep', isError: true);
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

  /// Fetch a compact summary object for today's dashboard (water ml, sleep minutes, exercise kcal)
  Future<Map<String, dynamic>> fetchTodaySummary() async {
    try {
      final s = await _local.dailySummary(DateTime.now());
      // also include legacy latestSleepLog starCount if present
      if (latestSleepLog != null && latestSleepLog!['starCount'] != null) {
        s['sleep_quality'] = latestSleepLog!['starCount'];
      } else {
        // keep whatever DB had (could be absent)
        s['sleep_quality'] = s['sleep_minutes'] != null ? null : null;
      }
      return s;
    } catch (e) {
      _snackFn?.call('โหลดสรุปประจำวันล้มเหลว', isError: true);
      return {
        'date_key': dateKeyOf(DateTime.now()),
        'sleep_minutes': 0,
        'water_count': 0,
        'water_ml': 0,
        'exercise_minutes': 0,
        'exercise_calories': 0.0,
        'sleep_quality': null,
      };
    }
  }

  /// Provide a small set of timeline entries for UI (time label + amount)
  /// Currently this is a lightweight helper: if the water row contains serialized timeline
  /// details in a future enhancement this can be replaced by a proper query. For now,
  /// return placeholder time buckets based on the day's ml distribution if available.
  List<Map<String, String>> buildWaterTimeline(int totalMl) {
    // If no data, provide common buckets as placeholders
    if (totalMl <= 0) {
      return [
        {'time': '6am - 8am', 'amount': '600ml'},
        {'time': '9am - 11am', 'amount': '500ml'},
        {'time': '11am - 2pm', 'amount': '1000ml'},
      ];
    }

    // Distribute into common buckets proportionally for display (6am-8am,9-11,11-2,2-4,4-now)
    final buckets = [600, 500, 1000, 700, 900];
    // cap sum to avoid odd distributions
    final sumBuckets = buckets.fold<int>(0, (p, e) => p + e);
    final scale = totalMl / sumBuckets;
    final out = <Map<String, String>>[];
    final labels = ['6am - 8am', '9am - 11am', '11am - 2pm', '2pm - 4pm', '4pm - now'];
    for (var i = 0; i < buckets.length; i++) {
      final val = (buckets[i] * scale).round();
      out.add({'time': labels[i], 'amount': '${val}ml'});
    }
    return out;
  }
}

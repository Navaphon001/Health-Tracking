import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/exercise_activity.dart';

/// Provider to manage a single exercise session (selection, timer, kcal calc, chart data)
class ExerciseProvider with ChangeNotifier {
  ActivityType _selected = ActivityType.walk;
  bool _isRunning = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  // latest calculated calories for the current session
  double _calories = 0.0;

  // simple chart data (calories sampled every N seconds)
  final List<double> _chart = [];

  ActivityType get selected => _selected;
  bool get isRunning => _isRunning;
  Duration get elapsed => _elapsed;
  double get calories => _calories;
  // compatibility: dashboard expects `exercise` (minutes)
  int get exercise => _elapsed.inMinutes;
  List<double> get chart => List.unmodifiable(_chart);

  // Weight is intentionally ignored in the new time-based calculation.
  void setUserWeight(String? weight) {
    // intentionally no-op to keep compatibility with existing callers
  }

  void setUserWeightDouble(double? weight) {
    // intentionally no-op
  }

  void select(ActivityType t) {
    if (_selected == t) return;
    _selected = t;
    // reset session when switching activity
    reset();
    notifyListeners();
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    // ensure timer sampling and increment calories per-second so the UI shows
    // a smooth increasing value while the timer runs. We use a small activity
    // multiplier table to tune burn rates so they aren't too fast or slow.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // increment elapsed first
      _elapsed = _elapsed + const Duration(seconds: 1);

      // compute calories from formula: kcal = MET_adj * weightKg * hours
      _calories = _computeCalories();

      // sample every 5 seconds to chart to avoid too many points
      if (_elapsed.inSeconds % 5 == 0) {
        _chart.add(_calories);
        if (_chart.length > 60) _chart.removeAt(0);
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void stop() {
    if (!_isRunning) return;
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void reset() {
    stop();
    _elapsed = Duration.zero;
    _calories = 0.0;
    _chart.clear();
    notifyListeners();
  }



  // Activity-specific multipliers to tune burn rates so they feel reasonable
  // (not too fast, not too slow). Values chosen conservatively.
  // Use per-activity kcal/hour values so calories depend on time only.
  // Values are conservative estimates (kcal burned per hour).
  double _kcalPerHour(ActivityType t) {
    switch (t) {
      case ActivityType.walk:
        // walking: 30 min burns ~75-150 kcal -> per hour ~150-300 kcal
        // choose a conservative midpoint ~225 kcal/hr
        return 225.0;
      case ActivityType.run:
        // running: ~0.22 kcal/sec -> 0.22 * 3600 = 792 kcal/hr
        return 792.0;
      case ActivityType.bike:
        // cycling: 10 min burns ~40-50 kcal -> per hour ~240-300 kcal, use midpoint
        return 270.0;
      case ActivityType.swim:
        // swimming: ~0.006-0.02 kcal/sec -> midpoint 0.013 * 3600 = ~46.8 kcal/hr
        return 46.8;
      case ActivityType.sport:
        // sport (intense): ~330 kcal in 10 minutes -> 330 * 6 = 1980 kcal/hr
        return 1980.0;
    }
  }

  double _computeCalories() {
    final kcalHr = _kcalPerHour(_selected);
    final hours = _elapsed.inSeconds / 3600.0;
    return kcalHr * hours;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// (old simple provider removed - functionality replaced by the richer provider above)
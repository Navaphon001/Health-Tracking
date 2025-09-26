import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  bool _waterReminderEnabled = true;
  bool _exerciseReminderEnabled = true;
  bool _mealLoggingEnabled = true;
  bool _sleepReminderEnabled = true;

  // Getters
  bool get waterReminderEnabled => _waterReminderEnabled;
  bool get exerciseReminderEnabled => _exerciseReminderEnabled;
  bool get mealLoggingEnabled => _mealLoggingEnabled;
  bool get sleepReminderEnabled => _sleepReminderEnabled;

  // Keys for SharedPreferences
  static const String _waterReminderKey = 'water_reminder_enabled';
  static const String _exerciseReminderKey = 'exercise_reminder_enabled';
  static const String _mealLoggingKey = 'meal_logging_enabled';
  static const String _sleepReminderKey = 'sleep_reminder_enabled';

  /// Load notification settings from SharedPreferences
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _waterReminderEnabled = prefs.getBool(_waterReminderKey) ?? true;
      _exerciseReminderEnabled = prefs.getBool(_exerciseReminderKey) ?? true;
      _mealLoggingEnabled = prefs.getBool(_mealLoggingKey) ?? true;
      _sleepReminderEnabled = prefs.getBool(_sleepReminderKey) ?? true;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  /// Toggle water reminder notification
  Future<void> toggleWaterReminder(bool enabled) async {
    try {
      _waterReminderEnabled = enabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_waterReminderKey, enabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving water reminder setting: $e');
    }
  }

  /// Toggle exercise reminder notification
  Future<void> toggleExerciseReminder(bool enabled) async {
    try {
      _exerciseReminderEnabled = enabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_exerciseReminderKey, enabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving exercise reminder setting: $e');
    }
  }

  /// Toggle meal logging notification
  Future<void> toggleMealLogging(bool enabled) async {
    try {
      _mealLoggingEnabled = enabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_mealLoggingKey, enabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving meal logging setting: $e');
    }
  }

  /// Toggle sleep reminder notification
  Future<void> toggleSleepReminder(bool enabled) async {
    try {
      _sleepReminderEnabled = enabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_sleepReminderKey, enabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving sleep reminder setting: $e');
    }
  }

  /// Reset all notification settings to default (enabled)
  Future<void> resetToDefault() async {
    try {
      _waterReminderEnabled = true;
      _exerciseReminderEnabled = true;
      _mealLoggingEnabled = true;
      _sleepReminderEnabled = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_waterReminderKey, true);
      await prefs.setBool(_exerciseReminderKey, true);
      await prefs.setBool(_mealLoggingKey, true);
      await prefs.setBool(_sleepReminderKey, true);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting notification settings: $e');
    }
  }
}
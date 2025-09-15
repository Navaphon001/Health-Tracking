import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _prefKeyPrimary = 'theme_primary';
  static const _prefKeyMode = 'theme_mode'; // 'light' | 'dark'

  Color _primary = Colors.teal; // default brand color
  Color get primary => _primary;

  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // load primary color
      final value = prefs.getInt(_prefKeyPrimary);
      if (value != null) {
        _primary = Color(value);
      }
      // load theme mode
      final modeStr = prefs.getString(_prefKeyMode);
      if (modeStr == 'dark') {
        _mode = ThemeMode.dark;
      } else if (modeStr == 'light') {
        _mode = ThemeMode.light;
      }
      notifyListeners();
    } catch (_) {
      // ignore persistence errors
    }
  }

  Future<void> setPrimary(Color color) async {
    _primary = color;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      // ignore: deprecated_member_use
      await prefs.setInt(_prefKeyPrimary, color.value);
    } catch (_) {
      // ignore persistence errors
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = mode == ThemeMode.dark ? 'dark' : 'light';
      await prefs.setString(_prefKeyMode, value);
    } catch (_) {
      // ignore persistence errors
    }
  }
}

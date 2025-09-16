import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const _prefKey = 'locale_code';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null && code.isNotEmpty) {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (_) {
      // ignore errors and keep default
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, locale.languageCode);
    } catch (_) {
      // ignore persistence errors
    }
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  final SharedPreferences _prefs;
  TokenStorage._(this._prefs);

  static Future<TokenStorage> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return TokenStorage._(prefs);
  }

  Future<void> write(String key, String? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, value);
    }
  }

  String? read(String key) => _prefs.getString(key);

  Future<void> delete(String key) async => _prefs.remove(key);
}

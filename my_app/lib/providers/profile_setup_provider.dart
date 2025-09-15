import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupProvider extends ChangeNotifier {
  String? _name;
  DateTime? _dob;
  String? _gender; // 'male' | 'female' | 'other'
  String? _activityLevel; // 'sedentary', 'lightly_active', 'moderately_active', 'very_active'
  List<String> _goals = []; // List of selected goals

  String? get name => _name;
  DateTime? get dob => _dob;
  String? get gender => _gender;
  String? get activityLevel => _activityLevel;
  List<String> get goals => List.unmodifiable(_goals);

  void setName(String? value) {
    _name = value;
    notifyListeners();
  }

  void setDob(DateTime? value) {
    _dob = value;
    notifyListeners();
  }

  void setGender(String? value) {
    _gender = value;
    notifyListeners();
  }

  void setActivityLevel(String? value) {
    _activityLevel = value;
    notifyListeners();
  }

  void setGoals(List<String> value) {
    _goals = value;
    notifyListeners();
  }

  void toggleGoal(String goal) {
    if (_goals.contains(goal)) {
      _goals.remove(goal);
    } else {
      _goals.add(goal);
    }
    notifyListeners();
  }

  Future<void> saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _name ?? '');
    await prefs.setString('dateOfBirth', _dob?.toIso8601String() ?? '');
    await prefs.setString('gender', _gender ?? '');
    await prefs.setString('activityLevel', _activityLevel ?? '');
    await prefs.setStringList('goals', _goals);
  }

  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name');
    final dobString = prefs.getString('dateOfBirth');
    _dob = dobString != null && dobString.isNotEmpty ? DateTime.parse(dobString) : null;
    _gender = prefs.getString('gender');
    _activityLevel = prefs.getString('activityLevel');
    _goals = prefs.getStringList('goals') ?? [];
    notifyListeners();
  }
}

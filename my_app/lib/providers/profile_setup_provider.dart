import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';

class ProfileSetupProvider extends ChangeNotifier {
  // Step 1: Basic Info
  String? _fullName;
  String? _nickname;
  DateTime? _birthDate;
  String? _gender;
  
  // Step 2: Physical Info
  double? _height;
  double? _weight;
  String? _activityLevel;
  String? _healthGoal;
  
  // Step 3: About Yourself
  String? _healthRating;
  String? _occupation;
  String? _lifestyle;
  double? _sleepHours;
  String? _wakeUpTime;
  List<String> _interests = [];
  List<String> _goals = [];

  // Getters
  String? get fullName => _fullName;
  String? get nickname => _nickname;
  DateTime? get birthDate => _birthDate;
  String? get gender => _gender;
  double? get height => _height;
  double? get weight => _weight;
  String? get activityLevel => _activityLevel;
  String? get healthGoal => _healthGoal;
  String? get healthRating => _healthRating;
  String? get occupation => _occupation;
  String? get lifestyle => _lifestyle;
  double? get sleepHours => _sleepHours;
  String? get wakeUpTime => _wakeUpTime;
  List<String> get interests => List.unmodifiable(_interests);
  List<String> get goals => List.unmodifiable(_goals);

  // Setters for Step 1
  void setFullName(String? value) {
    _fullName = value;
    notifyListeners();
  }

  void setNickname(String? value) {
    _nickname = value;
    notifyListeners();
  }

  void setBirthDate(DateTime? value) {
    _birthDate = value;
    notifyListeners();
  }

  void setGender(String? value) {
    _gender = value;
    notifyListeners();
  }

  // Setters for Step 2
  void setHeight(double? value) {
    _height = value;
    notifyListeners();
  }

  void setWeight(double? value) {
    _weight = value;
    notifyListeners();
  }

  void setActivityLevel(String? value) {
    _activityLevel = value;
    notifyListeners();
  }

  void setHealthGoal(String? value) {
    _healthGoal = value;
    notifyListeners();
  }

  // Setters for Step 3
  void setHealthRating(String? value) {
    _healthRating = value;
    notifyListeners();
  }

  void setOccupation(String? value) {
    _occupation = value;
    notifyListeners();
  }

  void setLifestyle(String? value) {
    _lifestyle = value;
    notifyListeners();
  }

  void setSleepHours(double? value) {
    _sleepHours = value;
    notifyListeners();
  }

  void setWakeUpTime(String? value) {
    _wakeUpTime = value;
    notifyListeners();
  }

  void setInterests(List<String> value) {
    _interests = value;
    notifyListeners();
  }

  void toggleInterest(String interest) {
    if (_interests.contains(interest)) {
      _interests.remove(interest);
    } else {
      _interests.add(interest);
    }
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

  // Save/Load methods using SQLite
  Future<void> saveStep1(String userId) async {
    if (_fullName != null && _nickname != null && _birthDate != null && _gender != null) {
      await UserProfileService.instance.saveStep1(
        userId: userId,
        fullName: _fullName!,
        nickname: _nickname!,
        birthDate: _birthDate!,
        gender: _gender!,
      );
    }
  }

  Future<void> saveStep2(String userId) async {
    if (_height != null && _weight != null && _activityLevel != null && _healthGoal != null) {
      await UserProfileService.instance.saveStep2(
        userId: userId,
        height: _height!,
        weight: _weight!,
        activityLevel: _activityLevel!,
        healthGoal: _healthGoal!,
      );
    }
  }

  Future<void> saveStep3(String userId) async {
    await UserProfileService.instance.saveStep3(
      userId: userId,
      healthRating: _healthRating,
      occupation: _occupation,
      lifestyle: _lifestyle,
      sleepHours: _sleepHours,
      wakeUpTime: _wakeUpTime,
      interests: _interests,
      goals: _goals,
    );
    // ทำเครื่องหมายว่า Profile Setup เสร็จสมบูรณ์
    await UserProfileService.instance.markProfileCompleted(userId);
  }

  Future<void> loadProfile(String userId) async {
    final profile = await UserProfileService.instance.getUserProfile(userId);
    if (profile != null) {
      _fullName = profile['full_name'];
      _nickname = profile['nickname'];
      _birthDate = profile['birth_date'] != null ? DateTime.parse(profile['birth_date']) : null;
      _gender = profile['gender'];
      _height = profile['height'];
      _weight = profile['weight'];
      _activityLevel = profile['activity_level'];
      _healthGoal = profile['health_goal'];
      _occupation = profile['occupation'];
      _lifestyle = profile['lifestyle'];
      _sleepHours = profile['sleep_hours'];
      _wakeUpTime = profile['wake_up_time'];
      _interests = profile['interests']?.toString().split(',') ?? [];
      _healthRating = profile['health_rating'];
      _goals = profile['goals']?.toString().split(',') ?? [];
      notifyListeners();
    }
  }

  void clearProfile() {
    _fullName = null;
    _nickname = null;
    _birthDate = null;
    _gender = null;
    _height = null;
    _weight = null;
    _activityLevel = null;
    _healthGoal = null;
    _occupation = null;
    _lifestyle = null;
    _sleepHours = null;
    _wakeUpTime = null;
    _interests = [];
    _healthRating = null;
    _goals = [];
    notifyListeners();
  }
}

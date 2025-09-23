import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhysicalInfoProvider extends ChangeNotifier {
  String? _weight; // in kg
  String? _height; // in cm
  String? _healthRating; // 'poor', 'fair', 'good', 'great', 'excellent'

  String? get weight => _weight;
  String? get height => _height;
  String? get healthRating => _healthRating;

  void setWeight(String? value) {
    _weight = value;
    notifyListeners();
    _saveToPrefs();
  }

  void setHeight(String? value) {
    _height = value;
    notifyListeners();
    _saveToPrefs();
  }

  void setHealthRating(String? value) {
    _healthRating = value;
    notifyListeners();
    _saveToPrefs();
  }

  // Validation methods
  bool get isWeightValid {
    if (_weight == null || _weight!.trim().isEmpty) return false;
    final weightValue = double.tryParse(_weight!);
    return weightValue != null && weightValue > 0 && weightValue <= 500;
  }

  bool get isHeightValid {
    if (_height == null || _height!.trim().isEmpty) return false;
    final heightValue = double.tryParse(_height!);
    return heightValue != null && heightValue > 0 && heightValue <= 300;
  }

  bool get isAllValid => isWeightValid && isHeightValid;

  // Get calculated BMI
  double? get bmi {
    if (!isWeightValid || !isHeightValid) return null;
    
    final weightValue = double.parse(_weight!);
    final heightValue = double.parse(_height!) / 100; // convert cm to m
    
    return weightValue / (heightValue * heightValue);
  }

  // Load data from SharedPreferences
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _weight = prefs.getString('physical_weight');
    _height = prefs.getString('physical_height');
    _healthRating = prefs.getString('physical_health_rating');
    
    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_weight != null && _weight!.isNotEmpty) {
      await prefs.setString('physical_weight', _weight!);
    }
    
    if (_height != null && _height!.isNotEmpty) {
      await prefs.setString('physical_height', _height!);
    }
    
    if (_healthRating != null && _healthRating!.isNotEmpty) {
      await prefs.setString('physical_health_rating', _healthRating!);
    }
  }

  // Clear all data
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('physical_weight');
    await prefs.remove('physical_height');
    await prefs.remove('physical_health_rating');
    
    _weight = null;
    _height = null;
    _healthRating = null;
    notifyListeners();
  }
}
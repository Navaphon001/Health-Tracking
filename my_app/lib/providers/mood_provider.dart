import 'package:flutter/material.dart';

class MoodProvider with ChangeNotifier {
  String? _selectedMood;

  String? get selectedMood => _selectedMood;

  void setMood(String mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  void resetMood() {
    _selectedMood = null;
    notifyListeners();
  }
}

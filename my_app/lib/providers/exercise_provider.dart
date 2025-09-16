import 'package:flutter/foundation.dart';

class ExerciseProvider with ChangeNotifier {
  int _exercise = 0;

  int get exercise => _exercise;

  void setExercise(int minutes) {
    _exercise = minutes;
    notifyListeners();
  }
}
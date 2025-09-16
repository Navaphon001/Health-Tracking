import 'package:flutter/foundation.dart';

class MealProvider with ChangeNotifier {
  String _meal = '';

  String get meal => _meal;

  void setMeal(String newMeal) {
    _meal = newMeal;
    notifyListeners();
  }
}

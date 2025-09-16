import 'package:flutter/foundation.dart';

class WaterProvider with ChangeNotifier {
  int _water = 0;

  int get water => _water;

  void setWater(int amount) {
    _water = amount;
    notifyListeners();
  }
}
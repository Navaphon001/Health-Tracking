// import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class BmiProvider with ChangeNotifier {
  double? _weight;
  double? _height;
  double? _bmi;
  bool _submitted = false;

  double? get weight => _weight;
  double? get height => _height;
  double? get bmi => _bmi;
  bool get submitted => _submitted;

  void setValues(double weight, double height) {
    _weight = weight;
    _height = height;
    _calculateBmi();
    _submitted = true;
    notifyListeners();
  }

  void reset() {
    _submitted = false;
    notifyListeners();
  }

  void _calculateBmi() {
    if (_weight != null && _height != null && _height! > 0) {
      final heightM = _height! / 100;
      _bmi = _weight! / (heightM * heightM);
    }
  }
}

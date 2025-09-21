import 'package:flutter/material.dart';
import '../models/goal.dart';

class GoalProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  
  List<Goal> get goals => _goals;
  
  List<Goal> get activeGoals => _goals.where((goal) => !goal.isCompleted).toList();
  
  List<Goal> get completedGoals => _goals.where((goal) => goal.isCompleted).toList();

  GoalProvider();

  void addGoal(Goal goal) {
    _goals.add(goal);
    notifyListeners();
  }

  void updateGoal(Goal updatedGoal) {
    final index = _goals.indexWhere((goal) => goal.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      notifyListeners();
    }
  }

  void markGoalAsCompleted(String goalId) {
    final index = _goals.indexWhere((goal) => goal.id == goalId);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(isCompleted: true);
      notifyListeners();
    }
  }

  void removeGoal(String goalId) {
    _goals.removeWhere((goal) => goal.id == goalId);
    notifyListeners();
  }

  Goal? getGoalById(String goalId) {
    try {
      return _goals.firstWhere((goal) => goal.id == goalId);
    } catch (e) {
      return null;
    }
  }

  List<Goal> getGoalsByCategory(String category) {
    return _goals.where((goal) => goal.category == category).toList();
  }

  // Helper method to generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Create goal with generated ID
  Goal createGoal({
    required String title,
    required String description,
    required String category,
    DateTime? targetDate,
    double? targetValue,
    String? unit,
  }) {
    return Goal(
      id: _generateId(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      targetDate: targetDate,
      category: category,
      targetValue: targetValue,
      unit: unit,
    );
  }
}
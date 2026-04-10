import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores user-defined fitness goals.
/// All values have sensible defaults but users can change them from Settings.
class UserGoalsProvider extends ChangeNotifier {
  static const _kStepGoal  = 'goal_steps';
  static const _kWaterGoal = 'goal_water_ml';
  static const _keySleepGoal = 'goal_sleep_h';

  int    _stepGoal  = 10000;
  int    _waterGoal = 2500;
  double _sleepGoal = 8.0;

  int    get stepGoal  => _stepGoal;
  int    get waterGoal => _waterGoal;
  double get sleepGoal => _sleepGoal;

  UserGoalsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _stepGoal  = prefs.getInt(_kStepGoal)    ?? 10000;
    _waterGoal = prefs.getInt(_kWaterGoal)   ?? 2500;
    _sleepGoal = prefs.getDouble(_keySleepGoal) ?? 8.0;
    notifyListeners();
  }

  Future<void> setStepGoal(int value) async {
    final clamped = value.clamp(1000, 50000);
    if (_stepGoal == clamped) return;
    _stepGoal = clamped;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kStepGoal, _stepGoal);
  }

  Future<void> setWaterGoal(int ml) async {
    final clamped = ml.clamp(500, 8000);
    if (_waterGoal == clamped) return;
    _waterGoal = clamped;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWaterGoal, _waterGoal);
  }

  Future<void> setSleepGoal(double hours) async {
    final clamped = hours.clamp(3.0, 12.0);
    if (_sleepGoal == clamped) return;
    _sleepGoal = clamped;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySleepGoal, _sleepGoal);
  }
}

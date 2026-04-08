import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FitnessProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _dailySummary;
  List<Map<String, dynamic>> _stepHistory = [];

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dailySummary => _dailySummary;
  List<Map<String, dynamic>> get stepHistory => _stepHistory;

  Future<void> logSteps(int steps, String date) async {
    try {
      await ApiService.post('/fitness/steps', {'steps_count': steps, 'log_date': date});
      await loadSummary();
    } catch (_) {}
  }

  Future<void> loadSummary({String? date}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final query = date != null ? '?date=$date' : '';
      final resp = await ApiService.get('/fitness/summary$query');
      _dailySummary = resp['data'] as Map<String, dynamic>?;
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadStepHistory({int days = 7}) async {
    try {
      final resp = await ApiService.get('/fitness/history?days=$days');
      _stepHistory = List<Map<String, dynamic>>.from(resp['data'] ?? []);
      notifyListeners();
    } catch (_) {}
  }
}

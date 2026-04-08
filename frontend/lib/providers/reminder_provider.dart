import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReminderProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _reminders = [];
  List<Map<String, dynamic>> _todaySchedule = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get reminders => _reminders;
  List<Map<String, dynamic>> get todaySchedule => _todaySchedule;
  bool get isLoading => _isLoading;

  Future<void> loadReminders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final resp = await ApiService.get('/reminders/');
      _reminders = List<Map<String, dynamic>>.from(resp['data'] ?? []);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadToday() async {
    try {
      final resp = await ApiService.get('/reminders/today');
      _todaySchedule = List<Map<String, dynamic>>.from(resp['data'] ?? []);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> createReminder(Map<String, dynamic> data) async {
    try {
      await ApiService.post('/reminders/', data);
      await loadReminders();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteReminder(String id) async {
    try {
      await ApiService.delete('/reminders/$id');
      await loadReminders();
      return true;
    } catch (_) {
      return false;
    }
  }
}

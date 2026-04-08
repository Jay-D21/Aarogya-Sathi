import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HealthProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _records = [];
  Map<String, dynamic>? _lastBPStatus;
  Map<String, dynamic>? _lastSugarStatus;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get records => _records;
  Map<String, dynamic>? get lastBPStatus => _lastBPStatus;
  Map<String, dynamic>? get lastSugarStatus => _lastSugarStatus;

  Future<Map<String, dynamic>?> logBP(int systolic, int diastolic, {String? notes}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final resp = await ApiService.post('/health/bp-reading', {
        'systolic': systolic,
        'diastolic': diastolic,
        'measured_at': DateTime.now().toUtc().toIso8601String(),
        if (notes != null) 'notes': notes,
      });
      _lastBPStatus = (resp['data'] as Map<String, dynamic>?)?['status'];
      _isLoading = false;
      notifyListeners();
      return resp['data'] as Map<String, dynamic>?;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> logSugar(int value, String type) async {
    _isLoading = true;
    notifyListeners();
    try {
      final resp = await ApiService.post('/health/sugar-reading', {
        'glucose_value': value,
        'reading_type': type,
        'measured_at': DateTime.now().toUtc().toIso8601String(),
      });
      _lastSugarStatus = (resp['data'] as Map<String, dynamic>?)?['status'];
      _isLoading = false;
      notifyListeners();
      return resp['data'] as Map<String, dynamic>?;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadRecords({String? type, int days = 30}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final query = type != null ? '?record_type=$type&days=$days' : '?days=$days';
      final resp = await ApiService.get('/health/records$query');
      _records = List<Map<String, dynamic>>.from(resp['data'] ?? []);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }
}

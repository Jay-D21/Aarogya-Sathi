import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class HealthProvider extends ChangeNotifier {
  static const _kCache = 'health_records_cache_v1';

  bool _isLoading = false;
  List<Map<String, dynamic>> _records = [];
  Map<String, dynamic>? _lastBPStatus;
  Map<String, dynamic>? _lastSugarStatus;

  bool get isLoading      => _isLoading;
  List<Map<String, dynamic>> get records => List.unmodifiable(_records);
  Map<String, dynamic>? get lastBPStatus    => _lastBPStatus;
  Map<String, dynamic>? get lastSugarStatus => _lastSugarStatus;

  // ── Load records ──────────────────────────────────────────────────────────

  Future<void> loadRecords({String? type, int days = 30}) async {
    _isLoading = true;

    // Load from local cache so UI is never empty
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCache);
    if (raw != null) {
      try {
        _records = List<Map<String, dynamic>>.from(
          (jsonDecode(raw) as List)
              .map((e) => Map<String, dynamic>.from(e as Map)),
        );
        _deriveStatuses();
        notifyListeners();
      } catch (_) {}
    }

    try {
      final query =
          type != null ? '?record_type=$type&days=$days' : '?days=$days';
      final resp = await ApiService.get('/health/records$query');
      _records = List<Map<String, dynamic>>.from(
        (resp['data'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map)),
      );
      await prefs.setString(_kCache, jsonEncode(_records));
      _deriveStatuses();
    } catch (_) {
      // Offline — cache already shown
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Log BP ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> logBP(
      int systolic, int diastolic, {String? notes}) async {
    _isLoading = true;

    // Optimistic insert — UI shows result instantly
    final optimistic = _buildRecord('vitals', {
      'systolic': systolic,
      'diastolic': diastolic,
      // ignore: use_null_aware_elements
      if (notes != null) 'notes': notes,
    });
    _records.insert(0, optimistic);
    notifyListeners();

    Map<String, dynamic>? result;
    try {
      final body = <String, dynamic>{
        'systolic': systolic,
        'diastolic': diastolic,
        'measured_at': DateTime.now().toUtc().toIso8601String(),
        // ignore: use_null_aware_elements
        if (notes != null) 'notes': notes,
      };
      final resp = await ApiService.post('/health/bp-reading', body);
      result = resp['data'] as Map<String, dynamic>?;
      if (result != null) {
        _records.removeWhere((r) => r['id'] == optimistic['id']);
        _records.insert(0, result);
        _lastBPStatus = result['status'];
        await _saveCache();
      }
    } catch (_) {
      // Keep the optimistic record; return it so UI can confirm
      result = optimistic;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // ── Log Sugar ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> logSugar(int value, String type) async {
    _isLoading = true;

    final optimistic = _buildRecord('vitals', {
      'glucose_value': value,
      'reading_type': type,
    });
    _records.insert(0, optimistic);
    notifyListeners();

    Map<String, dynamic>? result;
    try {
      final resp = await ApiService.post('/health/sugar-reading', {
        'glucose_value': value,
        'reading_type': type,
        'measured_at': DateTime.now().toUtc().toIso8601String(),
      });
      result = resp['data'] as Map<String, dynamic>?;
      if (result != null) {
        _records.removeWhere((r) => r['id'] == optimistic['id']);
        _records.insert(0, result);
        _lastSugarStatus = result['status'];
        await _saveCache();
      }
    } catch (_) {
      result = optimistic;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // ── Log Weight ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> logWeight(double weight) async {
    _isLoading = true;

    final optimistic = _buildRecord('weight', {'weight_kg': weight});
    _records.insert(0, optimistic);
    notifyListeners();

    Map<String, dynamic>? result;
    try {
      final resp = await ApiService.post('/health/weight', {
        'weight_kg': weight,
        'measured_at': DateTime.now().toUtc().toIso8601String(),
      });
      result = resp['data'] as Map<String, dynamic>?;
      if (result != null) {
        _records.removeWhere((r) => r['id'] == optimistic['id']);
        _records.insert(0, result);
        await _saveCache();
      }
    } catch (_) {
      result = optimistic;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // ── Log Symptom ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> logSymptom(String symptom,
      {String? notes}) async {
    _isLoading = true;

    final optimistic = _buildRecord('symptom', {
      'symptoms': [symptom],
      // ignore: use_null_aware_elements
      if (notes != null) 'notes': notes,
    });
    _records.insert(0, optimistic);
    notifyListeners();

    Map<String, dynamic>? result;
    try {
      final body = <String, dynamic>{
        'symptoms': [symptom],
        'severity': 3,
        // ignore: use_null_aware_elements
        if (notes != null) 'notes': notes,
      };
      final resp = await ApiService.post('/health/symptom-log', body);
      result = resp['data'] as Map<String, dynamic>?;
      if (result != null) {
        _records.removeWhere((r) => r['id'] == optimistic['id']);
        _records.insert(0, result);
        await _saveCache();
      }
    } catch (_) {
      result = optimistic;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Map<String, dynamic> _buildRecord(String type, Map<String, dynamic> data) =>
      {
        'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
        'record_type': type,
        'data': data,
        'recorded_at': DateTime.now().toIso8601String(),
        'status': null,
      };

  void _deriveStatuses() {
    try {
      final bp = _records.firstWhere(
          (r) => r['data']?['systolic'] != null && r['status'] != null);
      _lastBPStatus = bp['status'];
    } catch (_) {
      _lastBPStatus = null;
    }

    try {
      final sugar = _records.firstWhere((r) =>
          (r['data']?['glucose_value'] != null ||
              r['data']?['sugar_fasting'] != null) &&
          r['status'] != null);
      _lastSugarStatus = sugar['status'];
    } catch (_) {
      _lastSugarStatus = null;
    }
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCache, jsonEncode(_records));
  }
}

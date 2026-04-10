import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class FitnessProvider extends ChangeNotifier {
  // ── SharedPreferences keys ──────────────────────────────────────────────────
  static const _kDate       = 'fit_date';          // 'YYYY-MM-DD'
  static const _kSteps      = 'fit_steps';          // int: today's steps
  static const _kWater      = 'fit_water_ml';       // int: ml logged today
  static const _kSleep      = 'fit_sleep_h';        // double: hours slept
  static const _kPedoOffset = 'fit_pedo_offset';    // int: pedometer baseline
  static const _kPedoDate   = 'fit_pedo_date';      // String: date offset was set

  // ── Internal state ──────────────────────────────────────────────────────────
  // ignore: prefer_final_fields
  bool _loading = false;
  StreamSubscription<StepCount>? _stepSub;

  int    _localSteps = 0;
  int    _localWater = 0;
  double _localSleep = 0.0;

  // ── Public getters ──────────────────────────────────────────────────────────
  bool   get isLoading   => _loading;
  int    get steps       => _localSteps;
  int    get waterMl     => _localWater;
  double get sleepHours  => _localSleep;

  /// Weight-aware calorie estimate.
  /// Uses simplified MET formula: steps × weight(kg) × 0.000516
  /// Falls back to steps × 0.04 if weight is not provided.
  int calories({double weightKg = 70.0}) =>
      (steps * weightKg * 0.000516).toInt();

  // ── Initialisation ──────────────────────────────────────────────────────────

  /// Single init entry-point called from HomeScreen.
  /// Loads local data, starts pedometer, then tries to sync from backend.
  Future<void> init() async {
    await _loadLocalDay();
    notifyListeners();
    unawaited(initPedometer());
    unawaited(_syncFromBackend());
  }

  /// Load today's data from SharedPreferences.
  /// Resets all counters if the date has changed (midnight rollover).
  Future<void> _loadLocalDay() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _todayStr();
    final savedDate = prefs.getString(_kDate);

    if (savedDate != todayStr) {
      // New day — clear all counters and save today's date
      await prefs.setString(_kDate, todayStr);
      await prefs.setInt(_kSteps, 0);
      await prefs.setInt(_kWater, 0);
      await prefs.setDouble(_kSleep, 0.0);
      _localSteps = 0;
      _localWater = 0;
      _localSleep = 0.0;
    } else {
      _localSteps = prefs.getInt(_kSteps) ?? 0;
      _localWater = prefs.getInt(_kWater) ?? 0;
      _localSleep = prefs.getDouble(_kSleep) ?? 0.0;
    }
  }

  /// Start listening to the hardware step counter.
  /// Handles the cumulative-count daily offset correctly:
  /// - On the first event of a new day, the current total becomes the offset.
  /// - Steps today = (current total) − (offset).
  Future<void> initPedometer() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    final granted = await Permission.activityRecognition.request().isGranted;
    if (!granted) return;

    await _stepSub?.cancel();
    final prefs = await SharedPreferences.getInstance();

    _stepSub = Pedometer.stepCountStream.listen(
      (StepCount event) async {
        final todayStr = _todayStr();
        final offsetDate = prefs.getString(_kPedoDate);

        int offset;
        if (offsetDate != todayStr) {
          // First event of the day → capture baseline
          offset = event.steps;
          await prefs.setInt(_kPedoOffset, offset);
          await prefs.setString(_kPedoDate, todayStr);
        } else {
          offset = prefs.getInt(_kPedoOffset) ?? event.steps;
        }

        final todaySteps = (event.steps - offset).clamp(0, 999999);

        if (todaySteps != _localSteps) {
          _localSteps = todaySteps;
          await prefs.setInt(_kSteps, _localSteps);
          notifyListeners();

          // Background sync every 500 steps
          if (_localSteps > 0 && _localSteps % 500 == 0) {
            _fireAndForget(() => ApiService.post('/fitness/steps', {
                  'steps_count': _localSteps,
                  'log_date': todayStr,
                }));
          }
        }
      },
      onError: (err) => debugPrint('[Pedometer] $err'),
    );
  }

  // ── Public actions ──────────────────────────────────────────────────────────

  /// Log water intake in ml. Local-first with background API sync.
  Future<void> logWater(int ml) async {
    _localWater += ml;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWater, _localWater);
    notifyListeners();
    _fireAndForget(() => ApiService.post('/fitness/water', {'water_ml': ml}));
  }

  /// Log sleep hours + quality. Local-first with background API sync.
  Future<void> logSleep(double hours, int quality) async {
    _localSleep = hours;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kSleep, hours);
    notifyListeners();
    _fireAndForget(() => ApiService.post('/fitness/sleep', {
          'sleep_hours': hours,
          'sleep_quality': quality,
        }));
  }

  // ── Backward-compat alias ───────────────────────────────────────────────────
  Future<void> loadSummary({String? date}) => _syncFromBackend();

  // ── Backend sync ────────────────────────────────────────────────────────────

  /// Pull today's summary from backend. Takes the higher of server vs. local
  /// so data is never lost even when offline periods occur.
  Future<void> _syncFromBackend() async {
    try {
      final resp = await ApiService.get('/fitness/summary');
      final data = resp['data'] as Map<String, dynamic>?;
      if (data == null) return;

      final sSteps = (data['steps'] as num?)?.toInt() ?? 0;
      final sWater = (data['water_ml'] as num?)?.toInt() ?? 0;
      final sSleep = (data['sleep_hours'] as num?)?.toDouble() ?? 0.0;

      bool changed = false;
      if (sSteps > _localSteps) { _localSteps = sSteps; changed = true; }
      if (sWater > _localWater) { _localWater = sWater; changed = true; }
      if (sSleep > _localSleep) { _localSleep = sSleep; changed = true; }
      if (changed) notifyListeners();
    } catch (_) { /* Offline — local data is already displayed */ }
  }

  // ── Disposal ────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _stepSub?.cancel();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  static String _todayStr() => DateTime.now().toIso8601String().split('T')[0];

  void _fireAndForget(Future<dynamic> Function() fn) {
    fn().catchError((_) {});
  }
}

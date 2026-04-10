import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  static const _kReminders = 'local_reminders_v2';
  static const _uuid = Uuid();

  List<Map<String, dynamic>> _reminders = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get reminders => List.unmodifiable(_reminders);
  bool get isLoading => _isLoading;

  /// Reminders active for today's weekday (1=Mon … 7=Sun).
  /// If no active_days are set the reminder is treated as daily.
  List<Map<String, dynamic>> get todaySchedule {
    final today = DateTime.now().weekday;
    return _reminders.where((r) {
      final raw = r['active_days'];
      if (raw == null) return true;
      final days = (raw as List).map((e) => e as int).toList();
      return days.isEmpty || days.contains(today);
    }).toList();
  }

  // ── Loading ──────────────────────────────────────────────────────────────────

  Future<void> loadToday() => loadReminders();

  Future<void> loadReminders() async {
    _isLoading = true;
    await _readFromLocal();
    notifyListeners();

    try {
      final resp = await ApiService.get('/reminders');
      final serverList = List<Map<String, dynamic>>.from(
        (resp['data'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map)),
      );
      // Keep local-only drafts that haven't synced yet
      final serverIds = serverList.map((r) => r['id']).toSet();
      final localOnly = _reminders
          .where((r) => r['_local'] == true && !serverIds.contains(r['id']))
          .toList();
      _reminders = [...serverList, ...localOnly];
      await _writeToLocal();
    } catch (_) {
      // Offline — local data already loaded
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────────

  Future<bool> createReminder({
    required String title,
    required String type,
    required TimeOfDay time,
    required List<int> activeDays,
    String? description,
  }) async {
    final id = _uuid.v4();
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final notifId = _notifId(id);
    final desc = description ?? 'Time for your $title!';

    final reminder = <String, dynamic>{
      'id': id,
      'title': title,
      'reminder_type': type,
      'reminder_time': timeStr,
      'active_days': activeDays,
      'description': desc,
      'taken': false,
      'created_at': DateTime.now().toIso8601String(),
      '_local': true,
    };

    _reminders.add(reminder);
    await _writeToLocal();
    notifyListeners();

    // Schedule local notification
    await NotificationService.scheduleDailyReminder(
      id: notifId,
      title: title,
      body: desc,
      time: time,
    );

    // Fire-and-forget server sync
    _fireAndForget(() {
      final payload = Map<String, dynamic>.from(reminder)..remove('_local');
      return ApiService.post('/reminders', payload);
    });

    return true;
  }

  Future<bool> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r['id'] == id);
    await _writeToLocal();
    notifyListeners();
    await NotificationService.cancelReminder(_notifId(id));
    _fireAndForget(() => ApiService.delete('/reminders/$id'));
    return true;
  }

  Future<void> markTaken(String id, {required bool taken}) async {
    final idx = _reminders.indexWhere((r) => r['id'] == id);
    if (idx != -1) {
      _reminders[idx] = {..._reminders[idx], 'taken': taken};
      await _writeToLocal();
      notifyListeners();
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Future<void> _readFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kReminders);
    if (raw != null) {
      try {
        _reminders = List<Map<String, dynamic>>.from(
          (jsonDecode(raw) as List)
              .map((e) => Map<String, dynamic>.from(e as Map)),
        );
      } catch (_) {
        _reminders = [];
      }
    }
  }

  Future<void> _writeToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kReminders, jsonEncode(_reminders));
  }

  void _fireAndForget(Future<dynamic> Function() fn) {
    fn().catchError((_) {});
  }

  /// Converts a UUID string to a safe positive int for use as a notification ID.
  /// Uses abs() + modulo to stay in a safe range.
  static int _notifId(String id) => id.hashCode.abs() % 100000;
}

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    // Set device local timezone so notifications fire at the correct local time
    final String? tzName = _deviceTzName();
    if (tzName != null) {
      try {
        tz.setLocalLocation(tz.getLocation(tzName));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    } else {
      tz.setLocalLocation(tz.UTC);
    }

    const androidOptions = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosOptions = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidOptions, iOS: iosOptions);

    await _plugin.initialize(settings: initSettings);

    _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static String? _deviceTzName() {
    try {
      final raw = DateTime.now().timeZoneName;
      if (raw.isNotEmpty) return raw;
    } catch (_) {}
    return null;
  }

  // ── v21 API: all named parameters ────────────────────────────────────────

  static Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = DateTime.now();
    var scheduled =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'aarogya_sathi_reminders',
      'Health Reminders',
      channelDescription: 'Daily medication and health check reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // flutter_local_notifications v21: all-named-param variant of zonedSchedule
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduled, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// flutter_local_notifications v21: cancel uses named `id:` param.
  static Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id: id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

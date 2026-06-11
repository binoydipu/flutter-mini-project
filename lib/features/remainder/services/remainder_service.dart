import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mini_project/features/remainder/services/remainder_storage.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

class RemainderService {
  RemainderService(this._storage);

  final RemainderStorage _storage;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationDetails(
    'mini_project_channel',
    'Mini Project Notifications',
    channelDescription: 'Appointment reminders and mini project alerts',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _notifDetails = NotificationDetails(
    android: _androidChannel,
    iOS: DarwinNotificationDetails(),
  );

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    initializeTimeZones();
    setLocalLocation(getLocation('Asia/Dhaka'));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await requestPermission();
    debugPrint(
      'remainder_service: INFO: ***** Remainders init completed *****',
    );
  }

  // ── Permission ────────────────────────────────────────────────────────────

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final iOS = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    if (iOS != null) {
      return await iOS.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  /// Show notification instantly
  Future<void> showNow({required String title, required String body}) async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _notifDetails,
    );
  }

  /// Show one on time
  Future<void> scheduleOnce(RemainderPayload payload) async {
    final id = payload.id ?? await _storage.nextId();
    final resolved = payload.withId(id);

    await _plugin.zonedSchedule(
      id: id,
      title: resolved.title,
      body: resolved.body,
      scheduledDate: TZDateTime.from(resolved.scheduledTime, local),
      notificationDetails: _notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    await _storage.save(resolved);
  }

  /// Recurring notification
  Future<void> scheduleRecurring(RemainderPayload payload) async {
    assert(payload.repeat != null, 'Use scheduleOnce for non-recurring');
    final id = payload.id ?? await _storage.nextId();
    final resolved = payload.withId(id);

    final matchComponents = switch (payload.repeat!) {
      AppRepeatInterval.daily => DateTimeComponents.time, // everyday same time
      AppRepeatInterval.weekly =>
        DateTimeComponents.dayOfWeekAndTime, // every week same day same time
      AppRepeatInterval.monthly =>
        DateTimeComponents.dayOfMonthAndTime, // every month same day same time
    };

    await _plugin.zonedSchedule(
      id: id,
      title: resolved.title,
      body: resolved.body,
      scheduledDate: TZDateTime.from(resolved.scheduledTime, local),
      notificationDetails: _notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchComponents,
    );
    await _storage.save(resolved);
  }

  /// Reschedule all (call on reboot / app start)
  Future<void> rescheduleAll() async {
    final all = await _storage.loadAll();
    for (final entry in all.values) {
      final payload = RemainderPayload.fromJson(
        Map<String, dynamic>.from(entry),
      );
      if (!payload.isActive) continue;

      if (payload.repeat != null) {
        await scheduleRecurring(payload);
      } else {
        // Skip if time has already passed
        if (payload.scheduledTime.isAfter(DateTime.now())) {
          await scheduleOnce(payload);
        }
      }
    }
  }

  /// Cancle one notification
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
    await _storage.remove(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    await _storage.clear();
  }

  Future<List<RemainderPayload>> getAllScheduled() async {
    final all = await _storage.loadAll();
    return all.values
        .map((e) => RemainderPayload.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

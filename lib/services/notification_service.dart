import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    final String timeZoneName = await _getLocalTimeZone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  Future<String> _getLocalTimeZone() async {
    final now = DateTime.now();
    final localOffset = now.timeZoneOffset;

    final offsetHours = localOffset.inHours;

    final timezoneMap = {
      -3: 'America/Sao_Paulo',
      -5: 'America/New_York',
      -8: 'America/Los_Angeles',
      0: 'UTC',
      1: 'Europe/London',
      2: 'Europe/Paris',
      3: 'Europe/Moscow',
      8: 'Asia/Shanghai',
      9: 'Asia/Tokyo',
    };

    return timezoneMap[offsetHours] ?? 'America/Sao_Paulo';
  }

  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      if (granted != true) return false;
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted != true) return false;
    }

    return true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate to habit detail screen
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleHabitNotification(Habit habit) async {
    if (habit.scheduledTime == null) return;

    await initialize();

    if (!_isHabitScheduledForToday(habit)) return;

    final scheduledTime = habit.scheduledTime!;
    final notificationTime =
        scheduledTime.subtract(const Duration(minutes: 30));

    final notificationDetails = await _getNotificationDetails(habit);

    final now = tz.TZDateTime.now(tz.local);

    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      notificationTime.hour,
      notificationTime.minute,
    );

    if (scheduledDate.isBefore(now)) return;

    await _notifications.zonedSchedule(
      habit.id.hashCode,
      _getNotificationTitle(habit),
      _getNotificationBody(habit),
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  bool _isHabitScheduledForToday(Habit habit) {
    final today = DateTime.now();
    final weekday = today.weekday;

    switch (habit.frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        final createdWeekday = habit.createdAt.weekday;
        return weekday == createdWeekday;

      case HabitFrequency.custom:
        final todayIndex = weekday - 1;
        return habit.customDays.contains(todayIndex);
    }
  }

  String _getNotificationTitle(Habit habit) {
    return '🔔 Time for: ${habit.title}';
  }

  String _getNotificationBody(Habit habit) {
    if (habit.description != null && habit.description!.isNotEmpty) {
      return habit.description!;
    }
    return 'Your habit starts in 30 minutes. Get ready! 💪';
  }

  Future<NotificationDetails> _getNotificationDetails(Habit habit) async {
    final androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Notifications for scheduled habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: _getAndroidIconForHabit(habit),
      color: _parseColor(habit.color),
      enableLights: true,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        _getNotificationBody(habit),
        contentTitle: _getNotificationTitle(habit),
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  String _getAndroidIconForHabit(Habit habit) {
    // Always use the app launcher icon
    // Custom drawable icons would need to be added to android/app/src/main/res/drawable/
    return '@mipmap/ic_launcher';
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
  }

  Future<void> rescheduleAllHabitsForToday(List<Habit> habits) async {
    await cancelAllNotifications();

    for (final habit in habits) {
      await scheduleHabitNotification(habit);
    }
  }

  Future<void> cancelHabitNotification(String habitId) async {
    await _notifications.cancel(habitId.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<bool> areNotificationsEnabled() async {
    if (!_initialized) return false;

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled();
      return enabled ?? false;
    }

    return true;
  }
}

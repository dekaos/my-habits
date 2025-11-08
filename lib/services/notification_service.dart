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

    final scheduledTime = habit.scheduledTime!;
    final notificationTime =
        scheduledTime.subtract(const Duration(minutes: 30));

    final notificationDetails = await _getNotificationDetails(habit);

    final now = tz.TZDateTime.now(tz.local);

    // Handle different frequency types
    switch (habit.frequency) {
      case HabitFrequency.daily:
        await _scheduleDailyNotification(
          habit,
          notificationTime,
          notificationDetails,
          now,
        );
        break;

      case HabitFrequency.weekly:
        await _scheduleWeeklyNotification(
          habit,
          notificationTime,
          notificationDetails,
          now,
        );
        break;

      case HabitFrequency.custom:
        await _scheduleCustomNotifications(
          habit,
          notificationTime,
          notificationDetails,
          now,
        );
        break;
    }
  }

  Future<void> _scheduleDailyNotification(
    Habit habit,
    DateTime notificationTime,
    NotificationDetails notificationDetails,
    tz.TZDateTime now,
  ) async {
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      notificationTime.hour,
      notificationTime.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      habit.id.hashCode,
      _getNotificationTitle(habit),
      _getNotificationBody(habit),
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  Future<void> _scheduleWeeklyNotification(
    Habit habit,
    DateTime notificationTime,
    NotificationDetails notificationDetails,
    tz.TZDateTime now,
  ) async {
    // Schedule for the same day of week as creation
    final createdWeekday = habit.createdAt.weekday;
    final scheduledDate = _getNextWeekday(
      now,
      createdWeekday,
      notificationTime.hour,
      notificationTime.minute,
    );

    await _notifications.zonedSchedule(
      habit.id.hashCode,
      _getNotificationTitle(habit),
      _getNotificationBody(habit),
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime, // Repeat weekly
    );
  }

  Future<void> _scheduleCustomNotifications(
    Habit habit,
    DateTime notificationTime,
    NotificationDetails notificationDetails,
    tz.TZDateTime now,
  ) async {
    // Schedule a notification for each custom day
    for (final dayIndex in habit.customDays) {
      final weekday = dayIndex + 1; // Convert 0-6 to 1-7 (Mon-Sun)
      final scheduledDate = _getNextWeekday(
        now,
        weekday,
        notificationTime.hour,
        notificationTime.minute,
      );

      // Use unique ID for each day
      final notificationId = '${habit.id}_day$dayIndex'.hashCode;

      await _notifications.zonedSchedule(
        notificationId,
        _getNotificationTitle(habit),
        _getNotificationBody(habit),
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            DateTimeComponents.dayOfWeekAndTime, // Repeat weekly
      );
    }
  }

  tz.TZDateTime _getNextWeekday(
    tz.TZDateTime from,
    int weekday,
    int hour,
    int minute,
  ) {
    var scheduledDate = tz.TZDateTime(
      tz.local,
      from.year,
      from.month,
      from.day,
      hour,
      minute,
    );

    // Move to the target weekday
    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(from)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
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
    // Cancel main notification
    await _notifications.cancel(habitId.hashCode);

    // Also cancel custom day notifications (for custom frequency habits)
    for (int i = 0; i < 7; i++) {
      final notificationId = '${habitId}_day$i'.hashCode;
      await _notifications.cancel(notificationId);
    }
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

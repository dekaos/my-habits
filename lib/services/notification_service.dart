import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/habit.dart';
import '../main.dart' show navigatorKey;
import '../screens/habits/habit_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  String? _currentLocalizedTitle;
  String? _currentLocalizedBody;

  NotificationResponse? _launchNotification;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
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

      final launchDetails =
          await _notifications.getNotificationAppLaunchDetails();
      if (launchDetails != null &&
          launchDetails.didNotificationLaunchApp &&
          launchDetails.notificationResponse != null) {
        debugPrint('🚀 App launched from notification');
        _launchNotification = launchDetails.notificationResponse;
      }

      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
      // Don't rethrow - allow app to continue without notifications
    }
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

  void _onNotificationTapped(NotificationResponse response) async {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    await _handleNotificationNavigation(response);
  }

  Future<void> _handleNotificationNavigation(
      NotificationResponse response) async {
    final habitId = response.payload;
    if (habitId == null || habitId.isEmpty) {
      debugPrint('⚠️ No habit ID in notification payload');
      return;
    }

    try {
      // Fetch the habit from Supabase
      final supabase = Supabase.instance.client;
      final habitData = await supabase
          .from('habits')
          .select()
          .eq('id', habitId)
          .maybeSingle();

      if (habitData == null) {
        debugPrint('⚠️ Habit not found: $habitId');
        return;
      }

      final habit = Habit.fromSupabaseMap(habitData);

      // Navigate to habit detail screen
      final context = navigatorKey.currentContext;
      if (context != null && navigatorKey.currentState != null) {
        debugPrint('✅ Navigating to habit detail: ${habit.title}');
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => HabitDetailScreen(habit: habit),
          ),
        );
      } else {
        debugPrint(
            '⚠️ Navigator context not available, will retry after app initializes');
      }
    } catch (e) {
      debugPrint('❌ Error handling notification tap: $e');
    }
  }

  /// Call this method after the app has fully initialized and navigation is ready
  Future<void> handleLaunchNotification() async {
    if (_launchNotification != null) {
      debugPrint('📱 Handling notification that launched the app');
      final notification = _launchNotification;
      _launchNotification = null; // Clear it so we don't handle it again

      // Wait a bit to ensure navigation is ready
      await Future.delayed(const Duration(milliseconds: 500));

      await _handleNotificationNavigation(notification!);
    }
  }

  Future<void> scheduleHabitNotificationWithId(
    Habit habit, {
    required DateTime scheduledTime,
    required String notificationId,
    String? localizedTitle,
    String? localizedBody,
    bool? playSound,
    bool? enableVibration,
  }) async {
    try {
      await initialize();

      if (!_initialized) {
        return;
      }

      final notificationTime =
          scheduledTime.subtract(const Duration(minutes: 30));

      final notificationDetails = await _getNotificationDetails(
        habit,
        playSound: playSound ?? true,
        enableVibration: enableVibration ?? true,
      );

      _currentLocalizedTitle = localizedTitle;
      _currentLocalizedBody = localizedBody;

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        notificationTime.hour,
        notificationTime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        notificationId.hashCode,
        _getNotificationTitle(habit),
        _getNotificationBody(habit),
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
        payload: habit.id, // Include habit ID for navigation
      );

      _currentLocalizedTitle = null;
      _currentLocalizedBody = null;
    } catch (e) {
      debugPrint('Error scheduling notification with ID: $e');
    }
  }

  Future<void> scheduleHabitNotification(
    Habit habit, {
    String? localizedTitle,
    String? localizedBody,
    bool? playSound,
    bool? enableVibration,
  }) async {
    if (habit.scheduledTime == null) {
      debugPrint('⚠️ No scheduled time for habit, skipping notification');
      return;
    }

    try {
      debugPrint('🔔 Starting notification scheduling for: ${habit.title}');

      await initialize();

      if (!_initialized) {
        debugPrint(
            '❌ Notification service not initialized, skipping scheduling');
        return;
      }

      final scheduledTime = habit.scheduledTime!;
      final notificationTime =
          scheduledTime.subtract(const Duration(minutes: 30));

      debugPrint(
          '   ⏰ Habit time: ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}');
      debugPrint(
          '   🔔 Notification time: ${notificationTime.hour}:${notificationTime.minute.toString().padLeft(2, '0')} (30 min before)');
      debugPrint('   📋 Frequency: ${habit.frequency}');
      debugPrint(
          '   🔊 Sound: ${playSound ?? true}, Vibration: ${enableVibration ?? true}');

      final notificationDetails = await _getNotificationDetails(
        habit,
        playSound: playSound ?? true,
        enableVibration: enableVibration ?? true,
      );

      final now = tz.TZDateTime.now(tz.local);

      // Store localized strings for use in notification methods
      _currentLocalizedTitle = localizedTitle;
      _currentLocalizedBody = localizedBody;

      // Handle different frequency types
      switch (habit.frequency) {
        case HabitFrequency.daily:
          debugPrint('   📅 Scheduling DAILY recurring notification...');
          await _scheduleDailyNotification(
            habit,
            notificationTime,
            notificationDetails,
            now,
          );
          break;

        case HabitFrequency.weekly:
          debugPrint('   📅 Scheduling WEEKLY recurring notification...');
          await _scheduleWeeklyNotification(
            habit,
            notificationTime,
            notificationDetails,
            now,
          );
          break;

        case HabitFrequency.custom:
          debugPrint('   📅 Scheduling CUSTOM recurring notifications...');
          await _scheduleCustomNotifications(
            habit,
            notificationTime,
            notificationDetails,
            now,
          );
          break;
      }

      // Clear localized strings after use
      _currentLocalizedTitle = null;
      _currentLocalizedBody = null;

      debugPrint('✅ Notification scheduling completed for: ${habit.title}');
    } catch (e) {
      debugPrint('❌ Error scheduling habit notification: $e');
      // Don't rethrow - allow app to continue without notifications
    }
  }

  Future<void> _scheduleDailyNotification(
    Habit habit,
    DateTime notificationTime,
    NotificationDetails notificationDetails,
    tz.TZDateTime now,
  ) async {
    try {
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
        debugPrint('   ⏰ Time passed today, scheduling for tomorrow');
      }

      debugPrint('   📆 Daily notification will show at: $scheduledDate');
      debugPrint(
          '   🔁 Repeats: Every day at ${notificationTime.hour}:${notificationTime.minute.toString().padLeft(2, '0')}');

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
        payload: habit.id, // Include habit ID for navigation
      );

      debugPrint(
          '   ✅ Daily notification scheduled (ID: ${habit.id.hashCode})');
    } catch (e) {
      debugPrint('   ❌ Error scheduling daily notification: $e');
    }
  }

  Future<void> _scheduleWeeklyNotification(
    Habit habit,
    DateTime notificationTime,
    NotificationDetails notificationDetails,
    tz.TZDateTime now,
  ) async {
    try {
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
        payload: habit.id, // Include habit ID for navigation
      );
    } catch (e) {
      debugPrint('Error scheduling weekly notification: $e');
    }
  }

  Future<void> _scheduleCustomNotifications(
    Habit habit,
    DateTime notificationTime,
    NotificationDetails notificationDetails,
    tz.TZDateTime now,
  ) async {
    try {
      final dayNames = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      debugPrint(
          '   📅 Scheduling custom notifications for ${habit.customDays.length} days');

      // Schedule a notification for each custom day
      for (final dayIndex in habit.customDays) {
        try {
          final weekday = dayIndex + 1; // Convert 0-6 to 1-7 (Mon-Sun)
          final scheduledDate = _getNextWeekday(
            now,
            weekday,
            notificationTime.hour,
            notificationTime.minute,
          );

          // Use unique ID for each day
          final notificationId = '${habit.id}_day$dayIndex'.hashCode;

          debugPrint(
              '   📆 ${dayNames[dayIndex]}: $scheduledDate (ID: $notificationId)');

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
            payload: habit.id, // Include habit ID for navigation
          );

          debugPrint('   ✅ Notification scheduled for ${dayNames[dayIndex]}');
        } catch (e) {
          debugPrint(
              '   ❌ Error scheduling notification for day $dayIndex: $e');
        }
      }

      debugPrint('   🔁 All custom notifications will repeat weekly');
    } catch (e) {
      debugPrint('   ❌ Error scheduling custom notifications: $e');
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
    final icon = _getEmojiFromIconName(habit.icon);

    // Use localized title if provided, otherwise use default
    if (_currentLocalizedTitle != null) {
      return '$icon $_currentLocalizedTitle';
    }

    // Fallback for when no localization provided
    return '$icon Time for: ${habit.title}';
  }

  String _getEmojiFromIconName(String? iconName) {
    // Map icon names to emoji (matching habit_icon_selector.dart)
    final iconMap = {
      'fitness': '💪',
      'book': '📚',
      'water': '💧',
      'sleep': '😴',
      'restaurant': '🍽️',
      'run': '🏃',
      'meditation': '🧘',
      'yoga': '🧘‍♀️',
      'art': '🎨',
      'music': '🎵',
      'work': '💼',
      'school': '🎓',
      'heart': '❤️',
      'walk': '🚶',
      'bike': '🚴',
    };

    return iconMap[iconName] ?? '🔔';
  }

  String _getNotificationBody(Habit habit) {
    // Use habit description if available
    if (habit.description != null && habit.description!.isNotEmpty) {
      return habit.description!;
    }

    // Use localized body if provided, otherwise use default
    if (_currentLocalizedBody != null) {
      return _currentLocalizedBody!;
    }

    // Fallback for when no localization provided
    return 'Your habit starts in 30 minutes. Get ready! 💪';
  }

  Future<NotificationDetails> _getNotificationDetails(
    Habit habit, {
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Notifications for scheduled habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: _getAndroidIconForHabit(habit),
      color: _parseColor(habit.color),
      enableLights: true,
      enableVibration: enableVibration,
      playSound: playSound,
      styleInformation: BigTextStyleInformation(
        _getNotificationBody(habit),
        contentTitle: _getNotificationTitle(habit),
      ),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  String _getAndroidIconForHabit(Habit habit) {
    return '@mipmap/ic_launcher';
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
  }

  Future<void> rescheduleAllHabitsForToday(
    List<Habit> habits, {
    String Function(String)? localizedTitleGenerator,
    String? localizedBody,
    bool? playSound,
    bool? enableVibration,
  }) async {
    await cancelAllNotifications();

    for (final habit in habits) {
      if (habit.scheduledTime != null) {
        final localizedTitle = localizedTitleGenerator != null
            ? localizedTitleGenerator(habit.title)
            : null;
        await scheduleHabitNotification(
          habit,
          localizedTitle: localizedTitle,
          localizedBody: localizedBody,
          playSound: playSound,
          enableVibration: enableVibration,
        );
      }
    }
  }

  Future<void> cancelHabitNotification(String habitId) async {
    try {
      await _notifications.cancel(habitId.hashCode);

      for (int i = 0; i < 7; i++) {
        final notificationId = '${habitId}_day$i'.hashCode;
        await _notifications.cancel(notificationId);
      }

      for (int i = 0; i < 5; i++) {
        final notificationId = '${habitId}_completion_$i'.hashCode;
        await _notifications.cancel(notificationId);
      }
    } catch (e) {
      debugPrint('Error canceling habit notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      if (!_initialized) return false;

      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final enabled = await androidPlugin.areNotificationsEnabled();
        return enabled ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      return false;
    }
  }
}

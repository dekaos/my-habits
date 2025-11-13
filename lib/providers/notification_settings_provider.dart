import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../models/habit.dart';

class NotificationSettings {
  final bool pushNotificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool useDeviceSound; // If true, follow device settings

  const NotificationSettings({
    this.pushNotificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.useDeviceSound = true,
  });

  NotificationSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? useDeviceSound,
  }) {
    return NotificationSettings(
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      useDeviceSound: useDeviceSound ?? this.useDeviceSound,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'useDeviceSound': useDeviceSound,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      useDeviceSound: json['useDeviceSound'] ?? true,
    );
  }
}

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  static const String _prefsKey = 'notification_settings';

  @override
  NotificationSettings build() {
    _loadSettings();
    return const NotificationSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_prefsKey);

      if (json != null) {
        final parts = json.split(',');
        if (parts.length >= 4) {
          final settings = NotificationSettings(
            pushNotificationsEnabled: parts[0] == 'true',
            soundEnabled: parts[1] == 'true',
            vibrationEnabled: parts[2] == 'true',
            useDeviceSound: parts[3] == 'true',
          );

          state = settings;
          debugPrint('✅ Loaded notification settings:');
          debugPrint('   Push: ${settings.pushNotificationsEnabled}');
          debugPrint('   Sound: ${settings.soundEnabled}');
          debugPrint('   Vibration: ${settings.vibrationEnabled}');
          debugPrint('   Use Device Sound: ${settings.useDeviceSound}');
        }
      } else {
        debugPrint('ℹ️ No saved notification settings, using defaults');
      }
    } catch (e) {
      debugPrint('❌ Error loading notification settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json =
          '${state.pushNotificationsEnabled},${state.soundEnabled},${state.vibrationEnabled},${state.useDeviceSound}';
      await prefs.setString(_prefsKey, json);
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  Future<void> setPushNotificationsEnabled(
    bool enabled, {
    List<Habit>? habits,
    String Function(String)? localizedTitleGenerator,
    String? localizedBody,
  }) async {
    final wasEnabled = state.pushNotificationsEnabled;

    state = state.copyWith(pushNotificationsEnabled: enabled);

    await _saveSettings();

    if (enabled && !wasEnabled && habits != null && habits.isNotEmpty) {
      try {
        debugPrint('📅 Rescheduling all habit notifications after enabling...');
        await NotificationService().rescheduleAllHabitsForToday(
          habits,
          localizedTitleGenerator: localizedTitleGenerator,
          localizedBody: localizedBody,
          playSound: shouldPlaySound(),
          enableVibration: shouldVibrate(),
        );
      } catch (e) {
        debugPrint('❌ Error rescheduling notifications: $e');
      }
    } else if (!enabled && wasEnabled) {
      try {
        await NotificationService().cancelAllNotifications();
        debugPrint('✅ All notifications canceled');
      } catch (e) {
        debugPrint('❌ Error canceling notifications: $e');
      }
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    if (enabled) {
      // If manually enabling sound, disable useDeviceSound
      state = state.copyWith(useDeviceSound: false);
    }
    await _saveSettings();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    await _saveSettings();
  }

  Future<void> setUseDeviceSound(bool useDevice) async {
    state = state.copyWith(useDeviceSound: useDevice);
    await _saveSettings();
  }

  bool shouldPlaySound() {
    final result = state.pushNotificationsEnabled &&
        (state.useDeviceSound || state.soundEnabled);
    debugPrint(
        '🔊 shouldPlaySound: $result (push: ${state.pushNotificationsEnabled}, useDevice: ${state.useDeviceSound}, sound: ${state.soundEnabled})');
    return result;
  }

  bool shouldVibrate() {
    final result = state.pushNotificationsEnabled && state.vibrationEnabled;
    debugPrint(
        '📳 shouldVibrate: $result (push: ${state.pushNotificationsEnabled}, vibration: ${state.vibrationEnabled})');
    return result;
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);

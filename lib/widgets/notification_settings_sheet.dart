import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_settings_provider.dart';
import '../providers/habit_provider.dart';
import '../l10n/app_localizations.dart';
import 'glass_card.dart';

class NotificationSettingsSheet extends ConsumerWidget {
  const NotificationSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(notificationSettingsProvider);
    final settingsNotifier = ref.read(notificationSettingsProvider.notifier);
    final habitState = ref.watch(habitProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.notificationSettings,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
            ),

            // Settings list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                padding: EdgeInsets.zero,
                enableGlow: false,
                child: Column(
                  children: [
                    // Push notifications toggle
                    _SettingsTile(
                      icon: Icons.notifications_active,
                      title: l10n.enablePushNotifications,
                      subtitle: l10n.receiveHabitReminders,
                      value: settings.pushNotificationsEnabled,
                      onChanged: (value) {
                        settingsNotifier.setPushNotificationsEnabled(
                          value,
                          habits: habitState.habits,
                          localizedTitleGenerator: (title) =>
                              l10n.notificationTimeFor(title),
                          localizedBody: l10n.notificationHabitStartsSoon,
                        );
                      },
                    ),

                    _buildDivider(),

                    // Sound toggle
                    _SettingsTile(
                      icon: Icons.volume_up,
                      title: l10n.notificationSound,
                      subtitle: settings.useDeviceSound
                          ? l10n.followDeviceSettings
                          : (settings.soundEnabled
                              ? l10n.soundAlwaysOn
                              : l10n.soundAlwaysOff),
                      value: settings.useDeviceSound
                          ? true
                          : settings.soundEnabled,
                      onChanged: (value) {
                        if (settings.useDeviceSound) {
                          // Switch to manual control
                          settingsNotifier.setUseDeviceSound(false);
                          settingsNotifier.setSoundEnabled(value);
                        } else {
                          settingsNotifier.setSoundEnabled(value);
                        }
                      },
                      trailing: IconButton(
                        icon: Icon(
                          settings.useDeviceSound
                              ? Icons.phone_android
                              : Icons.settings,
                          size: 20,
                        ),
                        tooltip: settings.useDeviceSound
                            ? l10n.useManualControl
                            : l10n.useDeviceSettings,
                        onPressed: () {
                          settingsNotifier
                              .setUseDeviceSound(!settings.useDeviceSound);
                        },
                      ),
                    ),

                    _buildDivider(),

                    // Vibration toggle
                    _SettingsTile(
                      icon: Icons.vibration,
                      title: l10n.vibration,
                      subtitle: settings.vibrationEnabled
                          ? l10n.vibrateOnNotifications
                          : l10n.vibrationDisabled,
                      value: settings.vibrationEnabled,
                      onChanged: (value) {
                        settingsNotifier.setVibrationEnabled(value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Colors.grey.withValues(alpha: 0.2),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onChanged != null;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing!,
            ] else ...[
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void showNotificationSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const NotificationSettingsSheet(),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/notification_settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/haptic_service.dart';
import 'habit_card.dart';
import 'celebration_animation.dart';

class SlidableHabitCard extends ConsumerStatefulWidget {
  final Habit habit;
  final VoidCallback onTap;

  const SlidableHabitCard({
    required this.habit,
    required this.onTap,
    super.key,
  });

  @override
  ConsumerState<SlidableHabitCard> createState() => _SlidableHabitCardState();
}

class _SlidableHabitCardState extends ConsumerState<SlidableHabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _successController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _successController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete(Habit currentHabit) async {
    if (_isProcessing) return;

    _isProcessing = true;

    final settings = ref.read(notificationSettingsProvider);
    final settingsNotifier = ref.read(notificationSettingsProvider.notifier);
    final shouldPlaySound = settingsNotifier.shouldPlaySound();
    final shouldVibrate = settingsNotifier.shouldVibrate();

    debugPrint(
        '✅ Complete habit - Sound: ${settings.soundEnabled}, Vibration: ${settings.vibrationEnabled}');
    debugPrint(
        '   shouldPlaySound: $shouldPlaySound, shouldVibrate: $shouldVibrate');

    if (mounted) {
      showCelebration(
        context,
        habitIcon: currentHabit.icon,
        playSound: shouldPlaySound,
        enableVibration: shouldVibrate,
      );
    }

    _successController.forward().then((_) => _successController.reverse());

    final habitNotifier = ref.read(habitProvider.notifier);

    habitNotifier.completeHabit(currentHabit).then((_) {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    });
  }

  Future<void> _handleUndo(Habit currentHabit) async {
    if (_isProcessing) return;

    _isProcessing = true;

    // Respect vibration settings for undo action
    final settings = ref.read(notificationSettingsProvider);
    final settingsNotifier = ref.read(notificationSettingsProvider.notifier);
    final shouldVibrate = settingsNotifier.shouldVibrate();

    debugPrint(
        '🔄 Undo habit - Vibration setting: ${settings.vibrationEnabled}, shouldVibrate: $shouldVibrate');

    HapticService.playUndoHaptic(
      enableVibration: shouldVibrate,
    );

    _successController.forward().then((_) => _successController.reverse());

    final habitNotifier = ref.read(habitProvider.notifier);
    habitNotifier.uncompleteHabit(currentHabit).then((_) {
      if (mounted) {
        setState(() => _isProcessing = false);

        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.undo_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  l10n.habitMarkedIncomplete(currentHabit.title),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final habitState = ref.watch(habitProvider);
    final habitNotifier = ref.read(habitProvider.notifier);

    final currentHabit = habitState.habits.firstWhere(
      (h) => h.id == widget.habit.id,
      orElse: () => widget.habit,
    );
    final isCompleted = habitNotifier.isHabitCompletedToday(currentHabit);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Slidable(
        key: ValueKey(widget.habit.id),
        enabled: !_isProcessing,
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.25,
          children: [
            if (isCompleted)
              CustomSlidableAction(
                onPressed: (context) => _handleUndo(currentHabit),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.orange.shade600,
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.orange.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.undo_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.undo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              CustomSlidableAction(
                onPressed: (context) => _handleComplete(currentHabit),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.green.shade600,
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.done,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        child: HabitCard(
          habit: currentHabit,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

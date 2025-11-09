import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../services/haptic_service.dart';
import 'habit_card.dart';
import 'celebration_animation.dart';

class SlidableHabitCard extends ConsumerStatefulWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback? onActionComplete;

  const SlidableHabitCard({
    required this.habit,
    required this.onTap,
    this.onActionComplete,
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

  Future<void> _handleComplete() async {
    if (_isProcessing) return;

    // Mark as processing but don't block UI
    _isProcessing = true;

    // Play haptic feedback and sound IMMEDIATELY
    HapticService.celebrateSuccess();

    // Show celebration animation IMMEDIATELY (non-blocking)
    if (mounted) {
      showCelebration(context, habitIcon: widget.habit.icon);
    }

    // Animate the card
    _successController.forward().then((_) => _successController.reverse());

    // Process habit completion in background (don't await - let it run in parallel)
    final habitNotifier = ref.read(habitProvider.notifier);
    habitNotifier.completeHabit(widget.habit).then((_) {
      if (mounted) {
        // Refresh UI after completion
        setState(() => _isProcessing = false);
        widget.onActionComplete?.call();

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.habit.title} completed!',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '🔥 ${widget.habit.currentStreak + 1} day streak!',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });
  }

  Future<void> _handleUndo() async {
    if (_isProcessing) return;

    // Mark as processing but don't block UI
    _isProcessing = true;

    // Play undo haptic feedback IMMEDIATELY (just shake, no animation)
    HapticService.playUndoHaptic();

    // Animate the card
    _successController.forward().then((_) => _successController.reverse());

    // Process habit undo in background (don't await - let it run in parallel)
    final habitNotifier = ref.read(habitProvider.notifier);
    habitNotifier.uncompleteHabit(widget.habit).then((_) {
      if (mounted) {
        // Refresh UI after completion
        setState(() => _isProcessing = false);
        widget.onActionComplete?.call();

        // Show undo feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.undo_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  '${widget.habit.title} marked incomplete',
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
    final habitNotifier = ref.watch(habitProvider.notifier);
    final isCompleted = habitNotifier.isHabitCompletedToday(widget.habit);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Slidable(
        key: ValueKey(widget.habit.id),
        enabled: !_isProcessing,

        // Swipe from left to right reveals action
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.25,
          children: [
            if (isCompleted)
              // Undo action (when habit is already completed)
              CustomSlidableAction(
                onPressed: (context) => _handleUndo(),
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
                        color: Colors.orange.withOpacity(0.3),
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
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.undo_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Undo',
                        style: TextStyle(
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
              // Complete action (when habit is not completed)
              CustomSlidableAction(
                onPressed: (context) => _handleComplete(),
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
                        color: Colors.green.withOpacity(0.3),
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
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Done',
                        style: TextStyle(
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
          habit: widget.habit,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

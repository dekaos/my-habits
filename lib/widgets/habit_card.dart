import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import 'glass_card.dart';

class HabitCard extends ConsumerStatefulWidget {
  final Habit habit;
  final VoidCallback onTap;

  const HabitCard({
    required this.habit,
    required this.onTap,
    super.key,
  });

  @override
  ConsumerState<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<HabitCard> {
  bool _isCompleting = false;

  Color _getColor() {
    return Color(
        int.parse(widget.habit.color.substring(1), radix: 16) + 0xFF000000);
  }

  Future<void> _handleComplete(bool isCompleted) async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    final habitNotifier = ref.read(habitProvider.notifier);

    if (isCompleted) {
      // Uncomplete the habit
      await habitNotifier.uncompleteHabit(widget.habit);
    } else {
      // Complete the habit
      await habitNotifier.completeHabit(widget.habit);
    }

    if (mounted) {
      setState(() {
        _isCompleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCompleted
              ? '${widget.habit.title} marked as incomplete'
              : '${widget.habit.title} completed! 🎉'),
          backgroundColor: isCompleted ? Colors.orange : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitNotifier = ref.watch(habitProvider.notifier);
    final isCompleted = habitNotifier.isHabitCompletedToday(widget.habit);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(widget.habit.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        // Don't actually dismiss, just trigger the action
        if (!_isCompleting) {
          await _handleComplete(isCompleted);
        }
        return false; // Never dismiss
      },
      background: _buildSwipeBackground(true, context),
      secondaryBackground: _buildSwipeBackground(false, context),
      child: GlassCard(
        padding: EdgeInsets.zero,
        color:
            isCompleted ? Colors.green.withOpacity(isDark ? 0.1 : 0.05) : null,
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.4)
              : _getColor().withOpacity(0.3),
          width: 2,
        ),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Status indicator - Loading or checkmark
              if (_isCompleting)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(_getColor()),
                      ),
                    ),
                  ),
                )
              else if (isCompleted)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
              if (_isCompleting || isCompleted) const SizedBox(width: 12),

              // Icon
              if (widget.habit.icon != null)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    IconData(
                      int.parse(widget.habit.icon!),
                      fontFamily: 'MaterialIcons',
                    ),
                    color: _getColor(),
                    size: 24,
                  ),
                ),
              const SizedBox(width: 12),

              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                    ),
                    if (widget.habit.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.habit.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (widget.habit.currentStreak > 0) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 14,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.habit.currentStreak}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (widget.habit.isPublic) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.public,
                              size: 14,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(bool isLeftSwipe, BuildContext context) {
    final habitNotifier = ref.read(habitProvider.notifier);
    final isCompleted = habitNotifier.isHabitCompletedToday(widget.habit);

    // Left swipe = complete, Right swipe = uncomplete
    final isCompletingAction = isLeftSwipe ? !isCompleted : isCompleted;
    final backgroundColor = isCompletingAction ? Colors.green : Colors.orange;
    final icon = isCompletingAction ? Icons.check_circle : Icons.cancel;
    final text = isCompletingAction ? 'Complete' : 'Undo';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor.withOpacity(0.3),
            backgroundColor,
          ],
          begin: isLeftSwipe ? Alignment.centerLeft : Alignment.centerRight,
          end: isLeftSwipe ? Alignment.centerRight : Alignment.centerLeft,
        ),
      ),
      alignment: isLeftSwipe ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

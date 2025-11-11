import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/performance_utils.dart';
import '../utils/habit_icons.dart';
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
  late Color _color;

  @override
  void initState() {
    super.initState();
    // Cache color calculation - avoids recalculation on every build
    try {
      _color = Color(PerformanceUtils.getColorInt(widget.habit.color));
    } catch (e) {
      debugPrint('Error parsing color ${widget.habit.color}: $e');
      _color = Colors.blue; // Fallback color
    }
  }

  Color _getColor() => _color;

  IconData _getIcon() {
    // Use predefined icon map for tree-shaking support
    return HabitIcons.getIcon(widget.habit.icon);
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
    final habitState = ref.watch(habitProvider);
    final habitNotifier = ref.read(habitProvider.notifier);

    final currentHabit = habitState.habits.firstWhere(
      (h) => h.id == widget.habit.id,
      orElse: () => widget.habit,
    );

    final isCompleted = habitNotifier.isHabitCompletedToday(currentHabit);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final streakProgress = currentHabit.currentStreak /
        (currentHabit.longestStreak > 0 ? currentHabit.longestStreak : 1);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          enableGlow: false,
          color: isCompleted
              ? Colors.green.withValues(alpha: isDark ? 0.1 : 0.05)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress ring
                      if (currentHabit.currentStreak > 0)
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            value: streakProgress.clamp(0.0, 1.0),
                            strokeWidth: 3,
                            backgroundColor: _getColor().withValues(alpha: 0.1),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_getColor()),
                          ),
                        ),
                      GestureDetector(
                        onTap: () async {
                          if (!_isCompleting) {
                            await _handleComplete(isCompleted);
                          }
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green.withValues(alpha: 0.2)
                                : _getColor().withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted
                                  ? Colors.green
                                  : _getColor().withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: _isCompleting
                              ? const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                      size: 28,
                                    )
                                  : Icon(
                                      _getIcon(),
                                      color: _getColor(),
                                      size: 28,
                                    ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                currentHabit.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.3,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (currentHabit.isPublic)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.public,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                        if (currentHabit.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            currentHabit.description!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (currentHabit.currentStreak > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade600,
                                      Colors.orange.shade400,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.orange.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '🔥',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${currentHabit.currentStreak} day${currentHabit.currentStreak > 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.done_all,
                                    size: 14,
                                    color: _getColor(),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${currentHabit.totalCompletions} total',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (currentHabit.totalCompletions > 0) ...[
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Consistency',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                        ),
                        Text(
                          currentHabit.currentStreak > 0
                              ? 'On Fire! 🔥'
                              : 'Keep Building',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: currentHabit.currentStreak > 0
                                        ? Colors.orange
                                        : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600]),
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (currentHabit.currentStreak /
                                (currentHabit.longestStreak > 0
                                    ? currentHabit.longestStreak
                                    : 7))
                            .clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(_getColor()),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

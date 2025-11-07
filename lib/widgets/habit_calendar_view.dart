import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import 'glass_card.dart';
import 'animated_gradient_background.dart';

class HabitCalendarView extends ConsumerStatefulWidget {
  const HabitCalendarView({super.key});

  @override
  ConsumerState<HabitCalendarView> createState() => _HabitCalendarViewState();
}

class _HabitCalendarViewState extends ConsumerState<HabitCalendarView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DateTime _selectedMonth = DateTime.now();
  Habit? _selectedHabit;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
    });
  }

  Color _getCompletionColor(int completionCount, BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    if (completionCount == 0) {
      return Colors.grey.shade200;
    } else if (completionCount == 1) {
      return primary.withValues(alpha: 0.3);
    } else if (completionCount == 2) {
      return primary.withValues(alpha: 0.5);
    } else if (completionCount == 3) {
      return primary.withValues(alpha: 0.7);
    } else {
      return primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitState = ref.watch(habitProvider);
    final habits = habitState.habits;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AnimatedGradientBackground(
            particleCount: 25,
            animationDuration: const Duration(seconds: 15),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.6),
                        Colors.white.withValues(alpha: 0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress Calendar',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Track your consistency',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),

                // Habit selector
                if (habits.isNotEmpty)
                  Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: habits.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // "All Habits" option
                          final isSelected = _selectedHabit == null;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedHabit = null),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ],
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : Colors.white.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.white.withValues(alpha: 0.5),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.grid_view_rounded,
                                      size: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.indigo.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'All Habits',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.indigo.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final habit = habits[index - 1];
                        final isSelected = _selectedHabit?.id == habit.id;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedHabit = habit),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                habit.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.indigo.shade700,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 24),

                // Calendar
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildMonthSelector(),
                        const SizedBox(height: 24),
                        _buildCalendarHeatmap(context, habits),
                        const SizedBox(height: 24),
                        _buildLegend(context),
                        const SizedBox(height: 24),
                        _buildStats(context, habits),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      enableGlow: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
            ),
          ),
          TweenAnimationBuilder<double>(
            key: ValueKey(_selectedMonth),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
              );
            },
          ),
          IconButton(
            onPressed: _selectedMonth.month == DateTime.now().month &&
                    _selectedMonth.year == DateTime.now().year
                ? null
                : _nextMonth,
            icon: const Icon(Icons.chevron_right_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeatmap(BuildContext context, List<Habit> habits) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    final firstDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    return GlassCard(
      padding: const EdgeInsets.all(20),
      enableGlow: false,
      child: Column(
        children: [
          // Weekday labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Calendar grid
          ...List.generate((daysInMonth + firstWeekday) ~/ 7 + 1, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox(width: 40, height: 40);
                  }

                  final date = DateTime(
                      _selectedMonth.year, _selectedMonth.month, dayNumber);
                  final isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;
                  final isFuture = date.isAfter(DateTime.now());

                  // Calculate completion count for this day
                  int completionCount = 0;
                  if (_selectedHabit != null) {
                    // Single habit view
                    completionCount =
                        _getHabitCompletionsForDay(_selectedHabit!, date);
                  } else {
                    // All habits view
                    for (var habit in habits) {
                      completionCount +=
                          _getHabitCompletionsForDay(habit, date);
                    }
                  }

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (dayNumber * 10)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isFuture
                                ? Colors.grey.shade100
                                : _getCompletionColor(completionCount, context),
                            borderRadius: BorderRadius.circular(8),
                            border: isToday
                                ? Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 3,
                                  )
                                : null,
                            boxShadow: completionCount > 0 && !isFuture
                                ? [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontWeight:
                                    isToday ? FontWeight.bold : FontWeight.w500,
                                color: isFuture
                                    ? Colors.grey.shade400
                                    : completionCount > 2
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  int _getHabitCompletionsForDay(Habit habit, DateTime date) {
    // Check if habit has completions for this specific day
    // This is a simplified check - you may need to enhance based on your data structure
    if (habit.lastCompletedDate != null) {
      final lastCompleted = habit.lastCompletedDate!;
      if (lastCompleted.year == date.year &&
          lastCompleted.month == date.month &&
          lastCompleted.day == date.day) {
        return habit.targetCount;
      }
    }
    return 0;
  }

  Widget _buildLegend(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      enableGlow: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Less',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          ...List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: index == 0
                      ? Colors.grey.shade200
                      : _getCompletionColor(index, context),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          Text(
            'More',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, List<Habit> habits) {
    int totalCompletions = 0;
    int currentStreak = 0;
    int longestStreak = 0;

    if (_selectedHabit != null) {
      totalCompletions = _selectedHabit!.totalCompletions;
      currentStreak = _selectedHabit!.currentStreak;
      longestStreak = _selectedHabit!.longestStreak;
    } else {
      for (var habit in habits) {
        totalCompletions += habit.totalCompletions;
        if (habit.currentStreak > currentStreak) {
          currentStreak = habit.currentStreak;
        }
        if (habit.longestStreak > longestStreak) {
          longestStreak = habit.longestStreak;
        }
      }
    }

    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                context, '🔥', '$currentStreak', 'Current\nStreak')),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(
                context, '🏆', '$longestStreak', 'Longest\nStreak')),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(
                context, '✅', '$totalCompletions', 'Total\nCompleted')),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, String emoji, String value, String label) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      enableGlow: false,
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';
import '../../models/habit_completion.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_card.dart';
import '../../services/haptic_service.dart';
import '../../widgets/celebration_animation.dart';
import '../../widgets/share_progress_sheet.dart';
import 'edit_habit_screen.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final Habit habit;

  const HabitDetailScreen({required this.habit, super.key});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen>
    with SingleTickerProviderStateMixin {
  List<HabitCompletion> _completions = [];
  final _noteController = TextEditingController();
  bool _isCompleting = false;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompletions();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadCompletions() async {
    final completions = await ref
        .read(habitProvider.notifier)
        .getHabitCompletions(widget.habit.id);
    setState(() {
      _completions = completions;
    });
  }

  Future<void> _completeHabit() async {
    if (_isCompleting) return;

    _isCompleting = true;

    HapticService.celebrateSuccess();

    if (mounted) {
      showCelebration(context, habitIcon: widget.habit.icon);
    }

    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    final habitState = ref.read(habitProvider);
    final currentHabit = habitState.habits.firstWhere(
      (h) => h.id == widget.habit.id,
      orElse: () => widget.habit,
    );
    ref
        .read(habitProvider.notifier)
        .completeHabit(currentHabit, note: note)
        .then((_) async {
      await _loadCompletions();

      if (mounted) {
        _noteController.clear();
        setState(() {
          _isCompleting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitState = ref.watch(habitProvider);

    final currentHabit = habitState.habits.firstWhere(
      (h) => h.id == widget.habit.id,
      orElse: () => widget.habit,
    );

    final habitNotifier = ref.read(habitProvider.notifier);
    final isCompletedToday = habitNotifier.isHabitCompletedToday(currentHabit);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(currentHabit.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              showShareProgress(
                context,
                currentHabit,
                currentHabit.currentStreak,
                currentHabit.totalCompletions,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditHabitScreen(habit: currentHabit),
                ),
              );

              if (result == true && mounted) {
                await _loadCompletions();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Habit'),
                  content:
                      const Text('Are you sure you want to delete this habit?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref
                    .read(habitProvider.notifier)
                    .deleteHabit(widget.habit.id);

                if (!mounted || !context.mounted) return;

                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (value * 0.2),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildStreakCard(context, currentHabit),
                    ),
                    const SizedBox(height: 16),

                    if (!isCompletedToday) ...[
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: _buildCheckInSection(context),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          enableGlow: false,
                          color: Colors.green.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.4),
                            width: 2,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_circle,
                                    color: Colors.green, size: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Completed today! Great job! 🎉',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Chart section
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildChartSection(context),
                    ),
                    const SizedBox(height: 16),

                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildRecentCompletions(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, Habit habit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        enableGlow: false,
        color: isDark
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
            : Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStreakStat(
              context,
              emoji: '🔥',
              value: '${habit.currentStreak}',
              label: 'Current',
            ),
            Container(
              width: 1,
              height: 60,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
            ),
            _buildStreakStat(
              context,
              emoji: '🏆',
              value: '${habit.longestStreak}',
              label: 'Best',
            ),
            Container(
              width: 1,
              height: 60,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
            ),
            _buildStreakStat(
              context,
              emoji: '✓',
              value: '${habit.totalCompletions}',
              label: 'Total',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStat(
    BuildContext context, {
    required String emoji,
    required String value,
    required String label,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: Column(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckInSection(BuildContext context) {
    return RepaintBoundary(
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Check In',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              enableGlow: false,
              child: TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  hintText: 'Add a note (optional)...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 16),
            GlassButton(
              onPressed: _isCompleting ? () {} : _completeHabit,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isCompleting)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    const Icon(Icons.check_circle, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isCompleting ? 'Completing... 🎉' : 'Mark as Complete',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    if (_completions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get last 7 days of data
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    final completionsByDay = <DateTime, int>{};
    for (var completion in _completions) {
      final date = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );
      completionsByDay[date] = (completionsByDay[date] ?? 0) + 1;
    }

    return RepaintBoundary(
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        enableGlow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Last 7 Days',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: RepaintBoundary(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 5,
                    barGroups: last7Days.asMap().entries.map((entry) {
                      final date = DateTime(
                          entry.value.year, entry.value.month, entry.value.day);
                      final count = completionsByDay[date] ?? 0;
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: count.toDouble(),
                            color: Theme.of(context).colorScheme.primary,
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 28),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final date = last7Days[value.toInt()];
                            return Text(
                              [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun'
                              ][date.weekday - 1],
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCompletions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_completions.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(32),
        enableGlow: false,
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 60,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No completions yet.\nStart your streak today!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      enableGlow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Recent Completions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 16),
          ..._completions.take(10).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final completion = entry.value;
            return RepaintBoundary(
              key: ValueKey(completion.id),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 500 + (index * 80)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(20 * (1 - value), 0),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${completion.completedAt.day}/${completion.completedAt.month}/${completion.completedAt.year}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (completion.note != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                completion.note!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

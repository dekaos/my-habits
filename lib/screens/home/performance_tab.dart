import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';
import '../../models/habit_completion.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/glass_card.dart';
import '../../utils/chart_calculator.dart';
import '../habits/habit_detail_screen.dart';

class PerformanceTab extends ConsumerStatefulWidget {
  const PerformanceTab({super.key});

  @override
  ConsumerState<PerformanceTab> createState() => _PerformanceTabState();
}

class _PerformanceTabState extends ConsumerState<PerformanceTab>
    with AutomaticKeepAliveClientMixin {
  Map<String, List<HabitCompletion>> _allCompletions = {};
  bool _isLoadingCompletions = false;
  bool _hasLoadedOnce = false;

  TrendChartData? _trendChartData;
  WeeklyPatternData? _weeklyPatternData;
  bool _isCalculatingCharts = false;

  final ScrollController _heatmapScrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  /// Format date based on locale: EN = month/day, PT = day/month
  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'pt') {
      return '${date.day}/${date.month}';
    }
    // Default to month/day for English and other languages
    return '${date.month}/${date.day}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllCompletions();
    });
  }

  @override
  void dispose() {
    _heatmapScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAllCompletions() async {
    if (_isLoadingCompletions) return;

    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    setState(() {
      _isLoadingCompletions = true;
    });

    final habits = ref.read(habitProvider).habits;

    if (habits.isEmpty && !_hasLoadedOnce) {
      setState(() {
        _isLoadingCompletions = false;
      });
      return;
    }

    try {
      final allCompletions = await ref
          .read(habitProvider.notifier)
          .getAllUserCompletions(authState.user!.id);

      final completionsByHabit = <String, List<HabitCompletion>>{};

      for (final completion in allCompletions) {
        if (!completionsByHabit.containsKey(completion.habitId)) {
          completionsByHabit[completion.habitId] = [];
        }
        completionsByHabit[completion.habitId]!.add(completion);
      }

      if (mounted) {
        setState(() {
          _allCompletions = completionsByHabit;
          _isLoadingCompletions = false;
          _hasLoadedOnce = true;
        });

        // Calculate chart data in background isolate
        _calculateChartData();
      }
    } catch (e) {
      debugPrint('Error loading completions: $e');
      if (mounted) {
        setState(() {
          _isLoadingCompletions = false;
        });
      }
    }
  }

  /// Calculate chart data in isolate (runs in background for 100+ completions)
  Future<void> _calculateChartData() async {
    if (_isCalculatingCharts || _allCompletions.isEmpty) return;

    setState(() {
      _isCalculatingCharts = true;
    });

    try {
      // Calculate both charts in parallel
      final results = await Future.wait([
        ChartCalculator.calculateTrendData(_allCompletions),
        ChartCalculator.calculateWeeklyPattern(_allCompletions),
      ]);

      if (mounted) {
        setState(() {
          _trendChartData = results[0] as TrendChartData;
          _weeklyPatternData = results[1] as WeeklyPatternData;
          _isCalculatingCharts = false;
        });
      }
    } catch (e) {
      debugPrint('Error calculating chart data: $e');
      if (mounted) {
        setState(() {
          _isCalculatingCharts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final habitState = ref.watch(habitProvider);
    final habits = habitState.habits;

    ref.listen<HabitState>(habitProvider, (previous, next) {
      final prevTotal = previous?.habits.fold<int>(
            0,
            (sum, h) => sum + h.totalCompletions,
          ) ??
          0;
      final nextTotal = next.habits.fold<int>(
        0,
        (sum, h) => sum + h.totalCompletions,
      );

      if (previous?.habits.length != next.habits.length ||
          (next.habits.isNotEmpty && !_hasLoadedOnce) ||
          prevTotal != nextTotal) {
        _loadAllCompletions();
      }
    });

    if (habits.isNotEmpty && !_hasLoadedOnce && !_isLoadingCompletions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAllCompletions();
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: GlassAppBar(
          title: l10n.performance,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await _loadAllCompletions();
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final authState = ref.read(authProvider);
          if (authState.user != null) {
            await ref
                .read(habitProvider.notifier)
                .loadHabits(authState.user!.id);
            await _loadAllCompletions();
          }
        },
        child: _isLoadingCompletions
            ? const Center(child: CircularProgressIndicator())
            : habits.isEmpty
                ? _buildEmptyState(context)
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildOverviewCards(habits),
                      const SizedBox(height: 16),
                      _buildTimelineHeatmap(),
                      const SizedBox(height: 16),
                      _buildTrendChart(),
                      const SizedBox(height: 16),
                      _buildStreakInsights(habits),
                      const SizedBox(height: 16),
                      _buildTopHabits(habits),
                      const SizedBox(height: 16),
                      _buildWeeklyPattern(),
                      const SizedBox(height: 80),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noPerformanceData,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startTrackingHabits,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(List<Habit> habits) {
    final l10n = AppLocalizations.of(context)!;
    final totalCompletions = habits.fold<int>(
      0,
      (sum, habit) => sum + habit.totalCompletions,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            l10n.totalHabits,
            habits.length.toString(),
            Icons.format_list_bulleted,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            l10n.completions,
            totalCompletions.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return RepaintBoundary(
      child: GlassCard(
        enableGlow: false,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineHeatmap() {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 89));

    debugPrint('📊 Heatmap calculation:');
    debugPrint('   Today: $today');
    debugPrint('   Start Date: $startDate (90 days ago)');
    debugPrint('   Total habits with completions: ${_allCompletions.length}');

    final dateCompletions = <DateTime, int>{};
    int totalProcessed = 0;
    int totalInRange = 0;

    for (final habitCompletions in _allCompletions.values) {
      for (final completion in habitCompletions) {
        totalProcessed++;
        final date = DateTime(
          completion.completedAt.year,
          completion.completedAt.month,
          completion.completedAt.day,
        );
        if (!date.isBefore(startDate) && !date.isAfter(today)) {
          dateCompletions[date] = (dateCompletions[date] ?? 0) + 1;
          totalInRange++;
        }
      }
    }

    debugPrint('   Total completions processed: $totalProcessed');
    debugPrint('   Completions in date range: $totalInRange');
    debugPrint('   Unique dates with completions: ${dateCompletions.length}');
    if (dateCompletions.isNotEmpty) {
      debugPrint(
          '   Date range: ${dateCompletions.keys.reduce((a, b) => a.isBefore(b) ? a : b)} to ${dateCompletions.keys.reduce((a, b) => a.isAfter(b) ? a : b)}');
    }

    final maxCompletions = dateCompletions.values.isEmpty
        ? 1
        : dateCompletions.values.reduce((a, b) => a > b ? a : b);

    debugPrint('   Max completions in a day: $maxCompletions');

    return RepaintBoundary(
      child: GlassCard(
        enableGlow: false,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.activityHeatmap,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.last90Days,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            dateCompletions.isEmpty
                ? SizedBox(
                    height: 120,
                    child: Center(
                      child: Text(
                        l10n.noActivity90Days,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      _buildHeatmapGrid(
                          context, dateCompletions, startDate, maxCompletions),
                      const SizedBox(height: 12),
                      _buildHeatmapLegend(maxCompletions),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid(
    BuildContext context,
    Map<DateTime, int> completions,
    DateTime startDate,
    int maxCompletions,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const cellSize = 14.0;
    const cellSpacing = 4.0;

    final weeks = <List<DateTime>>[];
    final currentWeek = <DateTime>[];
    int totalDays = 0;
    int daysWithCompletions = 0;

    for (int i = 0; i <= 90; i++) {
      final rawDate = startDate.add(Duration(days: i));
      final date = DateTime(rawDate.year, rawDate.month, rawDate.day);

      if (date.isAfter(today)) break;

      totalDays++;
      if (completions.containsKey(date) && completions[date]! > 0) {
        daysWithCompletions++;
      }

      currentWeek.add(date);

      if (date.weekday == 7 || i == 90 || date == today) {
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }
    }

    debugPrint(
        '📅 Grid built: $totalDays total days, ${weeks.length} weeks, $daysWithCompletions days with activity');

    // Scroll to the right (most recent) after building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_heatmapScrollController.hasClients && mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_heatmapScrollController.hasClients && mounted) {
            _heatmapScrollController.animateTo(
              _heatmapScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            debugPrint('📜 Heatmap scrolled to show recent days');
          }
        });
      }
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _heatmapScrollController,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: weeks.asMap().entries.map((entry) {
          final weekIndex = entry.key;
          final week = entry.value;

          return Padding(
            padding: const EdgeInsets.only(right: cellSpacing),
            child: Column(
              children: week.asMap().entries.map((dayEntry) {
                final dayIndex = dayEntry.key;
                final date = dayEntry.value;
                final count = completions[date] ?? 0;
                final intensity =
                    maxCompletions > 0 ? count / maxCompletions : 0;

                // Debug logging for activity cells
                if (count > 0) {
                  debugPrint(
                      '   ✓ ${_formatDate(context, date)} (Week $weekIndex, Day $dayIndex): $count completions (${(intensity * 100).toStringAsFixed(0)}% intensity)');
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: cellSpacing),
                  child: Tooltip(
                    message: l10n.completionsTooltip(
                        _formatDate(context, date), count),
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        color: count == 0
                            ? Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.2)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.2 + (intensity * 0.8)),
                        borderRadius: BorderRadius.circular(3),
                        border: count > 0
                            ? Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.4),
                                width: 0.5,
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeatmapLegend(int maxCompletions) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          l10n.less,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          final intensity = (index + 1) / 5;
          return Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2 + (intensity * 0.8)),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          l10n.more,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildTrendChart() {
    final l10n = AppLocalizations.of(context)!;
    // Use pre-calculated data from isolate
    final data = _trendChartData;

    // Show loading state while calculating
    if (data == null) {
      return RepaintBoundary(
        child: GlassCard(
          enableGlow: false,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.dayTrend30,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final maxY = data.maxY;
    final yInterval = data.yInterval;
    final maxCount = data.maxCount;

    return RepaintBoundary(
      child: GlassCard(
        enableGlow: false,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dayTrend30,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
                if (maxCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.peak(maxCount),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: maxCount == 0
                  ? Center(
                      child: Text(
                        l10n.noCompletions30Days,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        maxY: maxY,
                        minY: 0,
                        minX: 0,
                        maxX: 29,
                        lineTouchData: const LineTouchData(enabled: true),
                        lineBarsData: [
                          LineChartBarData(
                            // Use pre-calculated data points from isolate
                            spots: data.dataPoints
                                .map((p) => FlSpot(p.x, p.y))
                                .toList(),
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: Theme.of(context).colorScheme.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: spot.y > 0 ? 3 : 0,
                                  color: Theme.of(context).colorScheme.primary,
                                  strokeWidth: 1,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: yInterval,
                              getTitlesWidget: (value, meta) {
                                // Only show whole numbers
                                if (value % yInterval == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 &&
                                    index < data.dataPoints.length &&
                                    (index % 7 == 0 || index == 29)) {
                                  final date = data.dataPoints[index].date;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _formatDate(context, date),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: yInterval,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.2),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakInsights(List<Habit> habits) {
    final l10n = AppLocalizations.of(context)!;
    final avgStreak = habits.isEmpty
        ? 0.0
        : habits.fold<int>(0, (sum, habit) => sum + habit.currentStreak) /
            habits.length;

    final longestStreak = habits.isEmpty
        ? 0
        : habits.fold<int>(
            0,
            (max, habit) =>
                habit.longestStreak > max ? habit.longestStreak : max,
          );

    final activeHabits = habits.where((h) => h.currentStreak > 0).length;

    return RepaintBoundary(
      child: GlassCard(
        enableGlow: false,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withValues(alpha: 0.3),
                        Colors.deepOrange.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.streakInsights,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInsightItem(
                    context,
                    l10n.avgStreak,
                    avgStreak.toStringAsFixed(1),
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightItem(
                    context,
                    l10n.bestStreak,
                    longestStreak.toString(),
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightItem(
                    context,
                    l10n.activeNow,
                    activeHabits.toString(),
                    Icons.bolt,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopHabits(List<Habit> habits) {
    final l10n = AppLocalizations.of(context)!;
    final sortedHabits = List<Habit>.from(habits)
      ..sort((a, b) => b.totalCompletions.compareTo(a.totalCompletions));

    final topHabits = sortedHabits.take(5).toList();

    if (topHabits.isEmpty) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: GlassCard(
        enableGlow: false,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withValues(alpha: 0.3),
                        Colors.blue.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.topPerformingHabits,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...topHabits.asMap().entries.map((entry) {
              final index = entry.key;
              final habit = entry.value;
              return _buildTopHabitItem(context, habit, index + 1);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHabitItem(BuildContext context, Habit habit, int rank) {
    final l10n = AppLocalizations.of(context)!;
    final color = Color(int.parse(habit.color.replaceFirst('#', '0xFF')));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HabitDetailScreen(habit: habit),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: color),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              l10n.completionsCount(habit.totalCompletions),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.local_fire_department,
                              size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              l10n.streakCount(habit.currentStreak),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyPattern() {
    final l10n = AppLocalizations.of(context)!;
    // Use pre-calculated data from isolate
    final data = _weeklyPatternData;

    // Show loading state while calculating
    if (data == null) {
      return RepaintBoundary(
        child: GlassCard(
          enableGlow: false,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.weeklyPattern,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final weekdayCompletions = data.weekdayCompletions;
    final maxY = data.maxY;
    final yInterval = data.yInterval;

    return RepaintBoundary(
      child: GlassCard(
        enableGlow: false,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withValues(alpha: 0.3),
                        Colors.teal.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.weeklyPattern,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: weekdayCompletions.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          width: 32,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: yInterval,
                        getTitlesWidget: (value, meta) {
                          // Only show whole numbers at proper intervals
                          if (value % yInterval == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = [
                            l10n.mon,
                            l10n.tue,
                            l10n.wed,
                            l10n.thu,
                            l10n.fri,
                            l10n.sat,
                            l10n.sun
                          ];
                          if (value.toInt() >= 0 && value.toInt() < 7) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  alignment: BarChartAlignment.spaceEvenly,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

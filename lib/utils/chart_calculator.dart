import 'package:flutter/foundation.dart';
import '../models/habit_completion.dart';

/// Heavy chart calculations moved to isolate
class ChartCalculator {
  /// Calculate trend chart data in isolate
  static Future<TrendChartData> calculateTrendData(
    Map<String, List<HabitCompletion>> allCompletions,
  ) async {
    // For small datasets, calculate on main thread
    final totalCompletions =
        allCompletions.values.fold<int>(0, (sum, list) => sum + list.length);

    if (totalCompletions < 100) {
      return _calculateTrendDataSync(allCompletions);
    }

    // For large datasets, use isolate
    debugPrint(
        '🔄 Calculating trend chart in isolate ($totalCompletions completions)');

    return await compute(
      _calculateTrendDataSync,
      allCompletions,
    );
  }

  /// Calculate weekly pattern data in isolate
  static Future<WeeklyPatternData> calculateWeeklyPattern(
    Map<String, List<HabitCompletion>> allCompletions,
  ) async {
    final totalCompletions =
        allCompletions.values.fold<int>(0, (sum, list) => sum + list.length);

    if (totalCompletions < 100) {
      return _calculateWeeklyPatternSync(allCompletions);
    }

    debugPrint(
        '🔄 Calculating weekly pattern in isolate ($totalCompletions completions)');

    return await compute(
      _calculateWeeklyPatternSync,
      allCompletions,
    );
  }

  /// Synchronous trend calculation (runs in isolate)
  static TrendChartData _calculateTrendDataSync(
    Map<String, List<HabitCompletion>> allCompletions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate last 30 days
    final last30Days = List.generate(30, (index) {
      final date = today.subtract(Duration(days: 29 - index));
      return DateTime(date.year, date.month, date.day);
    });

    // Count completions by day
    final completionsByDay = <DateTime, int>{};
    for (final habitCompletions in allCompletions.values) {
      for (final completion in habitCompletions) {
        final date = DateTime(
          completion.completedAt.year,
          completion.completedAt.month,
          completion.completedAt.day,
        );
        completionsByDay[date] = (completionsByDay[date] ?? 0) + 1;
      }
    }

    final maxCount = completionsByDay.values.isEmpty
        ? 0
        : completionsByDay.values.reduce((a, b) => a > b ? a : b);

    // Calculate chart bounds
    double maxY;
    double yInterval;

    if (maxCount == 0) {
      maxY = 10.0;
      yInterval = 2.0;
    } else if (maxCount <= 5) {
      maxY = 10.0;
      yInterval = 2.0;
    } else {
      maxY = ((maxCount + 4) / 5).ceil() * 5.0;
      yInterval = 5.0;
    }

    // Create data points
    final dataPoints = last30Days.asMap().entries.map((entry) {
      final date = entry.value;
      final count = completionsByDay[date] ?? 0;
      return ChartDataPoint(
        x: entry.key.toDouble(),
        y: count.toDouble(),
        date: date,
      );
    }).toList();

    return TrendChartData(
      dataPoints: dataPoints,
      maxY: maxY,
      yInterval: yInterval,
      maxCount: maxCount,
    );
  }

  /// Synchronous weekly pattern calculation (runs in isolate)
  static WeeklyPatternData _calculateWeeklyPatternSync(
    Map<String, List<HabitCompletion>> allCompletions,
  ) {
    final weekdayCompletions = List.filled(7, 0);

    for (final habitCompletions in allCompletions.values) {
      for (final completion in habitCompletions) {
        final weekday = completion.completedAt.weekday - 1; // 0 = Monday
        weekdayCompletions[weekday]++;
      }
    }

    final maxCompletions = weekdayCompletions.isEmpty
        ? 1
        : weekdayCompletions.reduce((a, b) => a > b ? a : b);

    // Calculate proper maxY and interval
    final rawMaxY = maxCompletions > 0 ? maxCompletions * 1.2 : 10.0;
    final maxY = rawMaxY < 10 ? 10.0 : ((rawMaxY + 4) / 5).ceil() * 5.0;
    final yInterval = maxY > 10 ? 5.0 : 2.0;

    return WeeklyPatternData(
      weekdayCompletions: weekdayCompletions,
      maxY: maxY,
      yInterval: yInterval,
      maxCompletions: maxCompletions,
    );
  }
}

/// Data class for trend chart
class TrendChartData {
  final List<ChartDataPoint> dataPoints;
  final double maxY;
  final double yInterval;
  final int maxCount;

  TrendChartData({
    required this.dataPoints,
    required this.maxY,
    required this.yInterval,
    required this.maxCount,
  });
}

/// Data point for charts
class ChartDataPoint {
  final double x;
  final double y;
  final DateTime date;

  ChartDataPoint({
    required this.x,
    required this.y,
    required this.date,
  });
}

/// Data class for weekly pattern
class WeeklyPatternData {
  final List<int> weekdayCompletions;
  final double maxY;
  final double yInterval;
  final int maxCompletions;

  WeeklyPatternData({
    required this.weekdayCompletions,
    required this.maxY,
    required this.yInterval,
    required this.maxCompletions,
  });
}

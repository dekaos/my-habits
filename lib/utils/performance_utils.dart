import 'dart:async';
import 'package:flutter/foundation.dart';

/// Performance utilities for multithreading and optimization
class PerformanceUtils {
  /// Cache for expensive color calculations
  static final Map<String, int> _colorCache = {};

  /// Parse color string to int with caching (avoids repeated parsing)
  static int getColorInt(String colorString) {
    return _colorCache.putIfAbsent(
      colorString,
      () => int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
    );
  }

  /// Run heavy computation on separate isolate
  static Future<T> runIsolated<T>(
    FutureOr<T> Function() computation,
  ) async {
    return await compute((_) => computation(), null);
  }

  /// Debounce function calls to reduce rebuilds
  static Timer? _debounceTimer;
  static void debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }

  /// Throttle function calls
  static DateTime? _lastThrottleTime;
  static void throttle(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 100),
  }) {
    final now = DateTime.now();
    if (_lastThrottleTime == null ||
        now.difference(_lastThrottleTime!) >= duration) {
      _lastThrottleTime = now;
      callback();
    }
  }

  /// Clear caches when needed (e.g., on theme change)
  static void clearCaches() {
    _colorCache.clear();
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'logger.dart';

/// Performance monitoring utility
class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};
  static const int maxMemoryMB = 150;

  /// Start timing an operation
  static void startTimer(String operation) {
    if (kDebugMode) {
      _timers[operation] = Stopwatch()..start();
    }
  }

  /// End timing and log the result
  static void endTimer(String operation) {
    if (kDebugMode) {
      final timer = _timers.remove(operation);
      if (timer != null) {
        timer.stop();
        final duration = Duration(milliseconds: timer.elapsedMilliseconds);
        AppLogger.performance(operation, duration);
        
        // Warn if operation takes too long
        if (duration.inMilliseconds > 2000) {
          AppLogger.warning('$operation took ${duration.inMilliseconds}ms (target: <2000ms)');
        }
      }
    }
  }

  /// Measure async operation
  static Future<T> measure<T>(
    String operation,
    Future<T> Function() callback,
  ) async {
    startTimer(operation);
    try {
      final result = await callback();
      endTimer(operation);
      return result;
    } catch (e, stackTrace) {
      endTimer(operation);
      AppLogger.error('$operation failed', e, stackTrace);
      rethrow;
    }
  }

  /// Check memory usage (approximate)
  static void logMemoryUsage() {
    if (kDebugMode) {
      // Note: Flutter doesn't provide direct memory access
      // This is a placeholder for future implementation
      AppLogger.debug('Memory check: Target < ${maxMemoryMB}MB');
    }
  }
}


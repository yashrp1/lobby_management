import 'package:flutter/foundation.dart';

/// Centralized logging utility following Flutter best practices
class AppLogger {
  static const String _tag = '[EventLobby]';

  /// Log debug messages (only in debug mode)
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_tag [DEBUG] $message');
      if (error != null) {
        debugPrint('$_tag [ERROR] $error');
        if (stackTrace != null) {
          debugPrint('$_tag [STACK] $stackTrace');
        }
      }
    }
  }

  /// Log info messages
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_tag [INFO] $message');
    }
  }

  /// Log warning messages
  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('$_tag [WARNING] $message');
      if (error != null) {
        debugPrint('$_tag [ERROR] $error');
      }
    }
  }

  /// Log error messages
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('$_tag [ERROR] $message');
    if (error != null) {
      debugPrint('$_tag [ERROR_DETAIL] $error');
      if (stackTrace != null) {
        debugPrint('$_tag [STACK_TRACE] $stackTrace');
      }
    }
  }

  /// Log API requests
  static void apiRequest(String method, String url, [Map<String, dynamic>? headers]) {
    if (kDebugMode) {
      debugPrint('$_tag [API] $method $url');
      if (headers != null && headers.isNotEmpty) {
        final sanitizedHeaders = Map<String, dynamic>.from(headers);
        // Remove sensitive headers from logs
        if (sanitizedHeaders.containsKey('Authorization')) {
          sanitizedHeaders['Authorization'] = 'Bearer ***';
        }
        debugPrint('$_tag [HEADERS] $sanitizedHeaders');
      }
    }
  }

  /// Log API responses
  static void apiResponse(int statusCode, String url, [int? responseTimeMs]) {
    if (kDebugMode) {
      final timeInfo = responseTimeMs != null ? ' (${responseTimeMs}ms)' : '';
      debugPrint('$_tag [API] $statusCode $url$timeInfo');
    }
  }

  /// Log performance metrics
  static void performance(String operation, Duration duration) {
    if (kDebugMode) {
      debugPrint('$_tag [PERF] $operation: ${duration.inMilliseconds}ms');
    }
  }
}


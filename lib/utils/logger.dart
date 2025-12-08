import 'package:flutter/foundation.dart';

/// Simple logger utility for the app
/// Only logs in debug mode, suppressed in production
class Logger {
  final String _tag;

  Logger(this._tag);

  /// Log debug message
  void debug(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] DEBUG: $message');
    }
  }

  /// Log info message
  void info(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] INFO: $message');
    }
  }

  /// Log warning message
  void warning(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] WARNING: $message');
    }
  }

  /// Log error message
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$_tag] ERROR: $message');
      if (error != null) {
        debugPrint('  Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('  StackTrace: $stackTrace');
      }
    }
  }
}

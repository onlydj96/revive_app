import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Error information model
class AppError {
  final String id;
  final String message;
  final String? details;
  final DateTime timestamp;
  final ErrorSeverity severity;
  final String? source; // Which provider/service caused the error

  AppError({
    required this.message,
    this.details,
    required this.severity,
    this.source,
    String? id,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = DateTime.now();

  @override
  String toString() {
    return 'AppError(message: $message, severity: $severity, source: $source)';
  }
}

enum ErrorSeverity {
  info, // Informational, no action required
  warning, // Warning, user should be aware
  error, // Error, action failed
  critical // Critical error, app functionality affected
}

/// Global error state provider
final errorProvider =
    StateNotifierProvider<ErrorNotifier, List<AppError>>((ref) {
  return ErrorNotifier();
});

/// Provider for the most recent error
final latestErrorProvider = Provider<AppError?>((ref) {
  final errors = ref.watch(errorProvider);
  return errors.isNotEmpty ? errors.last : null;
});

/// Provider for errors by severity
final errorsBySeverityProvider =
    Provider.family<List<AppError>, ErrorSeverity>((ref, severity) {
  final errors = ref.watch(errorProvider);
  return errors.where((error) => error.severity == severity).toList();
});

/// Provider for critical errors count
final criticalErrorsCountProvider = Provider<int>((ref) {
  final errors = ref.watch(errorProvider);
  return errors
      .where((error) => error.severity == ErrorSeverity.critical)
      .length;
});

class ErrorNotifier extends StateNotifier<List<AppError>> {
  ErrorNotifier() : super([]);

  /// Add a new error
  void addError({
    required String message,
    String? details,
    ErrorSeverity severity = ErrorSeverity.error,
    String? source,
  }) {
    final error = AppError(
      message: message,
      details: details,
      severity: severity,
      source: source,
    );

    state = [...state, error];

    // Auto-clear info and warning errors after 10 seconds
    if (severity == ErrorSeverity.info || severity == ErrorSeverity.warning) {
      Future.delayed(const Duration(seconds: 10), () {
        removeError(error.id);
      });
    }
  }

  /// Remove a specific error
  void removeError(String errorId) {
    state = state.where((error) => error.id != errorId).toList();
  }

  /// Clear all errors
  void clearAll() {
    state = [];
  }

  /// Clear errors by severity
  void clearBySeverity(ErrorSeverity severity) {
    state = state.where((error) => error.severity != severity).toList();
  }

  /// Clear errors by source
  void clearBySource(String source) {
    state = state.where((error) => error.source != source).toList();
  }
}

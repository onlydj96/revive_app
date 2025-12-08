import 'package:flutter/material.dart';

/// Unified UI utilities for dialogs, snackbars, and confirmations
/// Consolidates functionality from DialogUtils, SnackbarUtils, and ConfirmationDialog
class UIUtils {
  // ==================== Snackbar Methods ====================

  /// Show success message
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.green,
      duration: duration,
      action: action,
    );
  }

  /// Show error message
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.red,
      duration: duration,
      action: action,
    );
  }

  /// Show info message
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.blue,
      duration: duration,
      action: action,
    );
  }

  /// Show warning message
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.orange,
      duration: duration,
      action: action,
    );
  }

  /// Show loading snackbar (long duration)
  static void showLoading(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(minutes: 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Clear all snackbars
  static void clearSnackBars(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  // ==================== Dialog Methods ====================

  /// Show confirmation dialog
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
    Color? confirmColor,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? (isDestructive ? Colors.red : null),
              foregroundColor: isDestructive ? Colors.white : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show confirmation dialog with detailed content
  static Future<bool> showDetailedConfirmation(
    BuildContext context, {
    required String title,
    required String primaryMessage,
    required String secondaryMessage,
    String confirmText = '확인',
    String cancelText = '취소',
    Color? confirmColor,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              primaryMessage,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              secondaryMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? (isDestructive ? Colors.red : null),
              foregroundColor: isDestructive ? Colors.white : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show loading dialog
  static Future<void> showLoadingDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Hide current dialog
  static void hideDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  // ==================== Specialized Confirmation Dialogs ====================

  /// Leave team confirmation
  static Future<bool> showLeaveTeamConfirmation({
    required BuildContext context,
    required String teamName,
    required String teamType,
  }) {
    return showDetailedConfirmation(
      context,
      title: 'Leave $teamName?',
      primaryMessage: 'Are you sure you want to leave this $teamType?',
      secondaryMessage: 'You will need to re-apply if you want to join again. '
          'Your participation history will be preserved.',
      confirmText: 'Leave',
      cancelText: 'Cancel',
      isDestructive: true,
    );
  }

  /// Cancel application confirmation
  static Future<bool> showCancelApplicationConfirmation({
    required BuildContext context,
    required String teamName,
  }) {
    return showDetailedConfirmation(
      context,
      title: 'Cancel Application?',
      primaryMessage: 'Do you want to cancel your application to $teamName?',
      secondaryMessage: 'You can re-apply at any time.',
      confirmText: 'Cancel Application',
      cancelText: 'Keep Application',
      confirmColor: Colors.orange,
    );
  }

  // ==================== Private Helper Methods ====================

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        action: action,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

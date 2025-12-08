import 'package:flutter/material.dart';

/// 확인 다이얼로그 유틸리티 클래스
/// 파괴적 액션(삭제, 탈퇴 등)에 대한 사용자 확인을 받습니다
@Deprecated('Use UIUtils instead. This will be removed in a future version.')
class ConfirmationDialog {
  /// Leave Team 확인 다이얼로그
  static Future<bool> showLeaveTeamDialog({
    required BuildContext context,
    required String teamName,
    required String teamType, // 'Group' or 'Hangout'
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave $teamName?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to leave this $teamType?',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'You will need to re-apply if you want to join again. '
              'Your participation history will be preserved.',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Cancel Application 확인 다이얼로그
  static Future<bool> showCancelApplicationDialog({
    required BuildContext context,
    required String teamName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Application?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do you want to cancel your application to $teamName?',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'You can re-apply at any time.',
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
            child: const Text('Keep Application'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Application'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

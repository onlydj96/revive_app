import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// 일관된 Empty State UI를 제공하는 위젯
///
/// 데이터가 없거나 에러 상태를 표시할 때 사용합니다.
class EmptyState extends StatelessWidget {
  /// 표시할 아이콘
  final IconData icon;

  /// 주요 메시지
  final String message;

  /// 부가 설명 (선택)
  final String? description;

  /// 액션 버튼 텍스트 (선택)
  final String? actionLabel;

  /// 액션 버튼 클릭 콜백 (선택)
  final VoidCallback? onAction;

  /// 아이콘 크기 (기본값: 64)
  final double iconSize;

  /// 패딩 (기본값: AppSpacing.huge)
  final double padding;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.description,
    this.actionLabel,
    this.onAction,
    this.iconSize = 64,
    this.padding = AppSpacing.huge,
  });

  /// 검색 결과가 없을 때 사용하는 프리셋
  factory EmptyState.noResults({
    String message = 'No results found',
    String? description,
    VoidCallback? onClearSearch,
  }) {
    return EmptyState(
      icon: Icons.search_off,
      message: message,
      description: description,
      actionLabel: onClearSearch != null ? 'Clear search' : null,
      onAction: onClearSearch,
    );
  }

  /// 데이터가 없을 때 사용하는 프리셋
  factory EmptyState.noData({
    required IconData icon,
    String message = 'No data available',
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      icon: icon,
      message: message,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 에러 상태를 표시하는 프리셋
  factory EmptyState.error({
    String message = 'Something went wrong',
    String? description,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: Icons.error_outline,
      message: message,
      description: description ?? 'Please try again later.',
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: theme.colorScheme.outline,
            ),
            AppSpacing.verticalLg,
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              AppSpacing.verticalSm,
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.verticalXl,
              TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

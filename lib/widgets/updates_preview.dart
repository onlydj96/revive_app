import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/update.dart';
import '../config/app_theme.dart';

class UpdatesPreview extends StatelessWidget {
  final List<Update> updates;

  const UpdatesPreview({super.key, required this.updates});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Updates',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/updates'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          ...updates.map((update) => InkWell(
                onTap: () => context.push('/update/${update.id}'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppTheme.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              _getUpdateTypeColor(update.type, context).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getUpdateTypeIcon(update.type),
                          size: 16,
                          color: _getUpdateTypeColor(update.type, context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    update.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (update.isPinned)
                                  Icon(
                                    Icons.push_pin,
                                    size: 14,
                                    color: Theme.of(context).primaryColor,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              update.content.length > 80
                                  ? '${update.content.substring(0, 80)}...'
                                  : update.content,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.neutralN50,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('MMM d').format(update.createdAt)} • ${update.author}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.neutralN50,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  IconData _getUpdateTypeIcon(UpdateType type) {
    switch (type) {
      case UpdateType.announcement:
        return Icons.campaign;
      case UpdateType.news:
        return Icons.newspaper;
      case UpdateType.prayer:
        return Icons.favorite;
      case UpdateType.celebration:
        return Icons.celebration;
      case UpdateType.urgent:
        return Icons.priority_high;
    }
  }

  Color _getUpdateTypeColor(UpdateType type, BuildContext context) {
    switch (type) {
      case UpdateType.announcement:
        return AppTheme.getInfoColor(context); // 정보성 - 파랑
      case UpdateType.news:
        return AppTheme.getSuccessColor(context); // 긍정적 소식 - 녹색
      case UpdateType.prayer:
        return Theme.of(context).colorScheme.tertiary; // 감성적 - Tertiary
      case UpdateType.celebration:
        return AppTheme.getWarningColor(context); // 주목 필요 - 주황
      case UpdateType.urgent:
        return Theme.of(context).colorScheme.error; // 긴급 - 빨강
    }
  }
}

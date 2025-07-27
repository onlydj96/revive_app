import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/update.dart';

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
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          
          ...updates.map((update) => InkWell(
            onTap: () => context.push('/update/${update.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getUpdateTypeColor(update.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getUpdateTypeIcon(update.type),
                      size: 16,
                      color: _getUpdateTypeColor(update.type),
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
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('MMM d').format(update.createdAt)} • ${update.author}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
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

  Color _getUpdateTypeColor(UpdateType type) {
    switch (type) {
      case UpdateType.announcement:
        return Colors.blue;
      case UpdateType.news:
        return Colors.green;
      case UpdateType.prayer:
        return Colors.purple;
      case UpdateType.celebration:
        return Colors.orange;
      case UpdateType.urgent:
        return Colors.red;
    }
  }
}
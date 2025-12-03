import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/update.dart';
import '../providers/permissions_provider.dart';
import '../providers/updates_provider.dart';
import '../providers/user_pins_provider.dart';

class UpdateDetailDialog extends ConsumerWidget {
  final Update update;

  const UpdateDetailDialog({
    super.key,
    required this.update,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    final userPins = ref.watch(userPinsProvider);
    final isUserPinned = userPins.contains(update.id);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getUpdateTypeColor(update.type).withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getUpdateTypeColor(update.type).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getUpdateTypeIcon(update.type),
                      color: _getUpdateTypeColor(update.type),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getUpdateTypeColor(update.type),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getUpdateTypeLabel(update.type),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('MMM d, yyyy • h:mm a').format(update.createdAt)} • ${update.author}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (update.isPinned)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.push_pin,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  // User pin toggle button
                  IconButton(
                    onPressed: () {
                      final wasUserPinned = isUserPinned;
                      ref.read(userPinsProvider.notifier).togglePin(update.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            wasUserPinned
                                ? 'Removed from your pins'
                                : 'Added to your pins',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(
                      isUserPinned ? Icons.bookmark : Icons.bookmark_border,
                      color: isUserPinned
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                    ),
                    tooltip: isUserPinned ? 'Remove from pins' : 'Add to pins',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      update.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 16),

                    // Image
                    if (update.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: Image.network(
                            update.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: _getUpdateTypeColor(update.type)
                                    .withOpacity(0.1),
                                child: Center(
                                  child: Icon(
                                    _getUpdateTypeIcon(update.type),
                                    size: 48,
                                    color: _getUpdateTypeColor(update.type),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    if (update.imageUrl != null) const SizedBox(height: 16),

                    // Content
                    Text(
                      update.content,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                          ),
                    ),

                    // Tags
                    if (update.tags.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: update.tags
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Action buttons
            if (permissions.canEditContent || permissions.canDeleteContent)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (permissions.canEditContent) ...[
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showEditDialog(context, ref, update);
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (permissions.canDeleteContent)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showDeleteDialog(context, ref, update);
                        },
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Delete'),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                  ],
                ),
              ),
          ],
        ),
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

  String _getUpdateTypeLabel(UpdateType type) {
    switch (type) {
      case UpdateType.announcement:
        return 'ANNOUNCEMENT';
      case UpdateType.news:
        return 'NEWS';
      case UpdateType.prayer:
        return 'PRAYER';
      case UpdateType.celebration:
        return 'CELEBRATION';
      case UpdateType.urgent:
        return 'URGENT';
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Update update) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Update'),
        content: Text(
            'Edit functionality for "${update.title}" would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                // TODO: Implement actual edit functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit feature coming soon!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to edit update: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Update update) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Update'),
        content: Text(
            'Are you sure you want to delete "${update.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref
                    .read(updatesProvider.notifier)
                    .deleteUpdate(update.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted "${update.title}"')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete update: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

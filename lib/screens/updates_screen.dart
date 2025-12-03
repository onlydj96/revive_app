import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/updates_provider.dart';
import '../providers/permissions_provider.dart';
import '../providers/user_pins_provider.dart';
import '../models/update.dart';
import '../widgets/create_update_dialog.dart';
import '../widgets/update_detail_dialog.dart';

class UpdatesScreen extends ConsumerWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatesAsyncValue = ref.watch(updatesProvider);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
      ),
      floatingActionButton: permissions.canCreateContent
          ? FloatingActionButton(
              onPressed: () {
                _showCreateUpdateDialog(context, ref);
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: updatesAsyncValue.when(
        data: (updates) {
          final userPins = ref.watch(userPinsProvider);
          final pinnedUpdates =
              updates.where((update) => update.isPinned).toList();
          final recentUpdates =
              updates.where((update) => !update.isPinned).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(updatesProvider.notifier).refresh();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pinnedUpdates.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.push_pin,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pinned Updates',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...pinnedUpdates.map((update) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: UpdateCard(
                            update: update,
                            isPinned: true,
                            isUserPinned: userPins.contains(update.id),
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],
                  if (recentUpdates.isNotEmpty) ...[
                    Text(
                      'Recent Updates',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...recentUpdates.map((update) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: UpdateCard(
                            update: update,
                            isPinned: false,
                            isUserPinned: userPins.contains(update.id),
                          ),
                        )),
                  ],
                  if (pinnedUpdates.isEmpty && recentUpdates.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(64),
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Updates',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            Text(
                              'Check back later for church news and announcements',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading updates: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(updatesProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateUpdateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CreateUpdateDialog(
        onCreateUpdate: (title, content, type, imageUrl, isPinned, tags) async {
          try {
            await ref.read(updatesProvider.notifier).createUpdate(
                  title: title,
                  content: content,
                  type: type,
                  imageUrl: imageUrl,
                  isPinned: isPinned,
                  tags: tags,
                );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Update created successfully!')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to create update: $e')),
              );
            }
          }
        },
      ),
    );
  }
}

class UpdateCard extends ConsumerWidget {
  final Update update;
  final bool isPinned;
  final bool isUserPinned;

  const UpdateCard({
    super.key,
    required this.update,
    this.isPinned = false,
    this.isUserPinned = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    return Card(
      elevation: isPinned ? 4 : 2,
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (context) => UpdateDetailDialog(update: update),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: (isPinned || isUserPinned)
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPinned
                        ? Theme.of(context).primaryColor.withOpacity(0.3)
                        : Theme.of(context).primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (update.imageUrl != null)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Image.network(
                      update.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color:
                              _getUpdateTypeColor(update.type).withOpacity(0.1),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getUpdateTypeColor(update.type)
                                .withOpacity(0.1),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getUpdateTypeColor(update.type)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getUpdateTypeLabel(update.type),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: _getUpdateTypeColor(
                                                update.type),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  if (isPinned) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.push_pin,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                  if (isUserPinned) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.bookmark,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('MMM d, yyyy').format(update.createdAt)} • ${update.author}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (permissions.canEditContent ||
                            permissions.canDeleteContent) ...[
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditDialog(context, update);
                              } else if (value == 'delete') {
                                _showDeleteDialog(context, update);
                              }
                            },
                            itemBuilder: (context) => [
                              if (permissions.canEditContent)
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                              if (permissions.canDeleteContent)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 18),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ] else
                          const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      update.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      update.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (update.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: update.tags
                            .take(3)
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
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

  void _showEditDialog(BuildContext context, Update update) {
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
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit feature coming soon!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Update update) {
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
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted "${update.title}"')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../providers/updates_provider.dart';
import '../providers/permissions_provider.dart';
import '../providers/user_pins_provider.dart';
import '../models/update.dart';
import '../widgets/create_update_dialog.dart';
import '../widgets/update_detail_dialog.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/shimmer_loading.dart';
import '../config/app_theme.dart';

class UpdatesScreen extends ConsumerWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final updatesAsyncValue = ref.watch(updatesProvider);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.updates),
      ),
      floatingActionButton: permissions.canCreateContent
          ? FloatingActionButton(
              heroTag: 'updates_fab',
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
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.updatesRefreshed),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: SafeArea(
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
                          l10n.pinnedUpdates,
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
                      l10n.recentUpdates,
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
                    EmptyState.noData(
                      icon: Icons.article_outlined,
                      message: l10n.noUpdates,
                      description: l10n.checkBackLater,
                    ),
                ],
                ),
              ),
            ),
          );
        },
        loading: () => const UpdatesLoadingSkeleton(),
        error: (error, stack) => EmptyState.error(
          message: l10n.errorLoadingData,
          description: error.toString(),
          onRetry: () => ref.read(updatesProvider.notifier).refresh(),
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
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.updateCreatedSuccess)),
              );
            }
          } catch (e) {
            if (context.mounted) {
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${l10n.failedToCreateUpdate}: $e')),
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
    final l10n = AppLocalizations.of(context)!;
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
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                        : Theme.of(context).primaryColor.withValues(alpha: 0.2),
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
                              _getUpdateTypeColor(update.type).withValues(alpha: 0.1),
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
                                .withValues(alpha: 0.1),
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
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getUpdateTypeLabel(update.type, l10n),
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
                                _showDeleteDialog(context, ref, update);
                              }
                            },
                            itemBuilder: (context) => [
                              if (permissions.canEditContent)
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit, size: 18),
                                      const SizedBox(width: 8),
                                      Text(l10n.edit),
                                    ],
                                  ),
                                ),
                              if (permissions.canDeleteContent)
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete, size: 18),
                                      const SizedBox(width: 8),
                                      Text(l10n.delete),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      update.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.neutralN50,
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
                                    color: Theme.of(context).colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
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

  String _getUpdateTypeLabel(UpdateType type, AppLocalizations l10n) {
    switch (type) {
      case UpdateType.announcement:
        return l10n.updateTypeAnnouncement;
      case UpdateType.news:
        return l10n.updateTypeNews;
      case UpdateType.prayer:
        return l10n.updateTypePrayer;
      case UpdateType.celebration:
        return l10n.updateTypeCelebration;
      case UpdateType.urgent:
        return l10n.updateTypeUrgent;
    }
  }

  void _showEditDialog(BuildContext context, Update update) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editUpdate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.editing(update.title)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.construction,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.comingSoon,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Update update) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage(update.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await ref.read(updatesProvider.notifier).deleteUpdate(update.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.deleted(update.title))),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${l10n.failedToDelete}: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

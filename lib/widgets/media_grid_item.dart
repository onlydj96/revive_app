import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/media_item.dart';
import '../providers/permissions_provider.dart';

class MediaGridItem extends ConsumerWidget {
  final MediaItem mediaItem;
  final VoidCallback onTap;
  final VoidCallback onCollect;

  const MediaGridItem({
    super.key,
    required this.mediaItem,
    required this.onTap,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: mediaItem.thumbnailUrl != null
                        ? Image.network(
                            mediaItem.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  _getMediaTypeIcon(mediaItem.type),
                                  size: 48,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              _getMediaTypeIcon(mediaItem.type),
                              size: 48,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),
                  
                  if (mediaItem.type == MediaType.video)
                    const Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getMediaTypeLabel(mediaItem.type),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: onCollect,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              mediaItem.isCollected ? Icons.bookmark : Icons.bookmark_border,
                              size: 20,
                              color: mediaItem.isCollected ? Colors.yellow : Colors.white,
                            ),
                          ),
                        ),
                        if (permissions.canEditContent || permissions.canDeleteContent) ...[
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditDialog(context, mediaItem);
                              } else if (value == 'delete') {
                                _showDeleteDialog(context, mediaItem);
                              }
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.more_vert,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
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
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mediaItem.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getMediaCategoryLabel(mediaItem.category),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(mediaItem.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMediaTypeIcon(MediaType type) {
    switch (type) {
      case MediaType.photo:
        return Icons.photo;
      case MediaType.video:
        return Icons.videocam;
      case MediaType.audio:
        return Icons.audiotrack;
    }
  }

  String _getMediaTypeLabel(MediaType type) {
    switch (type) {
      case MediaType.photo:
        return 'PHOTO';
      case MediaType.video:
        return 'VIDEO';
      case MediaType.audio:
        return 'AUDIO';
    }
  }

  String _getMediaCategoryLabel(MediaCategory category) {
    switch (category) {
      case MediaCategory.worship:
        return 'Worship';
      case MediaCategory.sermon:
        return 'Sermons';
      case MediaCategory.fellowship:
        return 'Fellowship';
      case MediaCategory.outreach:
        return 'Outreach';
      case MediaCategory.youth:
        return 'Youth';
      case MediaCategory.children:
        return 'Children';
      case MediaCategory.general:
        return 'General';
    }
  }

  void _showEditDialog(BuildContext context, MediaItem mediaItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Media'),
        content: Text('Edit functionality for "${mediaItem.title}" would be implemented here.'),
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

  void _showDeleteDialog(BuildContext context, MediaItem mediaItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media'),
        content: Text('Are you sure you want to delete "${mediaItem.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted "${mediaItem.title}"')),
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
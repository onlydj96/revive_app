import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/media_item.dart';

class MediaGridItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                    child: InkWell(
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
                  ),
                ],
              ),
            ),
            
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Spacer(),
                    Text(
                      DateFormat('MMM d, yyyy').format(mediaItem.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
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
}
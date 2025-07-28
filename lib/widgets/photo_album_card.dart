import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/photo_album.dart';
import '../models/media_item.dart';

class PhotoAlbumCard extends StatelessWidget {
  final PhotoAlbum album;
  final VoidCallback onTap;

  const PhotoAlbumCard({
    super.key,
    required this.album,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover photo
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      color: Colors.grey[200],
                    ),
                    child: album.effectiveCoverPhotoUrl != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: CachedNetworkImage(
                              imageUrl: album.effectiveCoverPhotoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.photo_library,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.photo_library,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                  
                  // Photo count badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${album.photoCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(album.category).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getCategoryLabel(album.category),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Album info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    if (album.photographer != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            album.photographer!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                    ],
                    
                    Text(
                      _formatDate(album.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                    
                    if (album.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: album.tags.take(2).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(MediaCategory category) {
    switch (category) {
      case MediaCategory.worship:
        return Colors.purple;
      case MediaCategory.sermon:
        return Colors.blue;
      case MediaCategory.fellowship:
        return Colors.green;
      case MediaCategory.outreach:
        return Colors.orange;
      case MediaCategory.youth:
        return Colors.pink;
      case MediaCategory.children:
        return Colors.cyan;
      case MediaCategory.general:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(MediaCategory category) {
    switch (category) {
      case MediaCategory.worship:
        return '예배';
      case MediaCategory.sermon:
        return '설교';
      case MediaCategory.fellowship:
        return '교제';
      case MediaCategory.outreach:
        return '봉사';
      case MediaCategory.youth:
        return '청년부';
      case MediaCategory.children:
        return '어린이부';
      case MediaCategory.general:
        return '일반';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
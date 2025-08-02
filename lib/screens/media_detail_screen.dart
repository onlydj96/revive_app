import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/media_provider.dart';
import '../models/media_item.dart';

// Simple state provider for current index
final currentMediaIndexProvider = StateProvider<int>((ref) => 0);

class MediaDetailScreen extends ConsumerStatefulWidget {
  final String mediaId;
  final String? folderId;

  const MediaDetailScreen({
    super.key, 
    required this.mediaId,
    this.folderId,
  });

  @override
  ConsumerState<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends ConsumerState<MediaDetailScreen> {
  PageController? _pageController;
  List<MediaItem> _mediaItems = [];

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaAsyncValue = ref.watch(mediaProvider);

    return Scaffold(
      body: mediaAsyncValue.when(
        data: (mediaList) {
          // Get media items from the same folder
          List<MediaItem> folderMediaItems;
          if (widget.folderId != null && widget.folderId!.isNotEmpty) {
            folderMediaItems = mediaList
                .where((item) => item.folderId == widget.folderId)
                .toList();
          } else {
            folderMediaItems = mediaList;
          }

          if (folderMediaItems.isEmpty) {
            return const Center(
              child: Text('No media found'),
            );
          }

          // Find the index of the current media item
          final initialIndex = folderMediaItems.indexWhere(
            (item) => item.id == widget.mediaId,
          );

          if (initialIndex == -1) {
            return const Center(
              child: Text('Media not found'),
            );
          }

          // Initialize PageController if needed
          if (_pageController == null || _mediaItems != folderMediaItems) {
            _pageController?.dispose();
            _pageController = PageController(initialPage: initialIndex);
            _mediaItems = folderMediaItems;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(currentMediaIndexProvider.notifier).state = initialIndex;
            });
          }

          return _buildMediaSlider(context, folderMediaItems);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading media: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(mediaProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSlider(BuildContext context, List<MediaItem> mediaItems) {
    if (_pageController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentIndex = ref.watch(currentMediaIndexProvider);

    return Stack(
      children: [
        // PageView for sliding between media items
        PageView.builder(
          controller: _pageController!,
          onPageChanged: (index) {
            ref.read(currentMediaIndexProvider.notifier).state = index;
          },
          itemCount: mediaItems.length,
          itemBuilder: (context, index) {
            final mediaItem = mediaItems[index];
            return _buildMediaDetail(context, ref, mediaItem);
          },
        ),

        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: FloatingActionButton(
            heroTag: "back",
            mini: true,
            backgroundColor: Colors.black.withOpacity(0.5),
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),

        // Page indicator
        if (mediaItems.length > 1)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${currentIndex + 1} / ${mediaItems.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

        // Action buttons
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: "collect",
                mini: true,
                backgroundColor: (currentIndex < mediaItems.length && mediaItems[currentIndex].isCollected)
                    ? Colors.red 
                    : Colors.white.withOpacity(0.9),
                onPressed: currentIndex < mediaItems.length ? () {
                  ref.read(mediaProvider.notifier).toggleCollection(mediaItems[currentIndex].id);
                } : null,
                child: Icon(
                  (currentIndex < mediaItems.length && mediaItems[currentIndex].isCollected)
                      ? Icons.favorite 
                      : Icons.favorite_border,
                  color: (currentIndex < mediaItems.length && mediaItems[currentIndex].isCollected)
                      ? Colors.white 
                      : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: "share",
                mini: true,
                backgroundColor: Colors.white.withOpacity(0.9),
                onPressed: () {
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share functionality coming soon!')),
                  );
                },
                child: const Icon(Icons.share, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaDetail(BuildContext context, WidgetRef ref, MediaItem mediaItem) {
    return Stack(
      children: [
        // Background media
        if (mediaItem.type == MediaType.photo)
          _buildPhotoView(mediaItem)
        else
          _buildVideoView(mediaItem),
        
        // Content overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mediaItem.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (mediaItem.description != null) ...[
                  Text(
                    mediaItem.description!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Icon(
                      mediaItem.type == MediaType.photo ? Icons.photo : Icons.videocam,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      mediaItem.type.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.category,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      mediaItem.category.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (mediaItem.photographer != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.camera_alt,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mediaItem.photographer!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  'Created: ${_formatDate(mediaItem.createdAt)}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                if (mediaItem.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: mediaItem.tags.map((tag) => Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.2),
                      labelStyle: const TextStyle(color: Colors.white),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoView(MediaItem mediaItem) {
    return Hero(
      tag: 'media-${mediaItem.id}',
      child: InteractiveViewer(
        child: CachedNetworkImage(
          imageUrl: mediaItem.url,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Failed to load image'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoView(MediaItem mediaItem) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_filled,
              size: 80,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'Video Player\n(Coming Soon)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 32),
            if (mediaItem.thumbnailUrl != null)
              CachedNetworkImage(
                imageUrl: mediaItem.thumbnailUrl!,
                fit: BoxFit.cover,
                width: 200,
                height: 150,
                placeholder: (context, url) => Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[800],
                  child: const Icon(Icons.videocam, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
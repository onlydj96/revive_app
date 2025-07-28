import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/media_provider.dart';
import '../providers/photo_albums_provider.dart';
import '../providers/permissions_provider.dart';
import '../models/media_item.dart';
import '../models/photo_album.dart';
import '../widgets/media_grid_item.dart';
import '../widgets/create_photo_album_dialog.dart';
import '../widgets/photo_album_card.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  bool _isGridView = true;
  bool _showPhotosOnly = false; // Toggle between all media and photos only

  @override
  Widget build(BuildContext context) {
    final mediaAsyncValue = ref.watch(mediaProvider);
    final photoAlbumsAsyncValue = ref.watch(photoAlbumsProvider);
    final filteredMedia = ref.watch(filteredMediaProvider);
    final filteredAlbums = ref.watch(filteredPhotoAlbumsProvider);
    final searchQuery = ref.watch(mediaSearchProvider);
    final typeFilter = ref.watch(mediaFilterProvider);
    final categoryFilter = ref.watch(mediaCategoryFilterProvider);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      floatingActionButton: permissions.canCreateContent
          ? FloatingActionButton(
              onPressed: () {
                _showCreateOptions(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: mediaAsyncValue.when(
        data: (media) => Column(
          children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search photos, videos, and audio...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    ref.read(mediaSearchProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All Types'),
                        selected: typeFilter == null,
                        onSelected: (selected) {
                          ref.read(mediaFilterProvider.notifier).state = null;
                        },
                      ),
                      const SizedBox(width: 8),
                      ...MediaType.values.map((type) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getMediaTypeLabel(type)),
                          selected: typeFilter == type,
                          onSelected: (selected) {
                            ref.read(mediaFilterProvider.notifier).state = 
                                selected ? type : null;
                          },
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('전체'),
                      selected: !_showPhotosOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showPhotosOnly = false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('사진 앨범'),
                      selected: _showPhotosOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showPhotosOnly = true;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All Categories'),
                        selected: categoryFilter == null,
                        onSelected: (selected) {
                          ref.read(mediaCategoryFilterProvider.notifier).state = null;
                          // Also sync with photo album category filter
                          ref.read(photoAlbumCategoryFilterProvider.notifier).state = null;
                        },
                      ),
                      const SizedBox(width: 8),
                      ...MediaCategory.values.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getMediaCategoryLabel(category)),
                          selected: categoryFilter == category,
                          onSelected: (selected) {
                            ref.read(mediaCategoryFilterProvider.notifier).state = 
                                selected ? category : null;
                            // Also sync with photo album category filter
                            ref.read(photoAlbumCategoryFilterProvider.notifier).state = 
                                selected ? category : null;
                          },
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _showPhotosOnly
                ? photoAlbumsAsyncValue.when(
                    data: (albums) => _buildPhotoAlbumsGrid(filteredAlbums, searchQuery),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error loading albums: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.read(photoAlbumsProvider.notifier).refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildAllMediaGrid(filteredMedia, searchQuery),
          ),
          ],
        ),
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

  Widget _buildPhotoAlbumsGrid(List<PhotoAlbum> albums, String searchQuery) {
    if (albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? 'No albums found for "$searchQuery"'
                  : 'No photo albums available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first photo album',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return PhotoAlbumCard(
          album: album,
          onTap: () => context.push('/album/${album.id}'),
        );
      },
    );
  }

  Widget _buildAllMediaGrid(List<MediaItem> media, String searchQuery) {
    // Filter out photos that belong to albums, show only individual media
    final individualMedia = media.where((item) => 
        item.type != MediaType.photo || 
        (item.type == MediaType.photo && item.url.contains('individual'))
    ).toList();

    if (individualMedia.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? 'No media found for "$searchQuery"'
                  : 'No media available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return _isGridView
        ? GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: individualMedia.length,
            itemBuilder: (context, index) {
              final mediaItem = individualMedia[index];
              return MediaGridItem(
                mediaItem: mediaItem,
                onTap: () => context.push('/media/${mediaItem.id}'),
                onCollect: () => ref
                    .read(mediaProvider.notifier)
                    .toggleCollection(mediaItem.id),
              );
            },
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: individualMedia.length,
            itemBuilder: (context, index) {
              final mediaItem = individualMedia[index];
              return MediaListItem(
                mediaItem: mediaItem,
                onTap: () => context.push('/media/${mediaItem.id}'),
                onCollect: () => ref
                    .read(mediaProvider.notifier)
                    .toggleCollection(mediaItem.id),
              );
            },
          );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('사진 앨범 만들기'),
              subtitle: const Text('여러 사진을 모아서 앨범으로 관리'),
              onTap: () {
                Navigator.of(context).pop();
                _showCreatePhotoAlbumDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('개별 미디어 업로드'),
              subtitle: const Text('개별 사진, 영상, 오디오 파일 업로드'),
              onTap: () {
                Navigator.of(context).pop();
                _showCreateMediaDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePhotoAlbumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreatePhotoAlbumDialog(
        onCreateAlbum: (title, description, category, photoFiles, photographer, tags, coverPhotoIndex) async {
          try {
            await ref.read(photoAlbumsProvider.notifier).createPhotoAlbum(
              title: title,
              description: description,
              category: category,
              photoFiles: photoFiles,
              photographer: photographer,
              tags: tags,
              coverPhotoIndex: coverPhotoIndex,
            );
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('사진 앨범이 성공적으로 생성되었습니다!')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('앨범 생성 실패: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showCreateMediaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Media'),
        content: const Text('Media upload functionality would be implemented here with support for photos, videos, and audio files.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Media upload feature coming soon!')),
              );
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  String _getMediaTypeLabel(MediaType type) {
    switch (type) {
      case MediaType.photo:
        return 'Photos';
      case MediaType.video:
        return 'Videos';
      case MediaType.audio:
        return 'Audio';
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

class MediaListItem extends ConsumerWidget {
  final MediaItem mediaItem;
  final VoidCallback onTap;
  final VoidCallback onCollect;

  const MediaListItem({
    super.key,
    required this.mediaItem,
    required this.onTap,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: mediaItem.thumbnailUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          mediaItem.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              _getMediaTypeIcon(mediaItem.type),
                              color: Colors.grey[600],
                            );
                          },
                        ),
                      )
                    : Icon(
                        _getMediaTypeIcon(mediaItem.type),
                        color: Colors.grey[600],
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mediaItem.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (mediaItem.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        mediaItem.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
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
                        const SizedBox(width: 8),
                        if (mediaItem.photographer != null)
                          Text(
                            'by ${mediaItem.photographer}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      mediaItem.isCollected ? Icons.bookmark : Icons.bookmark_border,
                      color: mediaItem.isCollected ? Theme.of(context).primaryColor : null,
                    ),
                    onPressed: onCollect,
                  ),
                  if (permissions.canEditContent || permissions.canDeleteContent)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditMediaDialog(context, mediaItem);
                        } else if (value == 'delete') {
                          _showDeleteMediaDialog(context, mediaItem);
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
                ],
              ),
            ],
          ),
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

  void _showEditMediaDialog(BuildContext context, MediaItem mediaItem) {
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

  void _showDeleteMediaDialog(BuildContext context, MediaItem mediaItem) {
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/media_provider.dart';
import '../models/media_item.dart';
import '../widgets/media_grid_item.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final filteredMedia = ref.watch(filteredMediaProvider);
    final searchQuery = ref.watch(mediaSearchProvider);
    final typeFilter = ref.watch(mediaFilterProvider);
    final categoryFilter = ref.watch(mediaCategoryFilterProvider);

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
      body: Column(
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All Categories'),
                        selected: categoryFilter == null,
                        onSelected: (selected) {
                          ref.read(mediaCategoryFilterProvider.notifier).state = null;
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
            child: filteredMedia.isEmpty
                ? Center(
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
                  )
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredMedia.length,
                        itemBuilder: (context, index) {
                          final mediaItem = filteredMedia[index];
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
                        itemCount: filteredMedia.length,
                        itemBuilder: (context, index) {
                          final mediaItem = filteredMedia[index];
                          return MediaListItem(
                            mediaItem: mediaItem,
                            onTap: () => context.push('/media/${mediaItem.id}'),
                            onCollect: () => ref
                                .read(mediaProvider.notifier)
                                .toggleCollection(mediaItem.id),
                          );
                        },
                      ),
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

class MediaListItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
              IconButton(
                icon: Icon(
                  mediaItem.isCollected ? Icons.bookmark : Icons.bookmark_border,
                  color: mediaItem.isCollected ? Theme.of(context).primaryColor : null,
                ),
                onPressed: onCollect,
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
}
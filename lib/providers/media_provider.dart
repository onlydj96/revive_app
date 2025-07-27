import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/media_item.dart';

final mediaProvider = StateNotifierProvider<MediaNotifier, List<MediaItem>>((ref) {
  return MediaNotifier();
});

final mediaSearchProvider = StateProvider<String>((ref) => '');

final mediaFilterProvider = StateProvider<MediaType?>((ref) => null);

final mediaCategoryFilterProvider = StateProvider<MediaCategory?>((ref) => null);

final filteredMediaProvider = Provider<List<MediaItem>>((ref) {
  final media = ref.watch(mediaProvider);
  final searchQuery = ref.watch(mediaSearchProvider);
  final typeFilter = ref.watch(mediaFilterProvider);
  final categoryFilter = ref.watch(mediaCategoryFilterProvider);

  var filtered = media;

  if (searchQuery.isNotEmpty) {
    filtered = filtered.where((item) =>
        item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        (item.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
        item.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()))
    ).toList();
  }

  if (typeFilter != null) {
    filtered = filtered.where((item) => item.type == typeFilter).toList();
  }

  if (categoryFilter != null) {
    filtered = filtered.where((item) => item.category == categoryFilter).toList();
  }

  return filtered;
});

final collectedMediaProvider = Provider<List<MediaItem>>((ref) {
  final media = ref.watch(mediaProvider);
  return media.where((item) => item.isCollected).toList();
});

class MediaNotifier extends StateNotifier<List<MediaItem>> {
  MediaNotifier() : super([]) {
    _loadMockMedia();
  }

  void _loadMockMedia() {
    state = [
      MediaItem(
        id: '1',
        title: 'Sunday Worship - March 10',
        description: 'Beautiful worship moments from our Sunday service',
        type: MediaType.photo,
        category: MediaCategory.worship,
        url: 'https://example.com/photo1.jpg',
        thumbnailUrl: 'https://example.com/thumb1.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        photographer: 'Sarah Johnson',
        tags: ['worship', 'sunday', 'prayer'],
      ),
      MediaItem(
        id: '2',
        title: 'Pastor Mike - Faith Series Pt.3',
        description: 'Third part of the Faith series by Pastor Mike',
        type: MediaType.video,
        category: MediaCategory.sermon,
        url: 'https://example.com/video1.mp4',
        thumbnailUrl: 'https://example.com/thumb2.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        tags: ['sermon', 'faith', 'pastor mike'],
      ),
      MediaItem(
        id: '3',
        title: 'Youth Fellowship Photos',
        description: 'Fun moments from youth fellowship night',
        type: MediaType.photo,
        category: MediaCategory.youth,
        url: 'https://example.com/photo2.jpg',
        thumbnailUrl: 'https://example.com/thumb3.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        photographer: 'Mark Davis',
        tags: ['youth', 'fellowship', 'fun'],
      ),
      MediaItem(
        id: '4',
        title: 'Community Outreach Video',
        description: 'Our recent community service project',
        type: MediaType.video,
        category: MediaCategory.outreach,
        url: 'https://example.com/video2.mp4',
        thumbnailUrl: 'https://example.com/thumb4.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        tags: ['outreach', 'community', 'service'],
      ),
    ];
  }

  void toggleCollection(String mediaId) {
    state = state.map((item) {
      if (item.id == mediaId) {
        return item.copyWith(isCollected: !item.isCollected);
      }
      return item;
    }).toList();
  }

  void addMedia(MediaItem mediaItem) {
    state = [...state, mediaItem];
  }

  void updateMedia(MediaItem updatedMedia) {
    state = state.map((item) {
      return item.id == updatedMedia.id ? updatedMedia : item;
    }).toList();
  }

  void deleteMedia(String mediaId) {
    state = state.where((item) => item.id != mediaId).toList();
  }
}
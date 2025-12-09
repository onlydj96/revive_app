import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/media_item.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';
import '../widgets/upload_media_dialog.dart';

final mediaProvider =
    StateNotifierProvider<MediaNotifier, AsyncValue<List<MediaItem>>>((ref) {
  return MediaNotifier();
});

final mediaSearchProvider = StateProvider<String>((ref) => '');

final mediaFilterProvider = StateProvider<MediaType?>((ref) => null);

final mediaCategoryFilterProvider =
    StateProvider<MediaCategory?>((ref) => null);

// Sorting providers for media items
final mediaSortOptionProvider = StateProvider<MediaSortOption>((ref) => MediaSortOption.dateNewest);

// Grid view toggle for ResourcesScreen
final resourcesViewModeProvider =
    StateProvider<bool>((ref) => true); // true = grid, false = list

final filteredMediaProvider = Provider<List<MediaItem>>((ref) {
  final mediaAsyncValue = ref.watch(mediaProvider);
  final searchQuery = ref.watch(mediaSearchProvider);
  final typeFilter = ref.watch(mediaFilterProvider);
  final categoryFilter = ref.watch(mediaCategoryFilterProvider);

  return mediaAsyncValue.when(
    data: (media) {
      var filtered = media;

      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where((item) =>
                item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                (item.description
                        ?.toLowerCase()
                        .contains(searchQuery.toLowerCase()) ??
                    false) ||
                item.tags.any((tag) =>
                    tag.toLowerCase().contains(searchQuery.toLowerCase())))
            .toList();
      }

      if (typeFilter != null) {
        filtered = filtered.where((item) => item.type == typeFilter).toList();
      }

      if (categoryFilter != null) {
        filtered =
            filtered.where((item) => item.category == categoryFilter).toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final collectedMediaProvider = Provider<List<MediaItem>>((ref) {
  final mediaAsyncValue = ref.watch(mediaProvider);
  return mediaAsyncValue.when(
    data: (media) => media.where((item) => item.isCollected).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider for media items in a specific folder (excluding soft-deleted items)
final mediaByFolderProvider = Provider.family<List<MediaItem>, String?>((ref, folderId) {
  final mediaAsyncValue = ref.watch(mediaProvider);
  final sortOption = ref.watch(mediaSortOptionProvider);

  return mediaAsyncValue.when(
    data: (media) {
      var filtered = media
          .where((item) => item.folderId == folderId && !item.isDeleted)
          .toList();

      // Apply sorting
      filtered.sort((a, b) {
        switch (sortOption) {
          case MediaSortOption.dateNewest:
            return b.createdAt.compareTo(a.createdAt); // Descending
          case MediaSortOption.dateOldest:
            return a.createdAt.compareTo(b.createdAt); // Ascending
          case MediaSortOption.nameAZ:
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          case MediaSortOption.nameZA:
            return b.title.toLowerCase().compareTo(a.title.toLowerCase());
          case MediaSortOption.type:
            // Sort by type first, then by date
            final typeCompare = a.type.index.compareTo(b.type.index);
            return typeCompare != 0
                ? typeCompare
                : b.createdAt.compareTo(a.createdAt);
        }
      });

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final _logger = Logger('MediaNotifier');

class MediaNotifier extends StateNotifier<AsyncValue<List<MediaItem>>> {
  MediaNotifier() : super(const AsyncValue.loading()) {
    _logger.debug('🎯 [MEDIA NOTIFIER] Constructor called, initializing...');
    _loadMedia();
    _setupRealtimeSubscription();
  }

  RealtimeChannel? _channel;

  // Pagination state - optimized for smooth scrolling UX
  static const int _initialPageSize = 80; // Increased from 50 for better initial experience
  static const int _pageSize = 50; // Increased from 30 to reduce loading frequency
  int _currentOffset = 0;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  Future<void> _loadMedia() async {
    try {
      state = const AsyncValue.loading();
      _logger.debug('🔍 [MEDIA PROVIDER] Loading initial media items...');

      // Reset pagination state
      _currentOffset = 0;
      _hasMoreData = true;

      final data = await SupabaseService.getMediaItems(limit: _initialPageSize);
      _logger.debug('   Fetched ${data.length} media items from database');

      final media = data.map((item) => MediaItem.fromJson(item)).toList();
      _logger.debug('   Parsed ${media.length} MediaItem objects');

      if (media.isNotEmpty) {
        _logger.debug('   Sample IDs: ${media.take(3).map((m) => '${m.id} (folder: ${m.folderId})').toList()}');
      }

      // Update pagination state
      _currentOffset = media.length;
      _hasMoreData = data.length == _initialPageSize;

      _logger.debug('   Pagination: offset=$_currentOffset, hasMore=$_hasMoreData');

      state = AsyncValue.data(media);
    } catch (error, stackTrace) {
      _logger.error('❌ [MEDIA PROVIDER] Error loading media: $error', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadMoreMedia() async {
    // Prevent multiple simultaneous loads
    if (_isLoadingMore || !_hasMoreData) {
      _logger.debug('⏭️ [MEDIA PROVIDER] Skip load more: loading=$_isLoadingMore, hasMore=$_hasMoreData');
      return;
    }

    _isLoadingMore = true;
    _logger.debug('📄 [MEDIA PROVIDER] Loading more media items...');
    _logger.debug('   Current offset: $_currentOffset');

    try {
      final data = await SupabaseService.getMediaItems(
        limit: _pageSize,
        offset: _currentOffset,
      );

      _logger.debug('   Fetched ${data.length} additional items');

      if (data.isEmpty) {
        _hasMoreData = false;
        _logger.debug('   No more data available');
        return;
      }

      final newMedia = data.map((item) => MediaItem.fromJson(item)).toList();

      state.whenData((currentMedia) {
        final updatedMedia = [...currentMedia, ...newMedia];
        state = AsyncValue.data(updatedMedia);

        _currentOffset += newMedia.length;
        _hasMoreData = data.length == _pageSize;

        _logger.debug('   Total media: ${updatedMedia.length}');
        _logger.debug('   New offset: $_currentOffset, hasMore: $_hasMoreData');
      });
    } catch (error) {
      _logger.error('❌ [MEDIA PROVIDER] Error loading more media: $error', error);
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMoreData => _hasMoreData;
  bool get isLoadingMore => _isLoadingMore;

  void _setupRealtimeSubscription() {
    _channel = SupabaseService.subscribeToTable(
      'media_items',
      (newRecord) {
        // Handle insert
        final newMedia = MediaItem.fromJson(newRecord);
        state.whenData((media) {
          state = AsyncValue.data([newMedia, ...media]);
        });
      },
      (updatedRecord) {
        // Handle update
        final updatedMedia = MediaItem.fromJson(updatedRecord);
        state.whenData((media) {
          // If media is soft-deleted (has deletedAt), remove it from the list
          if (updatedMedia.deletedAt != null) {
            final filteredList =
                media.where((item) => item.id != updatedMedia.id).toList();
            state = AsyncValue.data(filteredList);
          } else {
            // Otherwise, update the item in the list
            final updatedList = media.map((item) {
              return item.id == updatedMedia.id ? updatedMedia : item;
            }).toList();
            state = AsyncValue.data(updatedList);
          }
        });
      },
      (deletedRecord) {
        // Handle delete
        final deletedId = deletedRecord['id'] as String;
        state.whenData((media) {
          final filteredList =
              media.where((item) => item.id != deletedId).toList();
          state = AsyncValue.data(filteredList);
        });
      },
    );
  }

  Future<void> createMediaItem({
    required String title,
    String? description,
    required MediaType type,
    required MediaCategory category,
    required String fileUrl,
    String? thumbnailUrl,
    String? photographer,
    List<String> tags = const [],
    String? folderId,
  }) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'type': type.name,
        'category': category.name,
        'file_url': fileUrl,  // Use file_url to match DB schema
        'thumbnail_url': thumbnailUrl,
        'photographer': photographer,
        'tags': tags,
        'folder_id': folderId,
      };

      await SupabaseService.createMediaItem(data);
      // The real-time subscription will handle updating the state
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateMediaItem(
    String id, {
    String? title,
    String? description,
    MediaType? type,
    MediaCategory? category,
    String? fileUrl,
    String? thumbnailUrl,
    String? photographer,
    List<String>? tags,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (type != null) data['type'] = type.name;
      if (category != null) data['category'] = category.name;
      if (fileUrl != null) data['file_url'] = fileUrl;  // Use file_url to match DB schema
      if (thumbnailUrl != null) data['thumbnail_url'] = thumbnailUrl;
      if (photographer != null) data['photographer'] = photographer;
      if (tags != null) data['tags'] = tags;

      await SupabaseService.update('media_items', id, data);
      // The real-time subscription will handle updating the state
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteMediaItem(String id) async {
    try {
      await SupabaseService.delete('media_items', id);
      // The real-time subscription will handle updating the state
    } catch (error) {
      rethrow;
    }
  }

  Future<void> softDeleteMedia(String id) async {
    try {
      // FIXED P0-4: Removed hardcoded user ID fallback - throw error instead
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to delete media');
      }

      await SupabaseService.update('media_items', id, {
        'deleted_at': DateTime.now().toIso8601String(),
        'deleted_by': currentUser.id,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Refresh the media list to reflect the changes
      await _loadMedia();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> restoreMedia(String id) async {
    try {
      await SupabaseService.update('media_items', id, {
        'deleted_at': null,
        'deleted_by': null,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Refresh the media list to reflect the changes
      await _loadMedia();
    } catch (error) {
      rethrow;
    }
  }

  void toggleCollection(String mediaId) {
    state.whenData((media) {
      final updatedList = media.map((item) {
        if (item.id == mediaId) {
          return item.copyWith(isCollected: !item.isCollected);
        }
        return item;
      }).toList();
      state = AsyncValue.data(updatedList);
    });
  }

  Future<void> uploadMediaFiles({
    required List<UploadMediaItem> mediaItems,
    required String folderPath,
    String? folderId,
    MediaCategory category = MediaCategory.general,
    String? photographer,
    Function(double)? onProgress,
  }) async {
    try {
      final totalFiles = mediaItems.length;
      int completedFiles = 0;

      // Upload files in parallel batches (3 concurrent uploads at a time)
      // This prevents UI blocking while significantly reducing total upload time
      const maxConcurrent = 3;

      for (int batchStart = 0; batchStart < totalFiles; batchStart += maxConcurrent) {
        final batchEnd = (batchStart + maxConcurrent).clamp(0, totalFiles);
        final batch = mediaItems.sublist(batchStart, batchEnd);

        // Upload all files in this batch in parallel
        await Future.wait(
          batch.asMap().entries.map((entry) async {
            final index = batchStart + entry.key;
            final mediaItem = entry.value;

            // Upload with retry logic (max 3 attempts)
            await _uploadSingleFileWithRetry(
              mediaItem: mediaItem,
              index: index,
              folderPath: folderPath,
              folderId: folderId,
              category: category,
              photographer: photographer,
              onComplete: () {
                completedFiles++;
                if (onProgress != null) {
                  final progress = completedFiles / totalFiles;
                  onProgress(progress);
                }
              },
            );
          }),
        );
      }

      // Reload media to show new items
      await _loadMedia();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> _uploadSingleFileWithRetry({
    required UploadMediaItem mediaItem,
    required int index,
    required String folderPath,
    String? folderId,
    required MediaCategory category,
    String? photographer,
    required void Function() onComplete,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final file = File(mediaItem.path);

        // Generate unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = mediaItem.name.split('.').last;
        final fileName = '${mediaItem.type.name}_${timestamp}_$index.$extension';

        // Upload to storage
        final fileUrl = await StorageService.uploadFile(
          bucketName: StorageService.mediaBucket,
          folderPath: folderPath,
          fileName: fileName,
          file: file,
        );

        // Create media item in database
        await createMediaItem(
          title: mediaItem.name.split('.').first,
          type: mediaItem.type,
          category: category,
          fileUrl: fileUrl,
          thumbnailUrl: mediaItem.type == MediaType.photo ? fileUrl : null,
          photographer: photographer,
          folderId: folderId,
        );

        // Success - call completion callback
        onComplete();
        return;
      } catch (error) {
        retryCount++;
        if (retryCount >= maxRetries) {
          // All retries exhausted - rethrow error
          rethrow;
        }
        // Wait before retrying (exponential backoff: 1s, 2s, 4s)
        await Future.delayed(Duration(seconds: 1 << (retryCount - 1)));
      }
    }
  }

  Future<void> refresh() async {
    await _loadMedia();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

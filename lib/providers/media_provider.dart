import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/media_item.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../widgets/upload_media_dialog.dart';

final mediaProvider = StateNotifierProvider<MediaNotifier, AsyncValue<List<MediaItem>>>((ref) {
  return MediaNotifier();
});

final mediaSearchProvider = StateProvider<String>((ref) => '');

final mediaFilterProvider = StateProvider<MediaType?>((ref) => null);

final mediaCategoryFilterProvider = StateProvider<MediaCategory?>((ref) => null);

final filteredMediaProvider = Provider<List<MediaItem>>((ref) {
  final mediaAsyncValue = ref.watch(mediaProvider);
  final searchQuery = ref.watch(mediaSearchProvider);
  final typeFilter = ref.watch(mediaFilterProvider);
  final categoryFilter = ref.watch(mediaCategoryFilterProvider);

  return mediaAsyncValue.when(
    data: (media) {
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

class MediaNotifier extends StateNotifier<AsyncValue<List<MediaItem>>> {
  MediaNotifier() : super(const AsyncValue.loading()) {
    _loadMedia();
    _setupRealtimeSubscription();
  }

  RealtimeChannel? _channel;

  Future<void> _loadMedia() async {
    try {
      state = const AsyncValue.loading();
      final data = await DatabaseService.getMediaItems(limit: 50);
      final media = data.map((item) => MediaItem.fromJson(item)).toList();
      state = AsyncValue.data(media);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _setupRealtimeSubscription() {
    _channel = DatabaseService.subscribeToTable(
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
          final updatedList = media.map((item) {
            return item.id == updatedMedia.id ? updatedMedia : item;
          }).toList();
          state = AsyncValue.data(updatedList);
        });
      },
      (deletedRecord) {
        // Handle delete
        final deletedId = deletedRecord['id'] as String;
        state.whenData((media) {
          final filteredList = media.where((item) => item.id != deletedId).toList();
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
        'url': fileUrl, // Using 'url' instead of 'file_url' to match existing schema
        'thumbnail_url': thumbnailUrl,
        'photographer': photographer,
        'tags': tags,
        'folder_id': folderId,
      };

      await DatabaseService.createMediaItem(data);
      // The real-time subscription will handle updating the state
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateMediaItem(String id, {
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
      if (fileUrl != null) data['url'] = fileUrl;
      if (thumbnailUrl != null) data['thumbnail_url'] = thumbnailUrl;
      if (photographer != null) data['photographer'] = photographer;
      if (tags != null) data['tags'] = tags;

      await DatabaseService.update('media_items', id, data);
      // The real-time subscription will handle updating the state
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteMediaItem(String id) async {
    try {
      await DatabaseService.delete('media_items', id);
      // The real-time subscription will handle updating the state
    } catch (error) {
      rethrow;
    }
  }

  Future<void> softDeleteMedia(String id) async {
    try {
      // Get current authenticated user ID
      final currentUser = SupabaseService.currentUser;
      final currentUserId = currentUser?.id ?? '37494678-2554-4e62-9fd0-c78308e82585'; // Fallback to a valid UUID
      
      await DatabaseService.update('media_items', id, {
        'deleted_at': DateTime.now().toIso8601String(),
        'deleted_by': currentUserId,
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
      await DatabaseService.update('media_items', id, {
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
  }) async {
    try {
      // Debug: Check if user is authenticated
      print('Starting upload with ${mediaItems.length} items');
      
      for (int i = 0; i < mediaItems.length; i++) {
        final mediaItem = mediaItems[i];
        final file = File(mediaItem.path);
        
        print('Uploading item ${i + 1}: ${mediaItem.name}');
        
        // Generate unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = mediaItem.name.split('.').last;
        final fileName = '${mediaItem.type.name}_${timestamp}_$i.$extension';
        
        // Upload to storage
        print('Uploading to storage: $folderPath/$fileName');
        final fileUrl = await StorageService.uploadFile(
          bucketName: StorageService.mediaBucket,
          folderPath: folderPath,
          fileName: fileName,
          file: file,
        );
        
        print('Upload successful, creating database entry...');
        
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
        
        print('Database entry created successfully');
      }
      
      // Reload media to show new items
      await _loadMedia();
      print('Upload process completed successfully');
    } catch (error) {
      print('Upload error: $error');
      rethrow;
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
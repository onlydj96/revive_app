import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/photo_album.dart';
import '../models/media_item.dart';
import '../services/database_service.dart';

final photoAlbumsProvider = StateNotifierProvider<PhotoAlbumsNotifier, AsyncValue<List<PhotoAlbum>>>((ref) {
  return PhotoAlbumsNotifier();
});

final photoAlbumSearchProvider = StateProvider<String>((ref) => '');

final photoAlbumCategoryFilterProvider = StateProvider<MediaCategory?>((ref) => null);

final filteredPhotoAlbumsProvider = Provider<List<PhotoAlbum>>((ref) {
  final albumsAsyncValue = ref.watch(photoAlbumsProvider);
  final searchQuery = ref.watch(photoAlbumSearchProvider);
  final categoryFilter = ref.watch(photoAlbumCategoryFilterProvider);

  return albumsAsyncValue.when(
    data: (albums) {
      var filtered = albums;

      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((album) =>
            album.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (album.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
            album.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()))
        ).toList();
      }

      if (categoryFilter != null) {
        filtered = filtered.where((album) => album.category == categoryFilter).toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

class PhotoAlbumsNotifier extends StateNotifier<AsyncValue<List<PhotoAlbum>>> {
  PhotoAlbumsNotifier() : super(const AsyncValue.loading()) {
    _loadPhotoAlbums();
    _setupRealtimeSubscription();
  }

  RealtimeChannel? _channel;

  Future<void> _loadPhotoAlbums() async {
    try {
      state = const AsyncValue.loading();
      
      // Get albums with their photos
      final albumsData = await DatabaseService.getAll('photo_albums', 
          orderBy: 'created_at', ascending: false);
      
      final albums = <PhotoAlbum>[];
      
      for (final albumData in albumsData) {
        // Get photos for this album
        final photosData = await DatabaseService.getMediaItems(albumId: albumData['id']);
        final photos = photosData.map((item) => MediaItem.fromJson(item)).toList();
        
        // Get cover photo URL if exists
        String? coverPhotoUrl;
        if (albumData['cover_photo_id'] != null) {
          final coverPhoto = photos.firstWhere(
            (p) => p.id == albumData['cover_photo_id'], 
            orElse: () => photos.isNotEmpty ? photos.first : MediaItem(
              id: '', title: '', type: MediaType.photo, category: MediaCategory.general, 
              url: '', createdAt: DateTime.now()
            )
          );
          coverPhotoUrl = coverPhoto.thumbnailUrl ?? coverPhoto.url;
        }
        
        albums.add(PhotoAlbum.fromJson({
          ...albumData,
          'cover_photo_url': coverPhotoUrl,
        }, photos: photos));
      }
      
      state = AsyncValue.data(albums);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _setupRealtimeSubscription() {
    _channel = DatabaseService.subscribeToTable(
      'photo_albums',
      (newRecord) {
        // Handle insert - reload to get photos
        _loadPhotoAlbums();
      },
      (updatedRecord) {
        // Handle update - reload to get photos
        _loadPhotoAlbums();
      },
      (deletedRecord) {
        // Handle delete
        final deletedId = deletedRecord['id'] as String;
        state.whenData((albums) {
          final filteredList = albums.where((album) => album.id != deletedId).toList();
          state = AsyncValue.data(filteredList);
        });
      },
    );
  }

  Future<String> createPhotoAlbum({
    required String title,
    String? description,
    required MediaCategory category,
    required List<String> photoFiles, // File paths or URLs
    String? photographer,
    List<String> tags = const [],
    int? coverPhotoIndex,
  }) async {
    try {
      // Create album first
      final albumData = {
        'title': title,
        'description': description,
        'category': category.name,
        'photographer': photographer,
        'tags': tags,
      };

      final albumResult = await DatabaseService.create('photo_albums', albumData);
      final albumId = albumResult!['id'] as String;

      // Upload photos to storage and create media items
      String? coverPhotoId;
      
      for (int i = 0; i < photoFiles.length; i++) {
        final filePath = photoFiles[i];
        
        // In a real implementation, you would upload the file to Supabase Storage here
        // For now, we'll create a placeholder URL structure
        final fileName = 'album_${albumId}/photo_${i + 1}.jpg';
        final storageUrl = 'https://goetblgcpplhbmbuttyv.supabase.co/storage/v1/object/public/media/$fileName';
        final thumbnailUrl = 'https://goetblgcpplhbmbuttyv.supabase.co/storage/v1/object/public/media/thumbs/$fileName';
        
        final mediaData = {
          'title': '$title - Photo ${i + 1}',
          'type': 'photo',
          'category': category.name,
          'url': storageUrl,
          'thumbnail_url': thumbnailUrl,
          'album_id': albumId,
          'is_album_cover': coverPhotoIndex == i || (coverPhotoIndex == null && i == 0),
          'photographer': photographer,
          'tags': tags,
        };

        final mediaResult = await DatabaseService.createMediaItem(mediaData);
        
        // Set cover photo ID
        if (coverPhotoIndex == i || (coverPhotoIndex == null && i == 0)) {
          coverPhotoId = mediaResult!['id'] as String;
        }
      }

      // Update album with cover photo ID
      if (coverPhotoId != null) {
        await DatabaseService.update('photo_albums', albumId, {
          'cover_photo_id': coverPhotoId,
        });
      }

      return albumId;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updatePhotoAlbum(String id, {
    String? title,
    String? description,
    MediaCategory? category,
    String? photographer,
    List<String>? tags,
    String? coverPhotoId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (category != null) data['category'] = category.name;
      if (photographer != null) data['photographer'] = photographer;
      if (tags != null) data['tags'] = tags;
      if (coverPhotoId != null) data['cover_photo_id'] = coverPhotoId;

      await DatabaseService.update('photo_albums', id, data);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deletePhotoAlbum(String id) async {
    try {
      // Delete all photos in the album first
      final photosData = await DatabaseService.getMediaItems(albumId: id);
      for (final photo in photosData) {
        await DatabaseService.delete('media_items', photo['id']);
      }
      
      // Delete the album
      await DatabaseService.delete('photo_albums', id);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    await _loadPhotoAlbums();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}
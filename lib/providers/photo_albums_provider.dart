import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import '../models/photo_album.dart';
import '../models/media_item.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import 'dart:typed_data';

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
    // Initialize and load photo albums
    _initializeAlbums();
    // _setupRealtimeSubscription();
  }

  RealtimeChannel? _channel;

  Future<void> _initializeAlbums() async {
    try {
      state = const AsyncValue.loading();
      
      // Load all albums
      await _loadPhotoAlbums();
    } catch (error, stackTrace) {
      print('Error initializing albums: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
  

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

  // Helper method to upload asset photos to storage
  Future<List<String>> _uploadAssetPhotos({
    required String folderPath,
    required List<String> assetPaths,
  }) async {
    final uploadedUrls = <String>[];
    
    for (int i = 0; i < assetPaths.length; i++) {
      final assetPath = assetPaths[i];
      final fileName = '${assetPath.split('/').last}';
      
      try {
        // Load asset as bytes
        final ByteData data = await rootBundle.load(assetPath);
        final Uint8List bytes = data.buffer.asUint8List();
        
        // Upload to storage
        final url = await StorageService.uploadFile(
          bucketName: StorageService.mediaBucket,
          folderPath: folderPath,
          fileName: fileName,
          file: bytes,
        );
        
        uploadedUrls.add(url);
        print('Uploaded asset $assetPath to $url');
      } catch (e) {
        print('Error uploading asset $assetPath: $e');
      }
    }
    
    return uploadedUrls;
  }

  Future<String> createPhotoAlbum({
    required String title,
    String? description,
    required MediaCategory category,
    required String folderPath, // Folder path in storage
    required List<String> photoFiles, // File paths, asset paths, or URLs
    String? photographer,
    List<String> tags = const [],
    int? coverPhotoIndex,
    bool useAssets = false, // Flag to indicate if photoFiles are asset paths
  }) async {
    try {
      // Create album first
      final albumData = {
        'title': title,
        'description': description,
        'category': category.name,
        'photographer': photographer,
        'tags': tags,
        'folder_path': folderPath,
      };

      final albumResult = await DatabaseService.create('photo_albums', albumData);
      final albumId = albumResult!['id'] as String;

      List<String> uploadedUrls = [];
      
      if (useAssets) {
        // Upload asset photos
        uploadedUrls = await _uploadAssetPhotos(
          folderPath: folderPath,
          assetPaths: photoFiles,
        );
      } else {
        // Upload regular file photos
        for (int i = 0; i < photoFiles.length; i++) {
          final filePath = photoFiles[i];
          final fileName = 'photo_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          
          try {
            // Upload file to storage
            final url = await StorageService.uploadFile(
              bucketName: StorageService.mediaBucket,
              folderPath: folderPath,
              fileName: fileName,
              file: filePath,
            );
            uploadedUrls.add(url);
          } catch (e) {
            print('Error uploading photo ${i + 1}: $e');
          }
        }
      }
      
      // Create media items in database for each uploaded photo
      for (int i = 0; i < uploadedUrls.length; i++) {
        final url = uploadedUrls[i];
        final fileName = useAssets ? photoFiles[i].split('/').last : 'photo_${i + 1}';
        
        try {
          final mediaData = {
            'title': '$title - ${fileName}',
            'type': 'photo',
            'category': category.name,
            'url': url,
            'thumbnail_url': url, // For now, use same URL
            'album_id': albumId,
            'is_album_cover': coverPhotoIndex == i || (coverPhotoIndex == null && i == 0),
            'photographer': photographer,
            'tags': tags,
          };

          await DatabaseService.createMediaItem(mediaData);
        } catch (e) {
          print('Error creating media item for photo ${i + 1}: $e');
        }
      }

      // Update the album with cover photo if we have uploaded photos
      if (uploadedUrls.isNotEmpty) {
        // Find the cover photo (first one or specified index)
        final coverIndex = coverPhotoIndex ?? 0;
        if (coverIndex < uploadedUrls.length) {
          // Get the media item that was created for the cover photo
          final albumPhotos = await DatabaseService.getMediaItems(albumId: albumId);
          if (albumPhotos.isNotEmpty) {
            final coverPhotoId = albumPhotos[coverIndex]['id'];
            await DatabaseService.update('photo_albums', albumId, {
              'cover_photo_id': coverPhotoId,
            });
          }
        }
      }

      // Reload albums to show the new one
      await _loadPhotoAlbums();
      
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
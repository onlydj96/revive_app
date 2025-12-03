import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/media_folder.dart';
import '../models/media_item.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import 'error_provider.dart';

final mediaFolderProvider =
    StateNotifierProvider<MediaFolderNotifier, AsyncValue<List<MediaFolder>>>(
        (ref) {
  return MediaFolderNotifier(ref);
});

final currentFolderProvider = StateProvider<String?>((ref) => null);

final mediaFolderSearchProvider = StateProvider<String>((ref) => '');

final showDeletedFoldersProvider = StateProvider<bool>((ref) => false);

final filteredMediaFoldersProvider = Provider<List<MediaFolder>>((ref) {
  final foldersAsyncValue = ref.watch(mediaFolderProvider);
  final searchQuery = ref.watch(mediaFolderSearchProvider);
  final currentFolderId = ref.watch(currentFolderProvider);
  final showDeleted = ref.watch(showDeletedFoldersProvider);

  return foldersAsyncValue.when(
    data: (folders) {
      // Filter by current folder (show subfolders of current folder)
      var filtered = folders
          .where((folder) =>
              folder.parentId == currentFolderId &&
              (showDeleted || !folder.isDeleted))
          .toList();

      // Apply search filter
      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where((folder) =>
                folder.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                (folder.description
                        ?.toLowerCase()
                        .contains(searchQuery.toLowerCase()) ??
                    false))
            .toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

class MediaFolderNotifier extends StateNotifier<AsyncValue<List<MediaFolder>>> {
  MediaFolderNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadMediaFolders();
    _setupRealtimeSubscription();
  }

  final Ref ref;
  RealtimeChannel? _channel;

  Future<void> _loadMediaFolders() async {
    try {
      state = const AsyncValue.loading();

      // Get all folders including soft deleted ones (filtering happens in UI)
      final foldersData = await DatabaseService.getAll('media_folders',
          orderBy: 'created_at', ascending: false, excludeSoftDeleted: false);

      final folders = <MediaFolder>[];
      final folderMap = <String, MediaFolder>{};

      // First pass: Create all folders with their direct media items
      for (final folderData in foldersData) {
        // Get media items for this folder
        final mediaData =
            await DatabaseService.getMediaItems(folderId: folderData['id']);
        final mediaItems =
            mediaData.map((item) => MediaItem.fromJson(item)).toList();

        final folder = MediaFolder.fromJson(folderData, mediaItems: mediaItems);
        folders.add(folder);
        folderMap[folder.id] = folder;
      }

      // Second pass: Build subfolder relationships
      for (final folder in folders) {
        if (folder.parentId != null) {
          final parent = folderMap[folder.parentId!];
          if (parent != null) {
            final updatedParent =
                parent.copyWith(subfolders: [...parent.subfolders, folder]);
            folderMap[parent.id] = updatedParent;
          }
        }
      }

      // Update the folders list with populated subfolder relationships
      final updatedFolders =
          folders.map((folder) => folderMap[folder.id]!).toList();

      state = AsyncValue.data(updatedFolders);
    } catch (error, stackTrace) {
      // Log error to error provider
      ref.read(errorProvider.notifier).addError(
            message: 'Failed to load media folders',
            details: error.toString(),
            severity: ErrorSeverity.warning,
            source: 'MediaFolderNotifier._loadMediaFolders',
          );

      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _setupRealtimeSubscription() {
    _channel = DatabaseService.subscribeToTable(
      'media_folders',
      (newRecord) {
        // Handle insert - reload folders
        _loadMediaFolders();
      },
      (updatedRecord) {
        // Handle update - reload folders
        _loadMediaFolders();
      },
      (deletedRecord) {
        // Handle delete - reload folders
        _loadMediaFolders();
      },
    );
  }

  Future<String> createFolder({
    required String name,
    String? description,
    String? parentId,
    required String folderPath,
    String? thumbnailUrl,
  }) async {
    try {
      final folderData = {
        'name': name,
        'description': description,
        'parent_id': parentId,
        'folder_path': folderPath,
        'thumbnail_url': thumbnailUrl,
      };

      final result = await DatabaseService.create('media_folders', folderData);
      final folderId = result!['id'] as String;

      // Create folder in storage
      await StorageService.createFolder(
        bucketName: StorageService.mediaBucket,
        folderPath: folderPath,
      );

      // Reload folders to show the new one
      await _loadMediaFolders();

      return folderId;
    } catch (error) {
      // Log error to error provider
      ref.read(errorProvider.notifier).addError(
            message: 'Failed to create folder: $name',
            details: error.toString(),
            severity: ErrorSeverity.error,
            source: 'MediaFolderNotifier.createFolder',
          );

      rethrow;
    }
  }

  Future<void> updateFolder(
    String id, {
    String? name,
    String? description,
    String? folderPath,
  }) async {
    // Store previous state for rollback
    final previousState = state;

    try {
      // Optimistic update: Update UI immediately
      state = state.whenData((folders) {
        return folders.map((folder) {
          if (folder.id == id) {
            return folder.copyWith(
              name: name ?? folder.name,
              description: description ?? folder.description,
              folderPath: folderPath ?? folder.folderPath,
            );
          }
          return folder;
        }).toList();
      });

      // Sync with backend
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (folderPath != null) data['folder_path'] = folderPath;
      data['updated_at'] = DateTime.now().toIso8601String();

      await DatabaseService.update('media_folders', id, data);
    } catch (error) {
      // Rollback on error
      state = previousState;
      rethrow;
    }
  }

  Future<void> deleteFolder(String id) async {
    try {
      // Get folder data first
      final folderData = await DatabaseService.getById('media_folders', id);
      if (folderData == null) return;

      // Delete all media items in this folder
      final mediaItems = await DatabaseService.getMediaItems(folderId: id);
      for (final item in mediaItems) {
        await DatabaseService.delete('media_items', item['id']);
      }

      // Delete all subfolders recursively
      final subfolders = await DatabaseService.query(
        'media_folders',
        where: 'parent_id = ?',
        whereArgs: [id],
      );
      for (final subfolder in subfolders) {
        await deleteFolder(subfolder['id']);
      }

      // Delete folder from storage
      final folderPath = folderData['folder_path'] as String;
      await StorageService.deleteFolder(
        bucketName: StorageService.mediaBucket,
        folderPath: folderPath,
      );

      // Delete folder from database
      await DatabaseService.delete('media_folders', id);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> moveFolder(String folderId, String? newParentId) async {
    try {
      await DatabaseService.update('media_folders', folderId, {
        'parent_id': newParentId,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      rethrow;
    }
  }

  // Get folder breadcrumb for navigation
  List<MediaFolder> getFolderBreadcrumb(String? folderId) {
    if (folderId == null) return [];

    return state.when(
      data: (folders) {
        final breadcrumb = <MediaFolder>[];
        var currentFolder = folders.firstWhere((f) => f.id == folderId,
            orElse: () => folders.first);

        while (true) {
          breadcrumb.insert(0, currentFolder);
          if (currentFolder.parentId == null) break;

          try {
            currentFolder =
                folders.firstWhere((f) => f.id == currentFolder.parentId);
          } catch (e) {
            break;
          }
        }

        return breadcrumb;
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  Future<void> softDeleteFolder(String id) async {
    // Store previous state for rollback
    final previousState = state;

    try {
      // Get current authenticated user ID
      final currentUser = SupabaseService.currentUser;
      final currentUserId =
          currentUser?.id ?? '37494678-2554-4e62-9fd0-c78308e82585';

      // Optimistic update: Mark as deleted immediately
      final now = DateTime.now();
      state = state.whenData((folders) {
        return folders.map((folder) {
          if (folder.id == id) {
            return folder.copyWith(
              deletedAt: now,
              deletedBy: currentUserId,
            );
          }
          return folder;
        }).toList();
      });

      // Sync with backend
      final updateData = {
        'deleted_at': now.toIso8601String(),
        'deleted_by': currentUserId,
        'updated_at': now.toIso8601String(),
      };

      await DatabaseService.update('media_folders', id, updateData);
    } catch (error) {
      // Rollback on error
      state = previousState;
      rethrow;
    }
  }

  Future<void> restoreFolder(String id) async {
    // Store previous state for rollback
    final previousState = state;

    try {
      // Optimistic update: Restore immediately
      state = state.whenData((folders) {
        return folders.map((folder) {
          if (folder.id == id) {
            return folder.copyWith(
              deletedAt: null,
              deletedBy: null,
            );
          }
          return folder;
        }).toList();
      });

      // Sync with backend
      await DatabaseService.update('media_folders', id, {
        'deleted_at': null,
        'deleted_by': null,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      // Rollback on error
      state = previousState;
      rethrow;
    }
  }

  Future<void> permanentDeleteFolder(String id) async {
    // Store previous state for rollback
    final previousState = state;

    try {
      // Optimistic update: Remove immediately
      state = state.whenData((folders) {
        return folders.where((folder) => folder.id != id).toList();
      });

      // Sync with backend - delete permanently
      await DatabaseService.delete('media_folders', id);
    } catch (error) {
      // Rollback on error
      state = previousState;
      rethrow;
    }
  }

  Future<void> refresh() async {
    await _loadMediaFolders();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

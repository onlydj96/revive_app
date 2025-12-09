import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/media_folder.dart';
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

// Sorting providers
final folderSortOptionProvider = StateProvider<FolderSortOption>((ref) => FolderSortOption.dateCreated);
final folderSortAscendingProvider = StateProvider<bool>((ref) => false); // false = descending (newest first)

// Provider to get actual media count for a folder from database
// This ensures accurate counts even with pagination
// Includes media items in all subfolders recursively
final folderMediaCountProvider = FutureProvider.family<int, String>((ref, folderId) async {
  return await SupabaseService.getMediaItemCountRecursive(folderId: folderId);
});

// Provider to get media counts for all folders in current directory
// Used for accurate sorting by item count
final folderMediaCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final foldersAsyncValue = ref.watch(mediaFolderProvider);
  final currentFolderId = ref.watch(currentFolderProvider);

  return await foldersAsyncValue.when(
    data: (folders) async {
      final filtered = folders
          .where((folder) => folder.parentId == currentFolderId && !folder.isDeleted)
          .toList();

      final counts = <String, int>{};
      for (final folder in filtered) {
        counts[folder.id] = await SupabaseService.getMediaItemCountRecursive(folderId: folder.id);
      }
      return counts;
    },
    loading: () async => <String, int>{},
    error: (_, __) async => <String, int>{},
  );
});

final filteredMediaFoldersProvider = Provider<List<MediaFolder>>((ref) {
  final foldersAsyncValue = ref.watch(mediaFolderProvider);
  final searchQuery = ref.watch(mediaFolderSearchProvider);
  final currentFolderId = ref.watch(currentFolderProvider);
  final showDeleted = ref.watch(showDeletedFoldersProvider);
  final sortOption = ref.watch(folderSortOptionProvider);
  final sortAscending = ref.watch(folderSortAscendingProvider);

  // Watch folder counts for accurate item count sorting
  final folderCountsAsync = ref.watch(folderMediaCountsProvider);

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

      // Apply sorting
      filtered.sort((a, b) {
        int comparison;
        switch (sortOption) {
          case FolderSortOption.name:
            comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
            break;
          case FolderSortOption.dateCreated:
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
          case FolderSortOption.dateModified:
            comparison = a.updatedAt.compareTo(b.updatedAt);
            break;
          case FolderSortOption.itemCount:
            // Use accurate database counts when available
            comparison = folderCountsAsync.when(
              data: (counts) {
                final countA = counts[a.id] ?? 0;
                final countB = counts[b.id] ?? 0;
                return countA.compareTo(countB);
              },
              loading: () {
                // Fallback to in-memory count during loading
                return a.totalItemCount.compareTo(b.totalItemCount);
              },
              error: (_, __) {
                // Fallback to in-memory count on error
                return a.totalItemCount.compareTo(b.totalItemCount);
              },
            );
            break;
        }
        return sortAscending ? comparison : -comparison;
      });

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
      final foldersData = await SupabaseService.getAll('media_folders',
          orderBy: 'created_at', ascending: false, excludeSoftDeleted: false);

      final folders = <MediaFolder>[];
      final folderMap = <String, MediaFolder>{};

      // First pass: Create all folders without media items
      // Media items are managed separately by mediaProvider and accessed via mediaByFolderProvider
      for (final folderData in foldersData) {
        final folder = MediaFolder.fromJson(folderData);
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
    _channel = SupabaseService.subscribeToTable(
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

      final result = await SupabaseService.create('media_folders', folderData);
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
    String? thumbnailUrl,
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
              thumbnailUrl: thumbnailUrl ?? folder.thumbnailUrl,
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
      if (thumbnailUrl != null) data['thumbnail_url'] = thumbnailUrl;
      data['updated_at'] = DateTime.now().toIso8601String();

      await SupabaseService.update('media_folders', id, data);
    } catch (error) {
      // Rollback on error
      state = previousState;
      rethrow;
    }
  }

  Future<void> deleteFolder(String id) async {
    try {
      // Get folder data first
      final folderData = await SupabaseService.getById('media_folders', id);
      if (folderData == null) return;

      // Delete all media items in this folder
      final mediaItems = await SupabaseService.getMediaItems(folderId: id);
      for (final item in mediaItems) {
        await SupabaseService.delete('media_items', item['id']);
      }

      // Delete all subfolders recursively
      final subfolders = await SupabaseService.client
          .from('media_folders')
          .select()
          .eq('parent_id', id);
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
      await SupabaseService.delete('media_folders', id);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> moveFolder(String folderId, String? newParentId) async {
    try {
      await SupabaseService.update('media_folders', folderId, {
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

      await SupabaseService.update('media_folders', id, updateData);

      // Cascade delete: Soft-delete all media items in this folder
      final mediaItems = await SupabaseService.from('media_items')
          .select('id')
          .eq('folder_id', id)
          .isFilter('deleted_at', null); // Only get non-deleted items

      // Soft-delete each media item
      for (final item in mediaItems) {
        await SupabaseService.update('media_items', item['id'], {
          'deleted_at': now.toIso8601String(),
          'deleted_by': currentUserId,
          'updated_at': now.toIso8601String(),
        });
      }

      // Invalidate folder media count cache
      ref.invalidate(folderMediaCountProvider(id));
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
      await SupabaseService.update('media_folders', id, {
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
      await SupabaseService.delete('media_folders', id);
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

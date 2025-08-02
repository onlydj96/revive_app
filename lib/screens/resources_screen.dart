import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/media_provider.dart';
import '../providers/media_folder_provider.dart';
import '../providers/permissions_provider.dart';
import '../models/media_item.dart';
import '../models/media_folder.dart';
import '../widgets/media_grid_item.dart';
import '../widgets/create_media_folder_dialog.dart';
import '../widgets/upload_media_dialog.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  bool _isGridView = true;
  
  @override
  Widget build(BuildContext context) {
    final foldersAsyncValue = ref.watch(mediaFolderProvider);
    final filteredFolders = ref.watch(filteredMediaFoldersProvider);
    final currentFolderId = ref.watch(currentFolderProvider);
    final searchQuery = ref.watch(mediaFolderSearchProvider);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        leading: currentFolderId != null 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _navigateUp(),
              )
            : null,
        actions: [
          // Admin toggle for showing deleted items
          if (permissions.isAdmin) ...[
            Consumer(
              builder: (context, ref, child) {
                final showDeleted = ref.watch(showDeletedFoldersProvider);
                return IconButton(
                  icon: Icon(
                    showDeleted ? Icons.visibility_off : Icons.visibility,
                    color: showDeleted ? Colors.orange : null,
                  ),
                  tooltip: showDeleted ? '삭제된 항목 숨기기' : '삭제된 항목 보기',
                  onPressed: () {
                    ref.read(showDeletedFoldersProvider.notifier).state = !showDeleted;
                  },
                );
              },
            ),
          ],
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
      body: foldersAsyncValue.when(
        data: (folders) => Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search folders and media...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (value) {
                  ref.read(mediaFolderSearchProvider.notifier).state = value;
                },
              ),
            ),
            
            // Breadcrumb navigation
            if (currentFolderId != null) _buildBreadcrumb(),
            
            // Content area
            Expanded(
              child: _buildFolderContent(filteredFolders, currentFolderId),
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
              Text('Error loading folders: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(mediaFolderProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    final currentFolderId = ref.watch(currentFolderProvider);
    if (currentFolderId == null) {
      return const Text('Resources');
    }
    
    final folders = ref.watch(mediaFolderProvider).value ?? [];
    final currentFolder = folders.firstWhere(
      (f) => f.id == currentFolderId,
      orElse: () => MediaFolder(
        id: '',
        name: 'Unknown',
        folderPath: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    return Text(currentFolder.name);
  }

  void _navigateUp() {
    final folders = ref.watch(mediaFolderProvider).value ?? [];
    final currentFolderId = ref.watch(currentFolderProvider);
    
    if (currentFolderId != null) {
      final currentFolder = folders.firstWhere((f) => f.id == currentFolderId);
      ref.read(currentFolderProvider.notifier).state = currentFolder.parentId;
    }
  }

  Widget _buildBreadcrumb() {
    final breadcrumb = ref.read(mediaFolderProvider.notifier).getFolderBreadcrumb(
      ref.watch(currentFolderProvider)
    );
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: breadcrumb.length + 1, // +1 for root
        separatorBuilder: (context, index) => const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return InkWell(
              onTap: () => ref.read(currentFolderProvider.notifier).state = null,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Text('Home', style: TextStyle(color: Colors.blue)),
              ),
            );
          }
          
          final folder = breadcrumb[index - 1];
          return InkWell(
            onTap: () => ref.read(currentFolderProvider.notifier).state = folder.id,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text(
                folder.name,
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFolderContent(List<MediaFolder> folders, String? currentFolderId) {
    // Get current folder's subfolders
    final subfolders = folders.where((f) => f.parentId == currentFolderId).toList();
    
    // Get all folders from the provider to access media items
    final allFolders = ref.watch(mediaFolderProvider).value ?? [];
    final currentFolder = currentFolderId != null
        ? allFolders.firstWhere((f) => f.id == currentFolderId, orElse: () => 
            MediaFolder(id: '', name: '', folderPath: '', createdAt: DateTime.now(), updatedAt: DateTime.now()))
        : null;
    
    final mediaItems = currentFolder?.mediaItems.where((item) => !item.isDeleted).toList() ?? [];
    
    if (subfolders.isEmpty && mediaItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'This folder is empty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add folders or media to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Show subfolders first
        if (subfolders.isNotEmpty) ...[
          const Text(
            'Folders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: subfolders.length,
            itemBuilder: (context, index) {
              final folder = subfolders[index];
              return _buildFolderCard(folder);
            },
          ),
          const SizedBox(height: 24),
        ],
        
        // Show media items
        if (mediaItems.isNotEmpty) ...[
          const Text(
            'Media',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: mediaItems.length,
            itemBuilder: (context, index) {
              final mediaItem = mediaItems[index];
              return MediaGridItem(
                mediaItem: mediaItem,
                onTap: () => context.push('/media/${mediaItem.id}?folderId=${mediaItem.folderId ?? ''}'),
                onCollect: () => ref
                    .read(mediaProvider.notifier)
                    .toggleCollection(mediaItem.id),
                onDelete: () => _deleteMediaSoft(context, mediaItem),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildFolderCard(MediaFolder folder) {
    final thumbnailUrl = folder.effectiveThumbnailUrl;
    final permissions = ref.watch(permissionsProvider);
    final isDeleted = folder.isDeleted;
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: isDeleted ? null : () => ref.read(currentFolderProvider.notifier).state = folder.id,
        onLongPress: permissions.canDeleteFolder(folder.createdBy) 
            ? () => _showFolderOptions(context, folder) 
            : null,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Opacity(
                opacity: isDeleted ? 0.5 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Thumbnail image or folder icon
                    Expanded(
                      flex: 3,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                                ? Image.network(
                                    thumbnailUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: isDeleted ? Colors.red[50] : Colors.grey[100],
                                        child: Icon(
                                          Icons.folder,
                                          size: 48,
                                          color: isDeleted ? Colors.red[300] : Theme.of(context).primaryColor,
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[100],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: isDeleted ? Colors.red[50] : Colors.grey[100],
                                    child: Icon(
                                      Icons.folder,
                                      size: 48,
                                      color: isDeleted ? Colors.red[300] : Theme.of(context).primaryColor,
                                    ),
                                  ),
                          ),
                          if (isDeleted)
                            Positioned.fill(
                              child: Container(
                                color: Colors.red.withOpacity(0.2),
                                child: Center(
                                  child: Icon(
                                    Icons.delete_forever,
                                    size: 32,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  // Folder info
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            folder.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (folder.description != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              folder.description!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${folder.totalItemCount}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
              // Admin options button
              if (permissions.canDeleteFolder(folder.createdBy))
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 16,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      onPressed: () => _showFolderOptions(context, folder),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }


  void _showFolderOptions(BuildContext context, MediaFolder folder) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '폴더 관리',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (folder.isDeleted) ...[
              // Options for deleted folders
              ListTile(
                leading: const Icon(Icons.restore, color: Colors.green),
                title: const Text('폴더 복구'),
                subtitle: Text('${folder.name} 폴더를 복구합니다'),
                onTap: () {
                  Navigator.of(context).pop();
                  _restoreFolder(context, folder);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('영구 삭제'),
                subtitle: const Text('폴더를 완전히 삭제합니다 (복구 불가)'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showPermanentDeleteConfirmation(context, folder);
                },
              ),
            ] else ...[
              // Options for active folders
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('폴더 삭제'),
                subtitle: Text('${folder.name} 폴더를 삭제합니다'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteFolderConfirmation(context, folder);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteFolderConfirmation(BuildContext context, MediaFolder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('폴더 삭제 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('정말로 "${folder.name}" 폴더를 삭제하시겠습니까?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '이 작업은 되돌릴 수 있습니다. 폴더와 내용물이 숨겨지지만 완전히 삭제되지는 않습니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteFolderSoft(context, folder);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFolderSoft(BuildContext context, MediaFolder folder) async {
    try {
      print('🖱️ [DEBUG] UI: Delete button clicked for folder: ${folder.name} (ID: ${folder.id})');
      
      await ref.read(mediaFolderProvider.notifier).softDeleteFolder(folder.id);
      
      print('🖱️ [DEBUG] UI: Soft delete completed');
      
      if (context.mounted) {
        final showDeleted = ref.read(showDeletedFoldersProvider);
        
        print('🖱️ [DEBUG] UI: showDeleted toggle state: $showDeleted');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(showDeleted 
              ? '${folder.name} 폴더가 삭제되었습니다 (관리자 모드에서는 계속 보입니다)'
              : '${folder.name} 폴더가 삭제되었습니다'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: '되돌리기',
              textColor: Colors.white,
              onPressed: () async {
                await ref.read(mediaFolderProvider.notifier).restoreFolder(folder.id);
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('🖱️ [ERROR] UI: Delete failed with error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('폴더 삭제 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteMediaSoft(BuildContext context, MediaItem mediaItem) async {
    try {
      await ref.read(mediaProvider.notifier).softDeleteMedia(mediaItem.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${mediaItem.title}이(가) 삭제되었습니다'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: '되돌리기',
              textColor: Colors.white,
              onPressed: () async {
                await ref.read(mediaProvider.notifier).restoreMedia(mediaItem.id);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('미디어 삭제 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreFolder(BuildContext context, MediaFolder folder) async {
    try {
      await ref.read(mediaFolderProvider.notifier).restoreFolder(folder.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${folder.name} 폴더가 복구되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('폴더 복구 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPermanentDeleteConfirmation(BuildContext context, MediaFolder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('영구 삭제 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('정말로 "${folder.name}" 폴더를 영구 삭제하시겠습니까?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '이 작업은 되돌릴 수 없습니다. 폴더와 모든 내용이 완전히 삭제됩니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _permanentDeleteFolder(context, folder);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('영구 삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _permanentDeleteFolder(BuildContext context, MediaFolder folder) async {
    try {
      await ref.read(mediaFolderProvider.notifier).permanentDeleteFolder(folder.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${folder.name} 폴더가 영구적으로 삭제되었습니다'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('영구 삭제 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              leading: const Icon(Icons.create_new_folder),
              title: const Text('폴더 만들기'),
              subtitle: const Text('새 폴더를 생성하여 미디어를 정리'),
              onTap: () {
                Navigator.of(context).pop();
                _showCreateFolderDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('미디어 업로드'),
              subtitle: const Text('사진이나 동영상을 현재 폴더에 업로드'),
              onTap: () {
                Navigator.of(context).pop();
                _showUploadMediaDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateMediaFolderDialog(
        parentFolderId: ref.read(currentFolderProvider),
        onCreateFolder: (name, description, folderPath, thumbnailUrl) async {
          try {
            await ref.read(mediaFolderProvider.notifier).createFolder(
              name: name,
              description: description,
              parentId: ref.read(currentFolderProvider),
              folderPath: folderPath,
              thumbnailUrl: thumbnailUrl,
            );
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('폴더가 성공적으로 생성되었습니다!')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('폴더 생성 실패: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showUploadMediaDialog(BuildContext context) {
    final currentFolderId = ref.read(currentFolderProvider);
    
    // Get current folder to determine upload path
    String folderPath = 'root';
    if (currentFolderId != null) {
      final folders = ref.read(mediaFolderProvider).value ?? [];
      final currentFolder = folders.firstWhere(
        (f) => f.id == currentFolderId,
        orElse: () => MediaFolder(
          id: '',
          name: 'root',
          folderPath: 'root',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      folderPath = currentFolder.folderPath;
    }

    showDialog(
      context: context,
      builder: (context) => UploadMediaDialog(
        folderId: currentFolderId,
        folderPath: folderPath,
        onUploadMedia: (mediaItems) async {
          try {
            await ref.read(mediaProvider.notifier).uploadMediaFiles(
              mediaItems: mediaItems,
              folderPath: folderPath,
              folderId: currentFolderId,
              category: MediaCategory.general,
              photographer: 'Church Media Team',
            );
            
            // Refresh folder data to show new media
            await ref.read(mediaFolderProvider.notifier).refresh();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('업로드 실패: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            rethrow;
          }
        },
      ),
    );
  }

}
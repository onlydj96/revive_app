import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/media_provider.dart';
import '../providers/media_folder_provider.dart';
import '../providers/permissions_provider.dart';
import '../providers/dialog_state_provider.dart';
import '../models/media_item.dart';
import '../models/media_folder.dart';
import '../widgets/media_grid_item.dart';
import '../widgets/create_media_folder_dialog.dart';
import '../widgets/upload_media_dialog.dart';
import '../services/storage_service.dart';
import '../utils/ui_utils.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }


  void _onScroll() {
    // Optimized trigger at 65% for smoother UX - loads next page before user reaches end
    // Prevents scroll stuttering on slow networks while balancing memory usage
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.65) {
      ref.read(mediaProvider.notifier).loadMoreMedia();
    }
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Watch mediaProvider at top level to ensure MediaNotifier initializes
    // Without this, media items are never loaded from Supabase
    ref.watch(mediaProvider);

    final foldersAsyncValue = ref.watch(mediaFolderProvider);
    final filteredFolders = ref.watch(filteredMediaFoldersProvider);
    final currentFolderId = ref.watch(currentFolderProvider);
    final permissions = ref.watch(permissionsProvider);
    final isGridView = ref.watch(resourcesViewModeProvider);

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
                    ref.read(showDeletedFoldersProvider.notifier).state =
                        !showDeleted;
                  },
                );
              },
            ),
          ],
          // Grid/List view toggle
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              ref.read(resourcesViewModeProvider.notifier).state = !isGridView;
            },
          ),
        ],
      ),
      floatingActionButton: permissions.canCreateContent
          ? FloatingActionButton(
              heroTag: 'resources_fab',
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
                onPressed: () =>
                    ref.read(mediaFolderProvider.notifier).refresh(),
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
    final breadcrumb = ref
        .read(mediaFolderProvider.notifier)
        .getFolderBreadcrumb(ref.watch(currentFolderProvider));

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
              onTap: () =>
                  ref.read(currentFolderProvider.notifier).state = null,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Text('Home', style: TextStyle(color: Colors.blue)),
              ),
            );
          }

          final folder = breadcrumb[index - 1];
          return InkWell(
            onTap: () =>
                ref.read(currentFolderProvider.notifier).state = folder.id,
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

  Widget _buildFolderContent(
      List<MediaFolder> folders, String? currentFolderId) {
    // Get current folder's subfolders
    final subfolders = folders
        .where((f) => f.parentId == currentFolderId && !f.isDeleted)
        .toList();

    // Get media items for current folder directly from mediaProvider
    // This ensures realtime updates work correctly
    final mediaItems = ref.watch(mediaByFolderProvider(currentFolderId));

    if (subfolders.isEmpty && mediaItems.isEmpty) {
      return _buildEmptyState();
    }

    return SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Padding at top
          const SliverPadding(padding: EdgeInsets.only(top: 16)),

          // Show subfolders first
          if (subfolders.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _buildSectionHeader(
                  title: 'Folders',
                  count: subfolders.length,
                  isFolder: true,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final folder = subfolders[index];
                    return _buildFolderCard(folder);
                  },
                  childCount: subfolders.length,
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],

          // Show media items
          if (mediaItems.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _buildSectionHeader(
                  title: 'Media',
                  count: mediaItems.length,
                  isFolder: false,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final mediaItem = mediaItems[index];
                    return MediaGridItem(
                      mediaItem: mediaItem,
                      onTap: () => context.push(
                          '/media/${mediaItem.id}?folderId=${mediaItem.folderId ?? ''}'),
                      onCollect: () => ref
                          .read(mediaProvider.notifier)
                          .toggleCollection(mediaItem.id),
                      onDelete: () => _deleteMediaSoft(context, mediaItem),
                    );
                  },
                  childCount: mediaItems.length,
                ),
              ),
            ),
          ],

          // Loading indicator at bottom when loading more - enhanced UX
          if (ref.read(mediaProvider.notifier).isLoadingMore)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Loading more media...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Padding at bottom
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }

  Widget _buildFolderCard(MediaFolder folder) {
    // Get thumbnail URL from folder or first media item in this folder
    final folderMediaItems = ref.watch(mediaByFolderProvider(folder.id));
    final thumbnailUrl = folder.thumbnailUrl ??
        folderMediaItems.where((item) => item.type == MediaType.photo).firstOrNull?.thumbnailUrl;

    // Get actual media count from database (accurate even with pagination)
    final mediaCountAsync = ref.watch(folderMediaCountProvider(folder.id));

    final permissions = ref.watch(permissionsProvider);
    final isDeleted = folder.isDeleted;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: isDeleted
            ? null
            : () => ref.read(currentFolderProvider.notifier).state = folder.id,
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
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: thumbnailUrl != null &&
                                    thumbnailUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: thumbnailUrl,
                                    fit: BoxFit.cover,
                                    memCacheWidth: 400,
                                    memCacheHeight: 400,
                                    maxWidthDiskCache: 600,
                                    maxHeightDiskCache: 600,
                                    // Progressive loading with smooth fade-in
                                    fadeInDuration: const Duration(milliseconds: 300),
                                    fadeOutDuration: const Duration(milliseconds: 100),
                                    // Shimmer-like placeholder for better UX
                                    placeholder: (context, url) => Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.grey[200]!,
                                            Colors.grey[100]!,
                                            Colors.grey[200]!,
                                          ],
                                          stops: const [0.0, 0.5, 1.0],
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 32,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) {
                                      return Container(
                                        color: isDeleted
                                            ? Colors.red[50]
                                            : Colors.grey[100],
                                        child: Icon(
                                          Icons.folder,
                                          size: 48,
                                          color: isDeleted
                                              ? Colors.red[300]
                                              : Theme.of(context).primaryColor,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: isDeleted
                                        ? Colors.red[50]
                                        : Colors.grey[100],
                                    child: Icon(
                                      Icons.folder,
                                      size: 48,
                                      color: isDeleted
                                          ? Colors.red[300]
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ),
                          ),
                          if (isDeleted)
                            Positioned.fill(
                              child: Container(
                                color: Colors.red.withValues(alpha: 0.2),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (folder.description != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                folder.description!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
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
                                mediaCountAsync.when(
                                  data: (count) {
                                    // Show direct media count from database
                                    // This is accurate even with pagination
                                    return Text(
                                      '$count',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey[500],
                                          ),
                                    );
                                  },
                                  loading: () => Text(
                                    '...',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey[500],
                                        ),
                                  ),
                                  error: (_, __) => Text(
                                    '0',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey[500],
                                        ),
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
                      color: Colors.black.withValues(alpha: 0.5),
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

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required bool isFolder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const Spacer(),
          // Sort button for this section
          PopupMenuButton<String>(
            icon: Icon(
              Icons.sort,
              size: 20,
              color: Colors.grey[700],
            ),
            tooltip: isFolder ? '폴더 정렬' : '미디어 정렬',
            offset: const Offset(0, 40),
            onSelected: (value) {
              if (isFolder) {
                // Folder sorting
                if (value == 'toggle_order') {
                  ref.read(folderSortAscendingProvider.notifier).state =
                      !ref.read(folderSortAscendingProvider);
                } else {
                  final option = FolderSortOption.values.firstWhere(
                    (e) => e.name == value,
                  );
                  ref.read(folderSortOptionProvider.notifier).state = option;
                }
              } else {
                // Media sorting
                final option = MediaSortOption.values.firstWhere(
                  (e) => e.name == value,
                );
                ref.read(mediaSortOptionProvider.notifier).state = option;
              }
            },
            itemBuilder: (context) {
              if (isFolder) {
                // Folder sort menu
                final currentSort = ref.watch(folderSortOptionProvider);
                final sortAscending = ref.watch(folderSortAscendingProvider);

                return [
                  ...FolderSortOption.values.map((option) => PopupMenuItem(
                        value: option.name,
                        child: Row(
                          children: [
                            if (currentSort == option)
                              Icon(Icons.check, size: 16, color: Theme.of(context).primaryColor),
                            if (currentSort == option) const SizedBox(width: 8),
                            Text(option.label),
                          ],
                        ),
                      )),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'toggle_order',
                    child: Row(
                      children: [
                        Icon(
                          sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(sortAscending ? '오름차순' : '내림차순'),
                      ],
                    ),
                  ),
                ];
              } else {
                // Media sort menu
                final currentSort = ref.watch(mediaSortOptionProvider);

                return MediaSortOption.values
                    .map((option) => PopupMenuItem(
                          value: option.name,
                          child: Row(
                            children: [
                              if (currentSort == option)
                                Icon(Icons.check, size: 16, color: Theme.of(context).primaryColor),
                              if (currentSort == option) const SizedBox(width: 8),
                              Text(option.label),
                            ],
                          ),
                        ))
                    .toList();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final searchQuery = ref.watch(mediaFolderSearchProvider);
    final permissions = ref.watch(permissionsProvider);

    // Case 1: Search results are empty
    if (searchQuery.isNotEmpty) {
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
              '검색 결과가 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '"$searchQuery"에 대한 폴더나 미디어를 찾을 수 없습니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(mediaFolderSearchProvider.notifier).state = '';
              },
              icon: const Icon(Icons.clear),
              label: const Text('검색 초기화'),
            ),
          ],
        ),
      );
    }

    // Case 2: Folder is empty - User has create permissions
    if (permissions.canCreateContent) {
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
              '폴더가 비어있습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '새 폴더를 만들거나 미디어를 업로드하세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showCreateFolderDialog(context),
                  icon: const Icon(Icons.create_new_folder),
                  label: const Text('폴더 만들기'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _showUploadMediaDialog(context),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('미디어 업로드'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Case 3: Folder is empty - User does not have create permissions
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
            '폴더가 비어있습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '아직 콘텐츠가 업로드되지 않았습니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
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
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('썸네일 수정'),
                subtitle: Text(folder.thumbnailUrl == null
                    ? '폴더 썸네일을 추가합니다'
                    : '폴더 썸네일을 변경합니다'),
                onTap: () {
                  Navigator.of(context).pop();
                  _updateFolderThumbnail(context, folder);
                },
              ),
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
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
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

  Future<void> _deleteFolderSoft(
      BuildContext context, MediaFolder folder) async {
    try {
      await ref.read(mediaFolderProvider.notifier).softDeleteFolder(folder.id);

      // Invalidate folder count provider to refresh counts
      ref.invalidate(folderMediaCountProvider);

      if (context.mounted) {
        final showDeleted = ref.read(showDeletedFoldersProvider);

        UIUtils.showSuccess(
          context,
          showDeleted
              ? '${folder.name} 폴더가 삭제되었습니다 (관리자 모드에서는 계속 보입니다)'
              : '${folder.name} 폴더가 삭제되었습니다',
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '되돌리기',
            textColor: Colors.white,
            onPressed: () async {
              await ref
                  .read(mediaFolderProvider.notifier)
                  .restoreFolder(folder.id);
              // Invalidate folder count provider to refresh counts
              ref.invalidate(folderMediaCountProvider);
            },
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        UIUtils.showError(context, '폴더 삭제 실패: $e');
      }
    }
  }

  Future<void> _deleteMediaSoft(
      BuildContext context, MediaItem mediaItem) async {
    try {
      await ref.read(mediaProvider.notifier).softDeleteMedia(mediaItem.id);

      // Invalidate folder count provider to refresh counts
      ref.invalidate(folderMediaCountProvider);

      if (context.mounted) {
        UIUtils.showSuccess(
          context,
          '${mediaItem.title}이(가) 삭제되었습니다',
          action: SnackBarAction(
            label: '되돌리기',
            textColor: Colors.white,
            onPressed: () async {
              await ref
                  .read(mediaProvider.notifier)
                  .restoreMedia(mediaItem.id);
              // Invalidate folder count provider to refresh counts
              ref.invalidate(folderMediaCountProvider);
            },
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        UIUtils.showError(context, '미디어 삭제 실패: $e');
      }
    }
  }

  Future<void> _restoreFolder(BuildContext context, MediaFolder folder) async {
    try {
      await ref.read(mediaFolderProvider.notifier).restoreFolder(folder.id);

      // Invalidate folder count provider to refresh counts
      ref.invalidate(folderMediaCountProvider);

      if (context.mounted) {
        UIUtils.showSuccess(context, '${folder.name} 폴더가 복구되었습니다');
      }
    } catch (e) {
      if (context.mounted) {
        UIUtils.showError(context, '폴더 복구 실패: $e');
      }
    }
  }

  Future<void> _updateFolderThumbnail(
      BuildContext context, MediaFolder folder) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      if (context.mounted) {
        // Show loading indicator
        UIUtils.showLoading(context, '썸네일 업로드 중...');
      }

      // Upload to Supabase Storage
      final file = File(image.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${folder.id}_$timestamp.jpg';

      final thumbnailUrl = await StorageService.uploadFile(
        bucketName: 'media-thumbnails',
        folderPath: 'folder_thumbnails',
        fileName: fileName,
        file: file,
      );

      // Update folder with new thumbnail URL
      await ref.read(mediaFolderProvider.notifier).updateFolder(
        folder.id,
        thumbnailUrl: thumbnailUrl,
      );

      if (context.mounted) {
        UIUtils.clearSnackBars(context);
        UIUtils.showSuccess(
            context, '${folder.name} 폴더의 썸네일이 업데이트되었습니다');
      }
    } catch (e) {
      if (context.mounted) {
        UIUtils.clearSnackBars(context);
        UIUtils.showError(context, '썸네일 업데이트 실패: $e');
      }
    }
  }

  void _showPermanentDeleteConfirmation(
      BuildContext context, MediaFolder folder) {
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
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
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

  Future<void> _permanentDeleteFolder(
      BuildContext context, MediaFolder folder) async {
    try {
      await ref
          .read(mediaFolderProvider.notifier)
          .permanentDeleteFolder(folder.id);

      if (context.mounted) {
        UIUtils.showError(context, '${folder.name} 폴더가 영구적으로 삭제되었습니다');
      }
    } catch (e) {
      if (context.mounted) {
        UIUtils.showError(context, '영구 삭제 실패: $e');
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
              UIUtils.showSuccess(context, '폴더가 성공적으로 생성되었습니다!');
            }
          } catch (e) {
            if (context.mounted) {
              UIUtils.showError(context, '폴더 생성 실패: $e');
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
                  onProgress: (progress) {
                    // Update progress provider as files are uploaded
                    ref.read(uploadProgressProvider.notifier).state = progress;
                  },
                );

            // Invalidate folder count provider to refresh counts
            ref.invalidate(folderMediaCountProvider);

            // Refresh folder data to show new media
            await ref.read(mediaFolderProvider.notifier).refresh();
          } catch (e) {
            if (context.mounted) {
              UIUtils.showError(context, '업로드 실패: $e');
            }
            rethrow;
          }
        },
      ),
    );
  }

  // NOTE: _calculateTotalMediaCount and _mediaCountCache are no longer used
  // We now use folderMediaCountProvider which gets accurate counts from database
  // This ensures correct counts even with pagination

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}

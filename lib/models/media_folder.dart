import 'media_item.dart';

class MediaFolder {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final String folderPath; // Storage path like "worship/2025/january"
  final String? thumbnailUrl; // Thumbnail image URL
  final DateTime createdAt;
  final String? createdBy;
  final DateTime updatedAt;
  final DateTime? deletedAt; // Soft delete timestamp
  final String? deletedBy; // Who deleted this folder
  final List<MediaFolder> subfolders;
  final List<MediaItem> mediaItems;

  const MediaFolder({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    required this.folderPath,
    this.thumbnailUrl,
    required this.createdAt,
    this.createdBy,
    required this.updatedAt,
    this.deletedAt,
    this.deletedBy,
    this.subfolders = const [],
    this.mediaItems = const [],
  });

  factory MediaFolder.fromJson(
    Map<String, dynamic> json, {
    List<MediaFolder>? subfolders,
    List<MediaItem>? mediaItems,
  }) {
    return MediaFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentId: json['parent_id'] as String?,
      folderPath: json['folder_path'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      deletedBy: json['deleted_by'] as String?,
      subfolders: subfolders ?? [],
      mediaItems: mediaItems ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parent_id': parentId,
      'folder_path': folderPath,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'deleted_by': deletedBy,
    };
  }

  MediaFolder copyWith({
    String? id,
    String? name,
    String? description,
    String? parentId,
    String? folderPath,
    String? thumbnailUrl,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? deletedBy,
    List<MediaFolder>? subfolders,
    List<MediaItem>? mediaItems,
  }) {
    return MediaFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      folderPath: folderPath ?? this.folderPath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      subfolders: subfolders ?? this.subfolders,
      mediaItems: mediaItems ?? this.mediaItems,
    );
  }

  // Helper methods
  bool get isRootFolder => parentId == null;
  bool get hasSubfolders => subfolders.isNotEmpty;
  bool get hasMediaItems => mediaItems.isNotEmpty;
  bool get isDeleted => deletedAt != null;
  int get totalItemCount =>
      mediaItems.where((item) => !item.isDeleted).length +
      subfolders
          .where((folder) => !folder.isDeleted)
          .fold(0, (sum, folder) => sum + folder.totalItemCount);

  // Get thumbnail URL with fallback to first image
  String? get effectiveThumbnailUrl {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      return thumbnailUrl;
    }

    // Try to find first image in this folder's media items
    final firstImage =
        mediaItems.where((item) => item.type == MediaType.photo).firstOrNull;

    return firstImage?.thumbnailUrl ?? firstImage?.url;
  }

  // Get folder breadcrumb path for navigation
  String get displayPath {
    final parts = folderPath.split('/');
    return parts.join(' > ');
  }
}

// Enum for folder sorting options
enum FolderSortOption {
  name,
  dateCreated,
  dateModified,
  itemCount,
}

extension FolderSortOptionExtension on FolderSortOption {
  String get label {
    switch (this) {
      case FolderSortOption.name:
        return '이름순';
      case FolderSortOption.dateCreated:
        return '생성일순';
      case FolderSortOption.dateModified:
        return '수정일순';
      case FolderSortOption.itemCount:
        return '항목 수';
    }
  }
}

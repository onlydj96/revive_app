enum MediaType {
  photo,
  video,
  audio;

  static MediaType fromString(String value) {
    switch (value) {
      case 'photo':
        return MediaType.photo;
      case 'video':
        return MediaType.video;
      case 'audio':
        return MediaType.audio;
      default:
        return MediaType.photo;
    }
  }
}

enum MediaCategory {
  worship,
  sermon,
  fellowship,
  outreach,
  youth,
  children,
  general;

  static MediaCategory fromString(String value) {
    switch (value) {
      case 'worship':
        return MediaCategory.worship;
      case 'sermon':
        return MediaCategory.sermon;
      case 'fellowship':
        return MediaCategory.fellowship;
      case 'outreach':
        return MediaCategory.outreach;
      case 'youth':
        return MediaCategory.youth;
      case 'children':
        return MediaCategory.children;
      case 'general':
        return MediaCategory.general;
      default:
        return MediaCategory.general;
    }
  }
}

class MediaItem {
  final String id;
  final String title;
  final String? description;
  final MediaType type;
  final MediaCategory category;
  final String url;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final String? photographer;
  final List<String> tags;
  final bool isCollected;
  final String? albumId;
  final String? folderId;
  final DateTime? deletedAt; // Soft delete timestamp
  final String? deletedBy; // Who deleted this item

  MediaItem({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.category,
    required this.url,
    this.thumbnailUrl,
    required this.createdAt,
    this.photographer,
    this.tags = const [],
    this.isCollected = false,
    this.albumId,
    this.folderId,
    this.deletedAt,
    this.deletedBy,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json, {bool isCollected = false}) {
    return MediaItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: MediaType.fromString(json['type'] as String? ?? 'photo'),
      category: MediaCategory.fromString(json['category'] as String? ?? 'general'),
      url: json['url'] as String? ?? json['file_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      photographer: json['photographer'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      isCollected: isCollected,
      albumId: json['album_id'] as String?,
      folderId: json['folder_id'] as String?,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      deletedBy: json['deleted_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'category': category.name,
      'file_url': url,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
      'photographer': photographer,
      'tags': tags,
      'album_id': albumId,
      'folder_id': folderId,
    };
  }

  MediaItem copyWith({
    String? id,
    String? title,
    String? description,
    MediaType? type,
    MediaCategory? category,
    String? url,
    String? thumbnailUrl,
    DateTime? createdAt,
    String? photographer,
    List<String>? tags,
    bool? isCollected,
    String? albumId,
    String? folderId,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      photographer: photographer ?? this.photographer,
      tags: tags ?? this.tags,
      isCollected: isCollected ?? this.isCollected,
      albumId: albumId ?? this.albumId,
      folderId: folderId ?? this.folderId,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }

  // Helper methods
  bool get isDeleted => deletedAt != null;
}
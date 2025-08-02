import '../models/media_item.dart';

class PhotoAlbum {
  final String id;
  final String title;
  final String? description;
  final MediaCategory category;
  final String? coverPhotoId;
  final String? photographer;
  final List<String> tags;
  final DateTime createdAt;
  final String? createdBy;
  final List<MediaItem> photos;
  final String? coverPhotoUrl;
  final String? folderPath; // Storage folder path (e.g., "Sunday Worship/July Week 4")

  PhotoAlbum({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.coverPhotoId,
    this.photographer,
    this.tags = const [],
    required this.createdAt,
    this.createdBy,
    this.photos = const [],
    this.coverPhotoUrl,
    this.folderPath,
  });

  factory PhotoAlbum.fromJson(Map<String, dynamic> json, {List<MediaItem> photos = const []}) {
    return PhotoAlbum(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: MediaCategory.fromString(json['category'] as String? ?? 'general'),
      coverPhotoId: json['cover_photo_id'] as String?,
      photographer: json['photographer'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String?,
      photos: photos,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      folderPath: json['folder_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'cover_photo_id': coverPhotoId,
      'photographer': photographer,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'folder_path': folderPath,
    };
  }

  PhotoAlbum copyWith({
    String? id,
    String? title,
    String? description,
    MediaCategory? category,
    String? coverPhotoId,
    String? photographer,
    List<String>? tags,
    DateTime? createdAt,
    String? createdBy,
    List<MediaItem>? photos,
    String? coverPhotoUrl,
    String? folderPath,
  }) {
    return PhotoAlbum(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      coverPhotoId: coverPhotoId ?? this.coverPhotoId,
      photographer: photographer ?? this.photographer,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      photos: photos ?? this.photos,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      folderPath: folderPath ?? this.folderPath,
    );
  }

  // Get cover photo URL - either from specified cover or first photo
  String? get effectiveCoverPhotoUrl {
    if (coverPhotoUrl != null) return coverPhotoUrl;
    if (photos.isNotEmpty) {
      final coverPhoto = coverPhotoId != null 
          ? photos.firstWhere((p) => p.id == coverPhotoId, orElse: () => photos.first)
          : photos.first;
      return coverPhoto.thumbnailUrl ?? coverPhoto.url;
    }
    return null;
  }

  int get photoCount => photos.length;
}
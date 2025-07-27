enum MediaType {
  photo,
  video,
  audio,
}

enum MediaCategory {
  worship,
  sermon,
  fellowship,
  outreach,
  youth,
  children,
  general,
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
  });

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
    );
  }
}
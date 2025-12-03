enum UpdateType {
  announcement,
  news,
  prayer,
  celebration,
  urgent;

  static UpdateType fromString(String value) {
    switch (value) {
      case 'announcement':
        return UpdateType.announcement;
      case 'news':
        return UpdateType.news;
      case 'prayer':
        return UpdateType.prayer;
      case 'celebration':
        return UpdateType.celebration;
      case 'urgent':
        return UpdateType.urgent;
      default:
        return UpdateType.announcement;
    }
  }
}

class Update {
  final String id;
  final String title;
  final String content;
  final UpdateType type;
  final DateTime createdAt;
  final String author;
  final bool isPinned;
  final String? imageUrl;
  final List<String> tags;

  Update({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.author,
    this.isPinned = false,
    this.imageUrl,
    this.tags = const [],
  });

  factory Update.fromJson(Map<String, dynamic> json) {
    return Update(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: UpdateType.fromString(json['type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      author: json['author_name'] as String,
      isPinned: json['is_pinned'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'author_name': author,
      'is_pinned': isPinned,
      'image_url': imageUrl,
      'tags': tags,
    };
  }

  Update copyWith({
    String? id,
    String? title,
    String? content,
    UpdateType? type,
    DateTime? createdAt,
    String? author,
    bool? isPinned,
    String? imageUrl,
    List<String>? tags,
  }) {
    return Update(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
      isPinned: isPinned ?? this.isPinned,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
    );
  }
}

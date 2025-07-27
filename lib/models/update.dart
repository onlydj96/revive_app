enum UpdateType {
  announcement,
  news,
  prayer,
  celebration,
  urgent,
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
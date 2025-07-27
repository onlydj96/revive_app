class BulletinItem {
  final String id;
  final String title;
  final String content;
  final int order;

  BulletinItem({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
  });
}

class Bulletin {
  final String id;
  final DateTime weekOf;
  final String theme;
  final List<BulletinItem> items;
  final String? bannerImageUrl;

  Bulletin({
    required this.id,
    required this.weekOf,
    required this.theme,
    required this.items,
    this.bannerImageUrl,
  });

  Bulletin copyWith({
    String? id,
    DateTime? weekOf,
    String? theme,
    List<BulletinItem>? items,
    String? bannerImageUrl,
  }) {
    return Bulletin(
      id: id ?? this.id,
      weekOf: weekOf ?? this.weekOf,
      theme: theme ?? this.theme,
      items: items ?? this.items,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
    );
  }
}
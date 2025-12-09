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

  factory BulletinItem.fromJson(Map<String, dynamic> json) {
    return BulletinItem(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      order: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'display_order': order,
    };
  }

  BulletinItem copyWith({
    String? id,
    String? title,
    String? content,
    int? order,
  }) {
    return BulletinItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      order: order ?? this.order,
    );
  }
}

class WorshipScheduleItem {
  final String id;
  final String time;
  final String activity;
  final String? leader;
  final int order;
  final String? linkedBulletinItemId; // Link to corresponding bulletin item

  WorshipScheduleItem({
    String? id,
    required this.time,
    required this.activity,
    this.leader,
    this.order = 0,
    this.linkedBulletinItemId,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory WorshipScheduleItem.fromJson(Map<String, dynamic> json) {
    return WorshipScheduleItem(
      id: json['id'] as String,
      time: json['time'] as String,
      activity: json['activity'] as String,
      leader: json['leader'] as String?,
      order: json['display_order'] as int? ?? 0,
      linkedBulletinItemId: json['linked_bulletin_item_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'activity': activity,
      'leader': leader,
      'display_order': order,
      'linked_bulletin_item_id': linkedBulletinItemId,
    };
  }

  WorshipScheduleItem copyWith({
    String? id,
    String? time,
    String? activity,
    String? leader,
    int? order,
    String? linkedBulletinItemId,
  }) {
    return WorshipScheduleItem(
      id: id ?? this.id,
      time: time ?? this.time,
      activity: activity ?? this.activity,
      leader: leader ?? this.leader,
      order: order ?? this.order,
      linkedBulletinItemId: linkedBulletinItemId ?? this.linkedBulletinItemId,
    );
  }
}

class Bulletin {
  final String id;
  final DateTime weekOf;
  final String theme;
  final List<BulletinItem> items;
  final List<WorshipScheduleItem> schedule;
  final String? bannerImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bulletin({
    required this.id,
    required this.weekOf,
    required this.theme,
    required this.items,
    required this.schedule,
    this.bannerImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Bulletin.fromJson(Map<String, dynamic> json, {
    List<BulletinItem>? items,
    List<WorshipScheduleItem>? schedule,
  }) {
    return Bulletin(
      id: json['id'] as String,
      weekOf: DateTime.parse(json['week_of'] as String),
      theme: json['theme'] as String? ?? '',
      items: items ?? [],
      schedule: schedule ?? [],
      bannerImageUrl: json['banner_image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week_of': weekOf.toIso8601String(),
      'theme': theme,
      'banner_image_url': bannerImageUrl,
      'title': theme, // For backward compatibility with existing schema
    };
  }

  Bulletin copyWith({
    String? id,
    DateTime? weekOf,
    String? theme,
    List<BulletinItem>? items,
    List<WorshipScheduleItem>? schedule,
    String? bannerImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bulletin(
      id: id ?? this.id,
      weekOf: weekOf ?? this.weekOf,
      theme: theme ?? this.theme,
      items: items ?? this.items,
      schedule: schedule ?? this.schedule,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

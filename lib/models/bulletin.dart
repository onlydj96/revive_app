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

class WorshipScheduleItem {
  final String time;
  final String activity;
  final String? leader;

  WorshipScheduleItem({
    required this.time,
    required this.activity,
    this.leader,
  });
}

class Bulletin {
  final String id;
  final DateTime weekOf;
  final String theme;
  final List<BulletinItem> items;
  final List<WorshipScheduleItem> schedule;
  final String? bannerImageUrl;

  Bulletin({
    required this.id,
    required this.weekOf,
    required this.theme,
    required this.items,
    required this.schedule,
    this.bannerImageUrl,
  });

  Bulletin copyWith({
    String? id,
    DateTime? weekOf,
    String? theme,
    List<BulletinItem>? items,
    List<WorshipScheduleItem>? schedule,
    String? bannerImageUrl,
  }) {
    return Bulletin(
      id: id ?? this.id,
      weekOf: weekOf ?? this.weekOf,
      theme: theme ?? this.theme,
      items: items ?? this.items,
      schedule: schedule ?? this.schedule,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
    );
  }
}

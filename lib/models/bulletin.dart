/// 컨텐츠 타입 구분
enum BulletinItemType {
  general,    // 일반 텍스트 내용
  songList,   // 찬양 콘티 (곡 목록)
  scripture,  // 성경 말씀
  prayer,     // 기도
  announcement; // 광고

  static BulletinItemType fromString(String? value) {
    switch (value) {
      case 'song_list':
        return BulletinItemType.songList;
      case 'scripture':
        return BulletinItemType.scripture;
      case 'prayer':
        return BulletinItemType.prayer;
      case 'announcement':
        return BulletinItemType.announcement;
      default:
        return BulletinItemType.general;
    }
  }

  String toJson() {
    switch (this) {
      case BulletinItemType.songList:
        return 'song_list';
      case BulletinItemType.scripture:
        return 'scripture';
      case BulletinItemType.prayer:
        return 'prayer';
      case BulletinItemType.announcement:
        return 'announcement';
      default:
        return 'general';
    }
  }
}

/// 찬양 곡 정보
class SongItem {
  final String title;
  final String? key;      // 조 (예: G, C, D)
  final String? artist;   // 가수/작곡가
  final String? notes;    // 추가 메모

  SongItem({
    required this.title,
    this.key,
    this.artist,
    this.notes,
  });

  factory SongItem.fromJson(Map<String, dynamic> json) {
    return SongItem(
      title: json['title'] as String,
      key: json['key'] as String?,
      artist: json['artist'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (key != null) 'key': key,
      if (artist != null) 'artist': artist,
      if (notes != null) 'notes': notes,
    };
  }

  /// 문자열에서 곡 정보 파싱 (예: "주님의 사랑이 (G Key)" 또는 "1. 감사해요 - 찬양팀")
  factory SongItem.fromString(String text) {
    // 번호 제거 (1. 2. 등)
    String cleaned = text.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '');

    // 키 추출 (괄호 안의 Key 정보)
    String? key;
    final keyMatch = RegExp(r'\(([A-G][#b]?)\s*(?:Key|키)?\)').firstMatch(cleaned);
    if (keyMatch != null) {
      key = keyMatch.group(1);
      cleaned = cleaned.replaceFirst(keyMatch.group(0)!, '').trim();
    }

    // 아티스트 추출 (- 뒤의 내용)
    String? artist;
    final artistMatch = RegExp(r'\s*[-–]\s*(.+)$').firstMatch(cleaned);
    if (artistMatch != null) {
      artist = artistMatch.group(1)?.trim();
      cleaned = cleaned.replaceFirst(artistMatch.group(0)!, '').trim();
    }

    return SongItem(
      title: cleaned.trim(),
      key: key,
      artist: artist,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer(title);
    if (key != null) buffer.write(' ($key Key)');
    if (artist != null) buffer.write(' - $artist');
    return buffer.toString();
  }
}

class BulletinItem {
  final String id;
  final String title;
  final String content;
  final int order;
  final BulletinItemType type;
  final List<SongItem>? songs; // 찬양 콘티인 경우 곡 목록

  BulletinItem({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
    this.type = BulletinItemType.general,
    this.songs,
  });

  /// content에서 찬양 목록 자동 파싱
  List<SongItem> get parsedSongs {
    if (songs != null && songs!.isNotEmpty) return songs!;
    if (type != BulletinItemType.songList) return [];

    // content에서 줄바꿈으로 구분된 곡 목록 파싱
    final lines = content.split(RegExp(r'[\n\r]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return lines.map((line) => SongItem.fromString(line)).toList();
  }

  /// 찬양 콘티 여부 (타입 또는 제목 기반)
  bool get isSongList {
    if (type == BulletinItemType.songList) return true;
    // 제목으로 자동 감지
    final lowerTitle = title.toLowerCase();
    return lowerTitle.contains('worship') ||
           lowerTitle.contains('찬양') ||
           lowerTitle.contains('praise') ||
           lowerTitle.contains('song') ||
           lowerTitle.contains('콘티');
  }

  factory BulletinItem.fromJson(Map<String, dynamic> json) {
    final type = BulletinItemType.fromString(json['type'] as String?);
    List<SongItem>? songs;

    // songs 배열이 있으면 파싱
    if (json['songs'] != null) {
      songs = (json['songs'] as List)
          .map((s) => SongItem.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return BulletinItem(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      order: json['display_order'] as int? ?? 0,
      type: type,
      songs: songs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'display_order': order,
      'type': type.toJson(),
      if (songs != null) 'songs': songs!.map((s) => s.toJson()).toList(),
    };
  }

  BulletinItem copyWith({
    String? id,
    String? title,
    String? content,
    int? order,
    BulletinItemType? type,
    List<SongItem>? songs,
  }) {
    return BulletinItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      order: order ?? this.order,
      type: type ?? this.type,
      songs: songs ?? this.songs,
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

enum EventType {
  service,
  connectGroup,
  hangout,
  special,
  training;

  static EventType fromString(String value) {
    switch (value) {
      case 'service':
        return EventType.service;
      case 'connectGroup':
        return EventType.connectGroup;
      case 'hangout':
        return EventType.hangout;
      case 'special':
        return EventType.special;
      case 'training':
        return EventType.training;
      default:
        return EventType.service;
    }
  }

  String toJson() => name;
}

/// 반복 일정 타입
enum RecurrenceType {
  none,       // 반복 없음
  daily,      // 매일
  weekly,     // 매주
  biweekly,   // 2주마다
  monthly,    // 매월
  yearly;     // 매년

  static RecurrenceType fromString(String? value) {
    if (value == null) return RecurrenceType.none;
    switch (value) {
      case 'daily':
        return RecurrenceType.daily;
      case 'weekly':
        return RecurrenceType.weekly;
      case 'biweekly':
        return RecurrenceType.biweekly;
      case 'monthly':
        return RecurrenceType.monthly;
      case 'yearly':
        return RecurrenceType.yearly;
      default:
        return RecurrenceType.none;
    }
  }

  String toJson() => name;

  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return 'Does not repeat';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.biweekly:
        return 'Every 2 weeks';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
    }
  }

  String get displayNameKo {
    switch (this) {
      case RecurrenceType.none:
        return '반복 안함';
      case RecurrenceType.daily:
        return '매일';
      case RecurrenceType.weekly:
        return '매주';
      case RecurrenceType.biweekly:
        return '2주마다';
      case RecurrenceType.monthly:
        return '매월';
      case RecurrenceType.yearly:
        return '매년';
    }
  }
}

/// 반복 일정 설정
class RecurrenceRule {
  final RecurrenceType type;
  final int interval;           // 반복 간격 (예: 2주마다 = weekly with interval 2)
  final List<int>? daysOfWeek;  // 매주 반복 시 요일 (1=월, 7=일)
  final int? dayOfMonth;        // 매월 반복 시 날짜
  final DateTime? endDate;      // 반복 종료일 (null이면 무제한)
  final int? occurrences;       // 반복 횟수 (endDate 대신 사용)

  const RecurrenceRule({
    this.type = RecurrenceType.none,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.endDate,
    this.occurrences,
  });

  bool get isRecurring => type != RecurrenceType.none;

  RecurrenceRule copyWith({
    RecurrenceType? type,
    int? interval,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    DateTime? endDate,
    int? occurrences,
    bool clearEndDate = false,
    bool clearOccurrences = false,
  }) {
    return RecurrenceRule(
      type: type ?? this.type,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      occurrences: clearOccurrences ? null : (occurrences ?? this.occurrences),
    );
  }

  factory RecurrenceRule.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RecurrenceRule();
    return RecurrenceRule(
      type: RecurrenceType.fromString(json['type'] as String?),
      interval: json['interval'] as int? ?? 1,
      daysOfWeek: (json['days_of_week'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      dayOfMonth: json['day_of_month'] as int?,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      occurrences: json['occurrences'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'interval': interval,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      if (occurrences != null) 'occurrences': occurrences,
    };
  }

  /// 반복 규칙에 따른 다음 이벤트 날짜들 생성
  List<DateTime> generateOccurrences(DateTime startDate, {int maxCount = 52}) {
    if (type == RecurrenceType.none) return [startDate];

    final occurrencesList = <DateTime>[];
    final effectiveMaxCount = occurrences ?? maxCount;
    final effectiveEndDate = endDate ?? startDate.add(const Duration(days: 365));

    // For weekly/biweekly with multiple days
    if ((type == RecurrenceType.weekly || type == RecurrenceType.biweekly) &&
        daysOfWeek != null &&
        daysOfWeek!.isNotEmpty) {
      return _generateMultiDayOccurrences(
        startDate,
        effectiveMaxCount,
        effectiveEndDate,
      );
    }

    // Default single-day logic
    var currentDate = startDate;
    while (occurrencesList.length < effectiveMaxCount &&
        currentDate.isBefore(effectiveEndDate.add(const Duration(days: 1)))) {
      occurrencesList.add(currentDate);
      currentDate = _getNextOccurrence(currentDate);
    }

    return occurrencesList;
  }

  /// Generate occurrences for multiple days of week (weekly/biweekly)
  List<DateTime> _generateMultiDayOccurrences(
    DateTime startDate,
    int maxCount,
    DateTime effectiveEndDate,
  ) {
    final occurrencesList = <DateTime>[];
    final sortedDays = List<int>.from(daysOfWeek!)..sort();

    // Find the week start (Monday) for the startDate
    final weekStart = startDate.subtract(Duration(days: startDate.weekday - 1));
    var currentWeekStart = weekStart;

    // Interval in weeks (biweekly = 2)
    final weekInterval = type == RecurrenceType.biweekly ? 2 : interval;

    while (occurrencesList.length < maxCount &&
        currentWeekStart.isBefore(effectiveEndDate.add(const Duration(days: 7)))) {
      for (final dayOfWeek in sortedDays) {
        final occurrence = currentWeekStart.add(Duration(days: dayOfWeek - 1));
        final occurrenceWithTime = DateTime(
          occurrence.year,
          occurrence.month,
          occurrence.day,
          startDate.hour,
          startDate.minute,
        );

        // Only add if after or equal to startDate and before endDate
        if (!occurrenceWithTime.isBefore(startDate) &&
            occurrenceWithTime.isBefore(effectiveEndDate.add(const Duration(days: 1))) &&
            occurrencesList.length < maxCount) {
          occurrencesList.add(occurrenceWithTime);
        }
      }
      currentWeekStart = currentWeekStart.add(Duration(days: 7 * weekInterval));
    }

    return occurrencesList;
  }

  DateTime _getNextOccurrence(DateTime current) {
    switch (type) {
      case RecurrenceType.none:
        return current;
      case RecurrenceType.daily:
        return current.add(Duration(days: interval));
      case RecurrenceType.weekly:
        return current.add(Duration(days: 7 * interval));
      case RecurrenceType.biweekly:
        return current.add(const Duration(days: 14));
      case RecurrenceType.monthly:
        return DateTime(
          current.year,
          current.month + interval,
          dayOfMonth ?? current.day,
          current.hour,
          current.minute,
        );
      case RecurrenceType.yearly:
        return DateTime(
          current.year + interval,
          current.month,
          current.day,
          current.hour,
          current.minute,
        );
    }
  }

  String getDescription(DateTime startDate) {
    switch (type) {
      case RecurrenceType.none:
        return '';
      case RecurrenceType.daily:
        return interval == 1 ? 'Every day' : 'Every $interval days';
      case RecurrenceType.weekly:
        final dayNames = _getDayNames();
        if (interval == 1) {
          return 'Every $dayNames';
        }
        return 'Every $interval weeks on $dayNames';
      case RecurrenceType.biweekly:
        final dayNames = _getDayNames();
        return 'Every 2 weeks on $dayNames';
      case RecurrenceType.monthly:
        return interval == 1
            ? 'Monthly on day ${startDate.day}'
            : 'Every $interval months on day ${startDate.day}';
      case RecurrenceType.yearly:
        return 'Yearly on ${_getMonthName(startDate.month)} ${startDate.day}';
    }
  }

  /// Get formatted day names from daysOfWeek list
  String _getDayNames() {
    if (daysOfWeek == null || daysOfWeek!.isEmpty) {
      return '';
    }
    final sortedDays = List<int>.from(daysOfWeek!)..sort();
    final names = sortedDays.map((d) => _getDayName(d)).toList();

    if (names.length == 1) {
      return names.first;
    } else if (names.length == 2) {
      return '${names[0]} & ${names[1]}';
    } else {
      final last = names.removeLast();
      return '${names.join(', ')} & $last';
    }
  }

  String _getDayName(int weekday) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday];
  }

  String _getMonthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final EventType type;
  final String? imageUrl;
  final bool isHighlighted;
  final bool requiresSignup;
  final int? maxParticipants;
  final int currentParticipants;
  final RecurrenceRule recurrence;
  final String? parentEventId;  // 반복 이벤트의 원본 ID
  final int? instanceIndex;     // 반복 이벤트에서의 인덱스

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.type,
    this.imageUrl,
    this.isHighlighted = false,
    this.requiresSignup = false,
    this.maxParticipants,
    this.currentParticipants = 0,
    this.recurrence = const RecurrenceRule(),
    this.parentEventId,
    this.instanceIndex,
  });

  bool get isRecurring => recurrence.isRecurring;
  bool get isRecurrenceInstance => parentEventId != null;

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    EventType? type,
    String? imageUrl,
    bool? isHighlighted,
    bool? requiresSignup,
    int? maxParticipants,
    int? currentParticipants,
    RecurrenceRule? recurrence,
    String? parentEventId,
    int? instanceIndex,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      requiresSignup: requiresSignup ?? this.requiresSignup,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      recurrence: recurrence ?? this.recurrence,
      parentEventId: parentEventId ?? this.parentEventId,
      instanceIndex: instanceIndex ?? this.instanceIndex,
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      location: json['location'] as String,
      type: EventType.fromString(json['type'] as String),
      imageUrl: json['image_url'] as String?,
      isHighlighted: json['is_highlighted'] as bool? ?? false,
      requiresSignup: json['requires_signup'] as bool? ?? false,
      maxParticipants: json['max_participants'] as int?,
      currentParticipants: json['current_participants'] as int? ?? 0,
      recurrence: RecurrenceRule.fromJson(
        json['recurrence'] as Map<String, dynamic>?,
      ),
      parentEventId: json['parent_event_id'] as String?,
      instanceIndex: json['instance_index'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'type': type.toJson(),
      'image_url': imageUrl,
      'is_highlighted': isHighlighted,
      'requires_signup': requiresSignup,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      if (recurrence.isRecurring) 'recurrence': recurrence.toJson(),
      if (parentEventId != null) 'parent_event_id': parentEventId,
      if (instanceIndex != null) 'instance_index': instanceIndex,
    };
  }

  /// 반복 일정 인스턴스 생성
  List<Event> generateRecurrenceInstances({int maxCount = 52}) {
    if (!isRecurring) return [this];

    final duration = endTime.difference(startTime);
    final occurrences = recurrence.generateOccurrences(startTime, maxCount: maxCount);

    return occurrences.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      return Event(
        id: index == 0 ? id : '${id}_$index',
        title: title,
        description: description,
        startTime: date,
        endTime: date.add(duration),
        location: location,
        type: type,
        imageUrl: imageUrl,
        isHighlighted: isHighlighted,
        requiresSignup: requiresSignup,
        maxParticipants: maxParticipants,
        currentParticipants: index == 0 ? currentParticipants : 0,
        recurrence: index == 0 ? recurrence : const RecurrenceRule(),
        parentEventId: index == 0 ? null : id,
        instanceIndex: index,
      );
    }).toList();
  }
}

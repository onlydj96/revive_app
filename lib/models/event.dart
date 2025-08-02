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
  });

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
    };
  }
}
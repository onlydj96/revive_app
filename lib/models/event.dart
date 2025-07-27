enum EventType {
  service,
  connectGroup,
  hangout,
  special,
  training,
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
}
enum TeamType {
  connectGroup,
  hangout,
}

class Team {
  final String id;
  final String name;
  final String description;
  final TeamType type;
  final String? imageUrl;
  final String leader;
  final DateTime? meetingTime;
  final String? meetingLocation;
  final bool requiresApplication;
  final int? maxMembers;
  final int currentMembers;
  final List<String> requirements;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.imageUrl,
    required this.leader,
    this.meetingTime,
    this.meetingLocation,
    this.requiresApplication = false,
    this.maxMembers,
    this.currentMembers = 0,
    this.requirements = const [],
  });

  Team copyWith({
    String? id,
    String? name,
    String? description,
    TeamType? type,
    String? imageUrl,
    String? leader,
    DateTime? meetingTime,
    String? meetingLocation,
    bool? requiresApplication,
    int? maxMembers,
    int? currentMembers,
    List<String>? requirements,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      leader: leader ?? this.leader,
      meetingTime: meetingTime ?? this.meetingTime,
      meetingLocation: meetingLocation ?? this.meetingLocation,
      requiresApplication: requiresApplication ?? this.requiresApplication,
      maxMembers: maxMembers ?? this.maxMembers,
      currentMembers: currentMembers ?? this.currentMembers,
      requirements: requirements ?? this.requirements,
    );
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'] == 'connectGroup' ? TeamType.connectGroup : TeamType.hangout,
      imageUrl: json['image_url'],
      leader: json['leader'],
      meetingTime: json['meeting_time'] != null ? DateTime.parse(json['meeting_time']) : null,
      meetingLocation: json['meeting_location'],
      requiresApplication: json['requires_application'] ?? false,
      maxMembers: json['max_members'],
      currentMembers: json['current_members'] ?? 0,
      requirements: json['requirements'] != null ? List<String>.from(json['requirements']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type == TeamType.connectGroup ? 'connectGroup' : 'hangout',
      'image_url': imageUrl,
      'leader': leader,
      'meeting_time': meetingTime?.toIso8601String(),
      'meeting_location': meetingLocation,
      'requires_application': requiresApplication,
      'max_members': maxMembers,
      'current_members': currentMembers,
      'requirements': requirements,
    };
  }
}
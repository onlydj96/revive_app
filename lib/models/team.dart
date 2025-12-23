import '../utils/logger.dart';

enum TeamType {
  connectGroup,
  hangout,
}

enum TeamCategory {
  worship,
  outreach,
  youth,
  children,
  admin,
  fellowship,
}

class Team {
  static final _logger = Logger('Team');

  final String id;
  final String name;
  final String description;
  final TeamType type;
  final TeamCategory category;
  final String? imageUrl;
  final String? leaderId;
  final String leader;
  final DateTime? meetingTime;
  final String? meetingLocation;
  final String? contactInfo;
  final bool requiresApplication;
  final bool isActive;
  final int? maxMembers;
  final int currentMembers;
  final List<String> requirements;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    this.imageUrl,
    this.leaderId,
    required this.leader,
    this.meetingTime,
    this.meetingLocation,
    this.contactInfo,
    this.requiresApplication = false,
    this.isActive = true,
    this.maxMembers,
    this.currentMembers = 0,
    this.requirements = const [],
  });

  Team copyWith({
    String? id,
    String? name,
    String? description,
    TeamType? type,
    TeamCategory? category,
    String? imageUrl,
    String? leaderId,
    String? leader,
    DateTime? meetingTime,
    String? meetingLocation,
    String? contactInfo,
    bool? requiresApplication,
    bool? isActive,
    int? maxMembers,
    int? currentMembers,
    List<String>? requirements,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      leaderId: leaderId ?? this.leaderId,
      leader: leader ?? this.leader,
      meetingTime: meetingTime ?? this.meetingTime,
      meetingLocation: meetingLocation ?? this.meetingLocation,
      contactInfo: contactInfo ?? this.contactInfo,
      requiresApplication: requiresApplication ?? this.requiresApplication,
      isActive: isActive ?? this.isActive,
      maxMembers: maxMembers ?? this.maxMembers,
      currentMembers: currentMembers ?? this.currentMembers,
      requirements: requirements ?? this.requirements,
    );
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    // Parse meetingTime with error handling
    // DB stores TEXT format which can be either ISO 8601 date or human-readable text
    DateTime? parsedMeetingTime;
    if (json['meeting_schedule'] != null) {
      try {
        parsedMeetingTime = DateTime.parse(json['meeting_schedule'] as String);
      } catch (e) {
        // If parsing fails (e.g., "Wednesdays 7:00 PM"), leave as null
        // The text value is stored in DB but not used in the current UI
        _logger.warning('Could not parse meeting_schedule as DateTime: ${json['meeting_schedule']}');
        parsedMeetingTime = null;
      }
    }

    return Team(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] == 'connect_group'
          ? TeamType.connectGroup
          : TeamType.hangout,
      category: _categoryFromString(json['category'] as String? ?? 'fellowship'),
      imageUrl: json['image_url'] as String?,
      leaderId: json['leader_id'] as String?,
      leader: json['leader_name'] as String? ?? '',
      meetingTime: parsedMeetingTime,
      meetingLocation: json['meeting_location'] as String?,
      contactInfo: json['contact_info'] as String?,
      requiresApplication: json['application_required'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      maxMembers: json['max_members'] as int?,
      currentMembers: json['current_members'] as int? ?? 0,
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'] as List)
          : [],
    );
  }

  static TeamCategory _categoryFromString(String category) {
    switch (category) {
      case 'worship':
        return TeamCategory.worship;
      case 'outreach':
        return TeamCategory.outreach;
      case 'youth':
        return TeamCategory.youth;
      case 'children':
        return TeamCategory.children;
      case 'admin':
        return TeamCategory.admin;
      case 'fellowship':
      default:
        return TeamCategory.fellowship;
    }
  }

  static String _categoryToString(TeamCategory category) {
    switch (category) {
      case TeamCategory.worship:
        return 'worship';
      case TeamCategory.outreach:
        return 'outreach';
      case TeamCategory.youth:
        return 'youth';
      case TeamCategory.children:
        return 'children';
      case TeamCategory.admin:
        return 'admin';
      case TeamCategory.fellowship:
        return 'fellowship';
    }
  }

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'description': description,
      'type': type == TeamType.connectGroup ? 'connect_group' : 'hangout',
      'category': _categoryToString(category),
      'image_url': imageUrl,
      'leader_id': leaderId,
      'leader_name': leader,
      'meeting_schedule': meetingTime?.toIso8601String(),
      'meeting_location': meetingLocation,
      'contact_info': contactInfo,
      'application_required': requiresApplication,
      'is_active': isActive,
      'max_members': maxMembers,
      'current_members': currentMembers,
      // 'requirements' removed - not in DB schema
    };

    // Only include id if it's not empty (for updates, not inserts)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    return json;
  }
}

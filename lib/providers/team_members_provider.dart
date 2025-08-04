import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';

// Team member model
class TeamMember {
  final String id;
  final String teamId;
  final String userId;
  final String userName;
  final String? userEmail;
  final String? userAvatar;
  final DateTime joinedAt;
  final String status; // 'pending', 'approved', 'member'

  const TeamMember({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.userName,
    this.userEmail,
    this.userAvatar,
    required this.joinedAt,
    required this.status,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'],
      teamId: json['team_id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? json['users']?['name'] ?? 'Unknown User',
      userEmail: json['user_email'] ?? json['users']?['email'],
      userAvatar: json['user_avatar'] ?? json['users']?['avatar_url'],
      joinedAt: DateTime.parse(json['applied_at'] ?? json['joined_at'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'member',
    );
  }
}

// Provider to get team members for a specific team
final teamMembersProvider = FutureProvider.family<List<TeamMember>, String>((ref, teamId) async {
  try {
    // Get team applications (pending members)
    final applicationsResponse = await SupabaseService.from('team_applications')
        .select('''
          id,
          team_id,
          user_id,
          status,
          applied_at,
          users:user_id (
            id,
            email,
            raw_user_meta_data
          )
        ''')
        .eq('team_id', teamId)
        .eq('status', 'pending');

    final members = <TeamMember>[];
    
    // Process applications
    for (final app in applicationsResponse as List) {
      final userData = app['users'];
      final userMeta = userData?['raw_user_meta_data'] as Map<String, dynamic>?;
      
      members.add(TeamMember(
        id: app['id'],
        teamId: app['team_id'],
        userId: app['user_id'],
        userName: userMeta?['full_name'] ?? userMeta?['name'] ?? userData?['email']?.split('@')[0] ?? 'Unknown User',
        userEmail: userData?['email'],
        userAvatar: userMeta?['avatar_url'],
        joinedAt: DateTime.parse(app['applied_at']),
        status: app['status'],
      ));
    }

    return members;
  } catch (e) {
    print('Error loading team members: $e');
    return [];
  }
});

// Provider to check if current user is a member of a team
final isTeamMemberProvider = FutureProvider.family<bool, String>((ref, teamId) async {
  try {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return false;

    final response = await SupabaseService.from('team_applications')
        .select('id')
        .eq('team_id', teamId)
        .eq('user_id', userId)
        .eq('status', 'pending');

    return (response as List).isNotEmpty;
  } catch (e) {
    print('Error checking team membership: $e');
    return false;
  }
});
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
      joinedAt: DateTime.parse(json['applied_at'] ??
          json['join_date'] ??
          json['joined_at'] ??
          DateTime.now().toIso8601String()),
      status: json['status'] ?? 'member',
    );
  }
}

// Provider to get team members for a specific team
final teamMembersProvider =
    FutureProvider.family<List<TeamMember>, String>((ref, teamId) async {
  try {
    // Get actual team members from team_memberships (active members)
    final membershipsResponse =
        await SupabaseService.from('team_memberships').select('''
          id,
          team_id,
          user_id,
          user_name,
          role,
          status,
          join_date
        ''').eq('team_id', teamId).eq('status', 'active');

    final members = <TeamMember>[];

    // Process memberships
    for (final membership in membershipsResponse as List) {
      members.add(TeamMember(
        id: membership['id'],
        teamId: membership['team_id'],
        userId: membership['user_id'],
        userName: membership['user_name'] ?? 'Unknown User',
        userEmail: null, // Not fetched from team_memberships
        userAvatar: null, // Not fetched from team_memberships
        joinedAt: DateTime.parse(membership['join_date'] ?? DateTime.now().toIso8601String()),
        status: membership['status'] ?? 'active',
      ));
    }

    return members;
  } catch (e) {
    print('Error loading team members: $e');
    return [];
  }
});

// Provider to check if current user is a member of a team
class TeamMembershipNotifier extends StateNotifier<Map<String, bool>> {
  TeamMembershipNotifier() : super({});

  Future<void> checkMembership(String teamId) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        state = {...state, teamId: false};
        return;
      }

      // Optimize: Run both queries in parallel instead of sequentially
      final results = await Future.wait([
        SupabaseService.from('team_memberships')
            .select('id')
            .eq('team_id', teamId)
            .eq('user_id', userId)
            .eq('status', 'active'),
        SupabaseService.from('team_applications')
            .select('id')
            .eq('team_id', teamId)
            .eq('user_id', userId)
            .eq('status', 'pending'),
      ]);

      final membershipResponse = results[0] as List;
      final applicationResponse = results[1] as List;

      // User is a member if they have active membership OR pending application
      final isMember = membershipResponse.isNotEmpty || applicationResponse.isNotEmpty;
      state = {...state, teamId: isMember};
    } catch (e) {
      print('Error checking team membership: $e');
      state = {...state, teamId: false};
    }
  }

  void invalidateMembership(String teamId) {
    final newState = Map<String, bool>.from(state);
    newState.remove(teamId);
    state = newState;
    checkMembership(teamId);
  }
}

final teamMembershipProvider =
    StateNotifierProvider<TeamMembershipNotifier, Map<String, bool>>((ref) {
  return TeamMembershipNotifier();
});

// Helper provider to get membership status for a specific team
final isTeamMemberProvider = Provider.family<bool, String>((ref, teamId) {
  final memberships = ref.watch(teamMembershipProvider);

  // If not checked yet, trigger check
  if (!memberships.containsKey(teamId)) {
    Future.microtask(() {
      ref.read(teamMembershipProvider.notifier).checkMembership(teamId);
    });
    return false;
  }

  return memberships[teamId] ?? false;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';

final _logger = Logger('TeamMembersProvider');

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
      joinedAt: DateTime.parse(json['join_date'] ??
          json['applied_at'] ??
          DateTime.now().toIso8601String()),
      status: json['status'] ?? 'member',
    );
  }
}

// Provider to get team members for a specific team
final teamMembersProvider =
    FutureProvider.family<List<TeamMember>, String>((ref, teamId) async {
  try {
    // Get team info to determine type
    final teamResponse = await SupabaseService.from('teams')
        .select('type')
        .eq('id', teamId)
        .maybeSingle();

    if (teamResponse == null) {
      return [];
    }

    final teamType = teamResponse['type'] == 'hangout'
        ? TeamType.hangout
        : TeamType.connectGroup;

    final members = <TeamMember>[];

    if (teamType == TeamType.hangout) {
      // Get hangout members from hangout_joins
      final hangoutResponse =
          await SupabaseService.from('hangout_joins').select('''
            id,
            team_id,
            user_id,
            user_name,
            status,
            joined_at
          ''').eq('team_id', teamId).eq('status', 'active');

      // Process hangout joins
      for (final join in hangoutResponse as List) {
        members.add(TeamMember(
          id: join['id'],
          teamId: join['team_id'],
          userId: join['user_id'],
          userName: join['user_name'] ?? 'Unknown User',
          userEmail: null,
          userAvatar: null,
          joinedAt: DateTime.parse(join['joined_at'] ?? DateTime.now().toIso8601String()),
          status: join['status'] ?? 'active',
        ));
      }
    } else {
      // Get connect group members from team_memberships (approved members)
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

      // Process approved memberships
      for (final membership in membershipsResponse as List) {
        members.add(TeamMember(
          id: membership['id'],
          teamId: membership['team_id'],
          userId: membership['user_id'],
          userName: membership['user_name'] ?? 'Unknown User',
          userEmail: null,
          userAvatar: null,
          joinedAt: DateTime.parse(membership['join_date'] ?? DateTime.now().toIso8601String()),
          status: membership['status'] ?? 'active',
        ));
      }

      // Also get pending applications for Connect Groups
      final applicationsResponse =
          await SupabaseService.from('team_applications').select('''
            id,
            team_id,
            user_id,
            user_name,
            user_email,
            status,
            applied_at
          ''').eq('team_id', teamId).eq('status', 'pending');

      // Process pending applications
      for (final application in applicationsResponse as List) {
        members.add(TeamMember(
          id: application['id'],
          teamId: application['team_id'],
          userId: application['user_id'],
          userName: application['user_name'] ?? 'Unknown User',
          userEmail: application['user_email'],
          userAvatar: null,
          joinedAt: DateTime.parse(application['applied_at'] ?? DateTime.now().toIso8601String()),
          status: 'pending', // Mark as pending for UI
        ));
      }
    }

    return members;
  } catch (e) {
    _logger.debug('Error loading team members: $e');
    return [];
  }
});

// Provider to check if current user is a member of a team
class TeamMembershipNotifier extends StateNotifier<Map<String, bool>> {
  TeamMembershipNotifier() : super({});

  Future<void> checkMembership(String teamId, {TeamType? teamType}) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        state = {...state, teamId: false};
        return;
      }

      bool isMember = false;

      // Determine team type if not provided
      if (teamType == null) {
        final teamResponse = await SupabaseService.from('teams')
            .select('type')
            .eq('id', teamId)
            .maybeSingle();

        if (teamResponse == null) {
          state = {...state, teamId: false};
          return;
        }

        teamType = teamResponse['type'] == 'hangout'
            ? TeamType.hangout
            : TeamType.connectGroup;
      }

      // Check appropriate table based on team type
      if (teamType == TeamType.hangout) {
        // Check hangout_joins for hangouts
        final hangoutResponse = await SupabaseService.from('hangout_joins')
            .select('id')
            .eq('team_id', teamId)
            .eq('user_id', userId)
            .eq('status', 'active');

        isMember = (hangoutResponse as List).isNotEmpty;
      } else {
        // Check team_memberships for connect groups
        final membershipResponse = await SupabaseService.from('team_memberships')
            .select('id')
            .eq('team_id', teamId)
            .eq('user_id', userId)
            .eq('status', 'active');

        isMember = (membershipResponse as List).isNotEmpty;
      }

      state = {...state, teamId: isMember};
    } catch (e) {
      _logger.debug('Error checking team membership: $e');
      state = {...state, teamId: false};
    }
  }

  Future<void> invalidateMembership(String teamId) async {
    final newState = Map<String, bool>.from(state);
    newState.remove(teamId);
    state = newState;
    await checkMembership(teamId);
  }

  // Optimistic update: Set membership status immediately without DB check
  void setMembershipOptimistic(String teamId, bool isMember) {
    _logger.debug('🔵 OPTIMISTIC UPDATE: teamId=$teamId, isMember=$isMember');
    _logger.debug('🔵 State BEFORE: ${state[teamId]}');
    state = {...state, teamId: isMember};
    _logger.debug('🔵 State AFTER: ${state[teamId]}');
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

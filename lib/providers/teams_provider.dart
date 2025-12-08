import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';
import 'team_members_provider.dart';

final _logger = Logger('TeamsProvider');

final teamsProvider = StateNotifierProvider<TeamsNotifier, List<Team>>((ref) {
  return TeamsNotifier(ref);
});

final connectGroupsProvider = Provider<List<Team>>((ref) {
  final teams = ref.watch(teamsProvider);
  return teams.where((team) => team.type == TeamType.connectGroup).toList();
});

final hangoutsProvider = Provider<List<Team>>((ref) {
  final teams = ref.watch(teamsProvider);
  return teams.where((team) => team.type == TeamType.hangout).toList();
});

class TeamsNotifier extends StateNotifier<List<Team>> {
  final Ref ref;
  final Set<String> _loadingTeams = {};

  TeamsNotifier(this.ref) : super([]) {
    loadTeams();
  }

  bool isLoading(String teamId) => _loadingTeams.contains(teamId);

  Future<void> loadTeams() async {
    try {
      final response =
          await SupabaseService.from('teams').select().order('created_at');

      final teams = (response as List)
          .map((teamData) => Team.fromJson(teamData))
          .toList();

      state = teams;
    } catch (e) {
      _logger.error('Errorloading teams: $e');
      state = [];
    }
  }

  Future<void> joinTeam(String teamId) async {
    _logger.debug('🟢 joinTeam START: teamId=$teamId');

    // Prevent duplicate requests
    if (_loadingTeams.contains(teamId)) {
      _logger.debug('⚠️ joinTeam BLOCKED: Already loading');
      return;
    }

    _loadingTeams.add(teamId);

    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final team = state.firstWhere((team) => team.id == teamId);

      // OPTIMISTIC UPDATE: Immediately update UI state
      _logger.debug('🟢 joinTeam: Calling setMembershipOptimistic(true)');
      ref.read(teamMembershipProvider.notifier).setMembershipOptimistic(teamId, true);

      // Get user name from metadata
      final userMeta = SupabaseService.currentUser?.userMetadata;
      final userName = userMeta?['full_name'] ??
                      userMeta?['name'] ??
                      SupabaseService.currentUser?.email?.split('@')[0] ??
                      'Unknown User';

      // Use upsert to prevent race conditions - database will handle uniqueness
      // This is safer than check-then-insert pattern
      final result = await SupabaseService.from('team_memberships')
          .upsert({
            'team_id': teamId,
            'user_id': userId,
            'user_name': userName,
            'role': 'member',
            'status': 'active',
            'join_date': DateTime.now().toIso8601String(),
          },
          onConflict: 'team_id,user_id')
          .select()
          .maybeSingle();

      // Only increment if this was a new insertion (not an update)
      if (result != null && result['join_date'] != null) {
        final joinDate = DateTime.parse(result['join_date']);
        final now = DateTime.now();
        final isNewMember = now.difference(joinDate).inSeconds < 5;

        if (isNewMember) {
          // Increment member count atomically
          final updatedTeam =
              team.copyWith(currentMembers: team.currentMembers + 1);

          await SupabaseService.from('teams').update(
              {'current_members': updatedTeam.currentMembers}).eq('id', teamId);

          state = state.map((team) {
            return team.id == teamId ? updatedTeam : team;
          }).toList();
        }
      }

      _logger.debug('🟢 joinTeam SUCCESS');
    } catch (e) {
      _logger.error('❌joinTeam ERROR: $e');
      // ROLLBACK: Revert optimistic update on failure
      ref.read(teamMembershipProvider.notifier).setMembershipOptimistic(teamId, false);
      rethrow;
    } finally {
      _loadingTeams.remove(teamId);
      _logger.debug('🟢 joinTeam END: Loading removed');
    }
  }

  Future<void> leaveTeam(String teamId) async {
    _logger.debug('🔴 leaveTeam START: teamId=$teamId');

    // Prevent duplicate requests
    if (_loadingTeams.contains(teamId)) {
      _logger.debug('⚠️ leaveTeam BLOCKED: Already loading');
      return;
    }

    _loadingTeams.add(teamId);

    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final team = state.firstWhere((team) => team.id == teamId);

      // OPTIMISTIC UPDATE: Immediately update UI state
      _logger.debug('🔴 leaveTeam: Calling setMembershipOptimistic(false)');
      ref.read(teamMembershipProvider.notifier).setMembershipOptimistic(teamId, false);

      // Remove user from team_memberships
      await SupabaseService.from('team_memberships')
          .delete()
          .eq('team_id', teamId)
          .eq('user_id', userId);

      // Decrement member count
      if (team.currentMembers > 0) {
        final updatedTeam =
            team.copyWith(currentMembers: team.currentMembers - 1);

        await SupabaseService.from('teams').update(
            {'current_members': updatedTeam.currentMembers}).eq('id', teamId);

        state = state.map((team) {
          return team.id == teamId ? updatedTeam : team;
        }).toList();
      }

      _logger.debug('🔴 leaveTeam SUCCESS');
    } catch (e) {
      _logger.error('❌leaveTeam ERROR: $e');
      // ROLLBACK: Revert optimistic update on failure
      ref.read(teamMembershipProvider.notifier).setMembershipOptimistic(teamId, true);
      rethrow;
    } finally {
      _loadingTeams.remove(teamId);
      _logger.debug('🔴 leaveTeam END: Loading removed');
    }
  }

  Future<void> addTeam(Team team) async {
    try {
      await SupabaseService.from('teams').insert(team.toJson());
      await loadTeams(); // Reload to get the team with server-generated id
    } catch (e) {
      _logger.error('Erroradding team: $e');
    }
  }

  Future<void> updateTeam(Team updatedTeam) async {
    try {
      await SupabaseService.from('teams')
          .update(updatedTeam.toJson())
          .eq('id', updatedTeam.id);

      state = state.map((team) {
        return team.id == updatedTeam.id ? updatedTeam : team;
      }).toList();
    } catch (e) {
      _logger.error('Errorupdating team: $e');
    }
  }

  Future<void> deleteTeam(String teamId) async {
    try {
      await SupabaseService.from('teams').delete().eq('id', teamId);
      state = state.where((team) => team.id != teamId).toList();
    } catch (e) {
      _logger.error('Errordeleting team: $e');
    }
  }
}

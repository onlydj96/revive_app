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

    // CRITICAL: Prevent duplicate requests with synchronous check
    if (_loadingTeams.contains(teamId)) {
      _logger.debug('⚠️ joinTeam BLOCKED: Already loading for teamId=$teamId');
      return;
    }

    // Immediately mark as loading BEFORE any async operations
    _loadingTeams.add(teamId);
    _logger.debug('🟢 joinTeam: Added to loading set, teamId=$teamId');

    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final team = state.firstWhere((team) => team.id == teamId);

      // Get user info from metadata
      final userMeta = SupabaseService.currentUser?.userMetadata;
      final userName = userMeta?['full_name'] ??
                      userMeta?['name'] ??
                      SupabaseService.currentUser?.email?.split('@')[0] ??
                      'Unknown User';

      // Route to correct table based on team type
      if (team.type == TeamType.hangout) {
        // Hangouts: Direct join via hangout_joins table
        _logger.debug('🟢 joinTeam: Joining hangout directly');

        // OPTIMISTIC UPDATE: Immediately update UI state
        ref.read(teamMembershipProvider.notifier).setMembershipOptimistic(teamId, true);

        final result = await SupabaseService.from('hangout_joins')
            .upsert({
              'team_id': teamId,
              'user_id': userId,
              'user_name': userName,
              'status': 'active',
              'joined_at': DateTime.now().toIso8601String(),
            },
            onConflict: 'team_id,user_id')
            .select()
            .maybeSingle();

        // Only increment if this was a new insertion
        if (result != null && result['joined_at'] != null) {
          final joinDate = DateTime.parse(result['joined_at']);
          final now = DateTime.now();
          final isNewMember = now.difference(joinDate).inSeconds < 5;

          if (isNewMember) {
            final updatedTeam = team.copyWith(currentMembers: team.currentMembers + 1);
            await SupabaseService.from('teams').update(
                {'current_members': updatedTeam.currentMembers}).eq('id', teamId);

            state = state.map((t) => t.id == teamId ? updatedTeam : t).toList();
          }
        }

        _logger.debug('🟢 joinTeam SUCCESS: Hangout joined');
      } else {
        // Connect Groups: Should use team_applications_provider instead
        // This code path should not be reached for Connect Groups
        _logger.error('⚠️ joinTeam: Connect Groups should use team_applications_provider');
        throw Exception('Connect Groups require application. Please use the application flow.');
      }
    } catch (e) {
      _logger.error('❌joinTeam ERROR: $e');
      // ROLLBACK: Revert optimistic update on failure (only for hangouts)
      final team = state.firstWhere((team) => team.id == teamId);
      if (team.type == TeamType.hangout) {
        ref.read(teamMembershipProvider.notifier).setMembershipOptimistic(teamId, false);
      }
      rethrow;
    } finally {
      _loadingTeams.remove(teamId);
      _logger.debug('🟢 joinTeam END: Loading removed');
    }
  }

  Future<void> leaveTeam(String teamId) async {
    _logger.debug('🔴 leaveTeam START: teamId=$teamId');

    // CRITICAL: Prevent duplicate requests with synchronous check
    if (_loadingTeams.contains(teamId)) {
      _logger.debug('⚠️ leaveTeam BLOCKED: Already loading for teamId=$teamId');
      return;
    }

    // Immediately mark as loading BEFORE any async operations
    _loadingTeams.add(teamId);
    _logger.debug('🔴 leaveTeam: Added to loading set, teamId=$teamId');

    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final team = state.firstWhere((team) => team.id == teamId);

      // OPTIMISTIC UPDATE: Immediately update UI state
      _logger.debug('🔴 leaveTeam: Calling setMembershipOptimistic(false)');
      ref.read(teamMembershipProvider.notifier).setMembershipOptimistic(teamId, false);

      // Route to correct table based on team type
      if (team.type == TeamType.hangout) {
        // Hangouts: Remove from hangout_joins
        _logger.debug('🔴 leaveTeam: Leaving hangout');
        await SupabaseService.from('hangout_joins')
            .delete()
            .eq('team_id', teamId)
            .eq('user_id', userId);
      } else {
        // Connect Groups: Remove from team_memberships
        _logger.debug('🔴 leaveTeam: Leaving connect group');
        await SupabaseService.from('team_memberships')
            .delete()
            .eq('team_id', teamId)
            .eq('user_id', userId);
      }

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

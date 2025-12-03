import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team.dart';
import '../services/supabase_service.dart';

final teamsProvider = StateNotifierProvider<TeamsNotifier, List<Team>>((ref) {
  return TeamsNotifier();
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
  TeamsNotifier() : super([]) {
    loadTeams();
  }

  Future<void> loadTeams() async {
    try {
      final response =
          await SupabaseService.from('teams').select().order('created_at');

      final teams = (response as List)
          .map((teamData) => Team.fromJson(teamData))
          .toList();

      state = teams;
    } catch (e) {
      print('Error loading teams: $e');
      state = [];
    }
  }

  Future<void> joinTeam(String teamId) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final team = state.firstWhere((team) => team.id == teamId);

      // Get user name from metadata
      final userMeta = SupabaseService.currentUser?.userMetadata;
      final userName = userMeta?['full_name'] ??
                      userMeta?['name'] ??
                      SupabaseService.currentUser?.email?.split('@')[0] ??
                      'Unknown User';

      // Check if user is already a member
      final existingMembership = await SupabaseService.from('team_memberships')
          .select('id')
          .eq('team_id', teamId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMembership != null) {
        // User is already a member, don't join again
        return;
      }

      // Add user to team_memberships
      await SupabaseService.from('team_memberships').insert({
        'team_id': teamId,
        'user_id': userId,
        'user_name': userName,
        'role': 'member',
        'status': 'active',
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Increment member count
      final updatedTeam =
          team.copyWith(currentMembers: team.currentMembers + 1);

      await SupabaseService.from('teams').update(
          {'current_members': updatedTeam.currentMembers}).eq('id', teamId);

      state = state.map((team) {
        return team.id == teamId ? updatedTeam : team;
      }).toList();
    } catch (e) {
      print('Error joining team: $e');
      rethrow;
    }
  }

  Future<void> leaveTeam(String teamId) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final team = state.firstWhere((team) => team.id == teamId);

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
    } catch (e) {
      print('Error leaving team: $e');
      rethrow;
    }
  }

  Future<void> addTeam(Team team) async {
    try {
      await SupabaseService.from('teams').insert(team.toJson());
      await loadTeams(); // Reload to get the team with server-generated id
    } catch (e) {
      print('Error adding team: $e');
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
      print('Error updating team: $e');
    }
  }

  Future<void> deleteTeam(String teamId) async {
    try {
      await SupabaseService.from('teams').delete().eq('id', teamId);
      state = state.where((team) => team.id != teamId).toList();
    } catch (e) {
      print('Error deleting team: $e');
    }
  }
}

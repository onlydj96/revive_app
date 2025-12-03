import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import 'teams_provider.dart';

// State class to track applications and loading state
class TeamApplicationsState {
  final Set<String> appliedTeams;
  final Set<String> loadingTeams;

  const TeamApplicationsState({
    this.appliedTeams = const <String>{},
    this.loadingTeams = const <String>{},
  });

  TeamApplicationsState copyWith({
    Set<String>? appliedTeams,
    Set<String>? loadingTeams,
  }) {
    return TeamApplicationsState(
      appliedTeams: appliedTeams ?? this.appliedTeams,
      loadingTeams: loadingTeams ?? this.loadingTeams,
    );
  }
}

// Provider to track team applications for the current user
final teamApplicationsProvider =
    StateNotifierProvider<TeamApplicationsNotifier, TeamApplicationsState>(
        (ref) {
  return TeamApplicationsNotifier(ref);
});

class TeamApplicationsNotifier extends StateNotifier<TeamApplicationsState> {
  final Ref ref;

  TeamApplicationsNotifier(this.ref) : super(const TeamApplicationsState()) {
    loadUserApplications();
  }

  Future<void> loadUserApplications() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      final response = await SupabaseService.from('team_applications')
          .select('team_id')
          .eq('user_id', userId)
          .eq('status', 'pending'); // Only get pending applications

      final applicationTeamIds =
          (response as List).map((app) => app['team_id'] as String).toSet();

      state = state.copyWith(appliedTeams: applicationTeamIds);
    } catch (e) {
      print('Error loading user applications: $e');
      state = state.copyWith(appliedTeams: <String>{});
    }
  }

  Future<void> applyToTeam(String teamId) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    // Prevent duplicate applications
    if (state.appliedTeams.contains(teamId) ||
        state.loadingTeams.contains(teamId)) {
      return;
    }

    // Set loading state
    state = state.copyWith(
      loadingTeams: <String>{...state.loadingTeams, teamId},
    );

    // Optimistic update: Update UI immediately
    final newAppliedTeams = <String>{...state.appliedTeams, teamId};
    state = state.copyWith(appliedTeams: newAppliedTeams);
    ref.read(teamsProvider.notifier).joinTeam(teamId);

    try {
      // Then try to update the server
      await SupabaseService.from('team_applications').insert({
        'user_id': userId,
        'team_id': teamId,
        'status': 'pending',
        'applied_at': DateTime.now().toIso8601String(),
      });

      // Remove from loading state on success
      state = state.copyWith(
        loadingTeams: Set<String>.from(state.loadingTeams)..remove(teamId),
      );
    } catch (e) {
      print('Error applying to team: $e');

      // Rollback optimistic update on failure
      final rolledBackAppliedTeams = Set<String>.from(state.appliedTeams)
        ..remove(teamId);
      state = state.copyWith(
        appliedTeams: rolledBackAppliedTeams,
        loadingTeams: Set<String>.from(state.loadingTeams)..remove(teamId),
      );
      ref.read(teamsProvider.notifier).leaveTeam(teamId);

      // Re-throw error so UI can handle it
      rethrow;
    }
  }

  Future<void> cancelApplication(String teamId) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    // Prevent duplicate cancellations
    if (!state.appliedTeams.contains(teamId) ||
        state.loadingTeams.contains(teamId)) {
      return;
    }

    // Set loading state
    state = state.copyWith(
      loadingTeams: <String>{...state.loadingTeams, teamId},
    );

    // Store original state for rollback
    final originalAppliedTeams = Set<String>.from(state.appliedTeams);

    // Optimistic update: Update UI immediately
    final newAppliedTeams = Set<String>.from(state.appliedTeams)
      ..remove(teamId);
    state = state.copyWith(appliedTeams: newAppliedTeams);
    ref.read(teamsProvider.notifier).leaveTeam(teamId);

    try {
      // Then try to update the server
      await SupabaseService.from('team_applications')
          .delete()
          .eq('user_id', userId)
          .eq('team_id', teamId)
          .eq('status', 'pending');

      // Remove from loading state on success
      state = state.copyWith(
        loadingTeams: Set<String>.from(state.loadingTeams)..remove(teamId),
      );
    } catch (e) {
      print('Error canceling application: $e');

      // Rollback optimistic update on failure
      state = state.copyWith(
        appliedTeams: originalAppliedTeams,
        loadingTeams: Set<String>.from(state.loadingTeams)..remove(teamId),
      );
      ref.read(teamsProvider.notifier).joinTeam(teamId);

      // Re-throw error so UI can handle it
      rethrow;
    }
  }

  bool hasApplied(String teamId) {
    return state.appliedTeams.contains(teamId);
  }

  bool isLoading(String teamId) {
    return state.loadingTeams.contains(teamId);
  }
}

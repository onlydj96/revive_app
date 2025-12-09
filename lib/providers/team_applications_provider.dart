import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';

final _logger = Logger('TeamApplicationsProvider');

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
      _logger.error('Error loading user applications: $e');
      state = state.copyWith(appliedTeams: <String>{});
    }
  }

  Future<void> applyToTeam(String teamId) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    // CRITICAL: Prevent duplicate applications with synchronous check
    if (state.appliedTeams.contains(teamId) ||
        state.loadingTeams.contains(teamId)) {
      _logger.debug('⚠️ applyToTeam BLOCKED: Already applied or loading for teamId=$teamId');
      return;
    }

    // ATOMIC: Set loading state AND optimistic update together
    // This ensures UI updates happen synchronously before any async operations
    final newLoadingTeams = <String>{...state.loadingTeams, teamId};
    final newAppliedTeams = <String>{...state.appliedTeams, teamId};

    state = state.copyWith(
      loadingTeams: newLoadingTeams,
      appliedTeams: newAppliedTeams,
    );

    _logger.debug('🟢 applyToTeam: Set loading and applied optimistically for teamId=$teamId');

    try {
      // Get user name and email from metadata
      final userMeta = SupabaseService.currentUser?.userMetadata;
      final userName = userMeta?['full_name'] ??
                      userMeta?['name'] ??
                      SupabaseService.currentUser?.email?.split('@')[0] ??
                      'Unknown User';
      final userEmail = SupabaseService.currentUser?.email ?? '';

      // Check if application already exists
      final existing = await SupabaseService.from('team_applications')
          .select('id, status')
          .eq('team_id', teamId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        final status = existing['status'];
        if (status == 'pending') {
          // Already has pending application - do nothing
          return;
        } else if (status == 'rejected') {
          // Update rejected application to pending
          await SupabaseService.from('team_applications')
              .update({
                'status': 'pending',
                'applied_at': DateTime.now().toIso8601String(),
              })
              .eq('id', existing['id']);
        }
      } else {
        // No existing application, create new one
        await SupabaseService.from('team_applications').insert({
          'user_id': userId,
          'team_id': teamId,
          'user_name': userName,
          'user_email': userEmail,
          'status': 'pending',
          'applied_at': DateTime.now().toIso8601String(),
        });
      }

      // Remove from loading state on success
      state = state.copyWith(
        loadingTeams: Set<String>.from(state.loadingTeams)..remove(teamId),
      );
      _logger.debug('🟢 applyToTeam SUCCESS: teamId=$teamId');
    } catch (e) {
      _logger.error('❌ applyToTeam ERROR: $e');

      // Rollback optimistic update on failure
      final rolledBackAppliedTeams = Set<String>.from(state.appliedTeams)
        ..remove(teamId);
      state = state.copyWith(
        appliedTeams: rolledBackAppliedTeams,
        loadingTeams: Set<String>.from(state.loadingTeams)..remove(teamId),
      );

      // Re-throw error so UI can handle it
      rethrow;
    }
  }

  Future<void> cancelApplication(String teamId) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    // CRITICAL: Prevent duplicate cancellations with synchronous check
    if (!state.appliedTeams.contains(teamId) ||
        state.loadingTeams.contains(teamId)) {
      _logger.debug('⚠️ cancelApplication BLOCKED: Not applied or already loading for teamId=$teamId');
      return;
    }

    // Store original state for rollback
    final originalAppliedTeams = Set<String>.from(state.appliedTeams);

    // ATOMIC: Set loading state AND optimistic update together
    final newLoadingTeams = <String>{...state.loadingTeams, teamId};
    final newAppliedTeams = Set<String>.from(state.appliedTeams)
      ..remove(teamId);

    state = state.copyWith(
      loadingTeams: newLoadingTeams,
      appliedTeams: newAppliedTeams,
    );

    _logger.debug('🔴 cancelApplication: Set loading and removed optimistically for teamId=$teamId');

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
      _logger.debug('🔴 cancelApplication SUCCESS: teamId=$teamId');
    } catch (e) {
      _logger.error('❌ cancelApplication ERROR: $e');

      // Rollback optimistic update on failure
      state = state.copyWith(
        appliedTeams: originalAppliedTeams,
        loadingTeams: Set<String>.from(state.loadingTeams)..remove(teamId),
      );

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

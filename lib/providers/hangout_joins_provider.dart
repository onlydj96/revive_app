import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import 'teams_provider.dart';
import '../utils/logger.dart';

// State class to track hangout joins and loading state
class HangoutJoinsState {
  final Set<String> joinedHangouts;
  final Set<String> loadingHangouts;

  const HangoutJoinsState({
    this.joinedHangouts = const <String>{},
    this.loadingHangouts = const <String>{},
  });

  HangoutJoinsState copyWith({
    Set<String>? joinedHangouts,
    Set<String>? loadingHangouts,
  }) {
    return HangoutJoinsState(
      joinedHangouts: joinedHangouts ?? this.joinedHangouts,
      loadingHangouts: loadingHangouts ?? this.loadingHangouts,
    );
  }
}

// Provider to track hangout joins for the current user
final hangoutJoinsProvider =
    StateNotifierProvider<HangoutJoinsNotifier, HangoutJoinsState>((ref) {
  return HangoutJoinsNotifier(ref);
});

class HangoutJoinsNotifier extends StateNotifier<HangoutJoinsState> {
  final Ref ref;
  final _logger = Logger('HangoutJoinsNotifier');

  HangoutJoinsNotifier(this.ref) : super(const HangoutJoinsState()) {
    loadUserJoinedHangouts();
  }

  Future<void> loadUserJoinedHangouts() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      // FIX: Query hangout_joins table (not team_memberships) for hangout membership
      final response = await SupabaseService.from('hangout_joins')
          .select('team_id')
          .eq('user_id', userId)
          .eq('status', 'active');

      final joinedHangoutIds =
          (response as List).map((join) => join['team_id'] as String).toSet();

      state = state.copyWith(joinedHangouts: joinedHangoutIds);
    } catch (e) {
      _logger.error('Error loading user joined hangouts', e);
      state = state.copyWith(joinedHangouts: <String>{});
    }
  }

  Future<void> joinHangout(String teamId) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    // Prevent duplicate joins
    if (state.joinedHangouts.contains(teamId) ||
        state.loadingHangouts.contains(teamId)) {
      return;
    }

    // Set loading state
    state = state.copyWith(
      loadingHangouts: <String>{...state.loadingHangouts, teamId},
    );

    // Optimistic update: Update UI immediately
    final newJoinedHangouts = <String>{...state.joinedHangouts, teamId};
    state = state.copyWith(joinedHangouts: newJoinedHangouts);

    try {
      // Delegate to teamsProvider - it handles DB insert with upsert
      await ref.read(teamsProvider.notifier).joinTeam(teamId);

      // Remove from loading state on success
      state = state.copyWith(
        loadingHangouts: Set<String>.from(state.loadingHangouts)
          ..remove(teamId),
      );
    } catch (e) {
      _logger.error('Error joining hangout', e);

      // Rollback optimistic update on failure
      final rolledBackJoinedHangouts = Set<String>.from(state.joinedHangouts)
        ..remove(teamId);
      state = state.copyWith(
        joinedHangouts: rolledBackJoinedHangouts,
        loadingHangouts: Set<String>.from(state.loadingHangouts)
          ..remove(teamId),
      );

      // Re-throw error so UI can handle it
      rethrow;
    }
  }

  Future<void> leaveHangout(String teamId) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    // Prevent duplicate leaves
    if (!state.joinedHangouts.contains(teamId) ||
        state.loadingHangouts.contains(teamId)) {
      return;
    }

    // Set loading state
    state = state.copyWith(
      loadingHangouts: <String>{...state.loadingHangouts, teamId},
    );

    // Store original state for rollback
    final originalJoinedHangouts = Set<String>.from(state.joinedHangouts);

    // Optimistic update: Update UI immediately
    final newJoinedHangouts = Set<String>.from(state.joinedHangouts)
      ..remove(teamId);
    state = state.copyWith(joinedHangouts: newJoinedHangouts);

    try {
      // Delegate to teamsProvider - it handles DB delete
      await ref.read(teamsProvider.notifier).leaveTeam(teamId);

      // Remove from loading state on success
      state = state.copyWith(
        loadingHangouts: Set<String>.from(state.loadingHangouts)
          ..remove(teamId),
      );
    } catch (e) {
      _logger.error('Error leaving hangout', e);

      // Rollback optimistic update on failure
      state = state.copyWith(
        joinedHangouts: originalJoinedHangouts,
        loadingHangouts: Set<String>.from(state.loadingHangouts)
          ..remove(teamId),
      );

      // Re-throw error so UI can handle it
      rethrow;
    }
  }

  bool hasJoined(String teamId) {
    return state.joinedHangouts.contains(teamId);
  }

  bool isLoading(String teamId) {
    return state.loadingHangouts.contains(teamId);
  }
}

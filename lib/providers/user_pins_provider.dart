import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPinsNotifier extends StateNotifier<Set<String>> {
  UserPinsNotifier() : super(<String>{}) {
    _loadPinnedUpdates();
  }

  static const String _pinnedUpdatesKey = 'user_pinned_updates';

  Future<void> _loadPinnedUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinnedIds = prefs.getStringList(_pinnedUpdatesKey) ?? [];
      state = pinnedIds.toSet();
    } catch (e) {
      // Handle error gracefully
      state = <String>{};
    }
  }

  Future<void> _savePinnedUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_pinnedUpdatesKey, state.toList());
    } catch (e) {
      // Handle error gracefully - could log error in production
    }
  }

  void togglePin(String updateId) {
    if (state.contains(updateId)) {
      state = {...state}..remove(updateId);
    } else {
      state = {...state, updateId};
    }
    _savePinnedUpdates();
  }

  bool isPinned(String updateId) {
    return state.contains(updateId);
  }

  void clearAllPins() {
    state = <String>{};
    _savePinnedUpdates();
  }
}

final userPinsProvider =
    StateNotifierProvider<UserPinsNotifier, Set<String>>((ref) {
  return UserPinsNotifier();
});

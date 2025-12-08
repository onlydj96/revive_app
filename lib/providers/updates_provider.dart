import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/update.dart';
import '../services/supabase_service.dart';

final updatesProvider =
    StateNotifierProvider<UpdatesNotifier, AsyncValue<List<Update>>>((ref) {
  return UpdatesNotifier();
});

final pinnedUpdatesProvider = Provider<List<Update>>((ref) {
  final updatesAsyncValue = ref.watch(updatesProvider);
  return updatesAsyncValue.when(
    data: (updates) => updates.where((update) => update.isPinned).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final recentUpdatesProvider = Provider<List<Update>>((ref) {
  final updatesAsyncValue = ref.watch(updatesProvider);
  return updatesAsyncValue.when(
    data: (updates) {
      final now = DateTime.now();
      return updates
          .where((update) => !update.isPinned)
          .where((update) =>
              update.createdAt.isAfter(now.subtract(const Duration(days: 30))))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

class UpdatesNotifier extends StateNotifier<AsyncValue<List<Update>>> {
  UpdatesNotifier() : super(const AsyncValue.loading()) {
    _loadUpdates();
    _setupRealtimeSubscription();
  }

  RealtimeChannel? _channel;

  Future<void> _loadUpdates() async {
    try {
      state = const AsyncValue.loading();
      final data = await SupabaseService.getAll('updates',
          orderBy: 'created_at', ascending: false, limit: 50);
      final updates = data.map((item) => Update.fromJson(item)).toList();
      state = AsyncValue.data(updates);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _setupRealtimeSubscription() {
    _channel = SupabaseService.subscribeToTable(
      'updates',
      (newRecord) {
        // Handle insert
        final newUpdate = Update.fromJson(newRecord);
        state.whenData((updates) {
          state = AsyncValue.data([newUpdate, ...updates]);
        });
      },
      (updatedRecord) {
        // Handle update
        final updatedUpdate = Update.fromJson(updatedRecord);
        state.whenData((updates) {
          final updatedList = updates.map((update) {
            return update.id == updatedUpdate.id ? updatedUpdate : update;
          }).toList();
          state = AsyncValue.data(updatedList);
        });
      },
      (deletedRecord) {
        // Handle delete
        final deletedId = deletedRecord['id'] as String;
        state.whenData((updates) {
          final filteredList =
              updates.where((update) => update.id != deletedId).toList();
          state = AsyncValue.data(filteredList);
        });
      },
    );
  }

  Future<void> createUpdate({
    required String title,
    required String content,
    required UpdateType type,
    String? imageUrl,
    bool isPinned = false,
    List<String> tags = const [],
  }) async {
    try {
      final data = {
        'title': title,
        'content': content,
        'type': type.name,
        'image_url': imageUrl,
        'is_pinned': isPinned,
        'tags': tags,
      };

      await SupabaseService.create('updates', data);
      // The real-time subscription will handle updating the state
    } catch (error) {
      // Handle error appropriately
      rethrow;
    }
  }

  Future<void> updateUpdate(
    String id, {
    String? title,
    String? content,
    UpdateType? type,
    String? imageUrl,
    bool? isPinned,
    List<String>? tags,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (type != null) data['type'] = type.name;
      if (imageUrl != null) data['image_url'] = imageUrl;
      if (isPinned != null) data['is_pinned'] = isPinned;
      if (tags != null) data['tags'] = tags;

      await SupabaseService.update('updates', id, data);
      // The real-time subscription will handle updating the state
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteUpdate(String id) async {
    try {
      await SupabaseService.delete('updates', id);
      // The real-time subscription will handle updating the state
    } catch (error) {
      rethrow;
    }
  }

  Future<void> togglePin(String id) async {
    state.whenData((updates) async {
      final update = updates.firstWhere((u) => u.id == id);
      await updateUpdate(id, isPinned: !update.isPinned);
    });
  }

  Future<void> refresh() async {
    await _loadUpdates();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

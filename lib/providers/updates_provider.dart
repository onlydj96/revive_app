import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/update.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';

final _logger = Logger('UpdatesProvider');

// PERF: StateNotifierProvider automatically keeps alive
final updatesProvider =
    StateNotifierProvider<UpdatesNotifier, AsyncValue<List<Update>>>((ref) {
  return UpdatesNotifier();
});

// PERF: AutoDispose disabled to cache pinned updates across page transitions
final pinnedUpdatesProvider = Provider<List<Update>>((ref) {
  final updatesAsyncValue = ref.watch(updatesProvider);
  return updatesAsyncValue.when(
    data: (updates) => updates.where((update) => update.isPinned).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// PERF: AutoDispose disabled to cache recent updates across page transitions
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
      // Get current user info for author fields
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to create updates');
      }

      // Get author name from user metadata or email
      final authorName = currentUser.userMetadata?['full_name'] as String? ??
          currentUser.email?.split('@').first ??
          'Unknown';

      final data = {
        'title': title,
        'content': content,
        'type': type.name,
        'image_url': imageUrl,
        'is_pinned': isPinned,
        'tags': tags,
        'author_id': currentUser.id,
        'author_name': authorName,
        'created_by': currentUser.id,
      };

      final result = await SupabaseService.create('updates', data);
      // The real-time subscription will handle updating the state

      // Send push notification to all users
      if (result != null) {
        await _sendPushNotification(
          title: title,
          content: content,
          type: type,
          updateId: result['id'] as String,
          isPinned: isPinned,
        );
      }
    } catch (error) {
      // Handle error appropriately
      rethrow;
    }
  }

  /// Send push notification when a new update is created
  Future<void> _sendPushNotification({
    required String title,
    required String content,
    required UpdateType type,
    required String updateId,
    required bool isPinned,
  }) async {
    try {
      // Build notification title with emoji based on type
      final notificationTitle = switch (type) {
        UpdateType.urgent => '🚨 $title',
        UpdateType.announcement => '📢 $title',
        UpdateType.prayer => '🙏 $title',
        UpdateType.celebration => '🎉 $title',
        UpdateType.news => '📰 $title',
      };

      // Truncate content for notification body
      final notificationBody = content.length > 200
          ? '${content.substring(0, 200)}...'
          : content;

      // Call Edge Function to send push notifications
      await SupabaseService.client.functions.invoke(
        'send-push-notification',
        body: {
          'title': notificationTitle,
          'body': notificationBody,
          'notification_type': 'update',
          'related_id': updateId,
          'data': {
            'update_type': type.name,
            'is_pinned': isPinned.toString(),
          },
        },
      );

      _logger.debug('Push notification sent for update: $updateId');
    } catch (e) {
      // Don't fail the update creation if notification fails
      _logger.error('Failed to send push notification: $e');
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
      final currentUser = SupabaseService.currentUser;

      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (type != null) data['type'] = type.name;
      if (imageUrl != null) data['image_url'] = imageUrl;
      if (isPinned != null) data['is_pinned'] = isPinned;
      if (tags != null) data['tags'] = tags;
      if (currentUser != null) data['updated_by'] = currentUser.id;

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

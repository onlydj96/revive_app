import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';

final _logger = Logger('NotificationPreferencesProvider');

/// Notification preferences model
class NotificationPreferences {
  final String? id;
  final String userId;
  final bool updatesEnabled;
  final bool eventsEnabled;
  final bool teamsEnabled;
  final bool systemEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;

  const NotificationPreferences({
    this.id,
    required this.userId,
    this.updatesEnabled = true,
    this.eventsEnabled = true,
    this.teamsEnabled = true,
    this.systemEnabled = true,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      updatesEnabled: json['updates_enabled'] as bool? ?? true,
      eventsEnabled: json['events_enabled'] as bool? ?? true,
      teamsEnabled: json['teams_enabled'] as bool? ?? true,
      systemEnabled: json['system_enabled'] as bool? ?? true,
      quietHoursStart: json['quiet_hours_start'] as String?,
      quietHoursEnd: json['quiet_hours_end'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'updates_enabled': updatesEnabled,
      'events_enabled': eventsEnabled,
      'teams_enabled': teamsEnabled,
      'system_enabled': systemEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
    };
  }

  NotificationPreferences copyWith({
    String? id,
    String? userId,
    bool? updatesEnabled,
    bool? eventsEnabled,
    bool? teamsEnabled,
    bool? systemEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatesEnabled: updatesEnabled ?? this.updatesEnabled,
      eventsEnabled: eventsEnabled ?? this.eventsEnabled,
      teamsEnabled: teamsEnabled ?? this.teamsEnabled,
      systemEnabled: systemEnabled ?? this.systemEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  /// Default preferences for a user
  factory NotificationPreferences.defaults(String userId) {
    return NotificationPreferences(userId: userId);
  }
}

/// Provider for notification preferences
final notificationPreferencesProvider = StateNotifierProvider<
    NotificationPreferencesNotifier, AsyncValue<NotificationPreferences?>>((ref) {
  return NotificationPreferencesNotifier();
});

class NotificationPreferencesNotifier
    extends StateNotifier<AsyncValue<NotificationPreferences?>> {
  NotificationPreferencesNotifier() : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final response = await SupabaseService.client
          .from('notification_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        state = AsyncValue.data(NotificationPreferences.fromJson(response));
      } else {
        // Create default preferences
        final defaults = NotificationPreferences.defaults(user.id);
        await _createPreferences(defaults);
        state = AsyncValue.data(defaults);
      }
    } catch (e, stack) {
      _logger.error('Failed to load notification preferences: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _createPreferences(NotificationPreferences prefs) async {
    try {
      await SupabaseService.client
          .from('notification_preferences')
          .insert(prefs.toJson());
    } catch (e) {
      _logger.error('Failed to create notification preferences: $e');
    }
  }

  /// Update notification preferences
  Future<void> updatePreferences({
    bool? updatesEnabled,
    bool? eventsEnabled,
    bool? teamsEnabled,
    bool? systemEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) async {
    final currentPrefs = state.value;
    if (currentPrefs == null) return;

    final newPrefs = currentPrefs.copyWith(
      updatesEnabled: updatesEnabled,
      eventsEnabled: eventsEnabled,
      teamsEnabled: teamsEnabled,
      systemEnabled: systemEnabled,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
    );

    try {
      await SupabaseService.client
          .from('notification_preferences')
          .update(newPrefs.toJson())
          .eq('user_id', currentPrefs.userId);

      state = AsyncValue.data(newPrefs);
      _logger.debug('Notification preferences updated');
    } catch (e, stack) {
      _logger.error('Failed to update notification preferences: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Toggle updates notifications
  Future<void> toggleUpdates(bool enabled) async {
    await updatePreferences(updatesEnabled: enabled);
  }

  /// Toggle events notifications
  Future<void> toggleEvents(bool enabled) async {
    await updatePreferences(eventsEnabled: enabled);
  }

  /// Toggle teams notifications
  Future<void> toggleTeams(bool enabled) async {
    await updatePreferences(teamsEnabled: enabled);
  }

  /// Toggle system notifications
  Future<void> toggleSystem(bool enabled) async {
    await updatePreferences(systemEnabled: enabled);
  }

  /// Refresh preferences
  Future<void> refresh() async {
    await _loadPreferences();
  }
}

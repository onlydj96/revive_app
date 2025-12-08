import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../services/supabase_service.dart';
import 'error_provider.dart';

final eventsProvider =
    StateNotifierProvider<EventsNotifier, List<Event>>((ref) {
  return EventsNotifier(ref);
});

// Provider to track which events the current user has signed up for
final userSignedUpEventsProvider =
    StateNotifierProvider<UserSignedUpEventsNotifier, Set<String>>((ref) {
  return UserSignedUpEventsNotifier(ref);
});

final upcomingEventsProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(eventsProvider);
  final now = DateTime.now();
  return events.where((event) => event.startTime.isAfter(now)).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
});

// Provider for upcoming events sorted by date (replaces highlighted events for banner)
final upcomingEventsBannerProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(eventsProvider);
  final now = DateTime.now();

  // Get all future events sorted by date
  final upcomingEvents = events
      .where((event) => event.startTime.isAfter(now))
      .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));

  // Return first 5 upcoming events for the banner
  return upcomingEvents.take(5).toList();
});

final highlightedEventsProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(eventsProvider);
  final now = DateTime.now();
  return events
      .where((event) => event.isHighlighted && event.startTime.isAfter(now))
      .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
});

class EventsNotifier extends StateNotifier<List<Event>> {
  EventsNotifier(this.ref) : super([]) {
    _loadEvents();
    _setupRealtimeSubscription();
  }

  final Ref ref;
  final _supabase = SupabaseService.client;
  RealtimeChannel? _eventsChannel;

  // FIXED P0-2: Track loading operations to prevent race conditions
  final Set<String> _loadingOperations = {};

  /// Check if an event operation is currently in progress
  bool isEventLoading(String eventId) => _loadingOperations.contains(eventId);

  Future<void> _loadEvents() async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .order('start_time', ascending: true);

      state = (response as List).map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      // Log error to error provider
      ref.read(errorProvider.notifier).addError(
            message: 'Failed to load events',
            details: e.toString(),
            severity: ErrorSeverity.warning,
            source: 'EventsProvider._loadEvents',
          );

      // Fallback to mock data if database fails
      _loadMockEvents();
    }
  }

  void _setupRealtimeSubscription() {
    _eventsChannel = _supabase
        .channel('public:events')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'events',
          callback: (payload) {
            _loadEvents(); // Reload events when changes occur
          },
        )
        .subscribe();
  }

  void _loadMockEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Helper function to create DateTime with specific time
    DateTime dateWithTime(int daysFromToday, int hour, [int minute = 0]) {
      final date = today.add(Duration(days: daysFromToday));
      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    state = [
      Event(
        id: '1',
        title: 'Morning Prayer',
        description: 'Start the day with prayer and meditation',
        startTime: dateWithTime(0, 7), // Today at 7 AM
        endTime: dateWithTime(0, 8), // Today at 8 AM
        location: 'Prayer Room',
        type: EventType.service,
        isHighlighted: false,
      ),
      Event(
        id: '2',
        title: 'Sunday Service',
        description: 'Weekly worship service with Pastor Mike',
        startTime: dateWithTime(1, 10), // Tomorrow at 10 AM
        endTime: dateWithTime(1, 12), // Tomorrow at 12 PM
        location: 'Main Sanctuary',
        type: EventType.service,
        isHighlighted: true,
      ),
      Event(
        id: '3',
        title: 'Bible Study Group',
        description: 'Deep dive into the Gospel of John',
        startTime: dateWithTime(2, 19), // 2 days from now at 7 PM
        endTime: dateWithTime(2, 20, 30), // 2 days from now at 8:30 PM
        location: 'Room 101',
        type: EventType.connectGroup,
        requiresSignup: true,
        maxParticipants: 15,
        currentParticipants: 8,
      ),
      Event(
        id: '4',
        title: 'Youth Futsal',
        description: 'Fun futsal game for youth and young adults',
        startTime: dateWithTime(5, 18), // 5 days from now at 6 PM
        endTime: dateWithTime(5, 20), // 5 days from now at 8 PM
        location: 'Sports Hall',
        type: EventType.hangout,
      ),
      Event(
        id: '5',
        title: 'Community Lunch',
        description: 'Fellowship lunch for all members',
        startTime: dateWithTime(7, 12), // 7 days from now at 12 PM
        endTime: dateWithTime(7, 14), // 7 days from now at 2 PM
        location: 'Fellowship Hall',
        type: EventType.special,
        requiresSignup: true,
        maxParticipants: 50,
        currentParticipants: 23,
      ),
      Event(
        id: '6',
        title: 'Easter Celebration',
        description: 'Special Easter service and fellowship',
        startTime: dateWithTime(14, 10), // 14 days from now at 10 AM
        endTime: dateWithTime(14, 13), // 14 days from now at 1 PM
        location: 'Main Sanctuary',
        type: EventType.special,
        isHighlighted: true,
      ),
    ];
  }

  Future<void> toggleEventSignUp(String eventId, WidgetRef widgetRef) async {
    // FIXED P0-2: Prevent race conditions with loading state tracking
    if (_loadingOperations.contains(eventId)) {
      return; // Already processing this event
    }

    final userSignedUpEvents = widgetRef.read(userSignedUpEventsProvider);
    final isSignedUp = userSignedUpEvents.contains(eventId);
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) return;

    // Mark as loading
    _loadingOperations.add(eventId);

    // Store previous state for rollback
    final previousState = state;

    try {
      // Optimistic update: Update UI immediately
      if (isSignedUp) {
        // Cancel sign-up - update state immediately
        widgetRef
            .read(userSignedUpEventsProvider.notifier)
            .removeEvent(eventId);
        state = state.map((event) {
          if (event.id == eventId && event.requiresSignup) {
            return event.copyWith(
              currentParticipants: event.currentParticipants - 1,
            );
          }
          return event;
        }).toList();

        // Sync with backend
        await _supabase
            .from('event_signups')
            .delete()
            .eq('event_id', eventId)
            .eq('user_id', userId);
      } else {
        // Sign up - check capacity and update state immediately
        final event = state.firstWhere((e) => e.id == eventId);
        if (event.maxParticipants == null ||
            event.currentParticipants < event.maxParticipants!) {
          widgetRef.read(userSignedUpEventsProvider.notifier).addEvent(eventId);
          state = state.map((e) {
            if (e.id == eventId && e.requiresSignup) {
              return e.copyWith(
                currentParticipants: e.currentParticipants + 1,
              );
            }
            return e;
          }).toList();

          // Sync with backend
          await _supabase.from('event_signups').insert({
            'event_id': eventId,
            'user_id': userId,
          });
        }
      }
    } catch (e) {
      // Rollback on error
      state = previousState;
      if (isSignedUp) {
        widgetRef.read(userSignedUpEventsProvider.notifier).addEvent(eventId);
      } else {
        widgetRef
            .read(userSignedUpEventsProvider.notifier)
            .removeEvent(eventId);
      }

      // Log error to error provider
      ref.read(errorProvider.notifier).addError(
            message: 'Failed to ${isSignedUp ? 'cancel' : 'sign up for'} event',
            details: e.toString(),
            severity: ErrorSeverity.error,
            source: 'EventsProvider.toggleEventSignUp',
          );

      rethrow;
    } finally {
      // FIXED P0-2: Always remove from loading set
      _loadingOperations.remove(eventId);
    }
  }

  Future<void> addEvent(Event event) async {
    try {
      final eventData = event.toJson();
      eventData.remove('id'); // Let database generate ID
      eventData['created_by'] = _supabase.auth.currentUser?.id;

      await _supabase.from('events').insert(eventData);
      await _loadEvents(); // Reload to get the new event with generated ID
    } catch (e) {
      // Log error to error provider
      ref.read(errorProvider.notifier).addError(
            message: 'Failed to create event',
            details: e.toString(),
            severity: ErrorSeverity.error,
            source: 'EventsProvider.addEvent',
          );

      rethrow;
    }
  }

  Future<void> updateEvent(Event updatedEvent) async {
    // Store previous state for rollback
    final previousState = state;

    try {
      // Optimistic update: Update UI immediately
      state = state.map((event) {
        return event.id == updatedEvent.id ? updatedEvent : event;
      }).toList();

      // Sync with backend
      final eventData = updatedEvent.toJson();
      eventData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('events')
          .update(eventData)
          .eq('id', updatedEvent.id);
    } catch (e) {
      // Rollback on error
      state = previousState;

      // Log error to error provider
      ref.read(errorProvider.notifier).addError(
            message: 'Failed to update event',
            details: e.toString(),
            severity: ErrorSeverity.error,
            source: 'EventsProvider.updateEvent',
          );

      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    // Store previous state for rollback
    final previousState = state;

    try {
      // Optimistic update: Remove from UI immediately
      state = state.where((event) => event.id != eventId).toList();

      // Sync with backend
      await _supabase.from('events').delete().eq('id', eventId);
    } catch (e) {
      // Rollback on error
      state = previousState;

      // Log error to error provider
      ref.read(errorProvider.notifier).addError(
            message: 'Failed to delete event',
            details: e.toString(),
            severity: ErrorSeverity.error,
            source: 'EventsProvider.deleteEvent',
          );

      rethrow;
    }
  }

  @override
  void dispose() {
    _eventsChannel?.unsubscribe();
    super.dispose();
  }
}

class UserSignedUpEventsNotifier extends StateNotifier<Set<String>> {
  UserSignedUpEventsNotifier(this.ref) : super(<String>{}) {
    _loadUserSignups();
  }

  final Ref ref;
  final _supabase = SupabaseService.client;

  Future<void> _loadUserSignups() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from('event_signups')
          .select('event_id')
          .eq('user_id', userId);

      state = Set<String>.from(
        (response as List).map((item) => item['event_id'] as String),
      );
    } catch (e) {
      // Log error to error provider
      ref.read(errorProvider.notifier).addError(
            message: 'Failed to load user event signups',
            details: e.toString(),
            severity: ErrorSeverity.warning,
            source: 'UserSignedUpEventsNotifier._loadUserSignups',
          );
    }
  }

  void addEvent(String eventId) {
    state = {...state, eventId};
  }

  void removeEvent(String eventId) {
    state = Set.from(state)..remove(eventId);
  }

  bool isSignedUp(String eventId) {
    return state.contains(eventId);
  }
}

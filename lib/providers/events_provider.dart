import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../services/supabase_service.dart';

final eventsProvider = StateNotifierProvider<EventsNotifier, List<Event>>((ref) {
  return EventsNotifier();
});

// Provider to track which events the current user has signed up for
final userSignedUpEventsProvider = StateNotifierProvider<UserSignedUpEventsNotifier, Set<String>>((ref) {
  return UserSignedUpEventsNotifier();
});

final upcomingEventsProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(eventsProvider);
  final now = DateTime.now();
  return events
      .where((event) => event.startTime.isAfter(now))
      .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
});

final highlightedEventsProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(eventsProvider);
  return events.where((event) => event.isHighlighted).toList();
});

class EventsNotifier extends StateNotifier<List<Event>> {
  EventsNotifier() : super([]) {
    _loadEvents();
    _setupRealtimeSubscription();
  }

  final _supabase = SupabaseService.client;
  RealtimeChannel? _eventsChannel;

  Future<void> _loadEvents() async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .order('start_time', ascending: true);

      state = (response as List)
          .map((json) => Event.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading events: $e');
      // Fallback to mock data if database fails
      _loadMockEvents();
    }
  }

  void _setupRealtimeSubscription() {
    _eventsChannel = _supabase.channel('public:events')
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
        startTime: dateWithTime(0, 7),  // Today at 7 AM
        endTime: dateWithTime(0, 8),     // Today at 8 AM
        location: 'Prayer Room',
        type: EventType.service,
        isHighlighted: false,
      ),
      Event(
        id: '2',
        title: 'Sunday Service',
        description: 'Weekly worship service with Pastor Mike',
        startTime: dateWithTime(1, 10),  // Tomorrow at 10 AM
        endTime: dateWithTime(1, 12),    // Tomorrow at 12 PM
        location: 'Main Sanctuary',
        type: EventType.service,
        isHighlighted: true,
      ),
      Event(
        id: '3',
        title: 'Bible Study Group',
        description: 'Deep dive into the Gospel of John',
        startTime: dateWithTime(2, 19),     // 2 days from now at 7 PM
        endTime: dateWithTime(2, 20, 30),   // 2 days from now at 8:30 PM
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
        startTime: dateWithTime(5, 18),  // 5 days from now at 6 PM
        endTime: dateWithTime(5, 20),    // 5 days from now at 8 PM
        location: 'Sports Hall',
        type: EventType.hangout,
      ),
      Event(
        id: '5',
        title: 'Community Lunch',
        description: 'Fellowship lunch for all members',
        startTime: dateWithTime(7, 12),  // 7 days from now at 12 PM
        endTime: dateWithTime(7, 14),    // 7 days from now at 2 PM
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
        endTime: dateWithTime(14, 13),   // 14 days from now at 1 PM
        location: 'Main Sanctuary',
        type: EventType.special,
        isHighlighted: true,
      ),
    ];
  }

  Future<void> toggleEventSignUp(String eventId, WidgetRef ref) async {
    final userSignedUpEvents = ref.read(userSignedUpEventsProvider);
    final isSignedUp = userSignedUpEvents.contains(eventId);
    final userId = _supabase.auth.currentUser?.id;
    
    if (userId == null) return;
    
    try {
      if (isSignedUp) {
        // Cancel sign-up
        await _supabase
            .from('event_signups')
            .delete()
            .eq('event_id', eventId)
            .eq('user_id', userId);
        
        ref.read(userSignedUpEventsProvider.notifier).removeEvent(eventId);
      } else {
        // Sign up
        final event = state.firstWhere((e) => e.id == eventId);
        if (event.maxParticipants == null || event.currentParticipants < event.maxParticipants!) {
          await _supabase
              .from('event_signups')
              .insert({
                'event_id': eventId,
                'user_id': userId,
              });
          
          ref.read(userSignedUpEventsProvider.notifier).addEvent(eventId);
        }
      }
      
      // Reload events to get updated participant counts
      await _loadEvents();
    } catch (e) {
      print('Error toggling event signup: $e');
      // Fallback to local update
      state = state.map((event) {
        if (event.id == eventId && event.requiresSignup) {
          if (isSignedUp) {
            // Cancel sign-up
            ref.read(userSignedUpEventsProvider.notifier).removeEvent(eventId);
            return event.copyWith(
              currentParticipants: event.currentParticipants - 1,
            );
          } else {
            // Sign up
            if (event.maxParticipants == null || event.currentParticipants < event.maxParticipants!) {
              ref.read(userSignedUpEventsProvider.notifier).addEvent(eventId);
              return event.copyWith(
                currentParticipants: event.currentParticipants + 1,
              );
            }
          }
        }
        return event;
      }).toList();
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
      print('Error adding event: $e');
      throw e;
    }
  }

  Future<void> updateEvent(Event updatedEvent) async {
    try {
      final eventData = updatedEvent.toJson();
      eventData['updated_at'] = DateTime.now().toIso8601String();
      
      await _supabase
          .from('events')
          .update(eventData)
          .eq('id', updatedEvent.id);
      
      await _loadEvents(); // Reload to get updated data
    } catch (e) {
      print('Error updating event: $e');
      throw e;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _supabase
          .from('events')
          .delete()
          .eq('id', eventId);
      
      await _loadEvents(); // Reload to reflect deletion
    } catch (e) {
      print('Error deleting event: $e');
      throw e;
    }
  }
  
  @override
  void dispose() {
    _eventsChannel?.unsubscribe();
    super.dispose();
  }
}

class UserSignedUpEventsNotifier extends StateNotifier<Set<String>> {
  UserSignedUpEventsNotifier() : super(<String>{}) {
    _loadUserSignups();
  }

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
      print('Error loading user signups: $e');
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
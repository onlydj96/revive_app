import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';

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
    _loadMockEvents();
  }

  void _loadMockEvents() {
    final now = DateTime.now();
    state = [
      Event(
        id: '1',
        title: 'Sunday Service',
        description: 'Weekly worship service with Pastor Mike',
        startTime: now.add(const Duration(days: 1)),
        endTime: now.add(const Duration(days: 1, hours: 2)),
        location: 'Main Sanctuary',
        type: EventType.service,
        isHighlighted: true,
      ),
      Event(
        id: '2',
        title: 'Bible Study Group',
        description: 'Deep dive into the Gospel of John',
        startTime: now.add(const Duration(days: 3)),
        endTime: now.add(const Duration(days: 3, hours: 1, minutes: 30)),
        location: 'Room 101',
        type: EventType.connectGroup,
        requiresSignup: true,
        maxParticipants: 15,
        currentParticipants: 8,
      ),
      Event(
        id: '3',
        title: 'Youth Futsal',
        description: 'Fun futsal game for youth and young adults',
        startTime: now.add(const Duration(days: 5)),
        endTime: now.add(const Duration(days: 5, hours: 2)),
        location: 'Sports Hall',
        type: EventType.hangout,
      ),
      Event(
        id: '4',
        title: 'Easter Celebration',
        description: 'Special Easter service and fellowship',
        startTime: now.add(const Duration(days: 14)),
        endTime: now.add(const Duration(days: 14, hours: 3)),
        location: 'Main Sanctuary',
        type: EventType.special,
        isHighlighted: true,
      ),
    ];
  }

  void toggleEventSignUp(String eventId, WidgetRef ref) {
    final userSignedUpEvents = ref.read(userSignedUpEventsProvider);
    final isSignedUp = userSignedUpEvents.contains(eventId);
    
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

  void addEvent(Event event) {
    state = [...state, event];
  }

  void updateEvent(Event updatedEvent) {
    state = state.map((event) {
      return event.id == updatedEvent.id ? updatedEvent : event;
    }).toList();
  }

  void deleteEvent(String eventId) {
    state = state.where((event) => event.id != eventId).toList();
  }
}

class UserSignedUpEventsNotifier extends StateNotifier<Set<String>> {
  UserSignedUpEventsNotifier() : super(<String>{});

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
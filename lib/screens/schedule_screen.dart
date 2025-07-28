import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/events_provider.dart';
import '../models/event.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final eventsForSelectedDateProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(eventsProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  
  return events.where((event) {
    return isSameDay(event.startTime, selectedDate);
  }).toList();
});

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);
    final highlightedEvents = ref.watch(highlightedEventsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final eventsForDate = ref.watch(eventsForSelectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: Column(
        children: [
          if (highlightedEvents.isNotEmpty) ...[
            Container(
              height: 200,
              child: PageView.builder(
                itemCount: highlightedEvents.length,
                itemBuilder: (context, index) {
                  final event = highlightedEvents[index];
                  return Container(
                    margin: const EdgeInsets.all(16),
                    child: EventBannerCard(event: event),
                  );
                },
              ),
            ),
          ],
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TableCalendar<Event>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: selectedDate,
                      calendarFormat: CalendarFormat.month,
                      eventLoader: (day) {
                        return events.where((event) => isSameDay(event.startTime, day)).toList();
                      },
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: TextStyle(color: Theme.of(context).primaryColor),
                        holidayTextStyle: TextStyle(color: Theme.of(context).primaryColor),
                        markerDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selectedDayPredicate: (day) {
                        return isSameDay(selectedDate, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        ref.read(selectedDateProvider.notifier).state = selectedDay;
                      },
                    ),
                  ),
                  
                  if (eventsForDate.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Events for ${DateFormat('MMMM d, yyyy').format(selectedDate)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...eventsForDate.map((event) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: EventListItem(event: event),
                    )),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events scheduled',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'for ${DateFormat('MMMM d, yyyy').format(selectedDate)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventBannerCard extends ConsumerWidget {
  final Event event;

  const EventBannerCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/event/${event.id}'),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              if (event.imageUrl != null)
                Positioned.fill(
                  child: Image.network(
                    event.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container();
                    },
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'FEATURED',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${DateFormat('MMM d').format(event.startTime)} • ${DateFormat('h:mm a').format(event.startTime)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (event.requiresSignup) ...[
                      const SizedBox(height: 12),
                      Consumer(
                        builder: (context, ref, child) {
                          final isSignedUp = ref.watch(userSignedUpEventsProvider).contains(event.id);
                          final isFull = event.maxParticipants != null && 
                              event.currentParticipants >= event.maxParticipants!;
                          
                          return ElevatedButton(
                            onPressed: (isFull && !isSignedUp) ? null : () {
                              ref.read(eventsProvider.notifier).toggleEventSignUp(event.id, ref);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isSignedUp 
                                      ? 'Cancelled registration for ${event.title}'
                                      : 'Signed up for ${event.title}!'
                                  ),
                                  backgroundColor: isSignedUp ? Colors.orange : Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSignedUp ? Colors.orange : Colors.white,
                              foregroundColor: isSignedUp ? Colors.white : Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              isFull && !isSignedUp 
                                ? 'Full'
                                : isSignedUp 
                                  ? 'Cancel'
                                  : 'Sign Up Now'
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventListItem extends ConsumerWidget {
  final Event event;

  const EventListItem({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/event/${event.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (event.isHighlighted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'FEATURED',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (event.requiresSignup) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (event.maxParticipants != null) ...[
                            Text(
                              '${event.currentParticipants}/${event.maxParticipants} signed up',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: event.currentParticipants / event.maxParticipants!,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Consumer(
                      builder: (context, ref, child) {
                        final isSignedUp = ref.watch(userSignedUpEventsProvider).contains(event.id);
                        final isFull = event.maxParticipants != null && 
                            event.currentParticipants >= event.maxParticipants!;
                        
                        return ElevatedButton(
                          onPressed: (isFull && !isSignedUp) ? null : () {
                            ref.read(eventsProvider.notifier).toggleEventSignUp(event.id, ref);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isSignedUp 
                                    ? 'Cancelled registration for ${event.title}'
                                    : 'Signed up for ${event.title}!'
                                ),
                                backgroundColor: isSignedUp ? Colors.orange : Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSignedUp ? Colors.orange : null,
                            foregroundColor: isSignedUp ? Colors.white : null,
                          ),
                          child: Text(
                            isFull && !isSignedUp 
                              ? 'Full'
                              : isSignedUp 
                                ? 'Cancel'
                                : 'Sign Up'
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
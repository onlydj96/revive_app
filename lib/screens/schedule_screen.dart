import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/events_provider.dart';
import '../providers/permissions_provider.dart';
import '../providers/hangout_joins_provider.dart';
import '../models/event.dart';
import '../widgets/create_event_dialog.dart';
import '../widgets/edit_event_dialog.dart';
import '../services/storage_service.dart';

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

  void _showCreateEventDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CreateEventDialog(
        onEventCreated: (event) async {
          try {
            await ref.read(eventsProvider.notifier).addEvent(event);
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Event "${event.title}" created successfully!')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to create event: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, WidgetRef ref, Event event) {
    showDialog(
      context: context,
      builder: (context) => EditEventDialog(
        event: event,
        onEventUpdated: (updatedEvent) async {
          try {
            await ref.read(eventsProvider.notifier).updateEvent(updatedEvent);
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Event "${updatedEvent.title}" updated successfully!')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update event: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildCustomDayCell(
    BuildContext context,
    DateTime day,
    List<Event> allEvents,
    DateTime selectedDate, {
    required bool isToday,
    required bool isSelected,
  }) {
    final hasEvents =
        allEvents.any((event) => isSameDay(event.startTime, day));
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        // Selected: filled background
        color: isSelected ? primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        // Today: thin border
        border: isToday && !isSelected
            ? Border.all(
                color: primaryColor.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
      ),
      child: Stack(
        children: [
          // Left bar for events
          if (hasEvents)
            Positioned(
              left: 2,
              top: 6,
              bottom: 6,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.9)
                      : primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          // Day number
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (day.weekday == DateTime.saturday ||
                            day.weekday == DateTime.sunday)
                        ? primaryColor
                        : Colors.black87,
                fontWeight: isToday || isSelected || hasEvents
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);
    final upcomingEvents = ref.watch(upcomingEventsBannerProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final eventsForDate = ref.watch(eventsForSelectedDateProvider);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          if (permissions.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateEventDialog(context, ref),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Upcoming Events Banner
            if (upcomingEvents.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: upcomingEvents.length,
                  itemBuilder: (context, index) {
                    final event = upcomingEvents[index];
                    return Container(
                      margin: const EdgeInsets.all(16),
                      child: EventBannerCard(
                        event: event,
                        onEdit: () => _showEditEventDialog(context, ref, event),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Calendar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
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
                  return events
                      .where((event) => isSameDay(event.startTime, day))
                      .toList();
                },
                startingDayOfWeek: StartingDayOfWeek.sunday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle:
                      TextStyle(color: Theme.of(context).primaryColor),
                  holidayTextStyle:
                      TextStyle(color: Theme.of(context).primaryColor),
                  // Remove default marker decoration (we'll use custom builder)
                  markerDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  // Remove default selected decoration (we'll use custom builder)
                  selectedDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  // Remove default today decoration (we'll use custom builder)
                  todayDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  // Set default cell style
                  defaultDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  weekendDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                ),
                selectedDayPredicate: (day) {
                  return isSameDay(selectedDate, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  ref.read(selectedDateProvider.notifier).state = selectedDay;
                },
                // Custom cell builder for visual design
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return _buildCustomDayCell(
                      context,
                      day,
                      events,
                      selectedDate,
                      isToday: false,
                      isSelected: false,
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return _buildCustomDayCell(
                      context,
                      day,
                      events,
                      selectedDate,
                      isToday: true,
                      isSelected: isSameDay(selectedDate, day),
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return _buildCustomDayCell(
                      context,
                      day,
                      events,
                      selectedDate,
                      isToday: isSameDay(day, DateTime.now()),
                      isSelected: true,
                    );
                  },
                ),
              ),
            ),

            // Selected Date Events
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
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: EventListItem(
                      event: event,
                      onEdit: () => _showEditEventDialog(context, ref, event),
                    ),
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
    );
  }
}

class EventBannerCard extends ConsumerWidget {
  final Event event;
  final VoidCallback? onEdit;

  const EventBannerCard({super.key, required this.event, this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysUntil = event.startTime.difference(DateTime.now()).inDays;
    final hoursUntil = event.startTime.difference(DateTime.now()).inHours;

    String timeUntilText;
    if (daysUntil > 0) {
      timeUntilText = 'In $daysUntil ${daysUntil == 1 ? 'day' : 'days'}';
    } else if (hoursUntil > 0) {
      timeUntilText = 'In $hoursUntil ${hoursUntil == 1 ? 'hour' : 'hours'}';
    } else {
      timeUntilText = 'Today';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/event/${event.id}'),
            child: SizedBox(
              height: 180,
              child: Stack(
                children: [
                  // Background image with overlay
                  Positioned.fill(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (StorageService.getEventImageUrl(event.imageUrl) != null)
                          CachedNetworkImage(
                            imageUrl:
                                StorageService.getEventImageUrl(event.imageUrl)!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.8),
                                  Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.church,
                                size: 60,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                        // Default gradient when no image
                        if (StorageService.getEventImageUrl(event.imageUrl) == null)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.church,
                                size: 60,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top badges
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        // Time until badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeUntilText,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Admin edit button
                        if (onEdit != null)
                          Consumer(
                            builder: (context, ref, child) {
                              final permissions =
                                  ref.watch(permissionsProvider);
                              if (!permissions.isAdmin) {
                                return const SizedBox.shrink();
                              }

                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: onEdit,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        if (event.isHighlighted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange, Colors.deepOrange],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'FEATURED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Bottom content
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            event.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black.withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Info row
                          Row(
                            children: [
                              // Date & Time
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MMM d, h:mm a')
                                          .format(event.startTime),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Location
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          event.location,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Sign up button if needed
                              if (event.requiresSignup) ...[
                                const SizedBox(width: 8),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final isSignedUp = event.type ==
                                            EventType.hangout
                                        ? ref
                                            .watch(hangoutJoinsProvider)
                                            .joinedHangouts
                                            .contains(event.id)
                                        : ref
                                            .watch(userSignedUpEventsProvider)
                                            .contains(event.id);
                                    final isFull =
                                        event.maxParticipants != null &&
                                            event.currentParticipants >=
                                                event.maxParticipants!;

                                    return SizedBox(
                                      height: 28,
                                      child: ElevatedButton(
                                        onPressed: (isFull && !isSignedUp)
                                            ? null
                                            : () async {
                                                if (event.type ==
                                                    EventType.hangout) {
                                                  if (isSignedUp) {
                                                    await ref
                                                        .read(
                                                            hangoutJoinsProvider
                                                                .notifier)
                                                        .leaveHangout(event.id);
                                                  } else {
                                                    await ref
                                                        .read(
                                                            hangoutJoinsProvider
                                                                .notifier)
                                                        .joinHangout(event.id);
                                                  }
                                                } else {
                                                  await ref
                                                      .read(eventsProvider
                                                          .notifier)
                                                      .toggleEventSignUp(
                                                          event.id, ref);
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isSignedUp
                                              ? Colors.white.withValues(alpha: 0.2)
                                              : Colors.white,
                                          foregroundColor: isSignedUp
                                              ? Colors.white
                                              : Theme.of(context).primaryColor,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: Text(
                                          isFull && !isSignedUp
                                              ? 'Full'
                                              : isSignedUp
                                                  ? 'Joined'
                                                  : 'Join',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EventListItem extends ConsumerWidget {
  final Event event;
  final VoidCallback? onEdit;

  const EventListItem({super.key, required this.event, this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventTypeIcon = _getEventTypeIcon(event.type);
    final eventTypeColor = _getEventTypeColor(event.type, context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/event/${event.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Event type icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: eventTypeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    eventTypeIcon,
                    color: eventTypeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Middle - Event details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with badges
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Admin edit button
                          if (onEdit != null)
                            Consumer(
                              builder: (context, ref, child) {
                                final permissions =
                                    ref.watch(permissionsProvider);
                                if (!permissions.isAdmin) {
                                  return const SizedBox.shrink();
                                }

                                return Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: onEdit,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (event.isHighlighted)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.orange, Colors.deepOrange],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'HOT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Description
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),

                      // Time and location chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          // Time chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 12,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${DateFormat('MMM d').format(event.startTime)} • ${DateFormat('h:mm a').format(event.startTime)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Location chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.place,
                                  size: 12,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(width: 4),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 120),
                                  child: Text(
                                    event.location,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Sign up section if needed
                      if (event.requiresSignup) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (event.maxParticipants != null) ...[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${event.currentParticipants}/${event.maxParticipants} joined',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: event.currentParticipants /
                                            event.maxParticipants!,
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          event.currentParticipants >=
                                                  event.maxParticipants!
                                              ? Colors.red
                                              : Theme.of(context).primaryColor,
                                        ),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Consumer(
                              builder: (context, ref, child) {
                                final isSignedUp =
                                    event.type == EventType.hangout
                                        ? ref
                                            .watch(hangoutJoinsProvider)
                                            .joinedHangouts
                                            .contains(event.id)
                                        : ref
                                            .watch(userSignedUpEventsProvider)
                                            .contains(event.id);
                                final isFull = event.maxParticipants != null &&
                                    event.currentParticipants >=
                                        event.maxParticipants!;

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: (isFull && !isSignedUp)
                                        ? null
                                        : () async {
                                            if (event.type ==
                                                EventType.hangout) {
                                              if (isSignedUp) {
                                                await ref
                                                    .read(hangoutJoinsProvider
                                                        .notifier)
                                                    .leaveHangout(event.id);
                                              } else {
                                                await ref
                                                    .read(hangoutJoinsProvider
                                                        .notifier)
                                                    .joinHangout(event.id);
                                              }
                                            } else {
                                              await ref
                                                  .read(eventsProvider.notifier)
                                                  .toggleEventSignUp(
                                                      event.id, ref);
                                            }
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(event.type ==
                                                          EventType.hangout
                                                      ? (isSignedUp
                                                          ? 'Left ${event.title}'
                                                          : 'Joined ${event.title}!')
                                                      : (isSignedUp
                                                          ? 'Cancelled registration'
                                                          : 'Successfully registered!')),
                                                  backgroundColor: isSignedUp
                                                      ? Colors.orange
                                                      : Colors.green,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isFull && !isSignedUp
                                            ? Colors.grey[300]
                                            : isSignedUp
                                                ? Colors.orange.withValues(alpha: 0.1)
                                                : Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isFull && !isSignedUp
                                              ? Colors.grey[400]!
                                              : isSignedUp
                                                  ? Colors.orange
                                                  : Theme.of(context)
                                                      .primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        isFull && !isSignedUp
                                            ? 'Full'
                                            : isSignedUp
                                                ? 'Cancel'
                                                : 'Join',
                                        style: TextStyle(
                                          color: isFull && !isSignedUp
                                              ? Colors.grey[600]
                                              : isSignedUp
                                                  ? Colors.orange
                                                  : Theme.of(context)
                                                      .primaryColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.service:
        return Icons.church;
      case EventType.connectGroup:
        return Icons.group;
      case EventType.hangout:
        return Icons.celebration;
      case EventType.special:
        return Icons.star;
      case EventType.training:
        return Icons.school;
    }
  }

  Color _getEventTypeColor(EventType type, BuildContext context) {
    switch (type) {
      case EventType.service:
        return Colors.purple;
      case EventType.connectGroup:
        return Colors.blue;
      case EventType.hangout:
        return Colors.orange;
      case EventType.special:
        return Colors.red;
      case EventType.training:
        return Colors.green;
    }
  }
}

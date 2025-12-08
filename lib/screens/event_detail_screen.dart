import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../providers/events_provider.dart';
import '../providers/permissions_provider.dart';
import '../widgets/edit_event_dialog.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);
    final event = events.firstWhere(
      (e) => e.id == eventId,
      orElse: () => Event(
        id: '',
        title: 'Event Not Found',
        description: 'The requested event could not be found.',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        location: '',
        type: EventType.service,
      ),
    );

    if (event.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Not Found')),
        body: const Center(
          child: Text('The requested event could not be found.'),
        ),
      );
    }

    final permissions = ref.watch(permissionsProvider);
    final isSignedUp = ref.watch(userSignedUpEventsProvider).contains(event.id);
    final isFull = event.maxParticipants != null &&
        event.currentParticipants >= event.maxParticipants!;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          if (permissions.isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditEventDialog(context, ref, event),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context, ref, event),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            if (event.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  event.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: const Icon(Icons.image, size: 64),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(_getEventTypeLabel(event.type)),
                        backgroundColor:
                            _getEventTypeColor(event.type).withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 8),
                      if (event.isHighlighted)
                        const Chip(
                          label: Text('FEATURED'),
                          backgroundColor: Colors.orange,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            context,
                            Icons.calendar_today,
                            'Date',
                            DateFormat('EEEE, MMMM d, yyyy')
                                .format(event.startTime),
                          ),
                          const Divider(),
                          _buildInfoRow(
                            context,
                            Icons.access_time,
                            'Time',
                            '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                          ),
                          const Divider(),
                          _buildInfoRow(
                            context,
                            Icons.location_on,
                            'Location',
                            event.location,
                          ),
                          if (event.requiresSignup) ...[
                            const Divider(),
                            _buildInfoRow(
                              context,
                              Icons.people,
                              'Participants',
                              event.maxParticipants != null
                                  ? '${event.currentParticipants} / ${event.maxParticipants}'
                                  : '${event.currentParticipants} signed up',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (event.requiresSignup) ...[
                    const SizedBox(height: 24),
                    if (event.maxParticipants != null) ...[
                      LinearProgressIndicator(
                        value:
                            event.currentParticipants / event.maxParticipants!,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${event.currentParticipants} of ${event.maxParticipants} spots filled',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (isFull && !isSignedUp)
                            ? null
                            : () async {
                                await ref
                                    .read(eventsProvider.notifier)
                                    .toggleEventSignUp(event.id, ref);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isSignedUp
                                          ? 'Cancelled registration for ${event.title}'
                                          : 'Signed up for ${event.title}!'),
                                      backgroundColor: isSignedUp
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: isSignedUp
                              ? Colors.orange
                              : Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          isFull && !isSignedUp
                              ? 'Event Full'
                              : isSignedUp
                                  ? 'Cancel Registration'
                                  : 'Sign Up for This Event',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
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

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.service:
        return 'Service';
      case EventType.connectGroup:
        return 'Connect Group';
      case EventType.hangout:
        return 'Hangout';
      case EventType.special:
        return 'Special Event';
      case EventType.training:
        return 'Training';
    }
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.service:
        return Colors.purple;
      case EventType.connectGroup:
        return Colors.blue;
      case EventType.hangout:
        return Colors.green;
      case EventType.special:
        return Colors.orange;
      case EventType.training:
        return Colors.red;
    }
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

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
            'Are you sure you want to delete "${event.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(eventsProvider.notifier).deleteEvent(event.id);
                if (context.mounted) {
                  context.pop(); // Go back to schedule screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted "${event.title}"')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete event: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

class UpcomingEventsList extends StatelessWidget {
  final List<Event> events;

  const UpcomingEventsList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          
          return InkWell(
            onTap: () => context.push('/event/${event.id}'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: index > 0 ? Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('MMM').format(event.startTime).toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('d').format(event.startTime),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('EEE').format(event.startTime),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('h:mm a').format(event.startTime),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.location_on,
                              size: 14,
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
                        if (event.requiresSignup && event.maxParticipants != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: event.currentParticipants / event.maxParticipants!,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${event.currentParticipants}/${event.maxParticipants}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
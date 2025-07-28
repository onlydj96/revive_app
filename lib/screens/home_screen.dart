import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../providers/bulletin_provider.dart';
import '../providers/sermons_provider.dart';
import '../providers/updates_provider.dart';
import '../providers/events_provider.dart';
import '../widgets/profile_summary_card.dart';
import '../widgets/bulletin_card.dart';
import '../widgets/sermon_card.dart';
import '../widgets/updates_preview.dart';
import '../widgets/upcoming_events_list.dart';
import '../widgets/worship_feedback_map_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final bulletin = ref.watch(bulletinProvider);
    final latestSermon = ref.watch(latestSermonProvider);
    final recentUpdates = ref.watch(recentUpdatesProvider);
    final upcomingEvents = ref.watch(upcomingEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ezer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(bulletinProvider);
          ref.invalidate(sermonsProvider);
          ref.invalidate(updatesProvider);
          ref.invalidate(eventsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user != null) ...[
                ProfileSummaryCard(user: user),
                const SizedBox(height: 16),
              ],
              
              WorshipFeedbackMapCard(),
              const SizedBox(height: 16),
              
              if (bulletin != null) ...[
                BulletinCard(bulletin: bulletin),
                const SizedBox(height: 16),
              ],
              
              if (latestSermon != null) ...[
                SermonCard(sermon: latestSermon),
                const SizedBox(height: 16),
              ],
              
              if (recentUpdates.isNotEmpty) ...[
                UpdatesPreview(updates: recentUpdates.take(3).toList()),
                const SizedBox(height: 16),
              ],
              
              if (upcomingEvents.isNotEmpty) ...[
                Text(
                  'Upcoming Events',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                UpcomingEventsList(events: upcomingEvents.take(5).toList()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
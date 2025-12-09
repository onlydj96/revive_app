import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bulletin.dart';
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
import '../utils/logger.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _logger = Logger('HomeScreen');

  // PERF: Removed storage initialization from initState
  // Storage is now initialized once in main.dart for better performance

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final bulletinsAsync = ref.watch(bulletinsProvider);
    final latestSermon = ref.watch(latestSermonProvider);
    final recentUpdates = ref.watch(recentUpdatesProvider);
    final upcomingEvents = ref.watch(upcomingEventsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(bulletinsProvider);
        ref.invalidate(sermonsProvider);
        ref.invalidate(updatesProvider);
        ref.invalidate(eventsProvider);
      },
      child: SafeArea(
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
            bulletinsAsync.when(
              data: (bulletins) {
                _logger.debug('Received ${bulletins.length} bulletins');
                if (bulletins.isEmpty) {
                  _logger.debug('No bulletins available, hiding card');
                  return const SizedBox.shrink();
                }
                // Find current week's bulletin or use most recent
                final now = DateTime.now();
                Bulletin? currentBulletin;
                try {
                  currentBulletin = bulletins.firstWhere(
                    (b) {
                      final weekStart = b.weekOf;
                      final weekEnd = weekStart.add(const Duration(days: 6));
                      return now.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                          now.isBefore(weekEnd.add(const Duration(days: 1)));
                    },
                  );
                  _logger.debug('Found current week bulletin: ${currentBulletin.theme}');
                } catch (e) {
                  // If no current week bulletin found, use most recent
                  currentBulletin = bulletins.first;
                  _logger.debug('No current week bulletin, using most recent: ${currentBulletin.theme}');
                }
                return Column(
                  children: [
                    BulletinCard(bulletin: currentBulletin),
                    const SizedBox(height: 16),
                  ],
                );
              },
              loading: () {
                _logger.debug('Bulletins loading...');
                return const SizedBox.shrink();
              },
              error: (error, stack) {
                _logger.error('Error loading bulletins', error, stack);
                return const SizedBox.shrink();
              },
            ),
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

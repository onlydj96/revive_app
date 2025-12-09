import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/bulletin.dart';
import '../providers/bulletin_provider.dart';
import '../providers/permissions_provider.dart';
import '../widgets/create_bulletin_dialog.dart';

class BulletinListScreen extends ConsumerWidget {
  const BulletinListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bulletins = ref.watch(bulletinsByYearProvider(2025));
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('2025 Bulletins'),
      ),
      floatingActionButton: permissions.canCreateContent
          ? FloatingActionButton(
              heroTag: 'bulletin_fab',
              onPressed: () {
                _showCreateBulletinDialog(context, ref);
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: bulletins.isEmpty
          ? const Center(
              child: Text('No bulletins available'),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(bulletinsProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bulletins.length,
                itemBuilder: (context, index) {
                  final bulletin = bulletins[index];
                  return BulletinListCard(bulletin: bulletin);
                },
              ),
            ),
    );
  }

  void _showCreateBulletinDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CreateBulletinDialog(),
    );
  }
}

class BulletinListCard extends StatelessWidget {
  final Bulletin bulletin;

  const BulletinListCard({super.key, required this.bulletin});

  @override
  Widget build(BuildContext context) {
    final isCurrentWeek = _isCurrentWeek(bulletin.weekOf);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCurrentWeek ? 4 : 1,
      child: InkWell(
        onTap: () {
          context.push('/bulletin/${bulletin.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: isCurrentWeek
              ? BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Date Circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isCurrentWeek
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(bulletin.weekOf).toUpperCase(),
                        style: TextStyle(
                          color:
                              isCurrentWeek ? Colors.white : Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('d').format(bulletin.weekOf),
                        style: TextStyle(
                          color:
                              isCurrentWeek ? Colors.white : Colors.grey[900],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Bulletin Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isCurrentWeek)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'THIS WEEK',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isCurrentWeek) const SizedBox(height: 4),
                      Text(
                        bulletin.theme,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Week of ${DateFormat('MMM d, yyyy').format(bulletin.weekOf)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${bulletin.items.length} items',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isCurrentWeek(DateTime weekOf) {
    final now = DateTime.now();
    final weekStart = weekOf;
    final weekEnd = weekStart.add(const Duration(days: 6));
    return now.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        now.isBefore(weekEnd.add(const Duration(days: 1)));
  }
}

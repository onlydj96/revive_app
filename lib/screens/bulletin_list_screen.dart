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

class BulletinListCard extends ConsumerWidget {
  final Bulletin bulletin;

  const BulletinListCard({super.key, required this.bulletin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurrentWeek = _isCurrentWeek(bulletin.weekOf);
    final permissions = ref.watch(permissionsProvider);

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

                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (permissions.canEditContent)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, ref, bulletin);
                        },
                        tooltip: 'Delete bulletin',
                      ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                  ],
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

  void _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref, Bulletin bulletin) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Bulletin'),
        content: Text(
          'Are you sure you want to delete the bulletin for ${DateFormat('MMMM d, yyyy').format(bulletin.weekOf)}?\n\n'
          'Theme: "${bulletin.theme}"\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _deleteBulletin(context, ref, bulletin);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBulletin(
      BuildContext context, WidgetRef ref, Bulletin bulletin) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Show loading indicator
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Text('Deleting bulletin...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Delete the bulletin
      await ref.read(bulletinsProvider.notifier).deleteBulletin(bulletin.id);

      // Show success message
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Bulletin deleted successfully'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (error) {
      // Show error message
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete bulletin: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

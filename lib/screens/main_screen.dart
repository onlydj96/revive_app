import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/notification.dart';
import '../providers/notification_provider.dart';
import '../widgets/feedback_detail_dialog.dart';

class MainScreen extends ConsumerWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnreadNotifications = ref.watch(hasUnreadNotificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    // Check if we're on a main screen (one of the bottom nav items)
    final String location = GoRouterState.of(context).uri.path;
    final isMainScreen = ['/home', '/resources', '/schedule', '/teams', '/updates']
        .any((path) => location.startsWith(path));

    return PopScope(
      canPop: !isMainScreen,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        // Only handle back button for main screens
        if (isMainScreen) {
          final shouldExit = await _showExitConfirmationDialog(context);
          if (shouldExit == true && context.mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Ezer'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => _showNotifications(context, ref),
              ),
              if (hasUnreadNotifications)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Updates',
          ),
        ],
      ),
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 종료'),
        content: const Text('앱을 종료하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/resources')) {
      return 1;
    }
    if (location.startsWith('/schedule')) {
      return 2;
    }
    if (location.startsWith('/teams')) {
      return 3;
    }
    if (location.startsWith('/updates')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/resources');
        break;
      case 2:
        GoRouter.of(context).go('/schedule');
        break;
      case 3:
        GoRouter.of(context).go('/teams');
        break;
      case 4:
        GoRouter.of(context).go('/updates');
        break;
    }
  }

  void _showNotifications(BuildContext context, WidgetRef ref) {
    final notifications = ref.read(notificationProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (notifications.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        ref.read(notificationProvider.notifier).markAllAsRead();
                      },
                      child: const Text('Mark all as read'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: notification.isRead
                                    ? Colors.grey[300]
                                    : Theme.of(context).primaryColor,
                                child: Icon(
                                  _getNotificationIcon(notification.type),
                                  color: notification.isRead
                                      ? Colors.grey[600]
                                      : Colors.white,
                                ),
                              ),
                              title: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notification.message),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        _formatTimestamp(
                                            notification.timestamp),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                      if (notification.isFeedbackNotification &&
                                          notification.hasLocation)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 12,
                                                color: Colors.blue[700],
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                'Location',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Colors.blue[700],
                                                      fontSize: 10,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                ref
                                    .read(notificationProvider.notifier)
                                    .markAsRead(notification.id);

                                // Show detailed view for feedback notifications
                                if (notification.isFeedbackNotification) {
                                  Navigator.of(context)
                                      .pop(); // Close the notification bottom sheet
                                  showDialog(
                                    context: context,
                                    builder: (context) => FeedbackDetailDialog(
                                      notification: notification,
                                    ),
                                  );
                                }
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () {
                                  ref
                                      .read(notificationProvider.notifier)
                                      .removeNotification(notification.id);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.feedbackSubmitted:
        return Icons.feedback;
      case NotificationType.generalAlert:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

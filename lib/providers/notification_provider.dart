import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier() : super([]);

  void addNotification(AppNotification notification) {
    state = [notification, ...state];
  }

  void markAsRead(String notificationId) {
    state = state.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
  }

  void markAllAsRead() {
    state = state
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
  }

  void removeNotification(String notificationId) {
    state = state
        .where((notification) => notification.id != notificationId)
        .toList();
  }

  void clearAllNotifications() {
    state = [];
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
  return NotificationNotifier();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider);
  return notifications.where((notification) => !notification.isRead).length;
});

final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  final count = ref.watch(unreadNotificationCountProvider);
  return count > 0;
});

final feedbackNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notifications = ref.watch(notificationProvider);
  return notifications
      .where((notification) => notification.isFeedbackNotification)
      .toList();
});

final feedbackNotificationsWithLocationProvider =
    Provider<List<AppNotification>>((ref) {
  final feedbackNotifications = ref.watch(feedbackNotificationsProvider);
  return feedbackNotifications
      .where((notification) => notification.hasLocation)
      .toList();
});

enum NotificationType {
  feedbackSubmitted,
  generalAlert,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  // Helper methods for feedback-related notifications
  bool get isFeedbackNotification => type == NotificationType.feedbackSubmitted;

  String? get feedbackType => data?['feedback'];

  Map<String, double>? get feedbackLocation {
    final location = data?['location'];
    if (location != null && location['x'] != null && location['y'] != null) {
      try {
        return {'x': location['x'].toDouble(), 'y': location['y'].toDouble()};
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, double>? get feedbackRelativeLocation {
    final location = data?['location'];
    if (location != null &&
        location['relativeX'] != null &&
        location['relativeY'] != null) {
      try {
        return {
          'relativeX': location['relativeX'].toDouble(),
          'relativeY': location['relativeY'].toDouble()
        };
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  bool get hasLocation {
    final hasLoc = feedbackLocation != null || feedbackRelativeLocation != null;
    return hasLoc;
  }
}

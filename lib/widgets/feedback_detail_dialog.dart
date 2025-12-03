import 'package:flutter/material.dart';
import '../models/notification.dart';

class FeedbackDetailDialog extends StatelessWidget {
  final AppNotification notification;

  const FeedbackDetailDialog({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Feedback details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.feedback,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Feedback Type:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFeedbackDescription(notification.feedbackType),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Submitted:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(notification.timestamp),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Location section
            if (notification.hasLocation) ...[
              Text(
                'Location on Worship Feedback Map',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final relativeLocation =
                            notification.feedbackRelativeLocation;

                        return Stack(
                          children: [
                            CustomPaint(
                              painter: WorshipFeedbackMapPainter(),
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            // Show the feedback location using relative coordinates
                            if (relativeLocation != null)
                              Positioned(
                                left: (relativeLocation['relativeX']! *
                                        constraints.maxWidth) -
                                    12,
                                top: (relativeLocation['relativeY']! *
                                        constraints.maxHeight) -
                                    24,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.3),
                                        spreadRadius: 4,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'The red marker shows where the person was sitting when they submitted this feedback.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.amber[800],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No location data available',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getFeedbackDescription(String? feedbackType) {
    if (feedbackType == null) return 'Unknown';

    switch (feedbackType) {
      case 'tooCold':
        return 'Too Cold';
      case 'tooHot':
        return 'Too Hot';
      case 'justRight':
        return 'Just Right';
      case 'tooLoud':
        return 'Too Loud';
      case 'tooQuiet':
        return 'Too Quiet';
      case 'lighting':
        return 'Lighting Issue';
      default:
        return feedbackType;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

// Simplified worship feedback map painter for the detail view
class WorshipFeedbackMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = Colors.grey[100]!
      ..style = PaintingStyle.fill;

    // Draw worship area outline
    final worshipAreaRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.2,
      size.width * 0.8,
      size.height * 0.6,
    );
    canvas.drawRect(worshipAreaRect, fillPaint);
    canvas.drawRect(worshipAreaRect, paint);

    // Draw stage
    final stageRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.15,
      size.width * 0.7,
      size.height * 0.1,
    );
    canvas.drawRect(
        stageRect, Paint()..color = const Color(0xFF6B46C1).withOpacity(0.3));
    canvas.drawRect(stageRect, paint);

    // Draw text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'STAGE',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        stageRect.center.dx - textPainter.width / 2,
        stageRect.center.dy - textPainter.height / 2,
      ),
    );

    // Draw seating rows
    final seatPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    for (int row = 0; row < 8; row++) {
      final y = size.height * 0.3 + (row * size.height * 0.06);
      for (int section = 0; section < 3; section++) {
        final x = size.width * 0.2 + (section * size.width * 0.25);
        final seatRect =
            Rect.fromLTWH(x, y, size.width * 0.15, size.height * 0.04);
        canvas.drawRRect(
          RRect.fromRectAndRadius(seatRect, const Radius.circular(4)),
          seatPaint,
        );
      }
    }

    // Draw entrance
    final entranceRect = Rect.fromLTWH(
      size.width * 0.45,
      size.height * 0.8,
      size.width * 0.1,
      size.height * 0.05,
    );
    canvas.drawRect(
        entranceRect, Paint()..color = Colors.green.withOpacity(0.3));

    final entranceTextPainter = TextPainter(
      text: TextSpan(
        text: 'ENTRANCE',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    entranceTextPainter.layout();
    entranceTextPainter.paint(
      canvas,
      Offset(
        entranceRect.center.dx - entranceTextPainter.width / 2,
        size.height * 0.87,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

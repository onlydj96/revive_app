import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EnvironmentFeedback {
  tooCold,
  tooHot,
  justRight,
  tooLoud,
  tooQuiet,
  lighting,
}

final selectedLocationProvider = StateProvider<Offset?>((ref) => null);
final environmentFeedbackProvider = StateProvider<EnvironmentFeedback?>((ref) => null);

class WorshipFeedbackMapScreen extends ConsumerWidget {
  const WorshipFeedbackMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocation = ref.watch(selectedLocationProvider);
    final environmentFeedback = ref.watch(environmentFeedbackProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worship Feedback Map'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Help Us Improve Your Experience',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap on the map to indicate your approximate location, then share your environmental feedback.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTapDown: (details) {
                        final RenderBox box = context.findRenderObject() as RenderBox;
                        final localPosition = box.globalToLocal(details.globalPosition);
                        ref.read(selectedLocationProvider.notifier).state = localPosition;
                      },
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: CustomPaint(
                          painter: SanctuaryMapPainter(selectedLocation: selectedLocation),
                        ),
                      ),
                    ),
                    
                    if (selectedLocation != null)
                      Positioned(
                        left: selectedLocation.dx - 12,
                        top: selectedLocation.dy - 24,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          if (selectedLocation != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How\'s the environment?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FeedbackChip(
                        label: 'Too Cold',
                        icon: Icons.ac_unit,
                        feedback: EnvironmentFeedback.tooCold,
                        selectedFeedback: environmentFeedback,
                        onSelected: (feedback) {
                          ref.read(environmentFeedbackProvider.notifier).state = feedback;
                        },
                      ),
                      FeedbackChip(
                        label: 'Too Hot',
                        icon: Icons.local_fire_department,
                        feedback: EnvironmentFeedback.tooHot,
                        selectedFeedback: environmentFeedback,
                        onSelected: (feedback) {
                          ref.read(environmentFeedbackProvider.notifier).state = feedback;
                        },
                      ),
                      FeedbackChip(
                        label: 'Just Right',
                        icon: Icons.check_circle,
                        feedback: EnvironmentFeedback.justRight,
                        selectedFeedback: environmentFeedback,
                        onSelected: (feedback) {
                          ref.read(environmentFeedbackProvider.notifier).state = feedback;
                        },
                      ),
                      FeedbackChip(
                        label: 'Too Loud',
                        icon: Icons.volume_up,
                        feedback: EnvironmentFeedback.tooLoud,
                        selectedFeedback: environmentFeedback,
                        onSelected: (feedback) {
                          ref.read(environmentFeedbackProvider.notifier).state = feedback;
                        },
                      ),
                      FeedbackChip(
                        label: 'Too Quiet',
                        icon: Icons.volume_down,
                        feedback: EnvironmentFeedback.tooQuiet,
                        selectedFeedback: environmentFeedback,
                        onSelected: (feedback) {
                          ref.read(environmentFeedbackProvider.notifier).state = feedback;
                        },
                      ),
                      FeedbackChip(
                        label: 'Lighting Issue',
                        icon: Icons.lightbulb,
                        feedback: EnvironmentFeedback.lighting,
                        selectedFeedback: environmentFeedback,
                        onSelected: (feedback) {
                          ref.read(environmentFeedbackProvider.notifier).state = feedback;
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: environmentFeedback != null
                          ? () {
                              _submitFeedback(context, ref, selectedLocation, environmentFeedback);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Submit Feedback'),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap anywhere on the worship area map to indicate your location',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _submitFeedback(BuildContext context, WidgetRef ref, Offset location, EnvironmentFeedback feedback) {
    ref.read(selectedLocationProvider.notifier).state = null;
    ref.read(environmentFeedbackProvider.notifier).state = null;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback! We\'ll work to improve the experience.'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.of(context).pop();
  }
}

class FeedbackChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final EnvironmentFeedback feedback;
  final EnvironmentFeedback? selectedFeedback;
  final Function(EnvironmentFeedback) onSelected;

  const FeedbackChip({
    super.key,
    required this.label,
    required this.icon,
    required this.feedback,
    required this.selectedFeedback,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedFeedback == feedback;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        onSelected(feedback);
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}

class SanctuaryMapPainter extends CustomPainter {
  final Offset? selectedLocation;

  SanctuaryMapPainter({this.selectedLocation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = Colors.grey[100]!
      ..style = PaintingStyle.fill;

    // Draw sanctuary outline
    final sanctuaryRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.2,
      size.width * 0.8,
      size.height * 0.6,
    );
    canvas.drawRect(sanctuaryRect, fillPaint);
    canvas.drawRect(sanctuaryRect, paint);

    // Draw stage
    final stageRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.15,
      size.width * 0.7,
      size.height * 0.1,
    );
    canvas.drawRect(stageRect, Paint()..color = const Color(0xFF6B46C1).withOpacity(0.3));
    canvas.drawRect(stageRect, paint);

    // Draw text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'STAGE',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
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
        final seatRect = Rect.fromLTWH(x, y, size.width * 0.15, size.height * 0.04);
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
    canvas.drawRect(entranceRect, Paint()..color = Colors.green.withOpacity(0.3));

    final entranceTextPainter = TextPainter(
      text: TextSpan(
        text: 'ENTRANCE',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
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
    return true;
  }
}
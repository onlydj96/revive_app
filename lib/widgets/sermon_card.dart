import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/sermon.dart';
import '../config/app_theme.dart';
import 'common/base_card.dart';

class SermonCard extends StatelessWidget {
  final Sermon sermon;

  const SermonCard({super.key, required this.sermon});

  @override
  Widget build(BuildContext context) {
    if (sermon.thumbnailUrl != null) {
      return ImageHeaderCard(
        elevation: 2.0,
        onTap: () => context.push('/sermon/${sermon.id}'),
        headerHeight: 140,
        bodyPadding: const EdgeInsets.all(16),
        headerImage: _buildHeaderImage(context),
        body: _buildCardBody(context),
      );
    }

    return BaseCard(
      elevation: 2.0,
      onTap: () => context.push('/sermon/${sermon.id}'),
      padding: const EdgeInsets.all(16),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      child: _buildCardBody(context),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          child: Icon(
            Icons.play_circle_outline,
            size: 48,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.neutralN90.withValues(alpha: 0.54),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'LAST WEEK',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const Positioned.fill(
          child: Center(
            child: Icon(
              Icons.play_circle_filled,
              size: 56,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Last Week\'s Sermon',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Text(
              DateFormat('MMM d').format(sermon.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralN50,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          sermon.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.person,
              size: 16,
              color: AppTheme.neutralN50,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                sermon.speaker,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neutralN50,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.book,
              size: 16,
              color: AppTheme.neutralN50,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                sermon.biblePassage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neutralN50,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (sermon.audioUrl != null) ...[
              _buildMediaBadge(context, Icons.headphones, 'Audio'),
              const SizedBox(width: 8),
            ],
            if (sermon.videoUrl != null) ...[
              _buildMediaBadge(context, Icons.videocam, 'Video'),
              const SizedBox(width: 8),
            ],
            if (sermon.transcript != null)
              _buildMediaBadge(context, Icons.text_snippet, 'Text'),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaBadge(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

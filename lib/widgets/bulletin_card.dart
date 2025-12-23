import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/bulletin.dart';
import '../config/app_theme.dart';
import 'common/base_card.dart';

class BulletinCard extends StatelessWidget {
  final Bulletin bulletin;

  const BulletinCard({super.key, required this.bulletin});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (bulletin.bannerImageUrl != null) {
      return ImageHeaderCard(
        elevation: 2.0,
        onTap: () => context.push('/bulletin/${bulletin.id}'),
        headerHeight: 120,
        bodyPadding: const EdgeInsets.all(16),
        headerImage: _buildHeaderImage(context, l10n),
        body: _buildCardBody(context, l10n),
      );
    }

    return BaseCard(
      elevation: 2.0,
      onTap: () => context.push('/bulletin/${bulletin.id}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purple header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.thisWeeksBulletin,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                Text(
                  l10n.weekOf(DateFormat('MMM d, yyyy').format(bulletin.weekOf)),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
          // White body section
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildCardBody(context, l10n, showHeader: false),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context, AppLocalizations l10n) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.2),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.thisWeeksBulletin,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                l10n.weekOf(DateFormat('MMM d, yyyy').format(bulletin.weekOf)),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardBody(BuildContext context, AppLocalizations l10n, {bool showHeader = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bulletin.theme,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        ...bulletin.items.take(3).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.content.isNotEmpty)
                          Text(
                            item.content,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.neutralN50,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        if (bulletin.items.length > 3) ...[
          const SizedBox(height: 8),
          Text(
            l10n.andMoreItems(bulletin.items.length - 3),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.neutralN50,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/bulletins'),
            icon: const Icon(Icons.library_books),
            label: Text(l10n.viewAllBulletins(DateTime.now().year)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

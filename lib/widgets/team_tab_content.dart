import 'package:flutter/material.dart';
import '../models/team.dart';
import '../screens/teams_screen.dart' show TeamCard;

// FIXED P0-8: Extracted unified tab content widget to eliminate duplication
/// Reusable tab content widget for both Connect Groups and Hangouts tabs
class TeamTabContent extends StatelessWidget {
  final List<Team> teams;
  final String title;
  final String description;
  final String sectionTitle;
  final IconData icon;
  final Color color;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  const TeamTabContent({
    super.key,
    required this.teams,
    required this.title,
    required this.description,
    required this.sectionTitle,
    required this.icon,
    required this.color,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Section title
          Text(
            sectionTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          // Teams list or empty state
          if (teams.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(emptyIcon, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      emptyTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    Text(
                      emptySubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...teams.map((team) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TeamCard(team: team),
                )),
        ],
        ),
      ),
    );
  }
}

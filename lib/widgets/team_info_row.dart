import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/team.dart';

/// Reusable widget to display team meeting time information
/// Handles both DateTime and null values gracefully
class TeamMeetingTimeInfo extends StatelessWidget {
  final DateTime? meetingTime;
  final TextStyle? textStyle;
  final Color? iconColor;
  final double iconSize;
  final bool showIcon;

  const TeamMeetingTimeInfo({
    super.key,
    required this.meetingTime,
    this.textStyle,
    this.iconColor,
    this.iconSize = 16,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    // If no meeting time, return empty widget
    if (meetingTime == null) {
      return const SizedBox.shrink();
    }

    final defaultIconColor = iconColor ?? Colors.grey[600];
    final defaultTextStyle = textStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            );

    // Format: "Wednesdays at 7:00 PM"
    final formattedTime =
        '${DateFormat('EEEE').format(meetingTime!)}s at ${DateFormat('h:mm a').format(meetingTime!)}';

    if (!showIcon) {
      return Text(formattedTime, style: defaultTextStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time,
          size: iconSize,
          color: defaultIconColor,
        ),
        const SizedBox(width: 4),
        Text(formattedTime, style: defaultTextStyle),
      ],
    );
  }
}

/// Reusable widget to display team location information
class TeamLocationInfo extends StatelessWidget {
  final String? location;
  final TextStyle? textStyle;
  final Color? iconColor;
  final double iconSize;
  final bool showIcon;
  final bool expandable;

  const TeamLocationInfo({
    super.key,
    required this.location,
    this.textStyle,
    this.iconColor,
    this.iconSize = 16,
    this.showIcon = true,
    this.expandable = false,
  });

  @override
  Widget build(BuildContext context) {
    // If no location, return empty widget
    if (location == null || location!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final defaultIconColor = iconColor ?? Colors.grey[600];
    final defaultTextStyle = textStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            );

    final locationWidget = Text(
      location!,
      style: defaultTextStyle,
      overflow: expandable ? null : TextOverflow.ellipsis,
    );

    if (!showIcon) {
      return expandable ? Expanded(child: locationWidget) : locationWidget;
    }

    return Row(
      mainAxisSize: expandable ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on,
          size: iconSize,
          color: defaultIconColor,
        ),
        const SizedBox(width: 4),
        if (expandable) Expanded(child: locationWidget) else locationWidget,
      ],
    );
  }
}

/// Combined widget for meeting time and location in a single row
/// Used in team cards for compact display
class TeamMeetingInfo extends StatelessWidget {
  final Team team;
  final TextStyle? textStyle;
  final Color? iconColor;
  final double iconSize;

  const TeamMeetingInfo({
    super.key,
    required this.team,
    this.textStyle,
    this.iconColor,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    // If neither time nor location exists, return empty widget
    if (team.meetingTime == null && team.meetingLocation == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Meeting Time
        if (team.meetingTime != null)
          TeamMeetingTimeInfo(
            meetingTime: team.meetingTime,
            textStyle: textStyle,
            iconColor: iconColor,
            iconSize: iconSize,
          ),

        // Separator if both exist
        if (team.meetingTime != null && team.meetingLocation != null)
          const SizedBox(width: 16),

        // Meeting Location
        if (team.meetingLocation != null)
          Expanded(
            child: TeamLocationInfo(
              location: team.meetingLocation,
              textStyle: textStyle,
              iconColor: iconColor,
              iconSize: iconSize,
              expandable: true,
            ),
          ),
      ],
    );
  }
}

/// Detailed meeting info display for detail screens
/// Shows time and location in separate rows with labels
class TeamMeetingInfoDetailed extends StatelessWidget {
  final Team team;

  const TeamMeetingInfoDetailed({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    // If neither time nor location exists, return empty widget
    if (team.meetingTime == null && team.meetingLocation == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meeting Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        // Meeting Time
        if (team.meetingTime != null)
          _buildInfoRow(
            context,
            Icons.access_time,
            'When',
            '${DateFormat('EEEE').format(team.meetingTime!)}s at ${DateFormat('h:mm a').format(team.meetingTime!)}',
          ),

        // Meeting Location
        if (team.meetingLocation != null)
          _buildInfoRow(
            context,
            Icons.location_on,
            'Where',
            team.meetingLocation!,
          ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

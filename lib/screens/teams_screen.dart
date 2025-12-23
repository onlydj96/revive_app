import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../providers/teams_provider.dart';
import '../providers/permissions_provider.dart';
import '../providers/team_applications_provider.dart';
import '../providers/hangout_joins_provider.dart';
import '../providers/team_members_provider.dart';
import '../models/team.dart';
import '../widgets/team_info_row.dart';
import '../widgets/team_tab_content.dart';
import '../utils/ui_utils.dart';

class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final connectGroups = ref.watch(connectGroupsProvider);
    final hangouts = ref.watch(hangoutsProvider);
    final permissions = ref.watch(permissionsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.teams),
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(text: l10n.connectGroups),
              Tab(text: l10n.hangouts),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ConnectGroupsTab(teams: connectGroups),
            HangoutsTab(teams: hangouts),
          ],
        ),
        floatingActionButton: permissions.isAdmin
            ? FloatingActionButton.extended(
                heroTag: 'teams_fab',
                onPressed: () => context.push('/create-team'),
                icon: const Icon(Icons.add),
                label: Text(l10n.createTeam),
              )
            : null,
      ),
    );
  }
}

// FIXED P0-8: Simplified using TeamTabContent widget (eliminated ~97 lines of duplication)
class ConnectGroupsTab extends StatelessWidget {
  final List<Team> teams;

  const ConnectGroupsTab({super.key, required this.teams});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TeamTabContent(
      teams: teams,
      title: l10n.aboutConnectGroups,
      description: l10n.connectGroupsDescription,
      sectionTitle: l10n.availableGroups,
      icon: Icons.info_outline,
      color: Theme.of(context).primaryColor,
      emptyIcon: Icons.groups_outlined,
      emptyTitle: l10n.noConnectGroupsAvailable,
      emptySubtitle: l10n.checkBackLaterForGroups,
    );
  }
}

// FIXED P0-8: Simplified using TeamTabContent widget (eliminated ~97 lines of duplication)
class HangoutsTab extends StatelessWidget {
  final List<Team> teams;

  const HangoutsTab({super.key, required this.teams});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TeamTabContent(
      teams: teams,
      title: l10n.aboutHangouts,
      description: l10n.hangoutsDescription,
      sectionTitle: l10n.joinAHangout,
      icon: Icons.celebration,
      color: Colors.orange,
      emptyIcon: Icons.sports_soccer,
      emptyTitle: l10n.noHangoutsAvailable,
      emptySubtitle: l10n.checkBackLaterForActivities,
    );
  }
}

/// Enum representing the possible action states for a team button
enum _TeamActionState {
  full,     // Team is at capacity
  member,   // User is already a member
  applied,  // User has pending application
  joinable, // User can join/apply
}

class TeamCard extends ConsumerWidget {
  final Team team;

  const TeamCard({super.key, required this.team});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsState = ref.watch(teamApplicationsProvider);
    final hangoutJoinsState = ref.watch(hangoutJoinsProvider);
    final isMember = ref.watch(isTeamMemberProvider(team.id));

    // Unified state tracking for both team types
    final hasApplied = applicationsState.appliedTeams.contains(team.id);
    final isLoading = team.type == TeamType.connectGroup
        ? applicationsState.loadingTeams.contains(team.id)
        : hangoutJoinsState.loadingHangouts.contains(team.id);

    // Determine the current action state
    final actionState = _getActionState(isMember, hasApplied);
    final isFull = _isTeamFull(isMember, hasApplied);

    return Card(
      child: InkWell(
        onTap: () => context.push('/team/${team.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildDescription(context),
              const SizedBox(height: 12),
              _buildLeaderAndMemberInfo(context),
              if (team.meetingTime != null || team.meetingLocation != null) ...[
                const SizedBox(height: 8),
                TeamMeetingInfo(team: team),
              ],
              const SizedBox(height: 12),
              _buildFooter(context, ref, actionState, isFull, isLoading),
            ],
          ),
        ),
      ),
    );
  }

  /// Determines the current action state based on membership and application status
  _TeamActionState _getActionState(bool isMember, bool hasApplied) {
    if (isMember) return _TeamActionState.member;
    if (hasApplied) return _TeamActionState.applied;
    return _TeamActionState.joinable;
  }

  /// Checks if the team is full (only for non-members without pending applications)
  bool _isTeamFull(bool isMember, bool hasApplied) {
    if (isMember || hasApplied) return false;
    if (team.maxMembers == null) return false;
    return team.currentMembers >= team.maxMembers!;
  }

  /// Builds the header row with team name and status badge
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            team.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildStatusBadge(context),
      ],
    );
  }

  /// Builds the status badge (APPLICATION REQUIRED or OPEN TO ALL)
  Widget _buildStatusBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isApplicationRequired = team.requiresApplication;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isApplicationRequired
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isApplicationRequired ? l10n.applicationRequired : l10n.openToAll,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isApplicationRequired
                  ? Theme.of(context).primaryColor
                  : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
      ),
    );
  }

  /// Builds the description text
  Widget _buildDescription(BuildContext context) {
    return Text(
      team.description,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the leader and member count info row
  Widget _buildLeaderAndMemberInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Icon(Icons.person, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          l10n.ledBy(team.leader),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(width: 16),
        Icon(Icons.group, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          l10n.membersCount(team.currentMembers),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  /// Builds the footer with capacity info (if applicable) and action button
  Widget _buildFooter(
    BuildContext context,
    WidgetRef ref,
    _TeamActionState actionState,
    bool isFull,
    bool isLoading,
  ) {
    return Row(
      children: [
        Expanded(child: _buildCapacityInfo(context)),
        _buildActionButton(context, ref, actionState, isFull, isLoading),
      ],
    );
  }

  /// Builds the capacity info (progress bar or member count)
  Widget _buildCapacityInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (team.maxMembers != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.spotsFilled(team.currentMembers, team.maxMembers!),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: team.currentMembers / team.maxMembers!,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              team.currentMembers >= team.maxMembers!
                  ? Colors.orange
                  : Theme.of(context).primaryColor,
            ),
          ),
        ],
      );
    }
    return Text(
      l10n.activeMembers(team.currentMembers),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
    );
  }

  /// Builds the action button (Join/Apply/Leave/Cancel)
  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    _TeamActionState actionState,
    bool isFull,
    bool isLoading,
  ) {
    final isDisabled = isFull || isLoading;

    return ElevatedButton(
      onPressed: isDisabled ? null : () => _handleButtonPress(context, ref, actionState),
      style: _getButtonStyle(actionState),
      child: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(_getButtonText(context, actionState, isFull)),
    );
  }

  /// Returns the appropriate button style based on action state
  ButtonStyle? _getButtonStyle(_TeamActionState actionState) {
    if (actionState == _TeamActionState.member ||
        actionState == _TeamActionState.applied) {
      return ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      );
    }
    return null;
  }

  /// Returns the button text based on action state
  String _getButtonText(BuildContext context, _TeamActionState actionState, bool isFull) {
    final l10n = AppLocalizations.of(context)!;
    if (isFull) return l10n.full;
    switch (actionState) {
      case _TeamActionState.member:
        return l10n.leave;
      case _TeamActionState.applied:
        return l10n.cancel;
      case _TeamActionState.joinable:
        return team.type == TeamType.connectGroup ? l10n.apply : l10n.join;
      case _TeamActionState.full:
        return l10n.full;
    }
  }

  /// Handles button press based on action state
  Future<void> _handleButtonPress(
    BuildContext context,
    WidgetRef ref,
    _TeamActionState actionState,
  ) async {
    switch (actionState) {
      case _TeamActionState.member:
        await _handleLeave(context, ref);
        break;
      case _TeamActionState.applied:
        await _handleCancelApplication(context, ref);
        break;
      case _TeamActionState.joinable:
        await _handleJoinOrApply(context, ref);
        break;
      case _TeamActionState.full:
        // Button should be disabled, no action needed
        break;
    }
  }

  /// Handles leaving a team
  Future<void> _handleLeave(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;

    try {
      if (team.type == TeamType.connectGroup) {
        await ref.read(teamsProvider.notifier).leaveTeam(team.id);
      } else {
        await ref.read(hangoutJoinsProvider.notifier).leaveHangout(team.id);
      }
      ref.invalidate(teamMembersProvider(team.id));

      // Show success message with undo action AFTER successful operation
      if (!context.mounted) return;
      UIUtils.showWarning(
        context,
        l10n.leftTeam(team.name),
        action: SnackBarAction(
          label: l10n.undo,
          textColor: Colors.white,
          onPressed: () => _handleJoinOrApply(context, ref),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      UIUtils.showError(context, l10n.failedToLeaveTeam(team.name));
    }
  }

  /// Handles cancelling an application
  Future<void> _handleCancelApplication(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;

    try {
      await ref.read(teamApplicationsProvider.notifier).cancelApplication(team.id);
      ref.invalidate(teamMembersProvider(team.id));

      // Show success message AFTER successful operation
      if (!context.mounted) return;
      UIUtils.showWarning(
        context,
        l10n.cancelledApplication(team.name),
        action: SnackBarAction(
          label: l10n.reapply,
          textColor: Colors.white,
          onPressed: () => _handleJoinOrApply(context, ref),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      UIUtils.showError(context, l10n.failedToCancelApplication);
    }
  }

  /// Handles joining or applying to a team
  Future<void> _handleJoinOrApply(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final isConnectGroup = team.type == TeamType.connectGroup;

    try {
      if (isConnectGroup) {
        await ref.read(teamApplicationsProvider.notifier).applyToTeam(team.id);
      } else {
        await ref.read(hangoutJoinsProvider.notifier).joinHangout(team.id);
      }
      ref.invalidate(teamMembersProvider(team.id));

      // Show success message AFTER successful operation
      if (!context.mounted) return;
      UIUtils.showSuccess(
        context,
        isConnectGroup
            ? l10n.applicationSubmitted(team.name)
            : l10n.joinedTeam(team.name),
      );
    } catch (e) {
      if (!context.mounted) return;
      UIUtils.showError(
        context,
        isConnectGroup
            ? l10n.failedToApplyTeam(team.name)
            : l10n.failedToJoinTeam(team.name),
      );
    }
  }
}

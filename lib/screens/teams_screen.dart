import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/teams_provider.dart';
import '../providers/permissions_provider.dart';
import '../providers/team_applications_provider.dart';
import '../providers/hangout_joins_provider.dart';
import '../providers/team_members_provider.dart';
import '../models/team.dart';
import '../widgets/team_info_row.dart';
import '../widgets/team_tab_content.dart';

class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectGroups = ref.watch(connectGroupsProvider);
    final hangouts = ref.watch(hangoutsProvider);
    final permissions = ref.watch(permissionsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teams'),
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Connect Groups'),
              Tab(text: 'Hangouts'),
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
                onPressed: () => context.push('/create-team'),
                icon: const Icon(Icons.add),
                label: const Text('Create Team'),
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
    return TeamTabContent(
      teams: teams,
      title: 'About Connect Groups',
      description:
          'Connect Groups are regular, application-based gatherings focused on spiritual growth, fellowship, and discipleship. These groups require commitment and may have specific requirements.',
      sectionTitle: 'Available Groups',
      icon: Icons.info_outline,
      color: Theme.of(context).primaryColor,
      emptyIcon: Icons.groups_outlined,
      emptyTitle: 'No Connect Groups Available',
      emptySubtitle: 'Check back later for new groups',
    );
  }
}

// FIXED P0-8: Simplified using TeamTabContent widget (eliminated ~97 lines of duplication)
class HangoutsTab extends StatelessWidget {
  final List<Team> teams;

  const HangoutsTab({super.key, required this.teams});

  @override
  Widget build(BuildContext context) {
    return TeamTabContent(
      teams: teams,
      title: 'About Hangouts',
      description:
          'Hangouts are open, casual events for fellowship, fun, and building relationships. Everyone is welcome to join - no application required!',
      sectionTitle: 'Join a Hangout',
      icon: Icons.celebration,
      color: Colors.orange,
      emptyIcon: Icons.sports_soccer,
      emptyTitle: 'No Hangouts Available',
      emptySubtitle: 'Check back later for new activities',
    );
  }
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
    final isLoading = team.requiresApplication
        ? applicationsState.loadingTeams.contains(team.id)
        : hangoutJoinsState.loadingHangouts.contains(team.id);

    return Card(
      child: InkWell(
        onTap: () => context.push('/team/${team.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      team.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (team.requiresApplication)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'APPLICATION REQUIRED',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'OPEN TO ALL',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                team.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Led by ${team.leader}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.group,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${team.currentMembers} members',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              // Meeting time and location info
              if (team.meetingTime != null || team.meetingLocation != null) ...[
                const SizedBox(height: 8),
                TeamMeetingInfo(team: team),
              ],
              if (team.maxMembers != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${team.currentMembers}/${team.maxMembers} spots filled',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: (team.maxMembers != null &&
                                  team.currentMembers >= team.maxMembers! &&
                                  !isMember &&
                                  !hasApplied) ||
                              isLoading
                          ? null
                          : () async {
                              // Unified logic for both Connect Groups and Hangouts
                              if (isMember) {
                                // Already a member → Leave
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Left ${team.name}'),
                                    backgroundColor: Colors.orange,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );

                                try {
                                  if (team.requiresApplication) {
                                    await ref
                                        .read(teamsProvider.notifier)
                                        .leaveTeam(team.id);
                                  } else {
                                    await ref
                                        .read(hangoutJoinsProvider.notifier)
                                        .leaveHangout(team.id);
                                  }
                                  ref.read(teamMembershipProvider.notifier)
                                      .invalidateMembership(team.id);
                                  ref.invalidate(teamMembersProvider(team.id));
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Failed to leave ${team.name}. Please try again.'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } else if (hasApplied) {
                                // Application pending → Cancel
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Cancelled application to ${team.name}'),
                                    backgroundColor: Colors.orange,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );

                                try {
                                  await ref
                                      .read(teamApplicationsProvider.notifier)
                                      .cancelApplication(team.id);
                                  ref.read(teamMembershipProvider.notifier)
                                      .invalidateMembership(team.id);
                                  ref.invalidate(teamMembersProvider(team.id));
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Failed to cancel application. Please try again.'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } else {
                                // Not a member and no pending application → Join/Apply
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(team.requiresApplication
                                        ? 'Applied to ${team.name}!'
                                        : 'Joined ${team.name}!'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );

                                try {
                                  if (team.requiresApplication) {
                                    await ref
                                        .read(teamApplicationsProvider.notifier)
                                        .applyToTeam(team.id);
                                  } else {
                                    await ref
                                        .read(hangoutJoinsProvider.notifier)
                                        .joinHangout(team.id);
                                  }
                                  ref.read(teamMembershipProvider.notifier)
                                      .invalidateMembership(team.id);
                                  ref.invalidate(teamMembersProvider(team.id));
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(team.requiresApplication
                                          ? 'Failed to apply to ${team.name}. Please try again.'
                                          : 'Failed to join ${team.name}. Please try again.'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                      style: (isMember || hasApplied)
                          ? ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            )
                          : null,
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              team.maxMembers != null &&
                                      team.currentMembers >= team.maxMembers! &&
                                      !isMember &&
                                      !hasApplied
                                  ? 'Full'
                                  : isMember
                                      ? 'Leave'
                                      : hasApplied
                                          ? 'Cancel'
                                          : team.requiresApplication
                                              ? 'Apply'
                                              : 'Join',
                            ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${team.currentMembers} active members',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              // Unified logic for both Connect Groups and Hangouts
                              if (isMember) {
                                // Already a member → Leave
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Left ${team.name}'),
                                    backgroundColor: Colors.orange,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );

                                try {
                                  if (team.requiresApplication) {
                                    await ref
                                        .read(teamsProvider.notifier)
                                        .leaveTeam(team.id);
                                  } else {
                                    await ref
                                        .read(hangoutJoinsProvider.notifier)
                                        .leaveHangout(team.id);
                                  }
                                  ref.read(teamMembershipProvider.notifier)
                                      .invalidateMembership(team.id);
                                  ref.invalidate(teamMembersProvider(team.id));
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Failed to leave ${team.name}. Please try again.'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } else if (hasApplied) {
                                // Application pending → Cancel
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Cancelled application to ${team.name}'),
                                    backgroundColor: Colors.orange,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );

                                try {
                                  await ref
                                      .read(teamApplicationsProvider.notifier)
                                      .cancelApplication(team.id);
                                  ref.read(teamMembershipProvider.notifier)
                                      .invalidateMembership(team.id);
                                  ref.invalidate(teamMembersProvider(team.id));
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Failed to cancel application. Please try again.'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } else {
                                // Not a member and no pending application → Join/Apply
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(team.requiresApplication
                                        ? 'Applied to ${team.name}!'
                                        : 'Joined ${team.name}!'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );

                                try {
                                  if (team.requiresApplication) {
                                    await ref
                                        .read(teamApplicationsProvider.notifier)
                                        .applyToTeam(team.id);
                                  } else {
                                    await ref
                                        .read(hangoutJoinsProvider.notifier)
                                        .joinHangout(team.id);
                                  }
                                  ref.read(teamMembershipProvider.notifier)
                                      .invalidateMembership(team.id);
                                  ref.invalidate(teamMembersProvider(team.id));
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(team.requiresApplication
                                          ? 'Failed to apply to ${team.name}. Please try again.'
                                          : 'Failed to join ${team.name}. Please try again.'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                      style: (isMember || hasApplied)
                          ? ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            )
                          : null,
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isMember
                              ? 'Leave'
                              : hasApplied
                                  ? 'Cancel'
                                  : team.requiresApplication
                                      ? 'Apply'
                                      : 'Join'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

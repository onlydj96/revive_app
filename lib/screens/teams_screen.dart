import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/teams_provider.dart';
import '../providers/permissions_provider.dart';
import '../providers/team_applications_provider.dart';
import '../providers/hangout_joins_provider.dart';
import '../models/team.dart';

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

class ConnectGroupsTab extends StatelessWidget {
  final List<Team> teams;

  const ConnectGroupsTab({super.key, required this.teams});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'About Connect Groups',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect Groups are regular, application-based gatherings focused on spiritual growth, fellowship, and discipleship. These groups require commitment and may have specific requirements.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            'Available Groups',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (teams.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Connect Groups Available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Check back later for new groups',
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
    );
  }
}

class HangoutsTab extends StatelessWidget {
  final List<Team> teams;

  const HangoutsTab({super.key, required this.teams});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'About Hangouts',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Hangouts are open, casual events for fellowship, fun, and building relationships. Everyone is welcome to join - no application required!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            'Join a Hangout',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (teams.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Hangouts Available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Check back later for new activities',
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
    final hasApplied = applicationsState.appliedTeams.contains(team.id);
    final hasJoined = hangoutJoinsState.joinedHangouts.contains(team.id);
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
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
              
              if (team.meetingTime != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('EEEE').format(team.meetingTime!)}s at ${DateFormat('h:mm a').format(team.meetingTime!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (team.meetingLocation != null) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          team.meetingLocation!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: (team.maxMembers != null && 
                          team.currentMembers >= team.maxMembers! && 
                          !(team.requiresApplication ? hasApplied : hasJoined)) || isLoading
                          ? null
                          : () async {
                              if (team.requiresApplication) {
                                if (hasApplied) {
                                  // Show optimistic feedback immediately
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Left ${team.name}'),
                                      backgroundColor: Colors.orange,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  
                                  try {
                                    // Cancel application
                                    await ref.read(teamApplicationsProvider.notifier).cancelApplication(team.id);
                                  } catch (e) {
                                    // Show error message if operation failed
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to leave ${team.name}. Please try again.'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } else {
                                  // Show optimistic feedback immediately
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Applied to ${team.name}!'),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  
                                  try {
                                    // Apply to team
                                    await ref.read(teamApplicationsProvider.notifier).applyToTeam(team.id);
                                  } catch (e) {
                                    // Show error message if operation failed
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to apply to ${team.name}. Please try again.'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                // For hangouts
                                if (hasJoined) {
                                  // Show optimistic feedback immediately
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Left ${team.name}'),
                                      backgroundColor: Colors.orange,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  
                                  try {
                                    // Leave hangout
                                    await ref.read(hangoutJoinsProvider.notifier).leaveHangout(team.id);
                                  } catch (e) {
                                    // Show error message if operation failed
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to leave ${team.name}. Please try again.'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } else {
                                  // Show optimistic feedback immediately
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Joined ${team.name}!'),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  
                                  try {
                                    // Join hangout
                                    await ref.read(hangoutJoinsProvider.notifier).joinHangout(team.id);
                                  } catch (e) {
                                    // Show error message if operation failed
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to join ${team.name}. Please try again.'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                      style: (team.requiresApplication ? hasApplied : hasJoined) ? 
                          ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ) : null,
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              team.maxMembers != null && 
                                  team.currentMembers >= team.maxMembers! &&
                                  !(team.requiresApplication ? hasApplied : hasJoined)
                                  ? 'Full'
                                  : team.requiresApplication
                                      ? (hasApplied ? 'Leave' : 'Apply')
                                      : (hasJoined ? 'Leave' : 'Join'),
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
                      onPressed: isLoading ? null : () async {
                        if (team.requiresApplication) {
                          if (hasApplied) {
                            // Show optimistic feedback immediately
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Left ${team.name}'),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            
                            try {
                              // Cancel application
                              await ref.read(teamApplicationsProvider.notifier).cancelApplication(team.id);
                            } catch (e) {
                              // Show error message if operation failed
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to leave ${team.name}. Please try again.'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          } else {
                            // Show optimistic feedback immediately
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Applied to ${team.name}!'),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            
                            try {
                              // Apply to team
                              await ref.read(teamApplicationsProvider.notifier).applyToTeam(team.id);
                            } catch (e) {
                              // Show error message if operation failed
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to apply to ${team.name}. Please try again.'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        } else {
                          // For hangouts
                          if (hasJoined) {
                            // Show optimistic feedback immediately
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Left ${team.name}'),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            
                            try {
                              // Leave hangout
                              await ref.read(hangoutJoinsProvider.notifier).leaveHangout(team.id);
                            } catch (e) {
                              // Show error message if operation failed
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to leave ${team.name}. Please try again.'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          } else {
                            // Show optimistic feedback immediately
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Joined ${team.name}!'),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            
                            try {
                              // Join hangout
                              await ref.read(hangoutJoinsProvider.notifier).joinHangout(team.id);
                            } catch (e) {
                              // Show error message if operation failed
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to join ${team.name}. Please try again.'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: (team.requiresApplication ? hasApplied : hasJoined) ? 
                          ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ) : null,
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(team.requiresApplication 
                              ? (hasApplied ? 'Leave' : 'Apply') 
                              : (hasJoined ? 'Leave' : 'Join')),
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
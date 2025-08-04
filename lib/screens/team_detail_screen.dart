import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/teams_provider.dart';
import '../providers/permissions_provider.dart';
import '../providers/team_members_provider.dart';
import '../providers/team_applications_provider.dart';
import '../models/team.dart';

class TeamDetailScreen extends ConsumerWidget {
  final String teamId;

  const TeamDetailScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamsProvider);
    final permissions = ref.watch(permissionsProvider);
    final applicationsState = ref.watch(teamApplicationsProvider);
    
    final team = teams.where((t) => t.id == teamId).firstOrNull;
    final hasApplied = applicationsState.appliedTeams.contains(teamId);
    final isLoading = applicationsState.loadingTeams.contains(teamId);
    
    if (team == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Team Not Found')),
        body: const Center(
          child: Text('Team not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        actions: permissions.isAdmin ? [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditTeamDialog(context, ref, team);
                  break;
                case 'delete':
                  _showDeleteConfirmation(context, ref, team);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Team'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Team'),
                  ],
                ),
              ),
            ],
          ),
        ] : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            if (team.imageUrl != null)
              SizedBox(
                height: 200,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: team.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  team.type == TeamType.connectGroup ? Icons.groups : Icons.celebration,
                  size: 80,
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: team.type == TeamType.connectGroup 
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: team.type == TeamType.connectGroup 
                            ? Theme.of(context).primaryColor.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      team.type == TeamType.connectGroup ? 'Connect Group' : 'Hangout',
                      style: TextStyle(
                        color: team.type == TeamType.connectGroup 
                            ? Theme.of(context).primaryColor
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Team Name
                  Text(
                    team.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Leader
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Led by ${team.leader}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'About This ${team.type == TeamType.connectGroup ? 'Group' : 'Hangout'}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    team.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Meeting Details
                  if (team.meetingTime != null || team.meetingLocation != null) ...[
                    Text(
                      'Meeting Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (team.meetingTime != null)
                      _buildInfoRow(
                        context,
                        Icons.access_time,
                        'When',
                        '${DateFormat('EEEE').format(team.meetingTime!)}s at ${DateFormat('h:mm a').format(team.meetingTime!)}',
                      ),
                    
                    if (team.meetingLocation != null)
                      _buildInfoRow(
                        context,
                        Icons.location_on,
                        'Where',
                        team.meetingLocation!,
                      ),
                    
                    const SizedBox(height: 24),
                  ],
                  
                  // Membership Info
                  Text(
                    'Membership',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildInfoRow(
                    context,
                    Icons.group,
                    'Current Members',
                    '${team.currentMembers}${team.maxMembers != null ? ' of ${team.maxMembers}' : ''} members',
                  ),
                  
                  _buildInfoRow(
                    context,
                    team.requiresApplication ? Icons.assignment : Icons.door_front_door_outlined,
                    'Joining',
                    team.requiresApplication ? 'Application Required' : 'Open to All',
                  ),
                  
                  // Requirements
                  if (team.requirements.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Requirements',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...team.requirements.map((requirement) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              requirement,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],

                  // Team Members Section
                  const SizedBox(height: 24),
                  _buildMembersSection(context, ref, team),
                  
                  const SizedBox(height: 32),
                  
                  // Join/Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (team.maxMembers != null && 
                          team.currentMembers >= team.maxMembers!) || isLoading
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
                                    await ref.read(teamApplicationsProvider.notifier).cancelApplication(team.id);
                                  } catch (e) {
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
                                    await ref.read(teamApplicationsProvider.notifier).applyToTeam(team.id);
                                  } catch (e) {
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
                                // Show optimistic feedback immediately
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Joined ${team.name}!'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                
                                ref.read(teamsProvider.notifier).joinTeam(team.id);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: hasApplied && team.requiresApplication ? Colors.orange : null,
                        foregroundColor: hasApplied && team.requiresApplication ? Colors.white : null,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              team.maxMembers != null && 
                                  team.currentMembers >= team.maxMembers!
                                  ? 'Team Full'
                                  : team.requiresApplication
                                      ? (hasApplied ? 'Leave Team' : 'Apply to Join')
                                      : 'Join This ${team.type == TeamType.connectGroup ? 'Group' : 'Hangout'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context, WidgetRef ref, Team team) {
    final membersAsync = ref.watch(teamMembersProvider(team.id));
    final permissions = ref.watch(permissionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Team Members',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (permissions.isAdmin)
              Text(
                '${team.currentMembers} members',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        membersAsync.when(
          data: (members) {
            if (members.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people_outline, color: Colors.grey[500]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No members have joined yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: members.map((member) => _buildMemberCard(context, member, permissions.isAdmin)).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to load members',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, TeamMember member, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            backgroundImage: member.userAvatar != null 
                ? CachedNetworkImageProvider(member.userAvatar!)
                : null,
            child: member.userAvatar == null
                ? Text(
                    member.userName.isNotEmpty ? member.userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // Member info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.userName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (member.userEmail != null && isAdmin)
                  Text(
                    member.userEmail!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                Text(
                  'Joined ${DateFormat('MMM d, yyyy').format(member.joinedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(member.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusText(member.status),
              style: TextStyle(
                color: _getStatusColor(member.status),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'member':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
      case 'member':
        return 'Member';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
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

  void _showApplicationDialog(BuildContext context, WidgetRef ref, Team team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply to ${team.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are applying to join this ${team.type == TeamType.connectGroup ? 'Connect Group' : 'Hangout'}.'),
            if (team.requirements.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Requirements:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...team.requirements.map((req) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(req)),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 16),
            const Text('Your application will be reviewed by the team leader.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Application submitted for ${team.name}!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit Application'),
          ),
        ],
      ),
    );
  }

  void _showEditTeamDialog(BuildContext context, WidgetRef ref, Team team) {
    final nameController = TextEditingController(text: team.name);
    final descriptionController = TextEditingController(text: team.description);
    final leaderController = TextEditingController(text: team.leader);
    final locationController = TextEditingController(text: team.meetingLocation ?? '');
    final imageUrlController = TextEditingController(text: team.imageUrl ?? '');
    final maxMembersController = TextEditingController(text: team.maxMembers?.toString() ?? '');
    
    TeamType selectedType = team.type;
    bool requiresApplication = team.requiresApplication;
    DateTime? selectedTime = team.meetingTime;
    List<String> requirements = List.from(team.requirements);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Team'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Team Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TeamType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Team Type'),
                    items: const [
                      DropdownMenuItem(value: TeamType.connectGroup, child: Text('Connect Group')),
                      DropdownMenuItem(value: TeamType.hangout, child: Text('Hangout')),
                    ],
                    onChanged: (value) => setState(() => selectedType = value!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: leaderController,
                    decoration: const InputDecoration(labelText: 'Leader'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Meeting Location'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: maxMembersController,
                    decoration: const InputDecoration(labelText: 'Max Members (optional)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Requires Application'),
                    value: requiresApplication,
                    onChanged: (value) => setState(() => requiresApplication = value!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedTeam = team.copyWith(
                  name: nameController.text,
                  description: descriptionController.text,
                  type: selectedType,
                  leader: leaderController.text,
                  meetingLocation: locationController.text.isEmpty ? null : locationController.text,
                  imageUrl: imageUrlController.text.isEmpty ? null : imageUrlController.text,
                  maxMembers: maxMembersController.text.isEmpty ? null : int.tryParse(maxMembersController.text),
                  requiresApplication: requiresApplication,
                  meetingTime: selectedTime,
                  requirements: requirements,
                );
                
                ref.read(teamsProvider.notifier).updateTeam(updatedTeam);
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Team updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Team team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text('Are you sure you want to delete "${team.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(teamsProvider.notifier).deleteTeam(team.id);
              Navigator.of(context).pop();
              context.pop(); // Go back to teams list
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${team.name} deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
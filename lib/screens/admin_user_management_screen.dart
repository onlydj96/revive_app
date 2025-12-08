import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../providers/permissions_provider.dart';
import '../providers/user_provider.dart';

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState
    extends ConsumerState<AdminUserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final users =
          await SupabaseService.getAll('user_profiles', orderBy: 'full_name');

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }

    return _users.where((user) {
      final name = (user['full_name'] as String? ?? '').toLowerCase();
      final email = (user['email'] as String? ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();

      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionsProvider);

    if (!permissions.canManageUsers) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('You do not have permission to manage users.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(
                        child: Text('No users found.'),
                      )
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return UserListTile(
                            user: user,
                            onRoleChanged: (newRole) async {
                              await _updateUserRole(user['id'], newRole);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await ref.read(userProvider.notifier).updateUserRole(userId, newRole);
      await _loadUsers(); // Refresh the list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User role updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user role: $e')),
        );
      }
    }
  }
}

class UserListTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final Function(String) onRoleChanged;

  const UserListTile({
    super.key,
    required this.user,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final role = user['role'] as String? ?? 'member';
    final isAdmin = role == 'admin';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isAdmin ? Colors.purple[100] : Colors.blue[100],
          backgroundImage: user['profile_image_url'] != null
              ? NetworkImage(user['profile_image_url'])
              : null,
          child: user['profile_image_url'] == null
              ? Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: isAdmin ? Colors.purple : Colors.blue,
                )
              : null,
        ),
        title: Text(
          user['full_name'] as String? ?? 'Unknown User',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isAdmin ? Colors.purple[800] : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] as String? ?? ''),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isAdmin ? Colors.purple[100] : Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isAdmin ? Colors.purple[800] : Colors.blue[800],
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value != role) {
              _showRoleChangeDialog(context, user, value);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'member',
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 18,
                    color: role == 'member' ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Member',
                    style: TextStyle(
                      fontWeight: role == 'member'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: role == 'member' ? Colors.blue : null,
                    ),
                  ),
                  if (role == 'member') ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check, size: 16, color: Colors.blue),
                  ],
                ],
              ),
            ),
            PopupMenuItem(
              value: 'admin',
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 18,
                    color: role == 'admin' ? Colors.purple : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Admin',
                    style: TextStyle(
                      fontWeight:
                          role == 'admin' ? FontWeight.bold : FontWeight.normal,
                      color: role == 'admin' ? Colors.purple : null,
                    ),
                  ),
                  if (role == 'admin') ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check, size: 16, color: Colors.purple),
                  ],
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showRoleChangeDialog(
      BuildContext context, Map<String, dynamic> user, String newRole) {
    final userName = user['full_name'] as String? ?? 'Unknown User';
    final isPromotingToAdmin = newRole == 'admin';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(isPromotingToAdmin ? 'Promote to Admin' : 'Change to Member'),
        content: Text(
          isPromotingToAdmin
              ? 'Are you sure you want to promote "$userName" to Administrator? They will have full access to create, edit, and delete content.'
              : 'Are you sure you want to change "$userName" to Member? They will lose administrative privileges.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRoleChanged(newRole);
            },
            style: TextButton.styleFrom(
              foregroundColor: isPromotingToAdmin ? Colors.purple : Colors.blue,
            ),
            child: Text(isPromotingToAdmin ? 'Promote' : 'Change'),
          ),
        ],
      ),
    );
  }
}

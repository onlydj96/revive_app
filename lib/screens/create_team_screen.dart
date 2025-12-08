import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/teams_provider.dart';
import '../models/team.dart';

class CreateTeamScreen extends ConsumerStatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _leaderController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _maxMembersController = TextEditingController();

  // Focus nodes for auto-scroll to invalid fields
  final _nameFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _leaderFocus = FocusNode();

  // Scroll controller for auto-scrolling
  final _scrollController = ScrollController();

  TeamType _selectedType = TeamType.hangout;
  TeamCategory _selectedCategory = TeamCategory.fellowship;
  bool _requiresApplication = false;
  DateTime? _selectedTime;
  final List<String> _requirements = [];
  final _requirementController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _leaderController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    _maxMembersController.dispose();
    _requirementController.dispose();
    _nameFocus.dispose();
    _descriptionFocus.dispose();
    _leaderFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Team'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTeam,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(
                  labelText: 'Team Name *',
                  hintText: 'Enter the team name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Team name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                focusNode: _descriptionFocus,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe what this team is about',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<TeamType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Team Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: TeamType.connectGroup,
                    child: Text('Connect Group'),
                  ),
                  DropdownMenuItem(
                    value: TeamType.hangout,
                    child: Text('Hangout'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    if (value == TeamType.connectGroup) {
                      _requiresApplication = true;
                    }
                  });
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<TeamCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: TeamCategory.worship,
                    child: Text('Worship'),
                  ),
                  DropdownMenuItem(
                    value: TeamCategory.outreach,
                    child: Text('Outreach'),
                  ),
                  DropdownMenuItem(
                    value: TeamCategory.youth,
                    child: Text('Youth'),
                  ),
                  DropdownMenuItem(
                    value: TeamCategory.children,
                    child: Text('Children'),
                  ),
                  DropdownMenuItem(
                    value: TeamCategory.admin,
                    child: Text('Admin'),
                  ),
                  DropdownMenuItem(
                    value: TeamCategory.fellowship,
                    child: Text('Fellowship'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Leadership Section
              _buildSectionHeader('Leadership'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _leaderController,
                focusNode: _leaderFocus,
                decoration: const InputDecoration(
                  labelText: 'Team Leader *',
                  hintText: 'Who will lead this team?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Team leader is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Meeting Information Section
              _buildSectionHeader('Meeting Information'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Location',
                  hintText: 'Where does this team meet?',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: _selectMeetingTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Meeting Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime != null
                            ? '${_getDayName(_selectedTime!.weekday)} at ${TimeOfDay.fromDateTime(_selectedTime!).format(context)}'
                            : 'Select meeting time',
                        style: TextStyle(
                          color:
                              _selectedTime != null ? null : Colors.grey[600],
                        ),
                      ),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Membership Section
              _buildSectionHeader('Membership'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _maxMembersController,
                decoration: const InputDecoration(
                  labelText: 'Maximum Members (optional)',
                  hintText: 'Leave empty for unlimited',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final number = int.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Please enter a valid positive number';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CheckboxListTile(
                title: const Text('Requires Application'),
                subtitle: const Text('Members need to apply to join this team'),
                value: _requiresApplication,
                onChanged: _selectedType == TeamType.connectGroup
                    ? null
                    : (value) {
                        setState(() {
                          _requiresApplication = value!;
                        });
                      },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 24),

              // Requirements Section (only show if requires application)
              if (_requiresApplication) ...[
                _buildSectionHeader('Requirements'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _requirementController,
                        decoration: const InputDecoration(
                          labelText: 'Add Requirement',
                          hintText: 'e.g., Must be a church member',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: _addRequirement,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addRequirement,
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_requirements.isNotEmpty) ...[
                  Text(
                    'Requirements:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ..._requirements.asMap().entries.map((entry) {
                    final index = entry.key;
                    final requirement = entry.value;
                    return Card(
                      child: ListTile(
                        leading:
                            const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(requirement),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeRequirement(index),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ],

              // Image Section
              _buildSectionHeader('Image (optional)'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.isAbsolute) {
                      return 'Please enter a valid URL';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTeam,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          'Create ${_selectedType == TeamType.connectGroup ? 'Connect Group' : 'Hangout'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
    );
  }

  void _selectMeetingTime() async {
    // First select day of week
    final selectedDay = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Meeting Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 1; i <= 7; i++)
              ListTile(
                title: Text(_getDayName(i)),
                onTap: () => Navigator.of(context).pop(i),
              ),
          ],
        ),
      ),
    );

    if (selectedDay != null && mounted) {
      // Then select time
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        setState(() {
          _selectedTime = DateTime(
              2024, 1, selectedDay, selectedTime.hour, selectedTime.minute);
        });
      }
    }
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  void _addRequirement([String? value]) {
    final requirement = value ?? _requirementController.text.trim();
    if (requirement.isNotEmpty && !_requirements.contains(requirement)) {
      setState(() {
        _requirements.add(requirement);
        _requirementController.clear();
      });
    }
  }

  void _removeRequirement(int index) {
    setState(() {
      _requirements.removeAt(index);
    });
  }

  Future<void> _saveTeam() async {
    if (!_formKey.currentState!.validate()) {
      // Find and scroll to the first invalid field
      if (_nameController.text.trim().isEmpty) {
        _nameFocus.requestFocus();
        await _scrollController.animateTo(
          0, // Scroll to top where name field is
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (_descriptionController.text.trim().isEmpty) {
        _descriptionFocus.requestFocus();
        await _scrollController.animateTo(
          100, // Approximate scroll position for description field
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (_leaderController.text.trim().isEmpty) {
        _leaderFocus.requestFocus();
        await _scrollController.animateTo(
          400, // Approximate scroll position for leader field
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final team = Team(
        id: '', // Will be generated by Supabase
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        category: _selectedCategory,
        leader: _leaderController.text.trim(),
        meetingLocation: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        meetingTime: _selectedTime,
        imageUrl: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : null,
        requiresApplication: _requiresApplication,
        maxMembers: _maxMembersController.text.trim().isNotEmpty
            ? int.tryParse(_maxMembersController.text.trim())
            : null,
        currentMembers: 0,
        requirements: _requirements,
      );

      await ref.read(teamsProvider.notifier).addTeam(team);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${team.name} created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating team: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

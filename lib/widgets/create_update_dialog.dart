import 'package:flutter/material.dart';
import '../models/update.dart';

class CreateUpdateDialog extends StatefulWidget {
  final Function(String title, String content, UpdateType type, String? imageUrl, bool isPinned, List<String> tags) onCreateUpdate;

  const CreateUpdateDialog({
    super.key,
    required this.onCreateUpdate,
  });

  @override
  State<CreateUpdateDialog> createState() => _CreateUpdateDialogState();
}

class _CreateUpdateDialogState extends State<CreateUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _tagsController = TextEditingController();
  
  UpdateType _selectedType = UpdateType.announcement;
  bool _isPinned = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Update'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<UpdateType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: UpdateType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getUpdateTypeIcon(type), size: 18),
                      const SizedBox(width: 8),
                      Text(_getUpdateTypeLabel(type)),
                    ],
                  ),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. service, easter, youth',
                ),
              ),
              const SizedBox(height: 16),
              
              CheckboxListTile(
                title: const Text('Pin this update'),
                subtitle: const Text('Pinned updates appear at the top'),
                value: _isPinned,
                onChanged: (value) {
                  setState(() {
                    _isPinned = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCreate,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      await widget.onCreateUpdate(
        _titleController.text.trim(),
        _contentController.text.trim(),
        _selectedType,
        _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        _isPinned,
        tags,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Error handling is done in the parent widget
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getUpdateTypeIcon(UpdateType type) {
    switch (type) {
      case UpdateType.announcement:
        return Icons.campaign;
      case UpdateType.news:
        return Icons.newspaper;
      case UpdateType.prayer:
        return Icons.favorite;
      case UpdateType.celebration:
        return Icons.celebration;
      case UpdateType.urgent:
        return Icons.priority_high;
    }
  }

  String _getUpdateTypeLabel(UpdateType type) {
    switch (type) {
      case UpdateType.announcement:
        return 'Announcement';
      case UpdateType.news:
        return 'News';
      case UpdateType.prayer:
        return 'Prayer Request';
      case UpdateType.celebration:
        return 'Celebration';
      case UpdateType.urgent:
        return 'Urgent';
    }
  }
}
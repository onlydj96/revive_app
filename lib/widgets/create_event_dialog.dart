import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

class CreateEventDialog extends StatefulWidget {
  final Function(Event) onEventCreated;

  const CreateEventDialog({super.key, required this.onEventCreated});

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);
  
  EventType _selectedType = EventType.service;
  bool _isHighlighted = false;
  bool _requiresSignup = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_note, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Create New Event',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title *',
                          hintText: 'Enter event title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter an event title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          hintText: 'Enter event description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location *',
                          hintText: 'Enter event location',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Event Type
                      DropdownButtonFormField<EventType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Event Type',
                          border: OutlineInputBorder(),
                        ),
                        items: EventType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getEventTypeLabel(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Start Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setState(() {
                                    _startDate = date;
                                    // Update end date if it's before start date
                                    if (_endDate.isBefore(_startDate)) {
                                      _endDate = _startDate;
                                    }
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Start Date',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(DateFormat('MMM d, yyyy').format(_startDate)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _startTime,
                                );
                                if (time != null) {
                                  setState(() {
                                    _startTime = time;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Start Time',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(_startTime.format(context)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // End Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: _startDate,
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setState(() {
                                    _endDate = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'End Date',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(DateFormat('MMM d, yyyy').format(_endDate)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _endTime,
                                );
                                if (time != null) {
                                  setState(() {
                                    _endTime = time;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'End Time',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(_endTime.format(context)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Image URL (optional)
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (optional)',
                          hintText: 'Enter image URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Checkboxes
                      CheckboxListTile(
                        title: const Text('Featured Event'),
                        subtitle: const Text('Show this event prominently'),
                        value: _isHighlighted,
                        onChanged: (value) {
                          setState(() {
                            _isHighlighted = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      CheckboxListTile(
                        title: const Text('Requires Sign-up'),
                        subtitle: const Text('Allow people to register for this event'),
                        value: _requiresSignup,
                        onChanged: (value) {
                          setState(() {
                            _requiresSignup = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      // Max participants (if signup required)
                      if (_requiresSignup) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _maxParticipantsController,
                          decoration: const InputDecoration(
                            labelText: 'Max Participants (optional)',
                            hintText: 'Enter maximum number of participants',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isNotEmpty == true) {
                              final number = int.tryParse(value!);
                              if (number == null || number <= 0) {
                                return 'Please enter a valid positive number';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _createEvent,
                    child: const Text('Create Event'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createEvent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final startDateTime = _combineDateTime(_startDate, _startTime);
    final endDateTime = _combineDateTime(_endDate, _endTime);

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final event = Event(
      id: '', // Will be generated by database
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      location: _locationController.text.trim(),
      type: _selectedType,
      imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
      isHighlighted: _isHighlighted,
      requiresSignup: _requiresSignup,
      maxParticipants: _requiresSignup && _maxParticipantsController.text.isNotEmpty
          ? int.tryParse(_maxParticipantsController.text)
          : null,
      currentParticipants: 0,
    );

    widget.onEventCreated(event);
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.service:
        return 'Service';
      case EventType.connectGroup:
        return 'Connect Group';
      case EventType.hangout:
        return 'Hangout';
      case EventType.special:
        return 'Special Event';
      case EventType.training:
        return 'Training';
    }
  }
}
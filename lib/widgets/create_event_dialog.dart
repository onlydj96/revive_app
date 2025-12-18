import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event.dart';
import '../services/storage_service.dart';
import 'recurrence_picker.dart';
import 'time_picker_5min.dart';

class CreateEventDialog extends StatefulWidget {
  final Function(Event) onEventCreated;
  final DateTime? initialDate;

  const CreateEventDialog({
    super.key,
    required this.onEventCreated,
    this.initialDate,
  });

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  // Focus nodes for auto-scroll
  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _locationFocus = FocusNode();

  // Scroll controller
  final _scrollController = ScrollController();

  // State variables
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  int _currentStep = 0;

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;

  EventType _selectedType = EventType.service;
  bool _isHighlighted = false;
  bool _requiresSignup = false;
  RecurrenceRule _recurrenceRule = const RecurrenceRule();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Use provided initial date or default to today
    final initialDate = widget.initialDate ?? DateTime.now();
    _startDate = initialDate;
    _endDate = initialDate;
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay(
      hour: (TimeOfDay.now().hour + 1) % 24,
      minute: TimeOfDay.now().minute,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _locationFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.service:
        return Icons.church;
      case EventType.connectGroup:
        return Icons.group;
      case EventType.hangout:
        return Icons.celebration;
      case EventType.special:
        return Icons.star;
      case EventType.training:
        return Icons.school;
    }
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.service:
        return Colors.purple;
      case EventType.connectGroup:
        return Colors.blue;
      case EventType.hangout:
        return Colors.orange;
      case EventType.special:
        return Colors.red;
      case EventType.training:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create New Event',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Fill in the details to create an event',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Steps
                  Row(
                    children: [
                      _buildStepIndicator(0, 'Basic Info'),
                      _buildStepConnector(0),
                      _buildStepIndicator(1, 'Schedule'),
                      _buildStepConnector(1),
                      _buildStepIndicator(2, 'Settings'),
                    ],
                  ),
                ],
              ),
            ),

            // Form Content with Steps
            Expanded(
              child: Form(
                key: _formKey,
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    // Step 1: Basic Information
                    _buildBasicInfoStep(),
                    // Step 2: Schedule
                    _buildScheduleStep(),
                    // Step 3: Settings & Image
                    _buildSettingsStep(),
                  ],
                ),
              ),
            ),

            // Modern Action Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  const Spacer(),
                  if (_currentStep < 2) ...[
                    FilledButton.icon(
                      onPressed: () {
                        if (_validateCurrentStep()) {
                          setState(() {
                            _currentStep++;
                          });
                        }
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ] else ...[
                    FilledButton.icon(
                      onPressed: _isUploading ? null : _createEvent,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check),
                      label:
                          Text(_isUploading ? 'Creating...' : 'Create Event'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    )
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive
                            ? Theme.of(context).primaryColor
                            : Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: isActive ? 1 : 0.6),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    return Container(
      height: 2,
      width: 40,
      color: _currentStep > step ? Colors.white : Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildBasicInfoStep() {
    return SafeArea(
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Type Selection
          Text(
            'Event Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: EventType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedType = type;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _getEventTypeColor(type).withValues(alpha: 0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? _getEventTypeColor(type)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getEventTypeIcon(type),
                                color: isSelected
                                    ? _getEventTypeColor(type)
                                    : Colors.grey[600],
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getEventTypeLabel(type),
                                style: TextStyle(
                                  color: isSelected
                                      ? _getEventTypeColor(type)
                                      : Colors.grey[600],
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Event Title
          TextFormField(
            controller: _titleController,
            focusNode: _titleFocus,
            decoration: InputDecoration(
              labelText: 'Event Title *',
              hintText: 'Enter a catchy event title',
              prefixIcon:
                  Icon(Icons.title, color: Theme.of(context).primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter an event title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Description (Optional)
          TextFormField(
            controller: _descriptionController,
            focusNode: _descriptionFocus,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'What\'s this event about? (optional)',
              prefixIcon: Icon(Icons.description,
                  color: Theme.of(context).primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Location
          TextFormField(
            controller: _locationController,
            focusNode: _locationFocus,
            decoration: InputDecoration(
              labelText: 'Location *',
              hintText: 'Where will it be held?',
              prefixIcon: Icon(Icons.location_on,
                  color: Theme.of(context).primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter a location';
              }
              return null;
            },
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildScheduleStep() {
    final bool isSameDay = _startDate.year == _endDate.year &&
        _startDate.month == _endDate.month &&
        _startDate.day == _endDate.day;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Combined Event Schedule Section
          Text(
            'Event Schedule',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),

          // Unified Schedule Card
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                // Start Section
                _buildScheduleRow(
                  label: 'Starts',
                  icon: Icons.play_circle_outline,
                  iconColor: Colors.green,
                  dateValue: DateFormat('EEE, MMM d, yyyy').format(_startDate),
                  timeValue: _startTime.format(context),
                  onDateTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2020), // Allow past dates
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                        // Auto-adjust end date if it's before start date
                        if (_endDate.isBefore(_startDate)) {
                          _endDate = _startDate;
                        }
                      });
                    }
                  },
                  onTimeTap: () async {
                    final time = await TimePicker5Min.show(
                      context,
                      initialTime: _startTime,
                      title: 'Start Time',
                    );
                    if (time != null) {
                      setState(() {
                        _startTime = time;
                      });
                    }
                  },
                ),

                // Divider with duration chip
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _calculateDuration(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                ),

                // End Section
                _buildScheduleRow(
                  label: 'Ends',
                  icon: Icons.stop_circle_outlined,
                  iconColor: Colors.red,
                  dateValue: isSameDay
                      ? 'Same day'
                      : DateFormat('EEE, MMM d, yyyy').format(_endDate),
                  timeValue: _endTime.format(context),
                  onDateTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate.isBefore(_startDate)
                          ? _startDate
                          : _endDate,
                      firstDate: _startDate, // End date must be >= start date
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                  onTimeTap: () async {
                    final time = await TimePicker5Min.show(
                      context,
                      initialTime: _endTime,
                      title: 'End Time',
                    );
                    if (time != null) {
                      setState(() {
                        _endTime = time;
                      });
                    }
                  },
                  isEndRow: true,
                ),
              ],
            ),
          ),

          // Past event info banner (only show if start date is in the past)
          if (_startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This event is scheduled in the past',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Recurrence Options
          RecurrencePicker(
            initialRule: _recurrenceRule,
            startDate: _startDate,
            onChanged: (rule) {
              setState(() {
                _recurrenceRule = rule;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow({
    required String label,
    required IconData icon,
    required Color iconColor,
    required String dateValue,
    required String timeValue,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
    bool isEndRow = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: isEndRow ? 12 : 16,
        bottom: isEndRow ? 16 : 12,
      ),
      child: Row(
        children: [
          // Label with icon
          SizedBox(
            width: 70,
            child: Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Date picker
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: onDateTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dateValue,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: dateValue == 'Same day'
                              ? Colors.grey[500]
                              : Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Time picker
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: onTimeTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        timeValue,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          Text(
            'Event Cover Image',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _isUploading ? null : _pickImage,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                image: _selectedImage != null
                    ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _selectedImage == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to upload image',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Recommended: 1920x1080',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 20),
                              onPressed: _removeImage,
                              padding: const EdgeInsets.all(4),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          const SizedBox(height: 24),

          // Event Options
          Text(
            'Event Options',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),

          // Featured Event Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: SwitchListTile(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Featured Event',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Highlight this event',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              value: _isHighlighted,
              onChanged: (value) {
                setState(() {
                  _isHighlighted = value;
                });
              },
              activeColor: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),

          // Requires Signup Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: SwitchListTile(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.how_to_reg,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registration Required',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Allow attendee registration',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              value: _requiresSignup,
              onChanged: (value) {
                setState(() {
                  _requiresSignup = value;
                  if (!value) {
                    _maxParticipantsController.clear();
                  }
                });
              },
              activeColor: Colors.blue,
            ),
          ),

          // Max Participants (if signup required)
          if (_requiresSignup) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxParticipantsController,
              decoration: InputDecoration(
                labelText: 'Maximum Participants',
                hintText: 'Leave empty for unlimited',
                prefixIcon:
                    Icon(Icons.group, color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
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
    );
  }

  String _calculateDuration() {
    final start = _combineDateTime(_startDate, _startTime);
    final end = _combineDateTime(_endDate, _endTime);
    final duration = end.difference(start);

    if (duration.isNegative) {
      return 'Invalid duration';
    }

    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''} ${duration.inHours % 24} hour${duration.inHours % 24 != 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} ${duration.inMinutes % 60} min';
    } else {
      return '${duration.inMinutes} minutes';
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_titleController.text.isEmpty) {
          _titleFocus.requestFocus();
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter event title')),
          );
          return false;
        }
        // Description is now optional - no validation needed
        if (_locationController.text.isEmpty) {
          _locationFocus.requestFocus();
          _scrollController.animateTo(
            200,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter event location')),
          );
          return false;
        }
        return true;
      case 1:
        final startDateTime = _combineDateTime(_startDate, _startTime);
        final endDateTime = _combineDateTime(_endDate, _endTime);
        if (endDateTime.isBefore(startDateTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End time must be after start time'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _uploadedImageUrl = null;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _uploadedImageUrl = null;
    });
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _currentStep = 0;
      });
      return;
    }

    final startDateTime = _combineDateTime(_startDate, _startTime);
    final endDateTime = _combineDateTime(_endDate, _endTime);

    if (endDateTime.isBefore(startDateTime)) {
      setState(() {
        _currentStep = 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Upload image if selected
    String? imageUrl;
    if (_selectedImage != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        final tempEventId = DateTime.now().millisecondsSinceEpoch.toString();
        imageUrl = await StorageService.uploadEventImage(
          eventId: tempEventId,
          file: _selectedImage!,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload image: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isUploading = false;
        });
        return;
      }

      setState(() {
        _isUploading = false;
      });
    }

    final event = Event(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      location: _locationController.text.trim(),
      type: _selectedType,
      imageUrl: imageUrl ?? _uploadedImageUrl,
      isHighlighted: _isHighlighted,
      requiresSignup: _requiresSignup,
      maxParticipants:
          _requiresSignup && _maxParticipantsController.text.isNotEmpty
              ? int.tryParse(_maxParticipantsController.text)
              : null,
      currentParticipants: 0,
      recurrence: _recurrenceRule,
    );

    widget.onEventCreated(event);
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.service:
        return 'Service';
      case EventType.connectGroup:
        return 'Connect';
      case EventType.hangout:
        return 'Hangout';
      case EventType.special:
        return 'Special';
      case EventType.training:
        return 'Training';
    }
  }
}

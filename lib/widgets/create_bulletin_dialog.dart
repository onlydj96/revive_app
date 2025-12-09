import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/bulletin.dart';
import '../providers/bulletin_provider.dart';
import '../utils/ui_utils.dart';

class CreateBulletinDialog extends ConsumerStatefulWidget {
  final Bulletin? bulletin;

  const CreateBulletinDialog({super.key, this.bulletin});

  @override
  ConsumerState<CreateBulletinDialog> createState() =>
      _CreateBulletinDialogState();
}

class _CreateBulletinDialogState extends ConsumerState<CreateBulletinDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TextEditingController _themeController;
  late TextEditingController _bannerUrlController;
  late List<BulletinItem> _items;
  late List<WorshipScheduleItem> _schedule;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.bulletin?.weekOf ?? _getNextSunday();
    _themeController = TextEditingController(text: widget.bulletin?.theme ?? '');
    _bannerUrlController =
        TextEditingController(text: widget.bulletin?.bannerImageUrl ?? '');
    _items = widget.bulletin?.items.map((item) => item).toList() ?? [];
    _schedule =
        widget.bulletin?.schedule.map((item) => item).toList() ?? _getDefaultSchedule();
  }

  @override
  void dispose() {
    _themeController.dispose();
    _bannerUrlController.dispose();
    super.dispose();
  }

  DateTime _getNextSunday() {
    final now = DateTime.now();
    final daysUntilSunday = (7 - now.weekday) % 7;
    return DateTime(now.year, now.month, now.day)
        .add(Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday));
  }

  List<WorshipScheduleItem> _getDefaultSchedule() {
    // Create default bulletin items with matching content
    final defaultItems = [
      {
        'title': 'Welcome & Announcements',
        'content': 'Join us as we welcome everyone and share important church announcements and upcoming events.',
      },
      {
        'title': 'Worship',
        'content': 'Experience powerful worship through music and songs of praise. Let\'s lift our voices together in worship.',
      },
      {
        'title': 'Message',
        'content': 'Hear God\'s word through today\'s sermon. The message will encourage, challenge, and inspire your faith journey.',
      },
      {
        'title': 'Closing Prayer',
        'content': 'We conclude our service with prayer, bringing our needs and thanksgiving before God.',
      },
    ];

    final scheduleItems = <WorshipScheduleItem>[];
    final times = ['10:00 AM', '10:10 AM', '10:40 AM', '11:30 AM'];

    for (int i = 0; i < defaultItems.length; i++) {
      final itemId = '${DateTime.now().millisecondsSinceEpoch}_$i';

      // Create matching bulletin item
      _items.add(
        BulletinItem(
          id: itemId,
          title: defaultItems[i]['title']!,
          content: defaultItems[i]['content']!,
          order: i,
        ),
      );

      // Create schedule item linked to bulletin item
      scheduleItems.add(
        WorshipScheduleItem(
          time: times[i],
          activity: defaultItems[i]['title']!,
          leader: null,
          order: i,
          linkedBulletinItemId: itemId,
        ),
      );
    }

    return scheduleItems;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      selectableDayPredicate: (date) => date.weekday == DateTime.sunday,
      helpText: 'Select Sunday',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addScheduleItem() {
    setState(() {
      // Create matching bulletin item
      final bulletinItemId = DateTime.now().millisecondsSinceEpoch.toString();
      _items.add(
        BulletinItem(
          id: bulletinItemId,
          title: '',
          content: '',
          order: _items.length,
        ),
      );

      _schedule.add(
        WorshipScheduleItem(
          time: '',
          activity: '',
          leader: null,
          order: _schedule.length,
          linkedBulletinItemId: bulletinItemId,
        ),
      );
    });
  }

  void _removeScheduleItem(int index) {
    setState(() {
      final linkedItemId = _schedule[index].linkedBulletinItemId;
      _schedule.removeAt(index);

      // Remove linked bulletin item
      if (linkedItemId != null) {
        _items.removeWhere((item) => item.id == linkedItemId);
      }

      // Reorder
      for (int i = 0; i < _schedule.length; i++) {
        _schedule[i] = _schedule[i].copyWith(order: i);
      }
      for (int i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(order: i);
      }
    });
  }

  void _reorderScheduleItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _schedule.removeAt(oldIndex);
      _schedule.insert(newIndex, item);
      for (int i = 0; i < _schedule.length; i++) {
        _schedule[i] = _schedule[i].copyWith(order: i);
      }
    });
  }

  Future<void> _saveBulletin() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      UIUtils.showError(context, 'Please add at least one bulletin item');
      return;
    }

    if (_schedule.isEmpty) {
      UIUtils.showError(context, 'Please add at least one schedule item');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(bulletinsProvider.notifier);

      if (widget.bulletin == null) {
        await notifier.createBulletin(
          weekOf: _selectedDate,
          theme: _themeController.text,
          bannerImageUrl: _bannerUrlController.text.isEmpty
              ? null
              : _bannerUrlController.text,
          items: _items,
          schedule: _schedule,
        );
        if (mounted) {
          UIUtils.showSuccess(context, 'Bulletin created successfully');
        }
      } else {
        await notifier.updateBulletin(
          bulletinId: widget.bulletin!.id,
          weekOf: _selectedDate,
          theme: _themeController.text,
          bannerImageUrl: _bannerUrlController.text.isEmpty
              ? null
              : _bannerUrlController.text,
          items: _items,
          schedule: _schedule,
        );
        if (mounted) {
          UIUtils.showSuccess(context, 'Bulletin updated successfully');
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        UIUtils.showError(
            context, 'Failed to save bulletin: ${error.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 800),
        child: Column(
          children: [
            AppBar(
              title: Text(
                  widget.bulletin == null ? 'Create Bulletin' : 'Edit Bulletin'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Selection
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Week Of'),
                        subtitle: Text(DateFormat('MMMM d, yyyy').format(_selectedDate)),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),

                      // Theme
                      TextFormField(
                        controller: _themeController,
                        decoration: const InputDecoration(
                          labelText: 'Theme',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a theme';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Banner Image URL
                      TextFormField(
                        controller: _bannerUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Banner Image URL (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Worship Schedule Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Worship Schedule',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addScheduleItem,
                            tooltip: 'Add Schedule Item',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _schedule.length,
                        onReorder: _reorderScheduleItems,
                        itemBuilder: (context, index) {
                          final item = _schedule[index];
                          return Card(
                            key: ValueKey(item.id),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.drag_handle),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: item.time,
                                          decoration: const InputDecoration(
                                            labelText: 'Time',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Required';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            _schedule[index] =
                                                item.copyWith(time: value);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _removeScheduleItem(index),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    initialValue: item.activity,
                                    decoration: const InputDecoration(
                                      labelText: 'Activity Title',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      helperText: 'This will be the title in detail section',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      _schedule[index] =
                                          item.copyWith(activity: value);

                                      // Update matching bulletin item title
                                      final linkedItemId = item.linkedBulletinItemId;
                                      if (linkedItemId != null) {
                                        final itemIndex = _items.indexWhere(
                                          (i) => i.id == linkedItemId,
                                        );
                                        if (itemIndex >= 0) {
                                          _items[itemIndex] =
                                              _items[itemIndex].copyWith(title: value);
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    initialValue: item.leader ?? '',
                                    decoration: const InputDecoration(
                                      labelText: 'Leader (Optional)',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      _schedule[index] = item.copyWith(
                                          leader: value.isEmpty ? null : value);
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  // Content field for the linked bulletin item
                                  Builder(
                                    builder: (context) {
                                      final linkedItemId = item.linkedBulletinItemId;
                                      final linkedItem = linkedItemId != null
                                          ? _items.firstWhere(
                                              (i) => i.id == linkedItemId,
                                              orElse: () => BulletinItem(
                                                id: '',
                                                title: '',
                                                content: '',
                                                order: 0,
                                              ),
                                            )
                                          : null;

                                      return TextFormField(
                                        initialValue: linkedItem?.content ?? '',
                                        decoration: const InputDecoration(
                                          labelText: 'Detail Content',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                          helperText: 'Content shown when clicked',
                                        ),
                                        maxLines: 3,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          if (linkedItemId != null) {
                                            final itemIndex = _items.indexWhere(
                                              (i) => i.id == linkedItemId,
                                            );
                                            if (itemIndex >= 0) {
                                              _items[itemIndex] = _items[itemIndex]
                                                  .copyWith(content: value);
                                            }
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Note about integrated editing
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Each schedule item has matching detail content. Click on a schedule title in the bulletin to see its details.',
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveBulletin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.bulletin == null ? 'Create' : 'Update'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

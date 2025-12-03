import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bulletin.dart';
import '../providers/bulletin_provider.dart';
import '../widgets/common/base_dialog.dart';

class CreateBulletinDialog extends ConsumerStatefulWidget {
  final Bulletin? bulletin;

  const CreateBulletinDialog({super.key, this.bulletin});

  @override
  ConsumerState<CreateBulletinDialog> createState() =>
      _CreateBulletinDialogState();
}

class _CreateBulletinDialogState extends ConsumerState<CreateBulletinDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _themeController;
  late TextEditingController _bannerUrlController;
  late DateTime _selectedDate;
  final List<BulletinItemData> _items = [];

  @override
  void initState() {
    super.initState();
    _themeController =
        TextEditingController(text: widget.bulletin?.theme ?? '');
    _bannerUrlController =
        TextEditingController(text: widget.bulletin?.bannerImageUrl ?? '');
    _selectedDate = widget.bulletin?.weekOf ?? _getNextSunday();

    if (widget.bulletin != null) {
      _items.addAll(
        widget.bulletin!.items.map((item) => BulletinItemData(
              id: item.id,
              titleController: TextEditingController(text: item.title),
              contentController: TextEditingController(text: item.content),
              order: item.order,
            )),
      );
    } else {
      _addDefaultItems();
    }
  }

  DateTime _getNextSunday() {
    final now = DateTime.now();
    final daysUntilSunday = (DateTime.sunday - now.weekday) % 7;
    return DateTime(now.year, now.month, now.day).add(
      Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday),
    );
  }

  void _addDefaultItems() {
    _items.addAll([
      BulletinItemData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titleController: TextEditingController(text: 'Welcome'),
        contentController: TextEditingController(),
        order: 1,
      ),
      BulletinItemData(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        titleController: TextEditingController(text: 'This Week\'s Message'),
        contentController: TextEditingController(),
        order: 2,
      ),
      BulletinItemData(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        titleController: TextEditingController(text: 'Upcoming Events'),
        contentController: TextEditingController(),
        order: 3,
      ),
      BulletinItemData(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        titleController: TextEditingController(text: 'Prayer Requests'),
        contentController: TextEditingController(),
        order: 4,
      ),
      BulletinItemData(
        id: (DateTime.now().millisecondsSinceEpoch + 4).toString(),
        titleController: TextEditingController(text: 'Announcements'),
        contentController: TextEditingController(),
        order: 5,
      ),
    ]);
  }

  @override
  void dispose() {
    _themeController.dispose();
    _bannerUrlController.dispose();
    for (var item in _items) {
      item.titleController.dispose();
      item.contentController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: widget.bulletin == null ? 'Create Bulletin' : 'Edit Bulletin',
      content: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Week Of (Sunday)'),
                subtitle: Text(
                  '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    selectableDayPredicate: (date) =>
                        date.weekday == DateTime.sunday,
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Theme
              TextFormField(
                controller: _themeController,
                decoration: const InputDecoration(
                  labelText: 'Theme *',
                  hintText: 'e.g., Walking in Faith',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a theme';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Banner URL
              TextFormField(
                controller: _bannerUrlController,
                decoration: const InputDecoration(
                  labelText: 'Banner Image URL (Optional)',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Bulletin Items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bulletin Items',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Item ${index + 1}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () => _removeItem(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: item.titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: item.contentController,
                          decoration: const InputDecoration(
                            labelText: 'Content',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveBulletin,
          child: Text(widget.bulletin == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }

  void _addItem() {
    setState(() {
      _items.add(BulletinItemData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titleController: TextEditingController(),
        contentController: TextEditingController(),
        order: _items.length + 1,
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].titleController.dispose();
      _items[index].contentController.dispose();
      _items.removeAt(index);
    });
  }

  void _saveBulletin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Use existing schedule or create default schedule
    final schedule = widget.bulletin?.schedule ??
        [
          WorshipScheduleItem(
            time: '3:30 PM',
            activity: 'Pray Together',
            leader: null,
          ),
          WorshipScheduleItem(
            time: '3:45 - 4:15 PM',
            activity: 'Praise & Worship',
            leader: 'Luke',
          ),
          WorshipScheduleItem(
            time: '4:15 - 4:30 PM',
            activity: 'Break Time & Small Talk',
            leader: null,
          ),
          WorshipScheduleItem(
            time: '4:30 - 5:00 PM',
            activity: 'Sermon',
            leader: 'Sai',
          ),
          WorshipScheduleItem(
            time: '5:00 - 5:10 PM',
            activity: 'Announcements',
            leader: null,
          ),
          WorshipScheduleItem(
            time: '5:10 PM',
            activity: 'Closing',
            leader: null,
          ),
        ];

    final bulletin = Bulletin(
      id: widget.bulletin?.id ??
          'bulletin_${DateTime.now().millisecondsSinceEpoch}',
      weekOf: _selectedDate,
      theme: _themeController.text.trim(),
      bannerImageUrl: _bannerUrlController.text.trim().isEmpty
          ? null
          : _bannerUrlController.text.trim(),
      schedule: schedule,
      items: _items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return BulletinItem(
          id: item.id,
          title: item.titleController.text.trim(),
          content: item.contentController.text.trim(),
          order: index + 1,
        );
      }).toList(),
    );

    if (widget.bulletin == null) {
      ref.read(bulletinsProvider.notifier).addBulletin(bulletin);
    } else {
      ref.read(bulletinsProvider.notifier).updateBulletin(bulletin);
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.bulletin == null
            ? 'Bulletin created successfully'
            : 'Bulletin updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class BulletinItemData {
  final String id;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final int order;

  BulletinItemData({
    required this.id,
    required this.titleController,
    required this.contentController,
    required this.order,
  });
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

/// 반복 일정 선택 위젯
class RecurrencePicker extends StatefulWidget {
  final RecurrenceRule initialRule;
  final DateTime startDate;
  final ValueChanged<RecurrenceRule> onChanged;

  const RecurrencePicker({
    super.key,
    required this.initialRule,
    required this.startDate,
    required this.onChanged,
  });

  @override
  State<RecurrencePicker> createState() => _RecurrencePickerState();
}

class _RecurrencePickerState extends State<RecurrencePicker> {
  late RecurrenceRule _rule;
  late RecurrenceEndType _endType;

  @override
  void initState() {
    super.initState();
    _rule = widget.initialRule;
    _endType = _rule.endDate != null
        ? RecurrenceEndType.onDate
        : _rule.occurrences != null
            ? RecurrenceEndType.afterOccurrences
            : RecurrenceEndType.never;
  }

  @override
  void didUpdateWidget(RecurrencePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRule != widget.initialRule) {
      _rule = widget.initialRule;
      _endType = _rule.endDate != null
          ? RecurrenceEndType.onDate
          : _rule.occurrences != null
              ? RecurrenceEndType.afterOccurrences
              : RecurrenceEndType.never;
    }
  }

  void _updateRule(RecurrenceRule newRule) {
    setState(() {
      _rule = newRule;
    });
    widget.onChanged(newRule);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recurrence Type Selection
        Text(
          'Repeat',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        _buildRecurrenceTypeSelector(),

        // Days of Week Selection (for weekly/biweekly)
        if (_rule.type == RecurrenceType.weekly ||
            _rule.type == RecurrenceType.biweekly) ...[
          const SizedBox(height: 24),
          _buildDaysOfWeekSelector(),
        ],

        // End Options (only show if recurring)
        if (_rule.isRecurring) ...[
          const SizedBox(height: 24),
          _buildEndOptions(),

          // Recurrence Summary
          const SizedBox(height: 16),
          _buildRecurrenceSummary(),
        ],
      ],
    );
  }

  Widget _buildRecurrenceTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: RecurrenceType.values.map((type) {
          final isSelected = _rule.type == type;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Initialize daysOfWeek with start date's weekday for weekly/biweekly
                List<int>? initialDays;
                if (type == RecurrenceType.weekly || type == RecurrenceType.biweekly) {
                  initialDays = [widget.startDate.weekday];
                }

                _updateRule(_rule.copyWith(
                  type: type,
                  daysOfWeek: initialDays,
                  clearEndDate: type == RecurrenceType.none,
                  clearOccurrences: type == RecurrenceType.none,
                ));
                if (type == RecurrenceType.none) {
                  setState(() {
                    _endType = RecurrenceEndType.never;
                  });
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      _getRecurrenceIcon(type),
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        type.displayName,
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[800],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDaysOfWeekSelector() {
    // Day names: 1=Mon, 2=Tue, ..., 7=Sun
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const dayNamesKo = ['월', '화', '수', '목', '금', '토', '일'];
    final selectedDays = _rule.daysOfWeek ?? [widget.startDate.weekday];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat on',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final dayNumber = index + 1; // 1=Mon, 7=Sun
              final isSelected = selectedDays.contains(dayNumber);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    final newDays = List<int>.from(selectedDays);
                    if (isSelected) {
                      // Prevent deselecting the last day
                      if (newDays.length > 1) {
                        newDays.remove(dayNumber);
                      }
                    } else {
                      newDays.add(dayNumber);
                      newDays.sort();
                    }
                    _updateRule(_rule.copyWith(daysOfWeek: newDays));
                  },
                  child: Container(
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        dayNamesKo[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        // Show selected days summary
        if (selectedDays.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Every ${selectedDays.map((d) => dayNames[d - 1]).join(', ')}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEndOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ends',
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
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              // Never
              _buildEndOption(
                RecurrenceEndType.never,
                'Never',
                Icons.all_inclusive,
                null,
              ),
              const Divider(height: 1),
              // On Date
              _buildEndOption(
                RecurrenceEndType.onDate,
                'On date',
                Icons.calendar_today,
                _buildDatePicker(),
              ),
              const Divider(height: 1),
              // After occurrences
              _buildEndOption(
                RecurrenceEndType.afterOccurrences,
                'After',
                Icons.repeat,
                _buildOccurrencesPicker(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEndOption(
    RecurrenceEndType type,
    String label,
    IconData icon,
    Widget? trailing,
  ) {
    final isSelected = _endType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _endType = type;
          });
          _updateEndType(type);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? Theme.of(context).primaryColor : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (trailing != null && isSelected) ...[
                const Spacer(),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final endDate = _rule.endDate ?? widget.startDate.add(const Duration(days: 30));

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: endDate,
          firstDate: widget.startDate,
          lastDate: widget.startDate.add(const Duration(days: 730)),
        );
        if (date != null) {
          _updateRule(_rule.copyWith(
            endDate: date,
            clearOccurrences: true,
          ));
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('MMM d, yyyy').format(endDate),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.edit,
              size: 14,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccurrencesPicker() {
    final occurrences = _rule.occurrences ?? 10;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _showOccurrencesPicker(occurrences),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              '$occurrences',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'occurrences',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showOccurrencesPicker(int currentValue) {
    showDialog(
      context: context,
      builder: (context) => _OccurrencesPickerDialog(
        initialValue: currentValue,
        onSelected: (value) {
          _updateRule(_rule.copyWith(
            occurrences: value,
            clearEndDate: true,
          ));
        },
      ),
    );
  }

  void _updateEndType(RecurrenceEndType type) {
    switch (type) {
      case RecurrenceEndType.never:
        _updateRule(_rule.copyWith(
          clearEndDate: true,
          clearOccurrences: true,
        ));
        break;
      case RecurrenceEndType.onDate:
        _updateRule(_rule.copyWith(
          endDate: _rule.endDate ?? widget.startDate.add(const Duration(days: 30)),
          clearOccurrences: true,
        ));
        break;
      case RecurrenceEndType.afterOccurrences:
        _updateRule(_rule.copyWith(
          occurrences: _rule.occurrences ?? 10,
          clearEndDate: true,
        ));
        break;
    }
  }

  Widget _buildRecurrenceSummary() {
    final description = _rule.getDescription(widget.startDate);
    String endDescription = '';

    if (_rule.endDate != null) {
      endDescription = ' until ${DateFormat('MMM d, yyyy').format(_rule.endDate!)}';
    } else if (_rule.occurrences != null) {
      endDescription = ' for ${_rule.occurrences} occurrences';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$description$endDescription',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRecurrenceIcon(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return Icons.event;
      case RecurrenceType.daily:
        return Icons.today;
      case RecurrenceType.weekly:
        return Icons.view_week;
      case RecurrenceType.biweekly:
        return Icons.date_range;
      case RecurrenceType.monthly:
        return Icons.calendar_month;
      case RecurrenceType.yearly:
        return Icons.calendar_today;
    }
  }
}

enum RecurrenceEndType {
  never,
  onDate,
  afterOccurrences,
}

class _OccurrencesPickerDialog extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onSelected;

  const _OccurrencesPickerDialog({
    required this.initialValue,
    required this.onSelected,
  });

  @override
  State<_OccurrencesPickerDialog> createState() => _OccurrencesPickerDialogState();
}

class _OccurrencesPickerDialogState extends State<_OccurrencesPickerDialog> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Number of occurrences'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _value > 1
                    ? () => setState(() => _value--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 32,
              ),
              const SizedBox(width: 16),
              Text(
                '$_value',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _value < 100
                    ? () => setState(() => _value++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _value.toDouble(),
            min: 1,
            max: 52,
            divisions: 51,
            label: '$_value',
            onChanged: (value) {
              setState(() {
                _value = value.round();
              });
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [5, 10, 12, 26, 52].map((count) {
              return ChoiceChip(
                label: Text('$count'),
                selected: _value == count,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _value = count);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSelected(_value);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

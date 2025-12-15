import 'package:flutter/material.dart';

/// 5분 단위로 시간을 선택할 수 있는 커스텀 Time Picker
class TimePicker5Min extends StatefulWidget {
  final TimeOfDay initialTime;
  final String title;

  const TimePicker5Min({
    super.key,
    required this.initialTime,
    this.title = 'Select Time',
  });

  static Future<TimeOfDay?> show(
    BuildContext context, {
    required TimeOfDay initialTime,
    String title = 'Select Time',
  }) {
    return showDialog<TimeOfDay>(
      context: context,
      builder: (context) => TimePicker5Min(
        initialTime: initialTime,
        title: title,
      ),
    );
  }

  @override
  State<TimePicker5Min> createState() => _TimePicker5MinState();
}

class _TimePicker5MinState extends State<TimePicker5Min> {
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isAm;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    // Convert 24h to 12h format
    _selectedHour = widget.initialTime.hourOfPeriod;
    if (_selectedHour == 0) _selectedHour = 12;
    _selectedMinute = (widget.initialTime.minute / 5).round() * 5;
    if (_selectedMinute >= 60) _selectedMinute = 55;
    _isAm = widget.initialTime.hour < 12;

    _hourController = FixedExtentScrollController(
      initialItem: _selectedHour - 1,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute ~/ 5,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  TimeOfDay _getSelectedTime() {
    int hour = _selectedHour;
    if (_isAm) {
      if (hour == 12) hour = 0;
    } else {
      if (hour != 12) hour += 12;
    }
    return TimeOfDay(hour: hour, minute: _selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Time Display
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                _formatDisplayTime(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  color: primaryColor,
                  letterSpacing: 2,
                ),
              ),
            ),

            // Picker Wheels
            SizedBox(
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hour Wheel
                  SizedBox(
                    width: 70,
                    child: ListWheelScrollView.useDelegate(
                      controller: _hourController,
                      itemExtent: 50,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedHour = index + 1;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 12,
                        builder: (context, index) {
                          final hour = index + 1;
                          final isSelected = hour == _selectedHour;
                          return Center(
                            child: Text(
                              hour.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: isSelected ? 28 : 20,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey[400],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Colon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  // Minute Wheel (5-minute intervals)
                  SizedBox(
                    width: 70,
                    child: ListWheelScrollView.useDelegate(
                      controller: _minuteController,
                      itemExtent: 50,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMinute = index * 5;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 12, // 0, 5, 10, 15, ..., 55
                        builder: (context, index) {
                          final minute = index * 5;
                          final isSelected = minute == _selectedMinute;
                          return Center(
                            child: Text(
                              minute.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: isSelected ? 28 : 20,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey[400],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // AM/PM Toggle
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAmPmButton('AM', _isAm, () {
                        setState(() => _isAm = true);
                      }),
                      const SizedBox(height: 8),
                      _buildAmPmButton('PM', !_isAm, () {
                        setState(() => _isAm = false);
                      }),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(_getSelectedTime());
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirm'),
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

  Widget _buildAmPmButton(String label, bool isSelected, VoidCallback onTap) {
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryColor : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDisplayTime() {
    final hourStr = _selectedHour.toString().padLeft(2, '0');
    final minuteStr = _selectedMinute.toString().padLeft(2, '0');
    final period = _isAm ? 'AM' : 'PM';
    return '$hourStr:$minuteStr $period';
  }
}

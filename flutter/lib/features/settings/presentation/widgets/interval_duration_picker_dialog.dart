import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class IntervalDurationPickerDialog extends StatefulWidget {
  final int initialDurationMinutes;

  const IntervalDurationPickerDialog({
    super.key,
    required this.initialDurationMinutes,
  });

  @override
  State<IntervalDurationPickerDialog> createState() =>
      _IntervalDurationPickerDialogState();
}

class _IntervalDurationPickerDialogState
    extends State<IntervalDurationPickerDialog> {
  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();
    _selectedMinutes =
        widget.initialDurationMinutes < 5 ? 5 : widget.initialDurationMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.grey1,
      title: const Text(
        'Interval Duration',
        style: TextStyle(color: AppColors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_selectedMinutes minutes',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 20),
          Slider(
            value: _selectedMinutes.toDouble(),
            min: 5,
            max: 60,
            divisions: 11, // (60-5)/5 = 11 steps of 5 mins
            activeColor: AppColors.white,
            inactiveColor: AppColors.grey3,
            onChanged: (value) {
              setState(() {
                _selectedMinutes = value.round();
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.grey4)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _selectedMinutes);
          },
          child: const Text('Save', style: TextStyle(color: AppColors.white)),
        ),
      ],
    );
  }
}

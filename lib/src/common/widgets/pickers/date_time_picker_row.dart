import 'package:flutter/material.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/common/widgets/pickers/date_picker_field.dart';
import 'package:ai_health/src/common/widgets/pickers/time_picker_field.dart';





@immutable
final class DateTimePickerRow extends StatelessWidget {
  const DateTimePickerRow({
    required this.startDate,
    required this.startTime,
    required this.onDateChanged,
    required this.onTimeChanged,
    super.key,
    this.dateLabel,
    this.timeLabel,
    this.spacing = 8.0,
    this.validator,
  });

  
  final DateTime? startDate;

  
  final TimeOfDay? startTime;

  
  final ValueChanged<DateTime> onDateChanged;

  
  final ValueChanged<TimeOfDay> onTimeChanged;

  
  final String? dateLabel;

  
  final String? timeLabel;

  
  final double spacing;

  
  
  final String? Function()? validator;

  String? _validateDateTime() {
    // Use custom validator if provided
    if (validator != null) {
      return validator!();
    }

    // Default validation
    if (startDate == null) {
      return '${AppTexts.pleaseSelect} ${dateLabel ?? AppTexts.date}';
    }
    if (startTime == null) {
      return '${AppTexts.pleaseSelect} ${timeLabel ?? AppTexts.time}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DatePickerField(
            label: dateLabel ?? AppTexts.date,
            initialValue: startDate,
            onChanged: onDateChanged,
            validator: (dateTime) => _validateDateTime(),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: TimePickerField(
            label: timeLabel ?? AppTexts.time,
            initialValue: startTime,
            onChanged: onTimeChanged,
            validator: (timeOfDay) => _validateDateTime(),
          ),
        ),
      ],
    );
  }
}

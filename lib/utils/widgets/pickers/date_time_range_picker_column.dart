import 'package:flutter/material.dart';
import 'package:ai_health/utils/constants/app_texts.dart';
import 'package:ai_health/utils/utils/date_formatter.dart';
import 'package:ai_health/utils/widgets/pickers/date_time_picker_row.dart';







@immutable
final class DateTimeRangePickerColumn extends StatelessWidget {
  const DateTimeRangePickerColumn({
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.onStartDateChanged,
    required this.onStartTimeChanged,
    required this.onEndDateChanged,
    required this.onEndTimeChanged,
    super.key,
    this.startDateLabel,
    this.startTimeLabel,
    this.endDateLabel,
    this.endTimeLabel,
    this.fieldSpacing = 8.0,
    this.rowSpacing = 16.0,
  });

  
  final DateTime? startDate;

  
  final TimeOfDay? startTime;

  
  final DateTime? endDate;

  
  final TimeOfDay? endTime;

  
  final ValueChanged<DateTime> onStartDateChanged;

  
  final ValueChanged<TimeOfDay> onStartTimeChanged;

  
  final ValueChanged<DateTime> onEndDateChanged;

  
  final ValueChanged<TimeOfDay> onEndTimeChanged;

  
  final String? startDateLabel;

  
  final String? startTimeLabel;

  
  final String? endDateLabel;

  
  final String? endTimeLabel;

  
  final double fieldSpacing;

  
  final double rowSpacing;

  
  DateTime? get _startDateTime => DateFormatter.combine(startDate, startTime);

  
  DateTime? get _endDateTime => DateFormatter.combine(endDate, endTime);

  String? _validateStartDateTime() {
    if (startDate == null) {
      return '${AppTexts.pleaseSelect} ${startDateLabel ?? AppTexts.startDate}';
    }
    if (startTime == null) {
      return '${AppTexts.pleaseSelect} ${startTimeLabel ?? AppTexts.startTime}';
    }
    if (endDate == null || endTime == null) {
      return AppTexts.pleaseSelectBothStartAndEndDateTime;
    }
    final start = _startDateTime;
    final end = _endDateTime;
    if (start != null &&
        end != null &&
        (end.isBefore(start) || end.isAtSameMomentAs(start))) {
      return AppTexts.endTimeMustBeAfterStartTime;
    }
    return null;
  }

  String? _validateEndDateTime() {
    if (endDate == null) {
      return '${AppTexts.pleaseSelect} ${endDateLabel ?? AppTexts.endDate}';
    }
    if (endTime == null) {
      return '${AppTexts.pleaseSelect} ${endTimeLabel ?? AppTexts.endTime}';
    }
    if (startDate == null || startTime == null) {
      return AppTexts.pleaseSelectBothStartAndEndDateTime;
    }
    final start = _startDateTime;
    final end = _endDateTime;
    if (start != null &&
        end != null &&
        (end.isBefore(start) || end.isAtSameMomentAs(start))) {
      return AppTexts.endTimeMustBeAfterStartTime;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Start Date and Time row
        DateTimePickerRow(
          startDate: startDate,
          startTime: startTime,
          onDateChanged: onStartDateChanged,
          onTimeChanged: onStartTimeChanged,
          dateLabel: startDateLabel ?? AppTexts.startDate,
          timeLabel: startTimeLabel ?? AppTexts.startTime,
          spacing: fieldSpacing,
          validator: _validateStartDateTime,
        ),
        SizedBox(height: rowSpacing),
        // End Date and Time row
        DateTimePickerRow(
          startDate: endDate,
          startTime: endTime,
          onDateChanged: onEndDateChanged,
          onTimeChanged: onEndTimeChanged,
          dateLabel: endDateLabel ?? AppTexts.endDate,
          timeLabel: endTimeLabel ?? AppTexts.endTime,
          spacing: fieldSpacing,
          validator: _validateEndDateTime,
        ),
      ],
    );
  }
}

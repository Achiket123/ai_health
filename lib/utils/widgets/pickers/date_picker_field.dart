import 'package:ai_health/utils/constants/app_icons.dart';
import 'package:ai_health/utils/utils/date_formatter.dart';
import 'package:ai_health/utils/widgets/pickers/base_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:ai_health/utils/utils/date_formatter.dart';
import 'package:ai_health/utils/widgets/pickers/base_picker_field.dart';





@immutable
final class DatePickerField extends BasePickerField<DateTime> {
  const DatePickerField({
    required super.label,
    required super.onChanged,
    super.key,
    super.initialValue,
    super.validator,
    this.firstDate,
    this.lastDate,
  }) : super(icon: AppIcons.calendarToday);

  
  final DateTime? firstDate;

  
  final DateTime? lastDate;

  @override
  String formatValue(DateTime? value) => DateFormatter.formatDate(value);

  @override
  Future<DateTime?> showPicker(
    BuildContext context,
    DateTime? currentValue,
  ) async {
    final now = DateTime.now();
    final initialDate = currentValue ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );

    if (pickedDate == null) {
      return null;
    }

    // Preserve time from current value if it exists, otherwise set to 00:00:00
    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      currentValue?.hour ?? 0,
      currentValue?.minute ?? 0,
    );
  }

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState
    extends BasePickerFieldState<DateTime, DatePickerField> {}

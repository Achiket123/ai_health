import 'package:flutter/material.dart';
import 'package:ai_health/utils/constants/app_icons.dart';
import 'package:ai_health/utils/constants/app_texts.dart';
import 'package:ai_health/utils/utils/date_formatter.dart';
import 'package:ai_health/utils/widgets/pickers/base_picker_field.dart';





@immutable
final class DurationPickerField extends BasePickerField<TimeOfDay> {
  const DurationPickerField({
    required super.onChanged,
    super.key,
    super.initialValue,
    super.validator,
    super.onTap,
    super.label = AppTexts.durationHHMM,
  }) : super(icon: AppIcons.accessTime);

  @override
  String formatValue(TimeOfDay? value) => DateFormatter.formatTime(value);

  @override
  Future<TimeOfDay?> showPicker(
    BuildContext context,
    TimeOfDay? currentValue,
  ) {
    return showTimePicker(
      context: context,
      initialTime: currentValue ?? TimeOfDay.now(),
    );
  }

  @override
  State<DurationPickerField> createState() => _DurationPickerFieldState();
}

class _DurationPickerFieldState
    extends BasePickerFieldState<TimeOfDay, DurationPickerField> {}

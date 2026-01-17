import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/common/constants/app_icons.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/common/utils/extensions/exercise_type_extension.dart';
import 'package:ai_health/src/common/widgets/searchable_dropdown_menu_form_field.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/interval_health_record_write_form.dart';


@immutable
final class ExerciseSessionWriteForm extends IntervalHealthRecordWriteForm {
  const ExerciseSessionWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  });

  @override
  ExerciseSessionFormState createState() => ExerciseSessionFormState();
}


final class ExerciseSessionFormState
    extends IntervalHealthRecordFormState<ExerciseSessionWriteForm> {
  
  ExerciseType? exerciseType;

  
  String? title;

  
  String? notes;

  @override
  List<Widget> buildFields(BuildContext context) {
    return [
      ...super.buildFields(context),
      const SizedBox(height: 16),
      SearchableDropdownMenuFormField<ExerciseType>(
        labelText: AppTexts.exerciseType,
        values: ExerciseType.values,
        initialValue: exerciseType,
        onChanged: (type) => setState(() => exerciseType = type),
        validator: (type) => type == null
            ? AppTexts.getPleaseSelectText(AppTexts.exerciseType)
            : null,
        displayNameBuilder: (type) => type.displayName,
        prefixIcon: AppIcons.fitnessCenter,
        hint: AppTexts.pleaseSelect,
      ),
      const SizedBox(height: 16),
      TextFormField(
        decoration: const InputDecoration(
          labelText: AppTexts.exerciseTitleOptional,
          border: OutlineInputBorder(),
          helperText: AppTexts.exerciseTitleHelper,
        ),
        onChanged: (value) => setState(() {
          title = value.isEmpty ? null : value;
        }),
      ),
      const SizedBox(height: 16),
      TextFormField(
        decoration: const InputDecoration(
          labelText: AppTexts.exerciseNotesOptional,
          border: OutlineInputBorder(),
          helperText: AppTexts.exerciseNotesHelper,
        ),
        onChanged: (value) => setState(() {
          notes = value.isEmpty ? null : value;
        }),
        maxLines: 3,
      ),
    ];
  }

  @override
  bool validate() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    return exerciseType != null;
  }

  @override
  HealthRecord buildRecord() {
    return ExerciseSessionRecord(
      startTime: startDateTime!,
      endTime: endDateTime!,
      exerciseType: exerciseType!,
      metadata: metadata,
      title: title,
      notes: notes,
    );
  }
}

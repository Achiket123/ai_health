import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/common/utils/mixins/start_date_time_picker_with_duration_page_state_mixin.dart';
import 'package:ai_health/src/common/widgets/pickers/duration_picker_field.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/base_health_record_write_form.dart';


@immutable
abstract class IntervalHealthRecordWriteForm extends BaseHealthRecordWriteForm {
  const IntervalHealthRecordWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  });

  @override
  IntervalHealthRecordFormState createState();
}

abstract class IntervalHealthRecordFormState<
  T extends IntervalHealthRecordWriteForm
>
    extends BaseHealthRecordWriteFormState<T>
    with StartDateTimePickerWithDurationPageStateMixin<T> {
  
  MeasurementUnit? value;

  @mustCallSuper
  @override
  List<Widget> buildFields(BuildContext context) {
    return [
      DurationPickerField(
        initialValue: duration,
        onChanged: setDuration,
        validator: durationValidator,
      ),
    ];
  }
}

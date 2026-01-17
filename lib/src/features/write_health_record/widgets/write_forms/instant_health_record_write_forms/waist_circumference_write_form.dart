import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/instant_health_record_write_form.dart';

@immutable
final class WaistCircumferenceWriteForm extends InstantHealthRecordWriteForm {
  const WaistCircumferenceWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  }) : super(dataType: HealthDataType.waistCircumference);

  @override
  WaistCircumferenceFormState createState() => WaistCircumferenceFormState();
}

final class WaistCircumferenceFormState
    extends InstantHealthRecordFormState<WaistCircumferenceWriteForm> {
  @override
  HealthRecord buildRecord() {
    return WaistCircumferenceRecord(
      time: startDateTime!,
      circumference: value! as Length,
      metadata: metadata,
    );
  }
}

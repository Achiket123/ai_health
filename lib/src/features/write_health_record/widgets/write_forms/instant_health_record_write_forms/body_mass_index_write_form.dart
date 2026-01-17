import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/instant_health_record_write_form.dart';


@immutable
final class BodyMassIndexWriteForm extends InstantHealthRecordWriteForm {
  const BodyMassIndexWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  }) : super(dataType: HealthDataType.bodyMassIndex);

  @override
  BodyMassIndexFormState createState() => BodyMassIndexFormState();
}


final class BodyMassIndexFormState
    extends InstantHealthRecordFormState<BodyMassIndexWriteForm> {
  @override
  HealthRecord buildRecord() {
    return BodyMassIndexRecord(
      time: startDateTime!,
      bmi: value! as Number,
      metadata: metadata,
    );
  }
}

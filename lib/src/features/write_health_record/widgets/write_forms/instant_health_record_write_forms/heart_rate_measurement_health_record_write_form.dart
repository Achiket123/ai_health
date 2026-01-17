import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/instant_health_record_write_form.dart';


@immutable
final class HeartRateMeasurementWriteForm extends InstantHealthRecordWriteForm {
  const HeartRateMeasurementWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  }) : super(dataType: HealthDataType.heartRate);

  @override
  HeartRateMeasurementFormState createState() =>
      HeartRateMeasurementFormState();
}


final class HeartRateMeasurementFormState
    extends InstantHealthRecordFormState<HeartRateMeasurementWriteForm> {
  @override
  HealthRecord buildRecord() {
    return HeartRateRecord(
      id: HealthRecordId.none,
      time: startDateTime!,
      rate: value! as Frequency,
      metadata: metadata,
    );
  }
}

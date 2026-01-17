import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/instant_health_record_write_form.dart';


@immutable
final class HeartRateVariabilitySDNNWriteForm
    extends InstantHealthRecordWriteForm {
  const HeartRateVariabilitySDNNWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  }) : super(dataType: HealthDataType.heartRateVariabilitySDNN);

  @override
  HeartRateVariabilitySDNNFormState createState() =>
      HeartRateVariabilitySDNNFormState();
}


final class HeartRateVariabilitySDNNFormState
    extends InstantHealthRecordFormState<HeartRateVariabilitySDNNWriteForm> {
  @override
  HealthRecord buildRecord() {
    return HeartRateVariabilitySDNNRecord(
      time: startDateTime!,
      sdnn: value! as TimeDuration,
      metadata: metadata,
    );
  }
}

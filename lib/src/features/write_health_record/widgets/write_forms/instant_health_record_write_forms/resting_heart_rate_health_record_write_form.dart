import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/instant_health_record_write_form.dart';


@immutable
final class RestingHeartRateWriteForm extends InstantHealthRecordWriteForm {
  const RestingHeartRateWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  }) : super(dataType: HealthDataType.restingHeartRate);

  @override
  RestingHeartRateFormState createState() => RestingHeartRateFormState();
}


final class RestingHeartRateFormState
    extends InstantHealthRecordFormState<RestingHeartRateWriteForm> {
  @override
  HealthRecord buildRecord() {
    return RestingHeartRateRecord(
      time: startDateTime!,
      rate: value! as Frequency,
      metadata: metadata,
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/instant_health_record_write_form.dart';


@immutable
final class BodyTemperatureWriteForm extends InstantHealthRecordWriteForm {
  const BodyTemperatureWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  }) : super(dataType: HealthDataType.bodyTemperature);

  @override
  BodyTemperatureFormState createState() => BodyTemperatureFormState();
}


final class BodyTemperatureFormState
    extends InstantHealthRecordFormState<BodyTemperatureWriteForm> {
  @override
  HealthRecord buildRecord() {
    return BodyTemperatureRecord(
      time: startDateTime!,
      temperature: value! as Temperature,
      metadata: metadata,
    );
  }
}

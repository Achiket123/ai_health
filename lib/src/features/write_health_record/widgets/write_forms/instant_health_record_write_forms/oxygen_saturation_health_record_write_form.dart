import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/instant_health_record_write_form.dart';


@immutable
final class OxygenSaturationWriteForm extends InstantHealthRecordWriteForm {
  const OxygenSaturationWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  }) : super(dataType: HealthDataType.oxygenSaturation);

  @override
  OxygenSaturationFormState createState() => OxygenSaturationFormState();
}


final class OxygenSaturationFormState
    extends InstantHealthRecordFormState<OxygenSaturationWriteForm> {
  @override
  HealthRecord buildRecord() {
    return OxygenSaturationRecord(
      time: startDateTime!,
      saturation: value! as Percentage,
      metadata: metadata,
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/instant_health_record_write_form.dart';





@immutable
final class WeightWriteForm extends InstantHealthRecordWriteForm {
  const WeightWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  }) : super(dataType: HealthDataType.weight);

  @override
  WeightFormState createState() => WeightFormState();
}




final class WeightFormState
    extends InstantHealthRecordFormState<WeightWriteForm> {
  @override
  HealthRecord buildRecord() {
    return WeightRecord(
      time: startDateTime!,
      weight: value! as Mass,
      metadata: metadata,
    );
  }
}

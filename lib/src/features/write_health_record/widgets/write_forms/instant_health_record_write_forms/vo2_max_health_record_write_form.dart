import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/instant_health_record_write_form.dart';


@immutable
final class Vo2MaxWriteForm extends InstantHealthRecordWriteForm {
  const Vo2MaxWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  }) : super(dataType: HealthDataType.vo2Max);

  @override
  Vo2MaxFormState createState() => Vo2MaxFormState();
}


final class Vo2MaxFormState
    extends InstantHealthRecordFormState<Vo2MaxWriteForm> {
  @override
  HealthRecord buildRecord() {
    return Vo2MaxRecord(
      time: startDateTime!,
      vo2MlPerMinPerKg: value! as Number,
      metadata: metadata,
    );
  }
}

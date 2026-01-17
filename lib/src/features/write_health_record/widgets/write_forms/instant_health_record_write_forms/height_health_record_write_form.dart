import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/instant_health_record_write_form.dart';


@immutable
final class HeightWriteForm extends InstantHealthRecordWriteForm {
  const HeightWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  }) : super(dataType: HealthDataType.height);

  @override
  HeightFormState createState() => HeightFormState();
}


final class HeightFormState
    extends InstantHealthRecordFormState<HeightWriteForm> {
  @override
  HealthRecord buildRecord() {
    return HeightRecord(
      time: startDateTime!,
      height: value! as Length,
      metadata: metadata,
    );
  }
}

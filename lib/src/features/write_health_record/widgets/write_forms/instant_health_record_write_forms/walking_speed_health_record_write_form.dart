import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/instant_health_record_write_form.dart';


@immutable
final class WalkingSpeedWriteForm extends InstantHealthRecordWriteForm {
  const WalkingSpeedWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  }) : super(dataType: HealthDataType.walkingSpeed);

  @override
  WalkingSpeedFormState createState() => WalkingSpeedFormState();
}


final class WalkingSpeedFormState
    extends InstantHealthRecordFormState<WalkingSpeedWriteForm> {
  @override
  HealthRecord buildRecord() {
    return WalkingSpeedRecord(
      time: startDateTime!,
      speed: value! as Velocity,
      metadata: metadata,
    );
  }
}

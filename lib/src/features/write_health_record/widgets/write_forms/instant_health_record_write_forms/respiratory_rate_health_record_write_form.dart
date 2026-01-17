import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/instant_health_record_write_form.dart';


@immutable
final class RespiratoryRateWriteForm extends InstantHealthRecordWriteForm {
  const RespiratoryRateWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  }) : super(dataType: HealthDataType.respiratoryRate);

  @override
  RespiratoryRateFormState createState() => RespiratoryRateFormState();
}


final class RespiratoryRateFormState
    extends InstantHealthRecordFormState<RespiratoryRateWriteForm> {
  @override
  HealthRecord buildRecord() {
    return RespiratoryRateRecord(
      time: startDateTime!,
      rate: value! as Frequency,
      metadata: metadata,
    );
  }
}

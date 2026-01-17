import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/base_health_record_write_form.dart';


@immutable
final class IntermenstrualBleedingWriteForm extends BaseHealthRecordWriteForm {
  const IntermenstrualBleedingWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  });

  @override
  IntermenstrualBleedingFormState createState() =>
      IntermenstrualBleedingFormState();
}


final class IntermenstrualBleedingFormState
    extends BaseHealthRecordWriteFormState<IntermenstrualBleedingWriteForm> {
  @override
  List<Widget> buildFields(BuildContext context) {
    // No additional fields needed - just time and metadata from base
    return [];
  }

  @override
  HealthRecord buildRecord() {
    return IntermenstrualBleedingRecord(
      time: startDateTime!,
      metadata: metadata,
    );
  }
}

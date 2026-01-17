import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_form_fields/health_record_value_write_form_field.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/interval_health_record_write_form.dart';


@immutable
final class BasalEnergyBurnedWriteForm extends IntervalHealthRecordWriteForm {
  const BasalEnergyBurnedWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  });

  @override
  BasalEnergyBurnedFormState createState() => BasalEnergyBurnedFormState();
}


final class BasalEnergyBurnedFormState
    extends IntervalHealthRecordFormState<BasalEnergyBurnedWriteForm> {
  @override
  List<Widget> buildFields(BuildContext context) {
    return [
      ...super.buildFields(context),
      const SizedBox(height: 16),
      HealthRecordValueWriteFormField(
        dataType: HealthDataType.basalEnergyBurned,
        onChanged: (newValue) {
          setState(() {
            value = newValue;
          });
        },
      ),
    ];
  }

  @override
  HealthRecord buildRecord() {
    return BasalEnergyBurnedRecord(
      startTime: startDateTime!,
      endTime: endDateTime!,
      energy: value! as Energy,
      metadata: metadata,
    );
  }
}

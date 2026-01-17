import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_form_fields/health_record_value_write_form_field.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/base_health_record_write_form.dart';


@immutable
abstract class InstantHealthRecordWriteForm extends BaseHealthRecordWriteForm {
  const InstantHealthRecordWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    required this.dataType,
    super.key,
  });

  
  final HealthDataType dataType;

  @override
  InstantHealthRecordFormState createState();
}


abstract class InstantHealthRecordFormState<
  T extends InstantHealthRecordWriteForm
>
    extends BaseHealthRecordWriteFormState<T> {
  
  MeasurementUnit? value;

  @override
  List<Widget> buildFields(BuildContext context) {
    return [
      HealthRecordValueWriteFormField(
        dataType: widget.dataType,
        onChanged: (newValue) {
          setState(() {
            value = newValue;
          });
        },
      ),
    ];
  }
}

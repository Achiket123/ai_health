import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart'
    show HealthDataType, MeasurementUnit;
import 'package:ai_health/src/common/utils/extensions/health_data_type_ui_extension.dart';
import 'package:ai_health/src/common/utils/measurement_unit_value_parser.dart';
import 'package:ai_health/src/common/utils/measurement_unit_value_validator.dart';








@immutable
final class HealthRecordValueWriteFormField extends StatefulWidget {
  const HealthRecordValueWriteFormField({
    required this.dataType,
    required this.onChanged,
    super.key,
    this.validator,
  });

  
  final HealthDataType dataType;

  
  
  
  
  final ValueChanged<MeasurementUnit?> onChanged;

  
  
  
  final String? Function(MeasurementUnit?)? validator;

  @override
  State<HealthRecordValueWriteFormField> createState() =>
      _HealthRecordValueWriteFormFieldState();
}

class _HealthRecordValueWriteFormFieldState
    extends State<HealthRecordValueWriteFormField> {
  late final TextEditingController controller;

  MeasurementUnit? _value;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  
  void _onChanged(String value) {
    setState(() {
      try {
        _value = MeasurementUnitValueParser.parseValue(
          forDataType: widget.dataType,
          value: value,
        );
      } on FormatException catch (_) {
        // Invalid input - set to null
        _value = null;
      } on ArgumentError catch (_) {
        // Empty input - set to null
        _value = null;
      }
    });
    widget.onChanged(_value);
  }

  
  String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return widget.dataType.emptyInputError;
    }

    try {
      final parsedValue = MeasurementUnitValueParser.parseValue(
        forDataType: widget.dataType,
        value: value,
      );

      MeasurementUnitValueValidator.validate(
        forDataType: widget.dataType,
        value: parsedValue,
      );

      // Validation successful
      return null;
    } on FormatException catch (e) {
      return e.message;
    } on ArgumentError catch (e) {
      return e.message.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: widget.dataType.fieldLabel,
        suffixText: widget.dataType.fieldSuffix,
        prefixIcon: Icon(widget.dataType.icon),
      ),
      keyboardType: widget.dataType.keyboardType,
      onChanged: _onChanged,
      validator: _validate,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/common/utils/mixins/start_date_time_picker_page_state_mixin.dart';
import 'package:ai_health/src/common/utils/show_app_snack_bar.dart';
import 'package:ai_health/src/common/widgets/buttons/elevated_gradient_button.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_form_fields/metadata_write_form_field_group.dart';


typedef OnSubmitCallback = Future<void> Function(HealthRecord record);
typedef RecordBuilder = HealthRecord Function();


@immutable
abstract class BaseHealthRecordWriteForm extends StatefulWidget {
  const BaseHealthRecordWriteForm({
    required this.healthPlatform,
    required this.onSubmit,
    super.key,
  });

  
  final HealthPlatform healthPlatform;

  
  final OnSubmitCallback onSubmit;

  @override
  BaseHealthRecordWriteFormState createState();
}









abstract class BaseHealthRecordWriteFormState<
  T extends BaseHealthRecordWriteForm
>
    extends State<T>
    with StartDateTimePickerPageStateMixin<T> {
  
  final formKey = GlobalKey<FormState>();

  RecordingMethod _recordingMethod = RecordingMethod.unknown;
  Device? _device;

  
  Metadata get metadata {
    return switch (_recordingMethod) {
      RecordingMethod.manualEntry => Metadata.manualEntry(
        device: _device,
      ),
      RecordingMethod.automaticallyRecorded => Metadata.automaticallyRecorded(
        device: _device!,
      ),
      RecordingMethod.activelyRecorded => Metadata.activelyRecorded(
        device: _device!,
      ),
      RecordingMethod.unknown => Metadata.unknownRecordingMethod(
        device: _device,
      ),
    };
  }

  
  
  
  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  
  
  
  
  HealthRecord buildRecord();

  Future<void> _submitRecord() async {
    if (!validate()) {
      return;
    }

    late final HealthRecord record;
    try {
      record = buildRecord();
    } on ArgumentError catch (e) {
      showAppSnackBar(
        context,
        SnackBarType.error,
        e.message.toString(),
      );

      return;
    }

    await widget.onSubmit(record);
  }

  
  
  
  List<Widget> buildFields(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Date/Time Picker provided by mixin
                  buildDateTimePicker(context),

                  // Type-specific form fields
                  const SizedBox(height: 16),
                  ...buildFields(context),

                  // Metadata fields (recording method, device)
                  const SizedBox(height: 16),
                  MetadataWriteFormFieldGroup(
                    healthPlatform: widget.healthPlatform,
                    initialRecordingMethod: _recordingMethod,
                    initialDevice: _device,
                    onRecordingMethodChanged: (method) {
                      if (method != null) {
                        setState(() {
                          _recordingMethod = method;
                        });
                      }
                    },
                    onDeviceChanged: (device) {
                      setState(() {
                        _device = device;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Submit Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedGradientButton(
            onPressed: _submitRecord,
            label: AppTexts.write,
          ),
        ),
      ],
    );
  }
}

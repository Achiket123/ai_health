import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_connector/health_connector_internal.dart'
    show Device, DeviceType, RecordingMethod, HealthPlatform;
import 'package:ai_health/src/common/constants/app_icons.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/common/utils/extensions/display_name_extensions.dart';
import 'package:ai_health/src/common/widgets/searchable_dropdown_menu_form_field.dart';















@immutable
final class MetadataWriteFormFieldGroup extends StatefulWidget {
  const MetadataWriteFormFieldGroup({
    required this.healthPlatform,
    required this.onRecordingMethodChanged,
    required this.onDeviceChanged,
    super.key,
    this.initialRecordingMethod = RecordingMethod.unknown,
    this.initialDevice,
    this.recordingMethodValidator,
    this.deviceTypeValidator,
    this.spacing = 16.0,
  });

  
  final HealthPlatform healthPlatform;

  
  final RecordingMethod initialRecordingMethod;

  
  final Device? initialDevice;

  
  final ValueChanged<RecordingMethod?> onRecordingMethodChanged;

  
  
  
  final ValueChanged<Device?> onDeviceChanged;

  
  final String? Function(RecordingMethod?)? recordingMethodValidator;

  
  final String? Function(DeviceType?)? deviceTypeValidator;

  
  final double spacing;

  @override
  State<MetadataWriteFormFieldGroup> createState() =>
      _MetadataWriteFormFieldGroupState();
}

class _MetadataWriteFormFieldGroupState
    extends State<MetadataWriteFormFieldGroup> {
  late RecordingMethod _recordingMethod;
  late DeviceType _deviceType;
  late final TextEditingController _nameController;
  late final TextEditingController _manufacturerController;
  late final TextEditingController _modelController;
  late final TextEditingController _hardwareVersionController;
  late final TextEditingController _firmwareVersionController;
  late final TextEditingController _softwareVersionController;
  late final TextEditingController _localIdentifierController;
  late final TextEditingController _udiDeviceIdentifierController;

  @override
  void initState() {
    super.initState();
    _recordingMethod = widget.initialRecordingMethod;
    _deviceType = widget.initialDevice?.type ?? DeviceType.unknown;
    _nameController = TextEditingController(text: widget.initialDevice?.name);
    _manufacturerController = TextEditingController(
      text: widget.initialDevice?.manufacturer,
    );
    _modelController = TextEditingController(text: widget.initialDevice?.model);
    _hardwareVersionController = TextEditingController(
      text: widget.initialDevice?.hardwareVersion,
    );
    _firmwareVersionController = TextEditingController(
      text: widget.initialDevice?.firmwareVersion,
    );
    _softwareVersionController = TextEditingController(
      text: widget.initialDevice?.softwareVersion,
    );
    _localIdentifierController = TextEditingController(
      text: widget.initialDevice?.localIdentifier,
    );
    _udiDeviceIdentifierController = TextEditingController(
      text: widget.initialDevice?.udiDeviceIdentifier,
    );

    // Schedule device update after the first frame to notify parent
    // of initial device state without causing setState during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateDevice();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _hardwareVersionController.dispose();
    _firmwareVersionController.dispose();
    _softwareVersionController.dispose();
    _localIdentifierController.dispose();
    _udiDeviceIdentifierController.dispose();
    super.dispose();
  }

  
  bool _isDeviceTypeRequired(RecordingMethod? method) {
    return method == RecordingMethod.automaticallyRecorded ||
        method == RecordingMethod.activelyRecorded;
  }

  void _updateDevice() {
    final device = Device(
      type: _deviceType,
      name: _nameController.text.isEmpty ? null : _nameController.text,
      manufacturer: _manufacturerController.text.isEmpty
          ? null
          : _manufacturerController.text,
      model: _modelController.text.isEmpty ? null : _modelController.text,
      hardwareVersion: _hardwareVersionController.text.isEmpty
          ? null
          : _hardwareVersionController.text,
      firmwareVersion: _firmwareVersionController.text.isEmpty
          ? null
          : _firmwareVersionController.text,
      softwareVersion: _softwareVersionController.text.isEmpty
          ? null
          : _softwareVersionController.text,
      localIdentifier: _localIdentifierController.text.isEmpty
          ? null
          : _localIdentifierController.text,
      udiDeviceIdentifier: _udiDeviceIdentifierController.text.isEmpty
          ? null
          : _udiDeviceIdentifierController.text,
    );

    widget.onDeviceChanged(device);
  }

  void _onRecordingMethodChanged(RecordingMethod? method) {
    if (method == null) {
      return;
    }

    setState(() {
      _recordingMethod = method;
      widget.onRecordingMethodChanged(method);
      _updateDevice();
    });
  }

  void _onDeviceTypeChanged(DeviceType? type) {
    if (type == null) {
      return;
    }

    setState(() {
      _deviceType = type;
    });
    _updateDevice();
  }

  void _onTextFieldChanged() {
    _updateDevice();
  }

  @override
  Widget build(BuildContext context) {
    final isDeviceTypeRequired = _isDeviceTypeRequired(_recordingMethod);
    final isAppleHealth = widget.healthPlatform == HealthPlatform.appleHealth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchableDropdownMenuFormField<RecordingMethod>(
          labelText: AppTexts.recordingMethod,
          values: RecordingMethod.values,
          initialValue: _recordingMethod,
          onChanged: _onRecordingMethodChanged,
          validator: widget.recordingMethodValidator,
          displayNameBuilder: (method) => method.displayName,
          prefixIcon: AppIcons.settings,
        ),
        SizedBox(height: widget.spacing),
        SearchableDropdownMenuFormField<DeviceType>(
          labelText: AppTexts.deviceType,
          values: DeviceType.values,
          initialValue: _deviceType,
          onChanged: _onDeviceTypeChanged,
          validator: isDeviceTypeRequired ? widget.deviceTypeValidator : null,
          displayNameBuilder: (deviceType) => deviceType.displayName,
          prefixIcon: AppIcons.devices,
        ),
        SizedBox(height: widget.spacing),
        TextFormField(
          controller: _manufacturerController,
          decoration: const InputDecoration(
            labelText: AppTexts.manufacturer,
            border: OutlineInputBorder(),
            prefixIcon: Icon(AppIcons.devices),
          ),
          onChanged: (_) => _onTextFieldChanged(),
        ),
        SizedBox(height: widget.spacing),
        TextFormField(
          controller: _modelController,
          decoration: const InputDecoration(
            labelText: AppTexts.model,
            border: OutlineInputBorder(),
            prefixIcon: Icon(AppIcons.devices),
          ),
          onChanged: (_) => _onTextFieldChanged(),
        ),
        if (isAppleHealth) ...[
          SizedBox(height: widget.spacing),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: AppTexts.name,
              border: OutlineInputBorder(),
              prefixIcon: Icon(AppIcons.devices),
            ),
            onChanged: (_) => _onTextFieldChanged(),
          ),
          SizedBox(height: widget.spacing),
          if (isAppleHealth)
            TextFormField(
              controller: _hardwareVersionController,
              decoration: const InputDecoration(
                labelText: AppTexts.hardwareVersion,
                border: OutlineInputBorder(),
                prefixIcon: Icon(AppIcons.devices),
              ),
              onChanged: (_) => _onTextFieldChanged(),
            ),
          SizedBox(height: widget.spacing),
          TextFormField(
            controller: _firmwareVersionController,
            decoration: const InputDecoration(
              labelText: AppTexts.firmwareVersion,
              border: OutlineInputBorder(),
              prefixIcon: Icon(AppIcons.devices),
            ),
            onChanged: (_) => _onTextFieldChanged(),
          ),
          SizedBox(height: widget.spacing),
          TextFormField(
            controller: _softwareVersionController,
            decoration: const InputDecoration(
              labelText: AppTexts.softwareVersion,
              border: OutlineInputBorder(),
              prefixIcon: Icon(AppIcons.devices),
            ),
            onChanged: (_) => _onTextFieldChanged(),
          ),
          SizedBox(height: widget.spacing),
          TextFormField(
            controller: _localIdentifierController,
            decoration: const InputDecoration(
              labelText: AppTexts.localIdentifier,
              border: OutlineInputBorder(),
              prefixIcon: Icon(AppIcons.devices),
            ),
            onChanged: (_) => _onTextFieldChanged(),
          ),
          SizedBox(height: widget.spacing),
          TextFormField(
            controller: _udiDeviceIdentifierController,
            decoration: const InputDecoration(
              labelText: AppTexts.udiDeviceId,
              border: OutlineInputBorder(),
              prefixIcon: Icon(AppIcons.devices),
            ),
            onChanged: (_) => _onTextFieldChanged(),
          ),
        ],
      ],
    );
  }
}

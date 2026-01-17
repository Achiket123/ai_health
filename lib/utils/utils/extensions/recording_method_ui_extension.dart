import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart'
    show RecordingMethod;
import 'package:ai_health/utils/constants/app_icons.dart';
import 'package:ai_health/utils/constants/app_texts.dart';


extension RecordingMethodUI on RecordingMethod {
  
  String get displayName {
    return switch (this) {
      RecordingMethod.manualEntry => AppTexts.manualEntry,
      RecordingMethod.automaticallyRecorded => AppTexts.automaticallyRecorded,
      RecordingMethod.activelyRecorded => AppTexts.activelyRecorded,
      RecordingMethod.unknown => AppTexts.unknown,
    };
  }

  
  IconData get icon {
    return switch (this) {
      RecordingMethod.manualEntry => AppIcons.edit,
      RecordingMethod.automaticallyRecorded => AppIcons.autoAwesome,
      RecordingMethod.activelyRecorded => AppIcons.fitnessCenter,
      RecordingMethod.unknown => AppIcons.helpOutline,
    };
  }
}

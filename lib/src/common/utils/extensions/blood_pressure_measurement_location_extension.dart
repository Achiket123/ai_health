import 'package:health_connector/health_connector_internal.dart'
    show BloodPressureMeasurementLocation;
import 'package:ai_health/src/common/constants/app_texts.dart';


extension BloodPressureMeasurementLocationExtension
    on BloodPressureMeasurementLocation {
  
  String get displayName => switch (this) {
    BloodPressureMeasurementLocation.leftWrist => AppTexts.leftWrist,
    BloodPressureMeasurementLocation.rightWrist => AppTexts.rightWrist,
    BloodPressureMeasurementLocation.leftUpperArm => AppTexts.leftUpperArm,
    BloodPressureMeasurementLocation.rightUpperArm => AppTexts.rightUpperArm,
    BloodPressureMeasurementLocation.unknown => AppTexts.unknown,
  };
}

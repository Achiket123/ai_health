import 'package:health_connector/health_connector_internal.dart'
    show BloodPressureBodyPosition;
import 'package:ai_health/utils/constants/app_texts.dart';


extension BloodPressureBodyPositionExtension on BloodPressureBodyPosition {
  
  String get displayName => switch (this) {
    BloodPressureBodyPosition.standingUp => AppTexts.standingUp,
    BloodPressureBodyPosition.sittingDown => AppTexts.sittingDown,
    BloodPressureBodyPosition.lyingDown => AppTexts.lyingDown,
    BloodPressureBodyPosition.reclining => AppTexts.reclining,
    BloodPressureBodyPosition.unknown => AppTexts.unknown,
  };
}

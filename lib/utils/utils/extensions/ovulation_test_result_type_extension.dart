import 'package:health_connector/health_connector_internal.dart'
    show OvulationTestResult;
import 'package:ai_health/utils/constants/app_texts.dart';


extension OvulationTestResultTypeExtension on OvulationTestResult {
  
  String get displayName {
    return switch (this) {
      OvulationTestResult.negative => AppTexts.negative,
      OvulationTestResult.inconclusive => AppTexts.inconclusive,
      OvulationTestResult.high => AppTexts.high,
      OvulationTestResult.positive => AppTexts.positive,
    };
  }
}

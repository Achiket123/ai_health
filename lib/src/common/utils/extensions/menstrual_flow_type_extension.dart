import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';


extension MenstrualFlowExtension on MenstrualFlow {
  
  String get label {
    return switch (this) {
      MenstrualFlow.unknown => AppTexts.unspecified,
      MenstrualFlow.light => AppTexts.light,
      MenstrualFlow.medium => AppTexts.medium,
      MenstrualFlow.heavy => AppTexts.heavy,
    };
  }
}

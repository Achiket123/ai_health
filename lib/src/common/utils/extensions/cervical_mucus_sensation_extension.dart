import 'package:health_connector/health_connector_internal.dart'
    show CervicalMucusSensation;
import 'package:ai_health/src/common/constants/app_texts.dart';


extension CervicalMucusSensationExtension on CervicalMucusSensation {
  
  String get displayName {
    return switch (this) {
      CervicalMucusSensation.unknown => AppTexts.unknown,
      CervicalMucusSensation.light => AppTexts.light,
      CervicalMucusSensation.medium => AppTexts.medium,
      CervicalMucusSensation.heavy => AppTexts.heavy,
    };
  }
}

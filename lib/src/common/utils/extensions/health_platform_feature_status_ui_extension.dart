import 'package:health_connector/health_connector_internal.dart'
    show HealthPlatformFeatureStatus;
import 'package:ai_health/src/common/constants/app_texts.dart';


extension HealthPlatformFeatureStatusUI on HealthPlatformFeatureStatus {
  
  String get displayName {
    return switch (this) {
      HealthPlatformFeatureStatus.available => AppTexts.available,
      HealthPlatformFeatureStatus.unavailable => AppTexts.unavailable,
    };
  }
}

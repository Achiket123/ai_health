import 'package:health_connector/health_connector_internal.dart'
    show
        HealthPlatformFeature,
        HealthPlatformFeatureReadHealthDataHistory,
        HealthPlatformFeatureReadHealthDataInBackground;
import 'package:ai_health/src/common/constants/app_texts.dart';


extension HealthPlatformFeatureUI on HealthPlatformFeature {
  
  String get displayName {
    return switch (this) {
      HealthPlatformFeatureReadHealthDataHistory _ =>
        AppTexts.readHealthDataHistory,
      HealthPlatformFeatureReadHealthDataInBackground _ =>
        AppTexts.readHealthDataInBackground,
    };
  }
}

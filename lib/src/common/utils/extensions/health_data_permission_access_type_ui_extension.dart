import 'package:health_connector/health_connector_internal.dart'
    show HealthDataPermissionAccessType;
import 'package:ai_health/src/common/constants/app_texts.dart';


extension HealthDataPermissionAccessTypeUI on HealthDataPermissionAccessType {
  
  String get displayName {
    return switch (this) {
      HealthDataPermissionAccessType.read => AppTexts.read,
      HealthDataPermissionAccessType.write => AppTexts.write,
    };
  }
}

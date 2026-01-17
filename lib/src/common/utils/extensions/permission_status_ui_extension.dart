import 'package:health_connector/health_connector_internal.dart'
    show PermissionStatus;
import 'package:ai_health/src/common/constants/app_texts.dart';


extension PermissionStatusUI on PermissionStatus {
  
  String get displayName {
    return switch (this) {
      PermissionStatus.granted => AppTexts.granted,
      PermissionStatus.denied => AppTexts.denied,
      PermissionStatus.unknown => AppTexts.unknown,
    };
  }
}

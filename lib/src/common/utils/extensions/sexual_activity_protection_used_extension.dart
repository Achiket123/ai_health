import 'package:health_connector/health_connector_internal.dart'
    show SexualActivityProtectionUsed;
import 'package:ai_health/src/common/constants/app_texts.dart';



extension SexualActivityProtectionUsedTypeExtension
    on SexualActivityProtectionUsed {
  
  String get displayName {
    return switch (this) {
      SexualActivityProtectionUsed.protected => AppTexts.protected,
      SexualActivityProtectionUsed.unprotected => AppTexts.unprotected,
      SexualActivityProtectionUsed.unknown => AppTexts.unknown,
    };
  }
}

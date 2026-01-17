import 'package:health_connector/health_connector_internal.dart'
    show CervicalMucusAppearance;
import 'package:ai_health/utils/constants/app_texts.dart';


extension CervicalMucusAppearanceExtension on CervicalMucusAppearance {
  
  String get displayName {
    return switch (this) {
      CervicalMucusAppearance.unknown => AppTexts.unknown,
      CervicalMucusAppearance.dry => AppTexts.dry,
      CervicalMucusAppearance.sticky => AppTexts.sticky,
      CervicalMucusAppearance.creamy => AppTexts.creamy,
      CervicalMucusAppearance.watery => AppTexts.watery,
      CervicalMucusAppearance.eggWhite => AppTexts.eggWhite,
      CervicalMucusAppearance.unusual => AppTexts.unusual,
    };
  }
}

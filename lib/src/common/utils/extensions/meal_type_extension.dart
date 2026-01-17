import 'package:health_connector/health_connector_internal.dart' show MealType;
import 'package:ai_health/src/common/constants/app_texts.dart';


extension MealTypeDisplayName on MealType {
  
  String get displayName {
    return switch (this) {
      MealType.unknown => AppTexts.unknown,
      MealType.breakfast => AppTexts.mealTypeBreakfast,
      MealType.lunch => AppTexts.mealTypeLunch,
      MealType.dinner => AppTexts.mealTypeDinner,
      MealType.snack => AppTexts.mealTypeSnack,
    };
  }
}

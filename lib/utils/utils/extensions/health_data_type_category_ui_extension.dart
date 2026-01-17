import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/utils/constants/app_texts.dart';


extension HealthDataTypeCategoryUiExtension on HealthDataTypeCategory {
  
  String get displayName {
    return switch (this) {
      HealthDataTypeCategory.activity => AppTexts.activityCategory,
      HealthDataTypeCategory.bodyMeasurement =>
        AppTexts.bodyMeasurementCategory,
      HealthDataTypeCategory.clinical => AppTexts.clinicalCategory,
      HealthDataTypeCategory.mentalHealth => AppTexts.mentalHealthCategory,
      HealthDataTypeCategory.mobility => AppTexts.mobilityCategory,
      HealthDataTypeCategory.nutrition => AppTexts.nutritionCategory,
      HealthDataTypeCategory.reproductiveHealth =>
        AppTexts.reproductiveHealthCategory,
      HealthDataTypeCategory.sleep => AppTexts.sleepCategory,
      HealthDataTypeCategory.vitals => AppTexts.vitalsCategory,
    };
  }

  
  IconData get icon {
    return switch (this) {
      HealthDataTypeCategory.activity => Icons.directions_run,
      HealthDataTypeCategory.bodyMeasurement => Icons.accessibility_new,
      HealthDataTypeCategory.clinical => Icons.medical_services,
      HealthDataTypeCategory.mentalHealth => Icons.psychology,
      HealthDataTypeCategory.mobility => Icons.assist_walker,
      HealthDataTypeCategory.nutrition => Icons.restaurant,
      HealthDataTypeCategory.reproductiveHealth => Icons.favorite,
      HealthDataTypeCategory.sleep => Icons.bedtime,
      HealthDataTypeCategory.vitals => Icons.monitor_heart,
    };
  }
}

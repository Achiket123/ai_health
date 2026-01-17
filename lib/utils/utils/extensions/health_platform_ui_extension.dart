import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart'
    show HealthPlatform;
import 'package:ai_health/utils/constants/app_icons.dart';
import 'package:ai_health/utils/constants/app_texts.dart';


extension HealthPlatformUI on HealthPlatform {
  
  String get displayName {
    return switch (this) {
      HealthPlatform.appleHealth => AppTexts.appleHealth,
      HealthPlatform.healthConnect => AppTexts.healthConnect,
    };
  }

  
  IconData get icon {
    return switch (this) {
      HealthPlatform.appleHealth => AppIcons.apple,
      HealthPlatform.healthConnect => AppIcons.android,
    };
  }
}

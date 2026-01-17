import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart'
    show DeviceType;
import 'package:ai_health/src/common/constants/app_icons.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';


extension DeviceTypeUI on DeviceType {
  
  String get displayName {
    return switch (this) {
      DeviceType.phone => AppTexts.phone,
      DeviceType.watch => AppTexts.watch,
      DeviceType.fitnessBand => AppTexts.fitnessBand,
      DeviceType.ring => AppTexts.ring,
      DeviceType.scale => AppTexts.scale,
      DeviceType.chestStrap => AppTexts.chestStrap,
      DeviceType.headMounted => AppTexts.headMounted,
      DeviceType.smartDisplay => AppTexts.smartDisplay,
      DeviceType.unknown => AppTexts.unknown,
    };
  }

  
  IconData get icon {
    return switch (this) {
      DeviceType.phone => AppIcons.phone,
      DeviceType.watch => AppIcons.watch,
      DeviceType.fitnessBand => AppIcons.fitnessBand,
      DeviceType.ring => AppIcons.ring,
      DeviceType.scale => AppIcons.scale,
      DeviceType.chestStrap => AppIcons.chestStrap,
      DeviceType.headMounted => AppIcons.headMounted,
      DeviceType.smartDisplay => AppIcons.smartDisplay,
      DeviceType.unknown => AppIcons.helpOutline,
    };
  }
}

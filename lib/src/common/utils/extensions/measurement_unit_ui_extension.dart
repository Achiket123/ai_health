import 'package:flutter/material.dart' hide Interval, Velocity;
import 'package:health_connector/health_connector_internal.dart'
    show
        Energy,
        Frequency,
        TimeDuration,
        Length,
        Mass,
        MeasurementUnit,
        Number,
        Percentage,
        BloodGlucose,
        Power,
        Pressure,
        Temperature,
        Velocity,
        Volume;
import 'package:ai_health/src/common/constants/app_icons.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';


extension MeasurementUnitUI on MeasurementUnit {
  
  String get displayName {
    return switch (this) {
      Mass _ => AppTexts.mass,
      Number _ => AppTexts.numeric,
      TimeDuration _ => AppTexts.interval,
      Percentage _ => AppTexts.percentage,
      Length _ => AppTexts.length,
      Energy _ => AppTexts.energy,
      BloodGlucose _ => AppTexts.bloodGlucose,
      Power _ => AppTexts.power,
      Pressure _ => AppTexts.pressure,
      Temperature _ => AppTexts.temperature,
      Velocity _ => AppTexts.velocity,
      Volume _ => AppTexts.volume,
      Frequency _ => AppTexts.frequency,
    };
  }

  
  IconData get icon {
    return switch (this) {
      Mass _ => AppIcons.mass,
      Number _ => AppIcons.numeric,
      TimeDuration _ => Icons.access_time,
      Percentage _ => AppIcons.percent,
      Length _ => AppIcons.length,
      Energy _ => AppIcons.energy,
      BloodGlucose _ => AppIcons.bloodGlucose,
      Power _ => AppIcons.power,
      Pressure _ => AppIcons.pressure,
      Temperature _ => AppIcons.temperature,
      Velocity _ => AppIcons.velocity,
      Volume _ => AppIcons.volume,
      Frequency _ => AppIcons.favorite,
    };
  }
}

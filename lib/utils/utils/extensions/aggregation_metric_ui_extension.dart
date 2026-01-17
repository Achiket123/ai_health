import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart'
    show AggregationMetric;
import 'package:ai_health/utils/constants/app_icons.dart';
import 'package:ai_health/utils/constants/app_texts.dart';


extension AggregationMetricUI on AggregationMetric {
  
  String get displayName {
    return switch (this) {
      AggregationMetric.sum => AppTexts.sum,
      AggregationMetric.avg => AppTexts.average,
      AggregationMetric.min => AppTexts.minimum,
      AggregationMetric.max => AppTexts.maximum,
    };
  }

  
  IconData get icon {
    return switch (this) {
      AggregationMetric.sum => AppIcons.sum,
      AggregationMetric.avg => AppIcons.avg,
      AggregationMetric.min => AppIcons.min,
      AggregationMetric.max => AppIcons.max,
    };
  }
}

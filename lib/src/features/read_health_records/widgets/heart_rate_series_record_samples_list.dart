import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/common/utils/date_formatter.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_detail_row.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_series_record_samples_list.dart';




@immutable
final class HeartRateSeriesRecordSampleList extends StatelessWidget {
  const HeartRateSeriesRecordSampleList({
    required this.samples,
    super.key,
  });

  
  final List<HeartRateSample> samples;

  @override
  Widget build(BuildContext context) {
    return HealthSeriesRecordSampleList<HeartRateSample>(
      title: AppTexts.heartRateSamples,
      samples: samples,
      itemBuilder: (sample, index) => HealthRecordDetailRow(
        label: DateFormatter.formatDateTime(sample.time),
        value:
            '${sample.rate.inPerMinute.toStringAsFixed(0)} '
            '${AppTexts.bpm}',
      ),
    );
  }
}

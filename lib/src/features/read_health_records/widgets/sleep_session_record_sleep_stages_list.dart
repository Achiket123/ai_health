import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart'
    show SleepStageSample;
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/common/utils/date_formatter.dart';
import 'package:ai_health/src/common/utils/extensions/sleep_stage_type_extension.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_series_record_samples_list.dart';





@immutable
final class SleepSessionRecordSleepStagesList extends StatelessWidget {
  const SleepSessionRecordSleepStagesList({
    required this.stages,
    super.key,
  });

  
  final List<SleepStageSample> stages;

  
  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return HealthSeriesRecordSampleList<SleepStageSample>(
      title: AppTexts.sleepStages,
      samples: stages,
      emptyMessage: AppTexts.noSleepStagesAvailable,
      itemBuilder: (stage, index) {
        final stageTypeName = stage.stageType.displayName;
        final duration = _formatDuration(stage.duration);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stageTypeName,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              '${DateFormatter.formatDateTime(stage.startTime)} - '
              '${DateFormatter.formatDateTime(stage.endTime)} '
              '($duration)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}

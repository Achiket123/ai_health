import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/common/constants/app_icons.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/series_health_record_list_tiles/series_health_record_list_tile.dart';
import 'package:ai_health/src/features/read_health_records/widgets/power_series_record_samples_list.dart';


final class PowerSeriesTile extends StatelessWidget {
  const PowerSeriesTile({
    required this.record,
    required this.onDelete,
    super.key,
  });

  final PowerSeriesRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SeriesHealthRecordTile<PowerSeriesRecord, PowerSample>(
      record: record,
      icon: AppIcons.power,
      title: 'Power Series',
      subtitleBuilder: (r, ctx) => Text(
        '${AppTexts.recording}: ${r.metadata.recordingMethod.name}',
        style: Theme.of(ctx).textTheme.bodySmall,
      ),
      detailRowsBuilder: (r, ctx) => [],
      samplesBuilder: (samples, ctx) =>
          PowerSeriesRecordSamplesList(samples: samples),
      onDelete: onDelete,
    );
  }
}

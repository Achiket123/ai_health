import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/common/constants/app_icons.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/health_record_list_tile_subtitle.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/instant_health_record_list_tiles/instant_health_record_list_tile.dart';


@immutable
final class CyclingPedalingCadenceMeasurementTile extends StatelessWidget {
  const CyclingPedalingCadenceMeasurementTile({
    required this.record,
    required this.onDelete,
    super.key,
  });

  final CyclingPedalingCadenceRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InstantHealthRecordTile<CyclingPedalingCadenceRecord>(
      record: record,
      icon: AppIcons.speed,
      title: '${record.cadence.inPerMinute} ${AppTexts.rpm}',
      subtitleBuilder: (r, ctx) => HealthRecordListTileSubtitle.instant(
        time: r.time,
        recordingMethod: r.metadata.recordingMethod.name,
      ),
      detailRowsBuilder: (r, ctx) => [],
      onDelete: onDelete,
    );
  }
}

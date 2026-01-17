import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/common/constants/app_icons.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/health_record_list_tile_subtitle.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/instant_health_record_list_tiles/instant_health_record_list_tile.dart';


final class Vo2MaxTile extends StatelessWidget {
  const Vo2MaxTile({
    required this.record,
    required this.onDelete,
    super.key,
  });

  final Vo2MaxRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InstantHealthRecordTile<Vo2MaxRecord>(
      record: record,
      icon: AppIcons.vo2Max,
      title:
          '${record.vo2MlPerMinPerKg.value.toStringAsFixed(1)} '
          '${AppTexts.millilitersPerKilogramPerMinute}',
      subtitleBuilder: (r, ctx) => HealthRecordListTileSubtitle.instant(
        time: r.time,
        recordingMethod: r.metadata.recordingMethod.name,
      ),
      detailRowsBuilder: (r, ctx) => [],
      onDelete: onDelete,
    );
  }
}

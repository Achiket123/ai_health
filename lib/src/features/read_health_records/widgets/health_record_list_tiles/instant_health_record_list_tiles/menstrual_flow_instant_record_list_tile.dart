import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/common/constants/app_icons.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/common/utils/extensions/menstrual_flow_type_extension.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_detail_row.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/health_record_list_tile_subtitle.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/instant_health_record_list_tiles/instant_health_record_list_tile.dart';


final class MenstrualFlowInstantRecordListTile extends StatelessWidget {
  const MenstrualFlowInstantRecordListTile({
    required this.record,
    required this.onDelete,
    super.key,
  });

  final MenstrualFlowInstantRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InstantHealthRecordTile<MenstrualFlowInstantRecord>(
      record: record,
      icon: AppIcons.waterDrop,
      title: AppTexts.menstrualFlowInstant,
      subtitleBuilder: (r, ctx) => HealthRecordListTileSubtitle.instant(
        time: r.time,
        recordingMethod: r.metadata.recordingMethod.name,
      ),
      detailRowsBuilder: (r, ctx) => [
        HealthRecordDetailRow(
          label: AppTexts.flow,
          value: r.flow.label,
        ),
      ],
      onDelete: onDelete,
    );
  }
}

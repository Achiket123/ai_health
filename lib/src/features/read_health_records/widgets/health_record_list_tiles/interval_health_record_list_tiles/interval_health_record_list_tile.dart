import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart'
    show IntervalHealthRecord;
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_detail_row.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/base_health_record_list_tile.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/health_record_list_tile_builder_type_aliases.dart';








@immutable
final class IntervalHealthRecordTile<T extends IntervalHealthRecord>
    extends StatelessWidget {
  const IntervalHealthRecordTile({
    required this.record,
    required this.icon,
    required this.title,
    required this.subtitleBuilder,
    required this.detailRowsBuilder,
    required this.onDelete,
    super.key,
  });

  final T record;
  final IconData icon;
  final String title;
  final RecordSubtitleBuilder<T> subtitleBuilder;
  final RecordDetailRowsBuilder<T> detailRowsBuilder;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final detailRows = [
      HealthRecordDetailRow(
        label: AppTexts.id,
        value: record.id.value,
      ),
      HealthRecordDetailRow(
        label: AppTexts.startZoneOffsetSeconds,
        value: record.startZoneOffsetSeconds,
      ),
      HealthRecordDetailRow(
        label: AppTexts.endZoneOffsetSeconds,
        value: record.endZoneOffsetSeconds,
      ),
      ...detailRowsBuilder(record, context),
    ];

    return BaseHealthRecordListTile(
      icon: icon,
      title: title,
      subtitle: subtitleBuilder(record, context),
      detailRows: detailRows,
      metadata: record.metadata,
      onDelete: onDelete,
    );
  }
}

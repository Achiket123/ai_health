import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart'
    show InstantHealthRecord;
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/common/utils/date_formatter.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_detail_row.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/base_health_record_list_tile.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/health_record_list_tile_builder_type_aliases.dart';







@immutable
final class InstantHealthRecordTile<T extends InstantHealthRecord>
    extends StatelessWidget {
  const InstantHealthRecordTile({
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
        label: AppTexts.time,
        value: DateFormatter.formatDateTime(record.time),
      ),
      HealthRecordDetailRow(
        label: AppTexts.zoneOffsetSeconds,
        value: record.zoneOffsetSeconds,
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

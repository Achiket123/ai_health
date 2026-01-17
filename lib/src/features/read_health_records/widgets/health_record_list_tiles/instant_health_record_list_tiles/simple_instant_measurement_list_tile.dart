import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/health_record_list_tile_subtitle.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/instant_health_record_list_tiles/instant_health_record_list_tile.dart';










final class SimpleInstantMeasurementListTile<R extends InstantHealthRecord>
    extends StatelessWidget {
  const SimpleInstantMeasurementListTile({
    required this.record,
    required this.icon,
    required this.titleBuilder,
    required this.valueExtractor,
    required this.onDelete,
    super.key,
  });

  final R record;
  final IconData icon;
  final String Function(R record) titleBuilder;
  final MeasurementUnit Function(R record) valueExtractor;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InstantHealthRecordTile<R>(
      record: record,
      icon: icon,
      title: titleBuilder(record),
      subtitleBuilder: (r, ctx) => HealthRecordListTileSubtitle.instant(
        time: r.time,
        recordingMethod: r.metadata.recordingMethod.name,
      ),
      detailRowsBuilder: (r, ctx) => [],
      onDelete: onDelete,
    );
  }
}

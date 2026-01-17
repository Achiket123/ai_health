import 'package:flutter/material.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';

import 'package:ai_health/src/common/utils/date_formatter.dart';











@immutable
final class HealthRecordListTileSubtitle extends StatelessWidget {
  
  const HealthRecordListTileSubtitle.instant({
    required DateTime this.time,
    required this.recordingMethod,
    super.key,
  }) : startTime = null,
       endTime = null,
       additionalRows = null;

  
  const HealthRecordListTileSubtitle.interval({
    required DateTime this.startTime,
    required DateTime this.endTime,
    required this.recordingMethod,
    super.key,
  }) : time = null,
       additionalRows = null;

  
  final DateTime? time;

  
  final DateTime? startTime;

  
  final DateTime? endTime;

  
  
  final String recordingMethod;

  
  
  
  final List<Widget>? additionalRows;

  
  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) {
      return '$hours${AppTexts.hourShort} $minutes${AppTexts.minuteShort}';
    } else if (hours > 0) {
      return '$hours${AppTexts.hourShort}';
    } else {
      return '$minutes${AppTexts.minuteShort}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        // Display time info based on record type
        if (time != null)
          Text(
            '${AppTexts.time}: ${DateFormatter.formatDateTime(time)}',
          )
        else if (startTime != null && endTime != null) ...[
          Text(
            '${AppTexts.startTime}: '
            '${DateFormatter.formatDateTime(startTime)}',
          ),
          Text(
            '${AppTexts.endTime}: '
            '${DateFormatter.formatDateTime(endTime)}',
          ),
          Text(
            '${AppTexts.duration}: '
            '${_formatDuration(endTime!.difference(startTime!))}',
          ),
        ],
        ...?additionalRows,
      ],
    );
  }
}

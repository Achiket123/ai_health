import 'package:health_connector/health_connector.dart';
import 'package:collection/collection.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailySteps {
  final DateTime date;
  final int count;

  DailySteps({required this.date, required this.count});
}

class StepRepository {
  final HealthConnector _healthConnector;

  StepRepository({required HealthConnector healthConnector})
    : _healthConnector = healthConnector;

  Future<List<DailySteps>> getDailySteps(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    // Align to start of the first day
    final startTime = DateTime(startDate.year, startDate.month, startDate.day);

    try {
      final response = await _healthConnector.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.steps,
          startTime: startTime,
          endTime: now,
        ),
      );

      final records = response.records;

      // Group by day
      final grouped = groupBy(records, (StepsRecord record) {
        return DateTime(
          record.startTime.year,
          record.startTime.month,
          record.startTime.day,
        );
      });

      List<DailySteps> dailySteps = [];

      // Initialize with 0 for all days in range to ensure continuity
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final dayStart = DateTime(date.year, date.month, date.day);

        // Find records for this day
        final dayRecords = grouped[dayStart];
        int count = 0;

        if (dayRecords != null) {
          double total = 0;
          for (var record in dayRecords) {
            total += double.parse(record.count.toString());
          }
          count = total.toInt();
        }

        dailySteps.add(DailySteps(date: dayStart, count: count));
      }

      // Sort by date (ascending)
      dailySteps.sort((a, b) => a.date.compareTo(b.date));
      print("DailySteps ${dailySteps}");
      return dailySteps;
    } catch (e) {
      throw Exception('Failed to fetch steps: $e');
    }
  }
}

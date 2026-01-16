import 'package:health_connector/health_connector.dart';
import 'package:collection/collection.dart';
import 'dart:developer' as developer;

class DailySteps {
  final DateTime date;
  final int count;

  DailySteps({required this.date, required this.count});
}

class StepRepository {
  final HealthConnector _healthConnector;

  StepRepository({HealthConnector? healthConnector})
      : _healthConnector = healthConnector ?? HealthConnector.instance;

  Future<List<DailySteps>> getDailySteps(int days) async {
    final now = DateTime.now();
    // Start from midnight 'days' ago
    final startDate = now.subtract(Duration(days: days));
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

      // Group by LOCAL day
      final grouped = groupBy(records, (StepsRecord record) {
        final localDate = record.startTime.toLocal();
        return DateTime(localDate.year, localDate.month, localDate.day);
      });

      List<DailySteps> dailySteps = [];
      grouped.forEach((date, dayRecords) {
        int total = 0;
        for (var record in dayRecords) {
          total += record.count;
        }
        dailySteps.add(DailySteps(date: date, count: total));
      });

      // Sort by date
      dailySteps.sort((a, b) => a.date.compareTo(b.date));

      developer.log("StepRepository: Fetched ${dailySteps.length} daily entries.");

      return dailySteps;
    } catch (e) {
      developer.log("StepRepository: Error fetching steps: $e", error: e);
      // Return empty list instead of throwing to avoid UI crash
      return [];
    }
  }
}

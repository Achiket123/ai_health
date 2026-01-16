import 'package:health_connector/health_connector.dart';
import 'package:collection/collection.dart';

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
        return DateTime(record.startTime.year, record.startTime.month, record.startTime.day);
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

      return dailySteps;
    } catch (e) {
      throw Exception('Failed to fetch steps: $e');
    }
  }
}

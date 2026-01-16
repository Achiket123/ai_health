import 'package:health_connector/health_connector.dart';
import 'package:ai_health/features/sleep/models/sleep_data.dart';
import 'dart:developer' as developer;

class SleepRepository {
  final HealthConnector _healthConnector;

  SleepRepository({HealthConnector? healthConnector})
      : _healthConnector = healthConnector ?? HealthConnector.instance;

  Future<void> saveSleepData(SleepData data) async {
    try {
      final record = SleepSessionRecord(
        startTime: data.bedTime,
        endTime: data.wakeTime,
        startZoneOffset: data.bedTime.timeZoneOffset,
        endZoneOffset: data.wakeTime.timeZoneOffset,
        notes: "Quality: ${data.quality}",
      );

      await _healthConnector.insertRecords([record]);
      developer.log("Saved sleep record to Health Connect");
    } catch (e) {
      throw Exception('Failed to save sleep data: $e');
    }
  }

  Future<List<SleepData>> getSleepHistory() async {
    try {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 30));

      final response = await _healthConnector.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.sleepSession,
          startTime: startTime,
          endTime: now,
        ),
      );

      final records = response.records.whereType<SleepSessionRecord>().toList();

      // Sort descending
      records.sort((a, b) => b.startTime.compareTo(a.startTime));

      return records.map((r) {
        final durationHours = r.endTime.difference(r.startTime).inMinutes / 60.0;

        String quality = 'Good';
        if (r.notes != null && r.notes!.startsWith("Quality: ")) {
          quality = r.notes!.substring(9);
        }

        // Convert timestamps to local time for display logic
        final localStartTime = r.startTime.toLocal();
        final localEndTime = r.endTime.toLocal();

        return SleepData(
          date: localStartTime,
          durationHours: durationHours,
          quality: quality,
          bedTime: localStartTime,
          wakeTime: localEndTime,
        );
      }).toList();

    } catch (e) {
      developer.log('Error fetching sleep history: $e', error: e);
      return [];
    }
  }

  Future<void> deleteSleepData(DateTime date) async {
    try {
        final startTime = DateTime(date.year, date.month, date.day);
        final endTime = startTime.add(const Duration(days: 1));

        await _healthConnector.deleteRecords(
            DeleteRecordsRequest(
                dataType: HealthDataType.sleepSession,
                startTime: startTime,
                endTime: endTime,
            )
        );
    } catch (e) {
        developer.log('Error deleting sleep data: $e');
        throw Exception('Failed to delete sleep data');
    }
  }
}

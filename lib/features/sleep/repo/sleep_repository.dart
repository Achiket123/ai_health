import 'package:health_connector/health_connector.dart';
import 'package:ai_health/features/sleep/models/sleep_data.dart'; // Keeping the model for UI compatibility, but mapping it
import 'dart:developer' as developer;

import 'package:health_connector/health_connector_internal.dart';

class SleepRepository {
  final HealthConnector _healthConnector;

  SleepRepository({required HealthConnector healthConnector})
    : _healthConnector = healthConnector;

  Future<void> saveSleepData(SleepData data) async {
    try {
      // Map SleepData to SleepSessionRecord
      // Note: SleepData has duration, bedTime, wakeTime.
      // Health Connect uses SleepSessionRecord.

      final record = SleepSessionRecord(
        id: HealthRecordId(DateTime.now().millisecondsSinceEpoch.toString()),
        startTime: data.bedTime,
        endTime: data.wakeTime,
        samples: [
          SleepStageSample(
            startTime: data.bedTime,
            endTime: data.wakeTime,
            stageType: SleepStage.unknown,
          ),
        ],
        //: data.bedTime.timeZoneOffset,
        // endZoneOffset: data.wakeTime.timeZoneOffset,
        metadata: Metadata.manualEntry(),
        notes:
            "Quality: ${data.quality}", // Storing quality in notes as HC doesn't have a simple quality field
      );

      await _healthConnector.writeRecords([record]);
      developer.log("Saved sleep record to Health Connect");
    } catch (e) {
      throw Exception('Failed to save sleep data: $e');
    }
  }

  Future<List<SleepData>> getSleepHistory() async {
    try {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 30)); // Last 30 days

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
        final durationHours =
            r.endTime.difference(r.startTime).inMinutes / 60.0;

        // Parse quality from notes if possible, else default
        String quality = 'Good';
        if (r.notes != null && r.notes!.startsWith("Quality: ")) {
          quality = r.notes!.substring(9);
        }

        return SleepData(
          date: r.startTime, // Using start time as the date key
          durationHours: durationHours,
          quality: quality,
          bedTime: r.startTime,
          wakeTime: r.endTime,
        );
      }).toList();
    } catch (e) {
      developer.log('Error fetching sleep history: $e', error: e);
      return [];
    }
  }

  Future<void> deleteSleepData(DateTime date) async {
    // Deleting by time range is tricky if we don't have UUIDs.
    // health_connector `deleteRecords` usually takes IDs.
    // However, the current API might allow deletion by time range.
    // If we only have date, we try to delete sleep sessions intersecting with that day.

    // NOTE: This implementation might delete all sleep sessions on that day.
    try {
      final startTime = DateTime(date.year, date.month, date.day);
      final endTime = startTime.add(const Duration(days: 1));

      await _healthConnector.deleteRecords(
        DeleteRecordsInTimeRangeRequest(
          dataType: HealthDataType.sleepSession,
          startTime: startTime,
          endTime: endTime,
        ),
      );
    } catch (e) {
      developer.log('Error deleting sleep data: $e');
      throw Exception('Failed to delete sleep data');
    }
  }
}

import 'package:health_connector/health_connector.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:collection/collection.dart';

class DailyHydration {
  final DateTime date;
  final int glasses; // Assuming 250ml per glass
  final int volumeMl;

  DailyHydration({
    required this.date,
    required this.glasses,
    required this.volumeMl,
  });
}

class HydrationRepository {
  final HealthConnector _healthConnector;

  HydrationRepository({required HealthConnector healthConnector})
    : _healthConnector = healthConnector;

  Future<List<DailyHydration>> getHydrationHistory(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final startTime = DateTime(startDate.year, startDate.month, startDate.day);

    try {
      final response = await _healthConnector.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.hydration,
          startTime: startTime,
          endTime: now,
        ),
      );

      final records = response.records;

      // Group by day
      final grouped = groupBy(records, (HydrationRecord record) {
        return DateTime(
          record.startTime.year,
          record.startTime.month,
          record.startTime.day,
        );
      });

      List<DailyHydration> dailyHydration = [];

      // Initialize with 0 for all days in range
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final dayStart = DateTime(date.year, date.month, date.day);

        // Find records for this day
        final dayRecords = grouped[dayStart];
        int volumeMl = 0;

        if (dayRecords != null) {
          double totalVolume = 0;
          for (var record in dayRecords) {
            totalVolume += record.volume.inMilliliters;
          }
          volumeMl = totalVolume.toInt();
        }
        print(volumeMl);
        dailyHydration.add(
          DailyHydration(
            date: dayStart,
            volumeMl: volumeMl,
            glasses: (volumeMl / 250).toInt(),
          ),
        );
      }

      // Sort by date
      dailyHydration.sort((a, b) => a.date.compareTo(b.date));

      return dailyHydration;
    } catch (e) {
      throw Exception('Failed to fetch hydration history: $e');
    }
  }

  Future<void> logGlass() async {
    try {
      final now = DateTime.now();
      // Create a hydration record with 250ml (one glass of water)
      final hydrationRecord = HydrationRecord(
        startTime: now,
        endTime: now.add(Duration(minutes: 2)), // Hydration is instantaneous
        volume: const Volume.milliliters(250), // 250ml per glass
        metadata: Metadata.internal(
          recordingMethod: RecordingMethod.manualEntry,
        ),
      );

      // Write the record to Health Connect
      await _healthConnector.writeRecords([hydrationRecord]);
    } catch (e) {
      throw Exception('Failed to log hydration: $e');
    }
  }
}

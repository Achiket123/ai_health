import 'package:hive_flutter/hive_flutter.dart';
import 'package:health_connector/health_connector.dart';
import 'package:health_connector/health_connector_internal.dart';
import '../models/vital_data.dart';

class VitalsRepository {
  static const String boxName = 'vitals_data_box';
  final HealthConnector? _healthConnector;

  VitalsRepository({HealthConnector? healthConnector})
    : _healthConnector = healthConnector;

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  Future<void> saveVitalData(VitalData data) async {
    final box = await _getBox();
    // Key by timestamp to allow multiple entries per day
    final key = data.date.millisecondsSinceEpoch.toString();

    // Save to Hive (Subjective Data)
    // We strictly use Hive only for Mood/Stress/Notes as per requirement.
    // So we shouldn't rely on Hive for Heart Rate.
    // However, the model has it. We'll save it for local backup but ignore it on read?
    // Or clear it before saving?
    // Let's clear HR before saving to Hive to enforce the separation.
    final hiveData = VitalData(
      date: data.date,
      heartRate: null, // Don't store HR in Hive
      stressLevel: data.stressLevel,
      mood: data.mood,
      notes: data.notes,
    );

    await box.put(key, hiveData.toMap());

    // Write heart rate to Health Connect if available and initialized
    if (data.heartRate != null && _healthConnector != null) {
      try {
        final record = HeartRateRecord(
          id: HealthRecordId(DateTime.now().millisecondsSinceEpoch.toString()),
          time: data.date,
          metadata: Metadata.manualEntry(),
          rate: Frequency.perMinute(data.heartRate?.toDouble() ?? 0.0),
        );

        await _healthConnector!.writeRecords([record]);
      } catch (e) {
        print('Error writing heart rate to Health Connect: $e');
      }
    }
  }

  Future<List<VitalData>> getVitalsHistory() async {
    final box = await _getBox();
    final List<VitalData> hiveList = [];

    // Read Mood/Stress from Hive
    for (var i = 0; i < box.length; i++) {
      final map = box.getAt(i) as Map<dynamic, dynamic>;
      final data = VitalData.fromMap(map);
      // Ensure we treat Hive data as purely subjective (no HR)
      hiveList.add(
        VitalData(
          date: data.date,
          heartRate: null,
          stressLevel: data.stressLevel,
          mood: data.mood,
          notes: data.notes,
        ),
      );
    }

    // Fetch Heart Rate from Health Connect
    List<VitalData> hcList = [];
    if (_healthConnector != null) {
      try {
        final now = DateTime.now();
        final startTime = now.subtract(const Duration(days: 30));

        final response = await _healthConnector!.readRecords(
          ReadRecordsInTimeRangeRequest(
            dataType: HealthDataType.heartRate,
            startTime: startTime,
            endTime: now,
          ),
        );

        final records = response.records.whereType<HeartRateRecord>().toList();

        for (var r in records) {
          // Average BPM if multiple samples
        }
      } on HealthConnectorException catch (e) {
        if (e.code == 'UNSUPPORTED_OPERATION') {
          print('Heart rate is not supported on this device. Silently ignoring.');
        } else {
          print('Error fetching heart rate from Health Connect: $e');
        }
      } catch (e) {
        print('An unexpected error occurred while fetching heart rate: $e');
      }
    }

    // Combine lists
    // If we want to merge them by time, it's complex because timestamps differ.
    // But since the chart plots them as separate series (or the same series with different properties?),
    // The chart uses `LineSeries<VitalData, DateTime>`.
    // If we have two entries: T1 (Mood only) and T2 (HR only).
    // The chart for Stress uses `stressLevel`. It will plot 0 for T2 (HR only) if we aren't careful.
    // Wait, the chart configuration:
    /*
      LineSeries<VitalData, DateTime>(
        dataSource: _weeklyVitals,
        yValueMapper: (VitalData data, _) => data.stressLevel,
    */
    // If we include HC records (Stress=0), the Stress chart will drop to 0. That's bad.
    // We should filter the list for the specific chart?
    // OR we should only include HC records if they have valid data for the chart?
    // No, `getVitalsHistory` returns a generic list. The UI decides how to use it.
    // The UI currently uses ONE list `_weeklyVitals` for the Stress chart.
    // It does NOT have a Heart Rate chart on the dashboard!
    // "Wellness Trends" -> SplineArea (Sleep), Line (Stress).
    // There is NO Heart Rate on the dashboard chart.
    // So if I include HR-only records in `_weeklyVitals` (with Stress=0), the Stress chart will look wrong.

    // Resolution:
    // 1. Return all data.
    // 2. But the UI filters/maps.
    // Wait, `VitalData` has `heartRate` AND `stressLevel`.
    // If the dashboard ONLY shows Stress, then `hcList` (Heart Rate only) effectively pollutes the Stress chart with 0s.
    // UNLESS I update the UI to filter out 0-stress items for the Stress Series.
    // OR I don't return HR records in `getVitalsHistory` if the UI doesn't use them?
    // But `VitalsPage` (feature page) probably uses HR.

    // I should probably NOT merge them into a single list of "VitalData" unless I merge by time.
    // But for now, let's keep them separate in logic or assume UI handles it.
    // ACTUALLY, checking `HomePage` again:
    /*
      LineSeries<VitalData, DateTime>(
        dataSource: _weeklyVitals,
        yValueMapper: (VitalData data, _) => data.stressLevel,
    */
    // It maps Stress Level directly.
    // If `_weeklyVitals` contains items with Stress=0 (from HR records), the line will drop to 0.

    // I must ensure that `_weeklyVitals` in HomePage ONLY contains items with valid Stress levels?
    // OR I filter them in the Repository?
    // But the Repository is "getVitalsHistory" - implies all vitals.

    // I'll filter in `HomePage`.

    final combined = [...hiveList, ...hcList];
    combined.sort((a, b) => b.date.compareTo(a.date));

    return combined;
  }
}

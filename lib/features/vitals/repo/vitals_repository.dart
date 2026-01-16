import 'package:hive_flutter/hive_flutter.dart';
import 'package:health_connector/health_connector.dart';
import 'package:health_connector/health_connector_internal.dart';
import '../models/vital_data.dart';
import 'dart:developer' as developer;

class VitalsRepository {
  static const String boxName = 'vitals_data_box';
  HealthConnector? _healthConnector;

  VitalsRepository({HealthConnector? healthConnector})
      : _healthConnector = healthConnector;

  // Use a default instance if not provided (e.g., from main)
  Future<HealthConnector> get _hc async {
    if (_healthConnector != null) return _healthConnector!;
    _healthConnector = await HealthConnector.create();
    return _healthConnector!;
  }

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  Future<void> saveVitalData(VitalData data) async {
    // 1. Save Mood/Stress to Hive (Local)
    final box = await _getBox();
    final key = data.date.millisecondsSinceEpoch.toString();
    await box.put(key, data.toMap());

    // 2. Save Heart Rate to Health Connect if available
    if (data.heartRate != null) {
      try {
        final hc = await _hc;
        final record = HeartRateRecord(
          startTime: data.date,
          endTime: data.date.add(const Duration(seconds: 1)),
          samples: [
            HeartRateSample(
              beatsPerMinute: data.heartRate!,
              time: data.date,
            ),
          ],
          metadata: Metadata.manualEntry(),
        );
        await hc.writeRecords([record]);
        developer.log("Saved heart rate to Health Connect");
      } catch (e) {
        developer.log("Failed to save heart rate to Health Connect: $e", error: e);
      }
    }
  }

  Future<List<VitalData>> getVitalsHistory() async {
    // 1. Fetch Hive Data (Mood/Stress)
    final box = await _getBox();
    final List<VitalData> hiveData = [];
    for (var i = 0; i < box.length; i++) {
      final map = box.getAt(i) as Map<dynamic, dynamic>;
      hiveData.add(VitalData.fromMap(map));
    }

    // 2. Fetch Heart Rate from Health Connect
    List<HeartRateRecord> hrRecords = [];
    try {
      final hc = await _hc;
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 30));

      final response = await hc.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.heartRate,
          startTime: startTime,
          endTime: now,
        ),
      );
      hrRecords = response.records.whereType<HeartRateRecord>().toList();
    } catch (e) {
       developer.log("Failed to fetch heart rate from Health Connect: $e", error: e);
    }

    // 3. Merge Data
    // We prioritize Health Connect Heart Rate.
    // If a Hive entry exists for a date, we update its heart rate.
    // If a Heart Rate record exists but no Hive entry, we create a new entry with default mood.

    // Convert Hive list to map for easier lookup (key: truncated date/hour or exact timestamp)
    // Note: Timestamps might not match exactly. We'll try to match by date and hour or just list all.
    // Since UI shows a list, we can just return all entries sorted.
    // However, if we have duplicate "events" (one in Hive, one in HC), we should merge.
    // Let's assume matching by "Day" is enough for the history list, or just list them all.
    // Actually, `VitalData` represents a single log entry.
    // If the user logged Mood at 10:00 AM and Heart Rate at 10:05 AM, they are separate.

    // Strategy: Return all Hive entries (with their stored HR if any, or update from HC if time matches close enough)
    // AND add generic entries for HR records that don't match any Hive entry.

    // For simplicity in this "fix", let's just append HR-only records as new VitalData objects
    // if they don't overlap with existing ones.

    // But wait, Hive data already has `heartRate`. If we fetch from HC, we should use that instead?
    // User might have logged HR manually in the form which saved to Hive.
    // Now we also save to HC. So we might have duplicates if we read both.
    // Decision: Use HC as source of truth for HR. If Hive entry has HR, ignore it?
    // Or just list what we have.

    // Let's return Hive data (Mood/Stress) and INTERLEAVE HC data (Heart Rate).
    // If a Hive entry has HR, we can keep it (it was manual).
    // If HC has HR, we show it.

    List<VitalData> combined = [...hiveData];

    for (var record in hrRecords) {
        // Create a VitalData from HR record
        // We don't have mood/stress, so we set defaults or nulls (if model allows).
        // VitalData requires stressLevel and mood.
        // We can check if there's already a VitalData close to this time (e.g. within 5 mins)
        // and update it, otherwise create new one with "Unknown" mood?

        bool merged = false;
        for (var existing in combined) {
            if (existing.date.difference(record.startTime).abs().inMinutes < 5) {
                // Merge (conceptually - but VitalData is immutable usually, and we already have it in list)
                // If the existing one is from Hive, it might already have HR.
                // Let's assume Hive is "Manual Log" which includes Mood.
                // HC is "Measured".
                // If they are close, maybe it's the same event.
                merged = true;
                break;
            }
        }

        if (!merged) {
             // Create independent HR entry
             // We need default values for required fields
             // Stress 1-10 (5 is middle), Mood "Measured" or similar?
             // The model has required strings.

             // VitalData(date, heartRate, stressLevel, mood, notes)
             combined.add(VitalData(
                date: record.startTime,
                heartRate: record.samples.isNotEmpty ? record.samples.first.beatsPerMinute : 0,
                stressLevel: 0, // 0 to indicate "no data" or "neutral"
                mood: 'Measured',
                notes: 'Auto-recorded Heart Rate',
             ));
        }
    }

    // Sort by date descending
    combined.sort((a, b) => b.date.compareTo(a.date));
    return combined;
  }
}

import 'package:health_connector/health_connector.dart';
import 'package:ai_health/features/vitals/models/vital_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class VitalsRepository {
  final HealthConnector _healthConnector;
  final SupabaseClient _supabase;

  VitalsRepository({HealthConnector? healthConnector, SupabaseClient? supabase})
      : _healthConnector = healthConnector ?? HealthConnector.instance,
        _supabase = supabase ?? Supabase.instance.client;

  Future<void> saveVitalData(VitalData data) async {
    try {
      // 1. Save Heart Rate to Health Connect
      if (data.heartRate != null) {
        final record = HeartRateRecord(
          startTime: data.date,
          endTime: data.date.add(const Duration(minutes: 1)),
          startZoneOffset: data.date.timeZoneOffset,
          endZoneOffset: data.date.timeZoneOffset,
          samples: [
            HeartRateSample(
                beatsPerMinute: data.heartRate!.toInt(),
                time: data.date
            )
          ],
        );
        await _healthConnector.insertRecords([record]);
      }

      // 2. Save Mood/Stress/Notes to Supabase
      if (_supabase.auth.currentUser != null) {
        await _supabase.from('daily_vitals_log').upsert({
          'user_id': _supabase.auth.currentUser!.id,
          'log_date': data.date.toIso8601String(),
          'stress_level': data.stressLevel,
          'mood': data.mood,
          'notes': data.notes
        });
        developer.log('Saved vitals to Supabase');
      }
    } catch (e) {
      developer.log('Error saving vitals: $e', error: e);
    }
  }

  Future<List<VitalData>> getVitalsHistory() async {
    List<VitalData> allVitals = [];

    // Fetch from Health Connect (Heart Rate)
    try {
       final now = DateTime.now();
       final startTime = now.subtract(const Duration(days: 30));

       final response = await _healthConnector.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.heartRate,
          startTime: startTime,
          endTime: now,
        ),
      );

      final records = response.records.whereType<HeartRateRecord>().toList();
      for (var r in records) {
          int avgHr = 0;
          if (r.samples.isNotEmpty) {
             avgHr = (r.samples.map((s) => s.beatsPerMinute).reduce((a, b) => a + b) / r.samples.length).round();
          }
          // We create a VitalData with just HR for now, utilizing local time
          allVitals.add(VitalData(
            date: r.startTime.toLocal(),
            heartRate: avgHr,
            stressLevel: 0,
            mood: '',
          ));
      }
    } catch (e) {
      developer.log('Error fetching HC records: $e');
    }

    // Fetch from Supabase (Mood/Stress)
    try {
      if (_supabase.auth.currentUser != null) {
        final response = await _supabase
            .from('daily_vitals_log')
            .select()
            .eq('user_id', _supabase.auth.currentUser!.id)
            .order('log_date', ascending: false)
            .limit(50);

        for (var row in response) {
          final date = DateTime.parse(row['log_date']).toLocal();

          final existingIndex = allVitals.indexWhere((v) =>
            v.date.difference(date).abs().inMinutes < 5 && v.heartRate != null
          );

          if (existingIndex != -1) {
            // Merge
            final existing = allVitals[existingIndex];
            allVitals[existingIndex] = VitalData(
              date: existing.date,
              heartRate: existing.heartRate,
              stressLevel: row['stress_level'] ?? 5,
              mood: row['mood'] ?? '',
              notes: row['notes']
            );
          } else {
            // Add new
            allVitals.add(VitalData(
              date: date,
              heartRate: null,
              stressLevel: row['stress_level'] ?? 5,
              mood: row['mood'] ?? '',
              notes: row['notes']
            ));
          }
        }
      }
    } catch (e) {
      developer.log('Error fetching Supabase records: $e');
    }

    allVitals.sort((a, b) => b.date.compareTo(a.date));
    return allVitals;
  }
}

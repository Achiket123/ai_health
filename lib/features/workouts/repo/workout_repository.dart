import 'package:health_connector/health_connector.dart';
import 'package:ai_health/features/workouts/models/workout_data.dart';
import 'dart:developer' as developer;

import 'package:health_connector/health_connector_internal.dart';

class WorkoutRepository {
  final HealthConnector _healthConnector;

  WorkoutRepository({required HealthConnector healthConnector})
    : _healthConnector = healthConnector;

  Future<void> saveWorkout(WorkoutData data) async {
    try {
      final endTime = data.date.add(Duration(minutes: data.durationMinutes));

      // Map String type to ExerciseType
      ExerciseType exerciseType = _mapStringToExerciseType(data.type);

      final record = ExerciseSessionRecord(
        startTime: data.date,
        endTime: endTime,
        metadata: Metadata.manualEntry(),
        //startZoneOffset: data.date.timeZoneOffset,
        //endZoneOffset: endTime.timeZoneOffset,
        exerciseType: exerciseType,
        notes: data.notes,
        title: data.type,
      );

      // We should also insert TotalEnergyBurnedRecord if calories are provided
      await _healthConnector.writeRecords([record]);

      if (data.caloriesBurned > 0) {
        final energyRecord = TotalEnergyBurnedRecord(
          startTime: data.date,
          endTime: endTime,
          metadata: Metadata.manualEntry(),
          //          startZoneOffset: data.date.timeZoneOffset,
          //        endZoneOffset: endTime.timeZoneOffset,
          energy: Energy.kilocalories(data.caloriesBurned.toDouble()),
        );
        await _healthConnector.writeRecords([energyRecord]);
      }

      developer.log("Saved workout to Health Connect");
    } catch (e) {
      throw Exception('Failed to save workout: $e');
    }
  }

  Future<List<WorkoutData>> getWorkoutHistory() async {
    try {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 90)); // Last 90 days

      final response = await _healthConnector.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.exerciseSession,
          startTime: startTime,
          endTime: now,
        ),
      );

      final records = response.records
          .whereType<ExerciseSessionRecord>()
          .toList();
      records.sort((a, b) => b.startTime.compareTo(a.startTime));

      // Note: fetching calories associated with each session is complex because they are separate records.
      // For simplicity/MVP, we might not fetch exact calories linked to session unless we do a correlated query.
      // We will set calories to 0 or try to fetch if possible.
      // Optimized approach: Fetch all energy records in range and match manually?
      // For now, we return 0 for calories on read, or implement a separate fetch.
      // Let's assume we read just the session info.

      return records.map((r) {
        final durationMinutes = r.endTime.difference(r.startTime).inMinutes;
        return WorkoutData(
          date: r.startTime,
          type: _mapExerciseTypeToString(r.exerciseType),
          durationMinutes: durationMinutes,
          caloriesBurned:
              0, // Placeholder as linking records is complex without UUIDs
          notes: r.notes,
        );
      }).toList();
    } catch (e) {
      developer.log('Error fetching workout history: $e', error: e);
      return [];
    }
  }

  ExerciseType _mapStringToExerciseType(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return ExerciseType.running;
      case 'walking':
        return ExerciseType.walking;
      case 'cycling':
        return ExerciseType.cycling;
      case 'swimming':
        return ExerciseType.swimmingPool; // Default to pool
      case 'gym':
        return ExerciseType.strengthTraining;
      case 'yoga':
        return ExerciseType.yoga;
      case 'hiit':
        return ExerciseType.highIntensityIntervalTraining;
      default:
        return ExerciseType.other;
    }
  }

  String _mapExerciseTypeToString(ExerciseType type) {
    // Simple reverse mapping
    return type.toString().split('.').last;
  }
}

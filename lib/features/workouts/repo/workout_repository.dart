import 'package:health_connector/health_connector.dart';
import 'package:ai_health/features/workouts/models/workout_data.dart';
import 'dart:developer' as developer;

class WorkoutRepository {
  final HealthConnector _healthConnector;

  WorkoutRepository({HealthConnector? healthConnector})
      : _healthConnector = healthConnector ?? HealthConnector.instance;

  Future<void> saveWorkout(WorkoutData data) async {
    try {
      final endTime = data.date.add(Duration(minutes: data.durationMinutes));

      ExerciseType exerciseType = _mapStringToExerciseType(data.type);

      final record = ExerciseSessionRecord(
        startTime: data.date,
        endTime: endTime,
        startZoneOffset: data.date.timeZoneOffset,
        endZoneOffset: endTime.timeZoneOffset,
        exerciseType: exerciseType,
        notes: data.notes,
        title: data.type,
      );

      await _healthConnector.insertRecords([record]);

      if (data.caloriesBurned > 0) {
          final energyRecord = TotalEnergyBurnedRecord(
              startTime: data.date,
              endTime: endTime,
              startZoneOffset: data.date.timeZoneOffset,
              endZoneOffset: endTime.timeZoneOffset,
              energy: Energy.kilocalories(data.caloriesBurned.toDouble()),
          );
           await _healthConnector.insertRecords([energyRecord]);
      }

      developer.log("Saved workout to Health Connect");
    } catch (e) {
      throw Exception('Failed to save workout: $e');
    }
  }

  Future<List<WorkoutData>> getWorkoutHistory() async {
    try {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 90));

      final response = await _healthConnector.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.exerciseSession,
          startTime: startTime,
          endTime: now,
        ),
      );

      final records = response.records.whereType<ExerciseSessionRecord>().toList();
      records.sort((a, b) => b.startTime.compareTo(a.startTime));

      return records.map((r) {
        final durationMinutes = r.endTime.difference(r.startTime).inMinutes;

        // Return with local time
        final localStartTime = r.startTime.toLocal();

        return WorkoutData(
          date: localStartTime,
          type: _mapExerciseTypeToString(r.exerciseType),
          durationMinutes: durationMinutes,
          caloriesBurned: 0,
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
          case 'running': return ExerciseType.running;
          case 'walking': return ExerciseType.walking;
          case 'cycling': return ExerciseType.cycling;
          case 'swimming': return ExerciseType.swimmingPool;
          case 'gym': return ExerciseType.strengthTraining;
          case 'yoga': return ExerciseType.yoga;
          case 'hiit': return ExerciseType.highIntensityIntervalTraining;
          default: return ExerciseType.other;
      }
  }

  String _mapExerciseTypeToString(ExerciseType type) {
      return type.toString().split('.').last;
  }
}

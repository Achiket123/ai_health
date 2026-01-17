import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector.dart';
import 'package:ai_health/features/step/repo/step_repository.dart'; // for DailySteps
import 'package:ai_health/features/sleep/models/sleep_data.dart'; // for DailySleep
import 'package:ai_health/features/hydration/pages/hydration_page.dart'; // DailyHydration is likely here or in repo
import 'package:ai_health/features/workouts/models/workout_data.dart'; // DailyWorkout
import 'package:ai_health/features/vitals/models/vital_data.dart'; // VitalData
import 'package:ai_health/features/nutrition/repo/nutrition_repo.dart';
import 'package:ai_health/features/meditation/data/meditation_repository.dart'; // For meditation history
import 'package:ai_health/features/hydration/repo/hydration_repository.dart';
import 'package:ai_health/features/workouts/repo/workout_repository.dart';
import 'package:ai_health/features/sleep/repo/sleep_repository.dart';
import 'package:ai_health/features/vitals/repo/vitals_repository.dart';


class DashboardProvider extends ChangeNotifier {
  final HealthConnector _healthConnector;
  
  // Repositories (can be passed in or created locally if they just wrap HealthConnector)
  // We'll create them locally to keep it simple as they seem stateless besides HealthConnector
  late final StepRepository _stepRepository;
  late final SleepRepository _sleepRepository;
  late final VitalsRepository _vitalsRepository;
  late final HydrationRepository _hydrationRepository;
  late final WorkoutRepository _workoutRepository;
  late final NutritionRepository _nutritionRepository;
  late final MeditationRepository _meditationRepository;

  DashboardProvider(this._healthConnector) {
    _stepRepository = StepRepository(healthConnector: _healthConnector);
    _sleepRepository = SleepRepository(healthConnector: _healthConnector);
    _vitalsRepository = VitalsRepository(healthConnector: _healthConnector);
    _hydrationRepository = HydrationRepository(healthConnector: _healthConnector);
    _workoutRepository = WorkoutRepository(healthConnector: _healthConnector);
    _nutritionRepository = NutritionRepository(healthConnector: _healthConnector);
    _meditationRepository = MeditationRepository(healthConnector: _healthConnector);
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<DailySteps> _weeklySteps = [];
  List<DailySleep> _weeklySleep = [];
  List<VitalData> _weeklyVitals = [];
  List<DailyHydration> _weeklyHydration = [];
  List<DailyWorkout> _weeklyWorkouts = [];
  List<DailyCalories> _weeklyCalories = [];
  List<Map<String, dynamic>> _meditationHistory = [];

  List<DailySteps> get weeklySteps => _weeklySteps;
  List<DailySleep> get weeklySleep => _weeklySleep;
  List<VitalData> get weeklyVitals => _weeklyVitals;
  List<DailyHydration> get weeklyHydration => _weeklyHydration;
  List<DailyWorkout> get weeklyWorkouts => _weeklyWorkouts;
  List<DailyCalories> get weeklyCalories => _weeklyCalories;
  List<Map<String, dynamic>> get meditationHistory => _meditationHistory;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Helper to safely fetch data or return a default value
      Future<T> safeFetch<T>(Future<T> future, T defaultValue) async {
        try {
          return await future;
        } catch (e) {
          print("Error fetching dashboard data part: $e");
          return defaultValue;
        }
      }

      final results = await Future.wait([
        safeFetch<List<DailySteps>>(_stepRepository.getDailySteps(7), []),
        safeFetch<List<DailySleep>>(_sleepRepository.getDailySleepDuration(7), []),
        safeFetch<List<VitalData>>(_vitalsRepository.getVitalsHistory(), []),
        safeFetch<List<DailyHydration>>(_hydrationRepository.getHydrationHistory(7), []),
        safeFetch<List<DailyWorkout>>(_workoutRepository.getDailyWorkoutDuration(7), []),
        safeFetch<List<DailyCalories>>(_nutritionRepository.getDailyCalories(7), []),
        safeFetch<List<Map<String, dynamic>>>(_meditationRepository.getMeditationHistory(), []),
      ]);

      _weeklySteps = results[0] as List<DailySteps>;
      _weeklySleep = results[1] as List<DailySleep>;
      final vitals = results[2] as List<VitalData>;
      _weeklyHydration = results[3] as List<DailyHydration>;
      _weeklyWorkouts = results[4] as List<DailyWorkout>;
      _weeklyCalories = results[5] as List<DailyCalories>;
      _meditationHistory = results[6] as List<Map<String, dynamic>>;

      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      _weeklyVitals = vitals.where((v) => v.date.isAfter(cutoff)).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

    } catch (e) {
      print("Error loading dashboard provider data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

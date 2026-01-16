import 'package:ai_health/features/auth/pages/login_page.dart';
import 'package:ai_health/features/form/pages/form_page.dart';
import 'package:ai_health/features/hydration/bloc/hydration_bloc.dart';
import 'package:ai_health/features/hydration/repo/hydration_repository.dart';
import 'package:ai_health/features/meditation/pages/meditation_page.dart';
import 'package:ai_health/features/nutrition/pages/nutrition_page.dart';
import 'package:ai_health/features/permissions/pages/permissions_page.dart';
import 'package:ai_health/features/streak/pages/streak_page.dart';
import 'package:ai_health/features/step/pages/step_page.dart';
import 'package:ai_health/features/hydration/pages/hydration_page.dart';
import 'package:ai_health/features/sleep/pages/sleep_page.dart';
import 'package:ai_health/features/sleep/models/sleep_data.dart';
import 'package:ai_health/features/sleep/repo/sleep_repository.dart';
import 'package:ai_health/features/vitals/pages/vitals_page.dart';
import 'package:ai_health/features/vitals/repo/vitals_repository.dart';
import 'package:ai_health/features/vitals/models/vital_data.dart';
import 'package:ai_health/features/workouts/models/workout_data.dart';
import 'package:ai_health/features/workouts/pages/workouts_page.dart';
import 'package:ai_health/features/workouts/repo/workout_repository.dart';
import 'package:ai_health/features/step/repo/step_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_health/main.dart' show healthConnector;
import 'package:ai_health/services/permissions_service.dart';
import 'package:ai_health/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ProfileService _profileService;
  late PermissionsService _permissionsService;
  late StepRepository _stepRepository;
  late SleepRepository _sleepRepository;
  late VitalsRepository _vitalsRepository;
  late HydrationRepository _hydrationRepository;
  late WorkoutRepository _workoutRepository;

  List<DailySteps> _weeklySteps = [];
  List<SleepData> _weeklySleep = [];
  List<VitalData> _weeklyVitals = [];
  List<DailyHydration> _weeklyHydration = [];
  List<WorkoutData> _weeklyWorkouts = [];

  bool _isLoadingDashboard = true;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(supabaseClient: Supabase.instance.client);
    _permissionsService = PermissionsService(healthConnector: healthConnector);
    _stepRepository = StepRepository(healthConnector: healthConnector);
    _sleepRepository = SleepRepository(healthConnector: healthConnector);
    _vitalsRepository = VitalsRepository();
    _hydrationRepository = HydrationRepository(
      healthConnector: healthConnector,
    );
    _workoutRepository = WorkoutRepository(healthConnector: healthConnector);

    _checkProfileCompletion();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // Helper to safely fetch data or return a default value
    Future<T> safeFetch<T>(Future<T> future, T defaultValue) async {
      try {
        return await future;
      } catch (e) {
        print("Error fetching dashboard data part: $e", );
        return defaultValue;
      }
    }

    try {
      // Fetch data for the last 7 days independently but in parallel
      final stepsFuture = safeFetch<List<DailySteps>>(
        _stepRepository.getDailySteps(7),
        [],
      );
      final sleepFuture = safeFetch<List<SleepData>>(
        _sleepRepository.getSleepHistory(),
        [],
      );
      final vitalsFuture = safeFetch<List<VitalData>>(
        _vitalsRepository.getVitalsHistory(),
        [],
      );
      final hydrationFuture = safeFetch<List<DailyHydration>>(
        _hydrationRepository.getHydrationHistory(7),
        [],
      );
      final workoutFuture = safeFetch<List<WorkoutData>>(
        _workoutRepository.getWorkoutHistory(),
        [],
      );

      final results = await Future.wait([
        stepsFuture,
        sleepFuture,
        vitalsFuture,
        hydrationFuture,
        workoutFuture,
      ]);

      if (mounted) {
        setState(() {
          _weeklySteps = results[0] as List<DailySteps>;

          final cutoff = DateTime.now().subtract(const Duration(days: 7));

          // Sleep
          final sleep = results[1] as List<SleepData>;
          _weeklySleep =
              sleep.where((s) => s.date.isAfter(cutoff)).toList()
                ..sort((a, b) => a.date.compareTo(b.date));

          // Vitals
          final vitals = results[2] as List<VitalData>;
          _weeklyVitals =
              vitals.where((v) => v.date.isAfter(cutoff)).toList()
                ..sort((a, b) => a.date.compareTo(b.date));

          // Hydration
          final hydration = results[3] as List<DailyHydration>;
          _weeklyHydration =
              hydration.where((h) => h.date.isAfter(cutoff)).toList()
                ..sort((a, b) => a.date.compareTo(b.date));

          // Workouts
          final workouts = results[4] as List<WorkoutData>;
          _weeklyWorkouts =
              workouts.where((w) => w.date.isAfter(cutoff)).toList()
                ..sort((a, b) => a.date.compareTo(b.date));

          _isLoadingDashboard = false;
        });
      }
    } catch (e) {
      print("Error loading dashboard: $e");
      if (mounted) setState(() => _isLoadingDashboard = false);
    } finally {
      if (mounted && _isLoadingDashboard) {
        setState(() => _isLoadingDashboard = false);
      }
    }
  }

  Future<void> _checkProfileCompletion() async {
    try {
      final isProfileCompleted = await _profileService.isProfileCompleted();

      if (!mounted) return;

      if (!isProfileCompleted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const FormPage()),
        );
      } else {
        _checkPermissionsCompletion();
      }
    } catch (e) {
      print('Error checking profile: $e', );
    }
  }

  Future<void> _checkPermissionsCompletion() async {
    try {
      final allPermissionsGranted = await _permissionsService
          .areAllPermissionsGranted();

      if (!mounted) return;

      if (!allPermissionsGranted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PermissionsPage()),
        );
      }
    } catch (e) {
      print('Error checking permissions: $e', );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name =
        user?.userMetadata?["name"]?.toString().split(" ")[0] ?? "User";
    final now = DateTime.now();
    final dateString = DateFormat('EEEE, d MMMM').format(now);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Lighter background
      body: _isLoadingDashboard
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateString.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Hello, $name",
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              // Optional: Profile tap action
                            },
                            borderRadius: BorderRadius.circular(50),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blueGrey[100],
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Summary List
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildSummaryCard(
                            title: "Steps",
                            value: _getTodaySteps().toString(),
                            unit: "steps",
                            icon: Icons.directions_walk,
                            color: Colors.orangeAccent,
                          ),
                          _buildSummaryCard(
                            title: "Sleep",
                            value: _getTodaySleep(),
                            unit: "hrs",
                            icon: Icons.bedtime,
                            color: Colors.indigoAccent,
                          ),
                          _buildSummaryCard(
                            title: "Water",
                            value: "${_getTodayWater()}ml",
                            unit: "today",
                            icon: Icons.water_drop,
                            color: Colors.blueAccent,
                          ),
                          _buildSummaryCard(
                            title: "Active",
                            value: "${_getTodayWorkoutMins()}m",
                            unit: "today",
                            icon: Icons.fitness_center,
                            color: Colors.teal,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(top: 24)),

                  // Charts Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Activity Trends",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 250,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SfCartesianChart(
                              margin: EdgeInsets.zero,
                              plotAreaBorderWidth: 0,
                              primaryXAxis: DateTimeAxis(
                                dateFormat: DateFormat.E(),
                                majorGridLines: const MajorGridLines(width: 0),
                                axisLine: const AxisLine(width: 0),
                                labelStyle: TextStyle(color: Colors.grey[600]),
                              ),
                              primaryYAxis: NumericAxis(
                                majorGridLines: MajorGridLines(
                                  width: 0.5,
                                  color: Colors.grey[200],
                                ),
                                axisLine: const AxisLine(width: 0),
                                labelStyle: TextStyle(color: Colors.grey[600]),
                              ),
                              series: [
                                ColumnSeries<DailySteps, DateTime>(
                                  dataSource: _weeklySteps,
                                  xValueMapper: (DailySteps data, _) =>
                                      data.date,
                                  yValueMapper: (DailySteps data, _) =>
                                      data.count,
                                  name: 'Steps',
                                  color: Colors.orangeAccent,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(top: 24)),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Wellness Trends",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 250,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SfCartesianChart(
                              margin: EdgeInsets.zero,
                              plotAreaBorderWidth: 0,
                              primaryXAxis: DateTimeAxis(
                                dateFormat: DateFormat.E(),
                                majorGridLines: const MajorGridLines(width: 0),
                                axisLine: const AxisLine(width: 0),
                                labelStyle: TextStyle(color: Colors.grey[600]),
                              ),
                              primaryYAxis: NumericAxis(
                                majorGridLines: MajorGridLines(
                                  width: 0.5,
                                  color: Colors.grey[200],
                                ),
                                axisLine: const AxisLine(width: 0),
                                minimum: 0,
                                maximum:
                                    12, // Adjusted for sleep hours or stress level
                                labelStyle: TextStyle(color: Colors.grey[600]),
                              ),
                              legend: Legend(
                                isVisible: true,
                                position: LegendPosition.bottom,
                              ),
                              series: [
                                SplineAreaSeries<SleepData, DateTime>(
                                  dataSource: _weeklySleep,
                                  xValueMapper: (SleepData data, _) =>
                                      data.date,
                                  yValueMapper: (SleepData data, _) =>
                                      data.durationHours,
                                  name: 'Sleep (hrs)',
                                  color: Colors.indigoAccent.withOpacity(0.1),
                                  borderColor: Colors.indigoAccent,
                                  borderWidth: 2,
                                ),
                                LineSeries<VitalData, DateTime>(
                                  dataSource: _weeklyVitals,
                                  xValueMapper: (VitalData data, _) =>
                                      data.date,
                                  yValueMapper: (VitalData data, _) =>
                                      data.stressLevel,
                                  name: 'Stress',
                                  color: Colors.redAccent,
                                  width: 2,
                                  markerSettings: const MarkerSettings(
                                    isVisible: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(top: 24)),

                  // Features List
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Features",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureTile(
                            context,
                            "Steps",
                            Icons.directions_walk,
                            Colors.orangeAccent,
                            const StepPage(),
                          ),
                          _buildFeatureTile(
                            context,
                            "Sleep",
                            Icons.bedtime,
                            Colors.indigoAccent,
                            const SleepPage(),
                          ),
                          _buildFeatureTile(
                            context,
                            "Hydration",
                            Icons.water_drop,
                            Colors.blueAccent,
                            BlocProvider(
                              create: (_) => HydrationBloc(),
                              child: const HydrationPage(),
                            ),
                          ),
                          _buildFeatureTile(
                            context,
                            "Nutrition",
                            Icons.restaurant_menu,
                            Colors.green,
                            NutritionPage(userId: user?.id ?? ''),
                          ),
                          _buildFeatureTile(
                            context,
                            "Vitals & Mood",
                            Icons.monitor_heart,
                            Colors.redAccent,
                            const VitalsPage(),
                          ),
                          _buildFeatureTile(
                            context,
                            "Workouts",
                            Icons.fitness_center,
                            Colors.teal,
                            const WorkoutsPage(),
                          ),
                          _buildFeatureTile(
                            context,
                            "Meditation",
                            Icons.self_improvement,
                            Colors.purple,
                            const MeditationPage(),
                          ),
                          _buildFeatureTile(
                            context,
                            "Streak",
                            Icons.local_fire_department,
                            Colors.deepOrange,
                            StreakPage(userId: user?.id ?? ''),
                          ),
                          // Logout button
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await Supabase.instance.client.auth.signOut();
                                if (mounted) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.grey,
                              ),
                              label: const Text(
                                "Log Out",
                                style: TextStyle(color: Colors.grey),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
                ],
              ),
            ),
    );
  }

  int _getTodaySteps() {
    if (_weeklySteps.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todaySteps = _weeklySteps.firstWhereOrNull(
      (s) => DateTime(s.date.year, s.date.month, s.date.day) == today,
    );
    return todaySteps?.count ?? 0;
  }

  String _getTodaySleep() {
    if (_weeklySleep.isEmpty) return "0";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Find sleep session that ended today (or started today, depending on logic)
    // Usually sleep for "today" means last night's sleep which might end today morning.
    // Let's look for sleep ending on "today".
    // _weeklySleep is SleepData with date=startTime.
    // We should probably check if date is today or yesterday.
    // Let's stick to simple "started today" or "ended today" if possible.
    // SleepRepository.getSleepHistory returns SleepData with date = startTime.
    // If I sleep at 11 PM and wake up at 7 AM, date is yesterday.
    // But usually people want to see "Last Night's Sleep".
    // Let's just pick the latest one if it's within 24 hours?
    // Or check if it matches today.
    // For now, to be safe and consistent with "Today's Summary", I'll check if the sleep record date (start time) is today.
    // Wait, if I sleep at 11PM, the date is yesterday.
    // Let's check for sleep ending today.
    // SleepData has wakeTime (endTime).

    final todaySleep = _weeklySleep.firstWhereOrNull((s) {
      final wakeDate = DateTime(
        s.wakeTime.year,
        s.wakeTime.month,
        s.wakeTime.day,
      );
      return wakeDate == today;
    });

    // Fallback: if no sleep ends today, maybe check if one started today (nap).
    // Or just return 0.

    return todaySleep?.durationHours.toStringAsFixed(1) ?? "0";
  }

  int _getTodayWater() {
    if (_weeklyHydration.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayHydration = _weeklyHydration.firstWhereOrNull(
      (h) => DateTime(h.date.year, h.date.month, h.date.day) == today,
    );
    return todayHydration?.volumeMl ?? 0;
  }

  int _getTodayWorkoutMins() {
    if (_weeklyWorkouts.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _weeklyWorkouts
        .where((w) => DateTime(w.date.year, w.date.month, w.date.day) == today)
        .fold(0, (sum, item) => sum + item.durationMinutes);
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "$title ($unit)",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }
}

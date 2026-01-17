import 'package:ai_health/features/auth/pages/login_page.dart';
import 'package:ai_health/features/form/pages/form_page.dart';
import 'package:ai_health/features/hydration/bloc/hydration_bloc.dart';
import 'package:ai_health/features/hydration/repo/hydration_repository.dart';
import 'package:ai_health/features/meditation/pages/meditation_page.dart';
import 'package:ai_health/features/meditation/data/meditation_repository.dart';
import 'package:ai_health/features/nutrition/pages/nutrition_page.dart';
import 'package:ai_health/features/nutrition/repo/nutrition_repo.dart';
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
import 'package:provider/provider.dart';
import 'package:ai_health/features/home/providers/dashboard_provider.dart';
import 'package:ai_health/src/features/read_health_records/pages/read_health_records_page.dart';
import 'package:ai_health/src/features/read_health_records/read_health_records_change_notifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ProfileService _profileService;
  late PermissionsService _permissionsService;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(supabaseClient: Supabase.instance.client);
    _permissionsService = PermissionsService(healthConnector: healthConnector);

    _checkProfileCompletion();
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
      print('Error checking profile: $e');
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
      print('Error checking permissions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name =
        user?.userMetadata?["name"]?.toString().split(" ")[0] ?? "User";
    final now = DateTime.now();
    final dateString = DateFormat('EEEE, d MMMM').format(now);

    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(healthConnector)..loadDashboardData(),
      child: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: SafeArea(
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
                            value: _getTodaySteps(provider.weeklySteps).toString(),
                            unit: "steps",
                            icon: Icons.directions_walk,
                            color: Colors.orangeAccent,
                          ),
                          _buildSummaryCard(
                            title: "Sleep",
                            value: _getTodaySleep(provider.weeklySleep),
                            unit: "hrs",
                            icon: Icons.bedtime,
                            color: Colors.indigoAccent,
                          ),
                          _buildSummaryCard(
                            title: "Water",
                            value: "${_getTodayWater(provider.weeklyHydration)}ml",
                            unit: "today",
                            icon: Icons.water_drop,
                            color: Colors.blueAccent,
                          ),
                          _buildSummaryCard(
                            title: "Active",
                            value: "${_getTodayWorkoutMins(provider.weeklyWorkouts)}m",
                            unit: "today",
                            icon: Icons.fitness_center,
                            color: Colors.teal,
                          ),
                          _buildSummaryCard(
                            title: "Calories",
                            value: _getTodayCalories(provider.weeklyCalories),
                            unit: "kcal",
                            icon: Icons.local_fire_department,
                            color: Colors.redAccent,
                          ),
                          _buildSummaryCard(
                            title: "Meditate",
                            value: "${_getTodayMeditationMins(provider.meditationHistory)}m",
                            unit: "today",
                            icon: Icons.self_improvement,
                            color: Colors.purple,
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
                                  dataSource: provider.weeklySteps,
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
                                maximum: 12,
                                labelStyle: TextStyle(color: Colors.grey[600]),
                              ),
                              legend: Legend(
                                isVisible: true,
                                position: LegendPosition.bottom,
                              ),
                              series: [
                                SplineAreaSeries<DailySleep, DateTime>(
                                  dataSource: provider.weeklySleep,
                                  xValueMapper: (DailySleep data, _) =>
                                      data.date,
                                  yValueMapper: (DailySleep data, _) =>
                                      data.durationHours,
                                  name: 'Sleep (hrs)',
                                  color: Colors.indigoAccent.withOpacity(0.1),
                                  borderColor: Colors.indigoAccent,
                                  borderWidth: 2,
                                ),
                                LineSeries<VitalData, DateTime>(
                                  dataSource: provider.weeklyVitals,
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
                            "All Health Records",
                            Icons.list_alt,
                            Colors.blueGrey,
                            ChangeNotifierProvider(
                              create: (_) => ReadHealthRecordsChangeNotifier(healthConnector),
                              child: ReadHealthRecordsPage(healthPlatform: healthConnector.healthPlatform),
                            ),
                          ),
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
        },
      ),
    );
  }

  int _getTodaySteps(List<DailySteps> weeklySteps) {
    if (weeklySteps.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todaySteps = weeklySteps.firstWhereOrNull(
      (s) => DateTime(s.date.year, s.date.month, s.date.day+1) == today,
    );
    return todaySteps?.count ?? 0;
  }

  String _getTodaySleep(List<DailySleep> weeklySleep) {
    if (weeklySleep.isEmpty) return "0";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todaySleep = weeklySleep.firstWhereOrNull((s) {
      return DateTime(s.date.year, s.date.month, s.date.day) == today;
    });

    return todaySleep?.durationHours.toStringAsFixed(1) ?? "0";
  }

  int _getTodayWater(List<DailyHydration> weeklyHydration) {
    if (weeklyHydration.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayHydration = weeklyHydration.firstWhereOrNull(
      (h) => DateTime(h.date.year, h.date.month, h.date.day) == today,
    );
    return todayHydration?.volumeMl ?? 0;
  }

  int _getTodayWorkoutMins(List<DailyWorkout> weeklyWorkouts) {
    if (weeklyWorkouts.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayWorkout = weeklyWorkouts.firstWhereOrNull(
      (w) => DateTime(w.date.year, w.date.month, w.date.day) == today,
    );
    return todayWorkout?.durationMinutes ?? 0;
  }

  String _getTodayCalories(List<DailyCalories> weeklyCalories) {
    if (weeklyCalories.isEmpty) return "0";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayCals = weeklyCalories.firstWhereOrNull(
      (c) => DateTime(c.date.year, c.date.month, c.date.day) == today,
    );
    return todayCals?.calories.toInt().toString() ?? "0";
  }

  int _getTodayMeditationMins(List<Map<String, dynamic>> meditationHistory) {
    if (meditationHistory.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return meditationHistory
        .where((m) {
          final date = m['startTime'] as DateTime;
          return DateTime(date.year, date.month, date.day) == today;
        })
        .fold(0, (sum, item) => sum + (item['durationMinutes'] as int));
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

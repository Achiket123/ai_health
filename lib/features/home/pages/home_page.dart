import 'package:ai_health/features/auth/pages/login_page.dart';
import 'package:ai_health/features/form/pages/form_page.dart';
import 'package:ai_health/features/home/widgets/feature_card.dart';
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
import 'package:ai_health/features/workouts/pages/workouts_page.dart';
import 'package:ai_health/features/step/repo/step_repository.dart';
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

  List<DailySteps> _weeklySteps = [];
  List<SleepData> _weeklySleep = [];
  List<VitalData> _weeklyVitals = [];
  bool _isLoadingDashboard = true;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(supabaseClient: Supabase.instance.client);
    _permissionsService = PermissionsService(healthConnector: healthConnector);
    _stepRepository = StepRepository();
    _sleepRepository = SleepRepository();
    _vitalsRepository = VitalsRepository();

    _checkProfileCompletion();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
      try {
          // Fetch data in parallel
          final stepsFuture = _stepRepository.getDailySteps(7);
          final sleepFuture = _sleepRepository.getSleepHistory();
          final vitalsFuture = _vitalsRepository.getVitalsHistory();

          final results = await Future.wait([stepsFuture, sleepFuture, vitalsFuture]);

          if (mounted) {
              setState(() {
                  _weeklySteps = results[0] as List<DailySteps>;

                  // Filter sleep for last 7 days and process
                  final sleepHistory = results[1] as List<SleepData>;
                  final cutoff = DateTime.now().subtract(const Duration(days: 7));
                  _weeklySleep = sleepHistory.where((s) => s.date.isAfter(cutoff)).toList()
                    ..sort((a, b) => a.date.compareTo(b.date));

                  // Filter vitals
                  final vitalsHistory = results[2] as List<VitalData>;
                  _weeklyVitals = vitalsHistory.where((v) => v.date.isAfter(cutoff)).toList()
                    ..sort((a, b) => a.date.compareTo(b.date));

                  _isLoadingDashboard = false;
              });
          }
      } catch (e) {
          developer.log("Error loading dashboard: $e");
          if (mounted) setState(() => _isLoadingDashboard = false);
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
      developer.log('Error checking profile: $e', error: e);
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
      developer.log('Error checking permissions: $e', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?["name"]?.toString().split(" ")[0] ?? "User";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, $name! 👋",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Here's your daily summary",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U'),
            ),
          ),
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            icon: const Icon(Icons.logout, color: Colors.grey),
          ),
        ],
      ),
      body: _isLoadingDashboard
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Combined Steps & Sleep Chart
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Steps & Sleep (Last 7 Days)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SfCartesianChart(
                            primaryXAxis: DateTimeAxis(
                                dateFormat: DateFormat.E(),
                                majorGridLines: const MajorGridLines(width: 0),
                            ),
                            primaryYAxis: NumericAxis(
                                majorGridLines: const MajorGridLines(width: 0),
                                title: AxisTitle(text: 'Steps'),
                            ),
                            axes: <ChartAxis>[
                              NumericAxis(
                                name: 'yAxis2',
                                oppposedPosition: true,
                                title: AxisTitle(text: 'Sleep (hrs)'),
                                majorGridLines: const MajorGridLines(width: 0),
                              )
                            ],
                            legend: Legend(isVisible: true, position: LegendPosition.bottom),
                            series: [
                                ColumnSeries<DailySteps, DateTime>(
                                    dataSource: _weeklySteps,
                                    xValueMapper: (DailySteps data, _) => data.date,
                                    yValueMapper: (DailySteps data, _) => data.count,
                                    name: 'Steps',
                                    color: Colors.blue.withOpacity(0.7),
                                ),
                                LineSeries<SleepData, DateTime>(
                                    dataSource: _weeklySleep,
                                    xValueMapper: (SleepData data, _) => data.date,
                                    yValueMapper: (SleepData data, _) => data.durationHours,
                                    name: 'Sleep',
                                    yAxisName: 'yAxis2',
                                    color: Colors.indigo,
                                    markerSettings: const MarkerSettings(isVisible: true),
                                )
                            ],
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mood Graph
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text(
                    "Mood & Stress",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _weeklyVitals.isEmpty
                    ? const Center(child: Text('No mood data yet'))
                    : SfCartesianChart(
                        primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat.Md(),
                            majorGridLines: const MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                            minimum: 0,
                            maximum: 10,
                            interval: 1,
                            majorGridLines: const MajorGridLines(width: 0.5),
                        ),
                        series: [
                           LineSeries<VitalData, DateTime>(
                                dataSource: _weeklyVitals,
                                xValueMapper: (VitalData data, _) => data.date,
                                yValueMapper: (VitalData data, _) => data.stressLevel,
                                name: 'Stress',
                                color: Colors.redAccent,
                                markerSettings: const MarkerSettings(isVisible: true),
                            ),
                        ],
                    ),
                  ),
                  FeatureCard(
                    title: 'Sleep',
                    icon: Icons.bed,
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SleepPage(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    title: 'Vitals & Mood',
                    icon: Icons.monitor_heart,
                    color: Colors.pink,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const VitalsPage(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    title: 'Workouts',
                    icon: Icons.fitness_center,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WorkoutsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                FeatureCard(
                  title: 'Steps',
                  icon: Icons.directions_walk,
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StepPage())),
                ),
                FeatureCard(
                  title: 'Sleep',
                  icon: Icons.bed,
                  color: Colors.indigo,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepPage())),
                ),
                FeatureCard(
                  title: 'Hydration',
                  icon: Icons.water_drop,
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => HydrationBloc(), child: const HydrationPage()))),
                ),
                FeatureCard(
                  title: 'Nutrition',
                  icon: Icons.restaurant_menu,
                  color: Colors.green,
                  onTap: () {
                     final userId = Supabase.instance.client.auth.currentUser?.id;
                     if (userId != null) Navigator.push(context, MaterialPageRoute(builder: (_) => NutritionPage(userId: userId)));
                  },
                ),
                FeatureCard(
                  title: 'Vitals',
                  icon: Icons.monitor_heart,
                  color: Colors.redAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VitalsPage())),
                ),
                FeatureCard(
                  title: 'Workouts',
                  icon: Icons.fitness_center,
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutsPage())),
                ),
                FeatureCard(
                    title: 'Meditation',
                    icon: Icons.self_improvement,
                    color: Colors.purple,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MeditationPage())),
                ),
                 FeatureCard(
                    title: 'Streak',
                    icon: Icons.local_fire_department,
                    color: Colors.deepOrange,
                    onTap: () {
                        final userId = Supabase.instance.client.auth.currentUser?.id;
                        if (userId != null) Navigator.push(context, MaterialPageRoute(builder: (_) => StreakPage(userId: userId)));
                    },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

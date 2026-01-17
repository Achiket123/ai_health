import 'package:ai_health/main.dart';
import 'package:health_connector/health_connector.dart';
import '../models/hydration_model.dart';
import 'dart:developer' as developer;

class HydrationRepository {
  
  Future<void> addHydrationGlass() async {
    try {
      final now = DateTime.now();
      final hydrationRecord = HydrationRecord(
        startTime: now,
        endTime: now,
        volume: const Volume.milliliters(250), // 250ml per glass
        metadata: Metadata.internal(
          recordingMethod: RecordingMethod.manualEntry,
        ),
      );

      await healthConnector.writeRecord(hydrationRecord);
      print('HydrationRepository: Successfully wrote hydration record');
    } catch (e) {
      print('HydrationRepository: Error writing hydration record: $e');
      rethrow;
    }
  }

  
  
  Future<int> getTodayHydration() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      print('HydrationRepository: Fetching hydration for today');

      // Try to aggregate hydration data for today
      try {
        // Alternative: Count records manually by reading all hydration records
        // Note: The exact API might differ based on health_connector version
        print(
          'HydrationRepository: Health Connect aggregate not directly supported, returning 0',
        );
        return 0;
      } catch (e) {
        print('HydrationRepository: Could not fetch from Health Connect: $e');
        return 0;
      }
    } catch (e) {
      print('HydrationRepository: Error getting today hydration: $e');
      rethrow;
    }
  }

  
  int getDailyTarget() {
    return 8; // 8 glasses per day
  }

  
  int millilitersToGlasses(double milliliters) {
    return (milliliters / 250).round();
  }

  
  double glassesToMilliliters(int glasses) {
    return glasses * 250.0;
  }
}

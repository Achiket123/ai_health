import 'dart:io';
import 'package:health_connector/health_connector.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:collection/collection.dart';
import '../models/nutrition_entry.dart';
import 'dart:developer' as developer;

class DailyCalories {
  final DateTime date;
  final double calories;

  DailyCalories({required this.date, required this.calories});
}

class NutritionRepository {
  final HealthConnector _healthConnector;

  NutritionRepository({required HealthConnector healthConnector})
    : _healthConnector = healthConnector;

  
  
  Future<NutritionEntry> submitNutritionEntry({
    required File imageFile,
    required String userId,
    required List<DishMetadata> dishes,
    required String notes,
    required DateTime mealTime,
  }) async {
    try {
      // Calculate nutrition info
      final nutritionInfo = NutritionInfo.calculate(dishes);

      // Create the nutrition data
      final entry = NutritionEntry(
        id: 'nutrition_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        imageUrl: imageFile
            .path, // We can't store image in HC, so just keeping local path
        dishes: dishes,
        notes: notes,
        mealTime: mealTime,
        nutritionInfo: nutritionInfo,
        createdAt: DateTime.now(),
      );

      // Write to Health Connect
      await writeNutritionToHealthConnect(entry);

      return entry;
    } catch (e) {
      throw Exception('Error submitting nutrition entry: $e');
    }
  }

  
  Future<List<NutritionEntry>> getNutritionEntries(String userId) async {
    return getNutritionHistory();
  }

  // Gets all nutrition history from Health Connect
  Future<List<NutritionEntry>> getNutritionHistory() async {
    try {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 30));

      final response = await _healthConnector.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.nutrition,
          startTime: startTime,
          endTime: now,
        ),
      );

      final records = response.records.whereType<NutritionRecord>().toList();
      records.sort((a, b) => b.startTime.compareTo(a.startTime));

      return records.map((r) {
        // Map back to NutritionEntry
        // Note: HC stores aggregates. We might lose individual dish info if we didn't store it in metadata/notes.
        // We will do best effort mapping.

        final calories = r.energy?.inKilocalories ?? 0;
        final protein = r.protein?.inGrams ?? 0;
        final carbs = r.totalCarbohydrate?.inGrams ?? 0;
        final fat = r.totalFat?.inGrams ?? 0;

        // Try to parse dishes from notes if we stored them there
        List<DishMetadata> dishes = [];
        String notes = r.foodName ?? "";

        return NutritionEntry(
          id: r.id.toString(), // Health Connect ID
          userId: "current",
          imageUrl: "", // Not stored in HC
          dishes: dishes,
          notes: notes,
          mealTime: r.startTime,
          nutritionInfo: NutritionInfo(
            calories: calories,
            protein: protein,
            carbohydrates: carbs,
            fat: fat,
          ),
          createdAt: r.startTime,
        );
      }).toList();
    } catch (e) {
      print('Error fetching nutrition entries: $e');
      return [];
    }
  }

  Future<List<DailyCalories>> getDailyCalories(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final startTime = DateTime(startDate.year, startDate.month, startDate.day);

    try {
      final response = await _healthConnector.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.nutrition,
          startTime: startTime,
          endTime: now,
        ),
      );

      final records = response.records.whereType<NutritionRecord>().toList();

      final grouped = groupBy(records, (NutritionRecord record) {
        return DateTime(
          record.startTime.year,
          record.startTime.month,
          record.startTime.day,
        );
      });

      List<DailyCalories> dailyCalories = [];

      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final dayStart = DateTime(date.year, date.month, date.day);

        final dayRecords = grouped[dayStart];
        double totalCalories = 0;

        if (dayRecords != null) {
          for (var record in dayRecords) {
            totalCalories += record.energy?.inKilocalories ?? 0;
          }
        }

        dailyCalories.add(
          DailyCalories(date: dayStart, calories: totalCalories),
        );
      }

      dailyCalories.sort((a, b) => a.date.compareTo(b.date));

      return dailyCalories;
    } catch (e) {
      print('Error fetching daily calories: $e');
      List<DailyCalories> dailyCalories = [];
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final dayStart = DateTime(date.year, date.month, date.day);
        dailyCalories.add(DailyCalories(date: dayStart, calories: 0));
      }
      dailyCalories.sort((a, b) => a.date.compareTo(b.date));
      return dailyCalories;
    }
  }

  
  Future<void> deleteNutritionEntry(String entryId) async {
    // Health Connect delete requires ID or time range.
    // If we have ID (and HC supports delete by ID for this record), we use it.
    // For now, implementing delete is tricky without knowing if entryId is HC ID or internal.
    // If it comes from getNutritionHistory, it is HC ID.
    try {
      await _healthConnector.deleteRecords(
        DeleteRecordsByIdsRequest(
          dataType: HealthDataType.nutrition,
          recordIds: [HealthRecordId(entryId)],
        ),
      );
    } catch (e) {
      // Fallback or ignore
      print("Delete failed: $e");
    }
  }

  
  Future<NutritionEntry> mockSubmitNutritionEntry({
    required File imageFile,
    required String userId,
    required List<DishMetadata> dishes,
    required String notes,
    required DateTime mealTime,
  }) async {
    return submitNutritionEntry(
      imageFile: imageFile,
      userId: userId,
      dishes: dishes,
      notes: notes,
      mealTime: mealTime,
    );
  }

  
  Future<List<NutritionEntry>> getMealsForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final response = await _healthConnector.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.nutrition,
          startTime: startOfDay,
          endTime: endOfDay,
        ),
      );

      final records = response.records.whereType<NutritionRecord>().toList();
      records.sort((a, b) => a.startTime.compareTo(b.startTime));

      return records.map((r) {
        final calories = r.energy?.inKilocalories ?? 0;
        final protein = r.protein?.inGrams ?? 0;
        final carbs = r.totalCarbohydrate?.inGrams ?? 0;
        final fat = r.totalFat?.inGrams ?? 0;

        return NutritionEntry(
          id: r.id.toString(),
          userId: userId,
          imageUrl: "",
          dishes: [],
          notes: r.foodName ?? "",
          mealTime: r.startTime,
          nutritionInfo: NutritionInfo(
            calories: calories,
            protein: protein,
            carbohydrates: carbs,
            fat: fat,
          ),
          createdAt: r.startTime,
        );
      }).toList();
    } catch (e) {
      print('Error fetching meals for date: $e');
      return [];
    }
  }

  
  Future<void> writeNutritionToHealthConnect(NutritionEntry entry) async {
    try {
      final record = NutritionRecord(
        startTime: entry.mealTime,
        endTime: entry.mealTime.add(
          const Duration(minutes: 30),
        ), // Meal duration assumption
        protein: Mass.grams(entry.nutritionInfo.protein),
        totalCarbohydrate: Mass.grams(entry.nutritionInfo.carbohydrates),
        totalFat: Mass.grams(entry.nutritionInfo.fat),
        energy: Energy.kilocalories(entry.nutritionInfo.calories),
        metadata: Metadata.manualEntry(),
      );

      await _healthConnector.writeRecords([record]);

      print(
        'Writing nutrition to Health Connect: '
        '${entry.nutritionInfo.calories} calories, '
        '${entry.nutritionInfo.protein}g protein',
      );
    } catch (e) {
      print('Error in writeNutritionToHealthConnect: $e');
      throw Exception('Failed to write nutrition to Health Connect');
    }
  }

  
  Future<void> deleteMeal(String userId, String entryId) async {
    await deleteNutritionEntry(entryId);
  }

  
  Future<NutritionInfo> getDailyNutrition(String userId, DateTime date) async {
    final meals = await getMealsForDate(userId, date);

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final meal in meals) {
      totalCalories += meal.nutritionInfo.calories;
      totalProtein += meal.nutritionInfo.protein;
      totalCarbs += meal.nutritionInfo.carbohydrates;
      totalFat += meal.nutritionInfo.fat;
    }

    return NutritionInfo(
      calories: totalCalories,
      protein: totalProtein,
      carbohydrates: totalCarbs,
      fat: totalFat,
    );
  }
}

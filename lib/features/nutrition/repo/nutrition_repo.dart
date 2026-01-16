import 'dart:io';
import 'package:health_connector/health_connector.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'dart:convert';
import '../models/nutrition_entry.dart';
import 'dart:developer' as developer;

class NutritionRepository {
  HealthConnector? _healthConnector;

  NutritionRepository({HealthConnector? healthConnector})
      : _healthConnector = healthConnector;

  // Use a default instance if not provided
  Future<HealthConnector> get _hc async {
    if (_healthConnector != null) return _healthConnector!;
    _healthConnector = await HealthConnector.create();
    return _healthConnector!;
  }

  /// Submit nutrition entry. We map this to NutritionRecord in Health Connect.
  /// Note: Images are not supported by Health Connect, so they are not saved.
  /// We serialize dishes/notes into the metadata or notes field.
  Future<NutritionEntry> submitNutritionEntry({
    required File imageFile,
    required String userId,
    required List<DishMetadata> dishes,
    required String notes,
    required DateTime mealTime,
  }) async {
    // Same as mockSubmitNutritionEntry
    return mockSubmitNutritionEntry(
        imageFile: imageFile,
        userId: userId,
        dishes: dishes,
        notes: notes,
        mealTime: mealTime
    );
  }

  /// Get nutrition entries for a user (not implemented for HC yet as typical flow is by date)
  Future<List<NutritionEntry>> getNutritionEntries(String userId) async {
     // Return empty or implement fetch last X days if needed
     return [];
  }

  /// Mock submit for testing without backend
  /// Now actually writes to Health Connect
  Future<NutritionEntry> mockSubmitNutritionEntry({
    required File imageFile,
    required String userId,
    required List<DishMetadata> dishes,
    required String notes,
    required DateTime mealTime,
  }) async {
    // Calculate nutrition info
    final nutritionInfo = NutritionInfo.calculate(dishes);

    final entry = NutritionEntry(
      id: 'nutrition_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      imageUrl: 'file://${imageFile.path}', // Local only for UI
      dishes: dishes,
      notes: notes,
      mealTime: mealTime,
      nutritionInfo: nutritionInfo,
      createdAt: DateTime.now(),
    );

    // Write to Health Connect
    try {
      await writeNutritionToHealthConnect(entry);
    } catch (e) {
      developer.log('Error writing to Health Connect: $e', error: e);
      throw Exception('Failed to write to Health Connect: $e');
    }

    developer.log(
      'Meal added to Health Connect: ${entry.dishes.map((d) => d.dishName).join(", ")} at ${entry.mealTime}',
    );

    return entry;
  }

  /// Get meals for a specific user on a specific date from Health Connect
  Future<List<NutritionEntry>> getMealsForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final hc = await _hc;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final response = await hc.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.nutrition,
          startTime: startOfDay,
          endTime: endOfDay,
        ),
      );

      final records = response.records.whereType<NutritionRecord>().toList();

      return records.map((r) {
         // Reconstruct dishes from notes if possible
         List<DishMetadata> dishes = [];
         String notes = "";
         if (r.notes != null) {
            try {
               final Map<String, dynamic> metadata = jsonDecode(r.notes!);
               if (metadata['dishes'] != null) {
                   dishes = (metadata['dishes'] as List).map((d) => DishMetadata.fromJson(d)).toList();
               }
               notes = metadata['notes'] ?? "";
            } catch (e) {
               // Fallback if notes aren't JSON
               notes = r.notes!;
               dishes = [DishMetadata(dishName: "Meal", calories: r.energy?.inKilocalories.toInt() ?? 0)];
            }
         }

         return NutritionEntry(
            id: r.metadata.id,
            userId: userId,
            imageUrl: "", // Images not supported in HC
            dishes: dishes,
            notes: notes,
            mealTime: r.startTime,
            nutritionInfo: NutritionInfo(
               calories: r.energy?.inKilocalories ?? 0,
               protein: r.protein?.inGrams ?? 0,
               carbohydrates: r.totalCarbohydrate?.inGrams ?? 0,
               fat: r.totalFat?.inGrams ?? 0,
            ),
            createdAt: r.startTime
         );
      }).toList();

    } catch (e) {
      developer.log('Error fetching meals from Health Connect: $e', error: e);
      return [];
    }
  }

  /// Write nutrition data to Health Connect
  Future<void> writeNutritionToHealthConnect(NutritionEntry entry) async {
    try {
      final hc = await _hc;

      // Serialize dishes/notes to string
      final metadata = {
          'dishes': entry.dishes.map((d) => d.toJson()).toList(),
          'notes': entry.notes
      };

      final record = NutritionRecord(
        startTime: entry.mealTime,
        endTime: entry.mealTime.add(const Duration(minutes: 15)),
        metadata: Metadata.manualEntry(),
        energy: Energy.kilocalories(entry.nutritionInfo.calories),
        protein: Mass.grams(entry.nutritionInfo.protein),
        totalCarbohydrate: Mass.grams(entry.nutritionInfo.carbohydrates),
        totalFat: Mass.grams(entry.nutritionInfo.fat),
        notes: jsonEncode(metadata),
      );

      await hc.writeRecords([record]);

      developer.log(
        'Written nutrition to Health Connect: '
        '${entry.nutritionInfo.calories} calories',
      );
    } catch (e) {
      developer.log('Error in writeNutritionToHealthConnect: $e', error: e);
      rethrow;
    }
  }

  /// Delete meal and remove from Health Connect
  Future<void> deleteMeal(String userId, String entryId) async {
    try {
       // Health Connect deletion usually requires the UUID (entryId).
       // If entryId is from HC, we can delete it.
       // However, the current API might need strict ID handling.
       final hc = await _hc;
       await hc.deleteRecords(
         DeleteRecordsByIdsRequest(
           dataType: HealthDataType.nutrition,
           ids: [HealthRecordId(entryId)],
         ),
       );
    } catch (e) {
      throw Exception('Error deleting meal from Health Connect: $e');
    }
  }

  /// Get total daily nutrition for a date
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

import 'package:flutter/foundation.dart' show immutable;
import 'package:health_connector/health_connector_internal.dart';





@immutable
final class NutritionData {
  const NutritionData({
    this.foodName,
    this.mealType = MealType.unknown,
    this.energy,
    this.protein,
    this.totalCarbohydrate,
    this.totalFat,
    this.saturatedFat,
    this.monounsaturatedFat,
    this.polyunsaturatedFat,
    this.cholesterol,
    this.dietaryFiber,
    this.sugar,
    this.vitaminA,
    this.vitaminB6,
    this.vitaminB12,
    this.vitaminC,
    this.vitaminD,
    this.vitaminE,
    this.vitaminK,
    this.thiamin,
    this.riboflavin,
    this.niacin,
    this.folate,
    this.biotin,
    this.pantothenicAcid,
    this.calcium,
    this.iron,
    this.magnesium,
    this.manganese,
    this.phosphorus,
    this.potassium,
    this.selenium,
    this.sodium,
    this.zinc,
    this.caffeine,
  });

  
  final String? foodName;

  
  final MealType mealType;

  // region Energy Nutrient

  
  final Energy? energy;

  // endregion

  // region Macronutrients

  
  final Mass? protein;

  
  final Mass? totalCarbohydrate;

  
  final Mass? totalFat;

  
  final Mass? saturatedFat;

  
  final Mass? monounsaturatedFat;

  
  final Mass? polyunsaturatedFat;

  
  final Mass? cholesterol;

  
  final Mass? dietaryFiber;

  
  final Mass? sugar;

  // endregion

  // region Vitamins

  
  final Mass? vitaminA;

  
  final Mass? vitaminB6;

  
  final Mass? vitaminB12;

  
  final Mass? vitaminC;

  
  final Mass? vitaminD;

  
  final Mass? vitaminE;

  
  final Mass? vitaminK;

  
  final Mass? thiamin;

  
  final Mass? riboflavin;

  
  final Mass? niacin;

  
  final Mass? folate;

  
  final Mass? biotin;

  
  final Mass? pantothenicAcid;

  // endregion

  // region Minerals

  
  final Mass? calcium;

  
  final Mass? iron;

  
  final Mass? magnesium;

  
  final Mass? manganese;

  
  final Mass? phosphorus;

  
  final Mass? potassium;

  
  final Mass? selenium;

  
  final Mass? sodium;

  
  final Mass? zinc;

  // endregion

  // region Other

  
  final Mass? caffeine;

  // endregion

  
  NutritionData copyWith({
    String? foodName,
    MealType? mealType,
    Energy? energy,
    Mass? protein,
    Mass? totalCarbohydrate,
    Mass? totalFat,
    Mass? saturatedFat,
    Mass? monounsaturatedFat,
    Mass? polyunsaturatedFat,
    Mass? cholesterol,
    Mass? dietaryFiber,
    Mass? sugar,
    Mass? vitaminA,
    Mass? vitaminB6,
    Mass? vitaminB12,
    Mass? vitaminC,
    Mass? vitaminD,
    Mass? vitaminE,
    Mass? vitaminK,
    Mass? thiamin,
    Mass? riboflavin,
    Mass? niacin,
    Mass? folate,
    Mass? biotin,
    Mass? pantothenicAcid,
    Mass? calcium,
    Mass? iron,
    Mass? magnesium,
    Mass? manganese,
    Mass? phosphorus,
    Mass? potassium,
    Mass? selenium,
    Mass? sodium,
    Mass? zinc,
    Mass? caffeine,
  }) {
    return NutritionData(
      foodName: foodName ?? this.foodName,
      mealType: mealType ?? this.mealType,
      energy: energy ?? this.energy,
      protein: protein ?? this.protein,
      totalCarbohydrate: totalCarbohydrate ?? this.totalCarbohydrate,
      totalFat: totalFat ?? this.totalFat,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      monounsaturatedFat: monounsaturatedFat ?? this.monounsaturatedFat,
      polyunsaturatedFat: polyunsaturatedFat ?? this.polyunsaturatedFat,
      cholesterol: cholesterol ?? this.cholesterol,
      dietaryFiber: dietaryFiber ?? this.dietaryFiber,
      sugar: sugar ?? this.sugar,
      vitaminA: vitaminA ?? this.vitaminA,
      vitaminB6: vitaminB6 ?? this.vitaminB6,
      vitaminB12: vitaminB12 ?? this.vitaminB12,
      vitaminC: vitaminC ?? this.vitaminC,
      vitaminD: vitaminD ?? this.vitaminD,
      vitaminE: vitaminE ?? this.vitaminE,
      vitaminK: vitaminK ?? this.vitaminK,
      thiamin: thiamin ?? this.thiamin,
      riboflavin: riboflavin ?? this.riboflavin,
      niacin: niacin ?? this.niacin,
      folate: folate ?? this.folate,
      biotin: biotin ?? this.biotin,
      pantothenicAcid: pantothenicAcid ?? this.pantothenicAcid,
      calcium: calcium ?? this.calcium,
      iron: iron ?? this.iron,
      magnesium: magnesium ?? this.magnesium,
      manganese: manganese ?? this.manganese,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      selenium: selenium ?? this.selenium,
      sodium: sodium ?? this.sodium,
      zinc: zinc ?? this.zinc,
      caffeine: caffeine ?? this.caffeine,
    );
  }

  
  NutritionData withNutrient(HealthDataType type, dynamic value) {
    switch (type) {
      case HealthDataType.dietaryEnergyConsumed:
        return copyWith(energy: value as Energy?);
      case HealthDataType.dietaryProtein:
        return copyWith(protein: value as Mass?);
      case HealthDataType.dietaryTotalCarbohydrate:
        return copyWith(totalCarbohydrate: value as Mass?);
      case HealthDataType.dietaryTotalFat:
        return copyWith(totalFat: value as Mass?);
      case HealthDataType.dietarySaturatedFat:
        return copyWith(saturatedFat: value as Mass?);
      case HealthDataType.dietaryMonounsaturatedFat:
        return copyWith(monounsaturatedFat: value as Mass?);
      case HealthDataType.dietaryPolyunsaturatedFat:
        return copyWith(polyunsaturatedFat: value as Mass?);
      case HealthDataType.dietaryCholesterol:
        return copyWith(cholesterol: value as Mass?);
      case HealthDataType.dietaryFiber:
        return copyWith(dietaryFiber: value as Mass?);
      case HealthDataType.dietarySugar:
        return copyWith(sugar: value as Mass?);
      case HealthDataType.dietaryVitaminA:
        return copyWith(vitaminA: value as Mass?);
      case HealthDataType.dietaryVitaminB6:
        return copyWith(vitaminB6: value as Mass?);
      case HealthDataType.dietaryVitaminB12:
        return copyWith(vitaminB12: value as Mass?);
      case HealthDataType.dietaryVitaminC:
        return copyWith(vitaminC: value as Mass?);
      case HealthDataType.dietaryVitaminD:
        return copyWith(vitaminD: value as Mass?);
      case HealthDataType.dietaryVitaminE:
        return copyWith(vitaminE: value as Mass?);
      case HealthDataType.dietaryVitaminK:
        return copyWith(vitaminK: value as Mass?);
      case HealthDataType.dietaryThiamin:
        return copyWith(thiamin: value as Mass?);
      case HealthDataType.dietaryRiboflavin:
        return copyWith(riboflavin: value as Mass?);
      case HealthDataType.dietaryNiacin:
        return copyWith(niacin: value as Mass?);
      case HealthDataType.dietaryFolate:
        return copyWith(folate: value as Mass?);
      case HealthDataType.dietaryBiotin:
        return copyWith(biotin: value as Mass?);
      case HealthDataType.dietaryPantothenicAcid:
        return copyWith(pantothenicAcid: value as Mass?);
      case HealthDataType.dietaryCalcium:
        return copyWith(calcium: value as Mass?);
      case HealthDataType.dietaryIron:
        return copyWith(iron: value as Mass?);
      case HealthDataType.dietaryMagnesium:
        return copyWith(magnesium: value as Mass?);
      case HealthDataType.dietaryManganese:
        return copyWith(manganese: value as Mass?);
      case HealthDataType.dietaryPhosphorus:
        return copyWith(phosphorus: value as Mass?);
      case HealthDataType.dietaryPotassium:
        return copyWith(potassium: value as Mass?);
      case HealthDataType.dietarySelenium:
        return copyWith(selenium: value as Mass?);
      case HealthDataType.dietarySodium:
        return copyWith(sodium: value as Mass?);
      case HealthDataType.dietaryZinc:
        return copyWith(zinc: value as Mass?);
      case HealthDataType.dietaryCaffeine:
        return copyWith(caffeine: value as Mass?);
      default:
        return this;
    }
  }
}

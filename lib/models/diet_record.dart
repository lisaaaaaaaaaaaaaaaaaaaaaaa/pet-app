// lib/models/diet_record.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DietRecord {
  final String id;
  final String petId;  // Added petId
  final DateTime date;
  final List<Meal> meals;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? totalCalories;
  final Map<String, double>? totalNutrients;
  // New premium features
  final String? veterinaryNotes;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final Map<String, dynamic>? nutritionGoals;
  final double? waterIntake;
  final List<String> supplements;
  final Map<String, dynamic>? mealPreferences;
  final List<String>? feedingScheduleIds;
  final bool followedPlan;
  final List<String>? symptoms;
  final Map<String, dynamic>? weightTracking;
  final String? feedingMethod;
  final Map<String, dynamic>? treatTracking;

  DietRecord({
    required this.id,
    required this.petId,
    required this.date,
    required this.meals,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
    this.totalCalories,
    this.totalNutrients,
    // New premium features
    this.veterinaryNotes,
    this.dietaryRestrictions = const [],
    this.allergies = const [],
    this.nutritionGoals,
    this.waterIntake,
    this.supplements = const [],
    this.mealPreferences,
    this.feedingScheduleIds,
    this.followedPlan = true,
    this.symptoms,
    this.weightTracking,
    this.feedingMethod,
    this.treatTracking,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'date': Timestamp.fromDate(date),
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'totalCalories': totalCalories,
      'totalNutrients': totalNutrients,
      // New premium features
      'veterinaryNotes': veterinaryNotes,
      'dietaryRestrictions': dietaryRestrictions,
      'allergies': allergies,
      'nutritionGoals': nutritionGoals,
      'waterIntake': waterIntake,
      'supplements': supplements,
      'mealPreferences': mealPreferences,
      'feedingScheduleIds': feedingScheduleIds,
      'followedPlan': followedPlan,
      'symptoms': symptoms,
      'weightTracking': weightTracking,
      'feedingMethod': feedingMethod,
      'treatTracking': treatTracking,
    };
  }

  factory DietRecord.fromJson(Map<String, dynamic> json) {
    return DietRecord(
      id: json['id'],
      petId: json['petId'],
      date: (json['date'] as Timestamp).toDate(),
      meals: (json['meals'] as List)
          .map((mealJson) => Meal.fromJson(mealJson))
          .toList(),
      notes: json['notes'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      totalCalories: json['totalCalories']?.toDouble(),
      totalNutrients: json['totalNutrients'] != null
          ? Map<String, double>.from(json['totalNutrients'])
          : null,
      // New premium features
      veterinaryNotes: json['veterinaryNotes'],
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      nutritionGoals: json['nutritionGoals'],
      waterIntake: json['waterIntake']?.toDouble(),
      supplements: List<String>.from(json['supplements'] ?? []),
      mealPreferences: json['mealPreferences'],
      feedingScheduleIds: json['feedingScheduleIds'] != null
          ? List<String>.from(json['feedingScheduleIds'])
          : null,
      followedPlan: json['followedPlan'] ?? true,
      symptoms: json['symptoms'] != null
          ? List<String>.from(json['symptoms'])
          : null,
      weightTracking: json['weightTracking'],
      feedingMethod: json['feedingMethod'],
      treatTracking: json['treatTracking'],
    );
  }

  // Enhanced copyWith method
  DietRecord copyWith({
    DateTime? date,
    List<Meal>? meals,
    String? notes,
    double? totalCalories,
    Map<String, double>? totalNutrients,
    String? veterinaryNotes,
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    Map<String, dynamic>? nutritionGoals,
    double? waterIntake,
    List<String>? supplements,
    Map<String, dynamic>? mealPreferences,
    List<String>? feedingScheduleIds,
    bool? followedPlan,
    List<String>? symptoms,
    Map<String, dynamic>? weightTracking,
    String? feedingMethod,
    Map<String, dynamic>? treatTracking,
  }) {
    return DietRecord(
      id: id,
      petId: petId,
      date: date ?? this.date,
      meals: meals ?? this.meals,
      notes: notes ?? this.notes,
      totalCalories: totalCalories ?? this.totalCalories,
      totalNutrients: totalNutrients ?? this.totalNutrients,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      veterinaryNotes: veterinaryNotes ?? this.veterinaryNotes,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      nutritionGoals: nutritionGoals ?? this.nutritionGoals,
      waterIntake: waterIntake ?? this.waterIntake,
      supplements: supplements ?? this.supplements,
      mealPreferences: mealPreferences ?? this.mealPreferences,
      feedingScheduleIds: feedingScheduleIds ?? this.feedingScheduleIds,
      followedPlan: followedPlan ?? this.followedPlan,
      symptoms: symptoms ?? this.symptoms,
      weightTracking: weightTracking ?? this.weightTracking,
      feedingMethod: feedingMethod ?? this.feedingMethod,
      treatTracking: treatTracking ?? this.treatTracking,
    );
  }

  // Helper methods
  bool hasMetNutritionalGoals() {
    if (nutritionGoals == null || totalNutrients == null) return true;
    for (var goal in nutritionGoals!.entries) {
      final actual = totalNutrients![goal.key] ?? 0;
      final target = goal.value as double;
      if (actual < target * 0.9) return false; // Within 90% of goal
    }
    return true;
  }

  bool hasAllergicIngredients() {
    return meals.any((meal) => 
      allergies.any((allergen) => 
        meal.ingredients?.any((ingredient) => 
          ingredient.toLowerCase().contains(allergen.toLowerCase())) ?? false));
  }

  double getTotalWaterIntake() {
    return waterIntake ?? 0.0 + 
           meals.fold(0.0, (sum, meal) => sum + (meal.waterContent ?? 0.0));
  }
}

class Meal {
  final String id;
  final TimeOfDay time;
  final String? foodName;
  final double portionSize;
  final double? calories;
  final String? notes;
  final Map<String, double>? nutrients;
  final bool wasEaten;
  final DateTime? eatenAt;
  // New premium features
  final List<String>? ingredients;
  final String? brand;
  final String? batchNumber;
  final double? waterContent;
  final MealType type;
  final double? leftoverAmount;
  final String? feedingLocation;
  final String? feederName;
  final Map<String, dynamic>? palatabilityScore;
  final List<String>? feedingBehaviors;
  final Duration? eatingDuration;

  Meal({
    required this.id,
    required this.time,
    this.foodName,
    required this.portionSize,
    this.calories,
    this.notes,
    this.nutrients,
    this.wasEaten = false,
    this.eatenAt,
    // New premium features
    this.ingredients,
    this.brand,
    this.batchNumber,
    this.waterContent,
    this.type = MealType.mainMeal,
    this.leftoverAmount,
    this.feedingLocation,
    this.feederName,
    this.palatabilityScore,
    this.feedingBehaviors,
    this.eatingDuration,
  });

  // Update toJson and fromJson methods accordingly...
  // (Previous methods remain the same, just add the new fields)

  double getConsumptionRate() {
    if (leftoverAmount == null) return wasEaten ? 1.0 : 0.0;
    return 1.0 - (leftoverAmount! / portionSize);
  }
}

enum MealType {
  mainMeal,
  snack,
  treat,
  medication,
  supplement
}
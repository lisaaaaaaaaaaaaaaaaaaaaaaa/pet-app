// lib/models/meal_schedule.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealSchedule {
  final String id;
  final String petId;  // Added petId
  final TimeOfDay time;
  final String name;
  final double portionSize;
  final String? foodType;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  // New premium features
  final List<String> foodItems;  // References to FoodItem IDs
  final Map<String, double> nutritionTargets;
  final List<String> supplements;
  final Map<String, dynamic> preparationInstructions;
  final List<String> alternativeFoods;
  final Map<String, bool> daysOfWeek;
  final bool isRecurring;
  final String? recurringPattern;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> reminders;
  final String? assignedTo;
  final Map<String, dynamic>? seasonalAdjustments;
  final Map<String, dynamic>? portionAdjustments;
  final bool requiresPreparation;
  final int preparationTimeMinutes;
  final List<String> feedingTips;
  final Map<String, dynamic>? mealHistory;
  final bool isVetApproved;
  final String? vetNotes;

  MealSchedule({
    required this.id,
    required this.petId,
    required this.time,
    required this.name,
    required this.portionSize,
    this.foodType,
    this.notes,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
    // New premium features
    this.foodItems = const [],
    this.nutritionTargets = const {},
    this.supplements = const [],
    this.preparationInstructions = const {},
    this.alternativeFoods = const [],
    this.daysOfWeek = const {
      'monday': true,
      'tuesday': true,
      'wednesday': true,
      'thursday': true,
      'friday': true,
      'saturday': true,
      'sunday': true,
    },
    this.isRecurring = true,
    this.recurringPattern,
    this.startDate,
    this.endDate,
    this.reminders = const [],
    this.assignedTo,
    this.seasonalAdjustments,
    this.portionAdjustments,
    this.requiresPreparation = false,
    this.preparationTimeMinutes = 0,
    this.feedingTips = const [],
    this.mealHistory,
    this.isVetApproved = false,
    this.vetNotes,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'time': '${time.hour}:${time.minute}',
      'name': name,
      'portionSize': portionSize,
      'foodType': foodType,
      'notes': notes,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      // New premium features
      'foodItems': foodItems,
      'nutritionTargets': nutritionTargets,
      'supplements': supplements,
      'preparationInstructions': preparationInstructions,
      'alternativeFoods': alternativeFoods,
      'daysOfWeek': daysOfWeek,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reminders': reminders,
      'assignedTo': assignedTo,
      'seasonalAdjustments': seasonalAdjustments,
      'portionAdjustments': portionAdjustments,
      'requiresPreparation': requiresPreparation,
      'preparationTimeMinutes': preparationTimeMinutes,
      'feedingTips': feedingTips,
      'mealHistory': mealHistory,
      'isVetApproved': isVetApproved,
      'vetNotes': vetNotes,
    };
  }

  factory MealSchedule.fromJson(Map<String, dynamic> json) {
    final timeStr = json['time'] as String;
    final timeParts = timeStr.split(':');
    
    return MealSchedule(
      id: json['id'],
      petId: json['petId'],
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      name: json['name'],
      portionSize: json['portionSize'].toDouble(),
      foodType: json['foodType'],
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] as Timestamp).toDate() 
          : null,
      // New premium features
      foodItems: List<String>.from(json['foodItems'] ?? []),
      nutritionTargets: Map<String, double>.from(json['nutritionTargets'] ?? {}),
      supplements: List<String>.from(json['supplements'] ?? []),
      preparationInstructions: 
          Map<String, dynamic>.from(json['preparationInstructions'] ?? {}),
      alternativeFoods: List<String>.from(json['alternativeFoods'] ?? []),
      daysOfWeek: Map<String, bool>.from(json['daysOfWeek'] ?? {
        'monday': true, 'tuesday': true, 'wednesday': true,
        'thursday': true, 'friday': true, 'saturday': true, 'sunday': true,
      }),
      isRecurring: json['isRecurring'] ?? true,
      recurringPattern: json['recurringPattern'],
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : null,
      reminders: List<String>.from(json['reminders'] ?? []),
      assignedTo: json['assignedTo'],
      seasonalAdjustments: json['seasonalAdjustments'],
      portionAdjustments: json['portionAdjustments'],
      requiresPreparation: json['requiresPreparation'] ?? false,
      preparationTimeMinutes: json['preparationTimeMinutes'] ?? 0,
      feedingTips: List<String>.from(json['feedingTips'] ?? []),
      mealHistory: json['mealHistory'],
      isVetApproved: json['isVetApproved'] ?? false,
      vetNotes: json['vetNotes'],
    );
  }

  // Helper methods
  bool isScheduledForDay(String day) {
    return daysOfWeek[day.toLowerCase()] ?? false;
  }

  bool isCurrentlyActive() {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  double getAdjustedPortion(String season) {
    return seasonalAdjustments?[season]?.toDouble() ?? portionSize;
  }

  List<String> getActiveReminders() {
    return reminders.where((reminder) {
      final reminderTime = DateTime.parse(reminder);
      return reminderTime.isAfter(DateTime.now());
    }).toList();
  }

  bool needsPreparation() {
    return requiresPreparation && preparationTimeMinutes > 0;
  }

  DateTime getPreparationStartTime() {
    final mealTime = DateTime.now().copyWith(
      hour: time.hour,
      minute: time.minute,
    );
    return mealTime.subtract(Duration(minutes: preparationTimeMinutes));
  }

  bool hasMetNutritionalTargets(Map<String, double> actualNutrition) {
    for (var target in nutritionTargets.entries) {
      final actual = actualNutrition[target.key] ?? 0;
      if (actual < target.value * 0.9) return false; // Within 90% of target
    }
    return true;
  }
}

enum RecurringPattern {
  daily,
  weekdays,
  weekends,
  custom
}

extension RecurringPatternExtension on RecurringPattern {
  String get displayName {
    switch (this) {
      case RecurringPattern.daily:
        return 'Daily';
      case RecurringPattern.weekdays:
        return 'Weekdays';
      case RecurringPattern.weekends:
        return 'Weekends';
      case RecurringPattern.custom:
        return 'Custom';
    }
  }
}
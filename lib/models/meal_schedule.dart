import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealSchedule {
  final String id;
  final String petId;
  final List<ScheduledMeal> meals;
  final Map<String, double> portions;
  final String? notes;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final Map<String, dynamic>? metadata;
  final List<String>? dietaryRestrictions;
  final Map<String, dynamic>? nutritionalGoals;
  final List<String>? approvedFoods;
  final List<String>? restrictedFoods;
  final Map<String, dynamic>? feedingInstructions;
  final String? veterinaryNotes;

  MealSchedule({
    required this.id,
    required this.petId,
    required this.meals,
    required this.portions,
    this.notes,
    this.isActive = true,
    required this.startDate,
    this.endDate,
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.metadata,
    this.dietaryRestrictions,
    this.nutritionalGoals,
    this.approvedFoods,
    this.restrictedFoods,
    this.feedingInstructions,
    this.veterinaryNotes,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'portions': portions,
      'notes': notes,
      'isActive': isActive,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'metadata': metadata,
      'dietaryRestrictions': dietaryRestrictions,
      'nutritionalGoals': nutritionalGoals,
      'approvedFoods': approvedFoods,
      'restrictedFoods': restrictedFoods,
      'feedingInstructions': feedingInstructions,
      'veterinaryNotes': veterinaryNotes,
    };
  }

  factory MealSchedule.fromJson(Map<String, dynamic> json) {
    return MealSchedule(
      id: json['id'],
      petId: json['petId'],
      meals: (json['meals'] as List)
          .map((meal) => ScheduledMeal.fromJson(meal))
          .toList(),
      portions: Map<String, double>.from(json['portions']),
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'])
          : null,
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      metadata: json['metadata'],
      dietaryRestrictions: json['dietaryRestrictions'] != null 
          ? List<String>.from(json['dietaryRestrictions'])
          : null,
      nutritionalGoals: json['nutritionalGoals'],
      approvedFoods: json['approvedFoods'] != null 
          ? List<String>.from(json['approvedFoods'])
          : null,
      restrictedFoods: json['restrictedFoods'] != null 
          ? List<String>.from(json['restrictedFoods'])
          : null,
      feedingInstructions: json['feedingInstructions'],
      veterinaryNotes: json['veterinaryNotes'],
    );
  }

  List<ScheduledMeal> getMealsForDay(DateTime date) {
    return meals.where((meal) => 
      meal.daysOfWeek.contains(date.weekday)).toList();
  }

  bool isValidForDate(DateTime date) {
    if (!isActive) return false;
    if (date.isBefore(startDate)) return false;
    if (endDate != null && date.isAfter(endDate!)) return false;
    return true;
  }

  double getPortionForMeal(String mealType) => portions[mealType] ?? 0.0;

  bool hasRestriction(String restriction) => 
      dietaryRestrictions?.contains(restriction) ?? false;

  bool isApprovedFood(String food) => 
      approvedFoods?.contains(food) ?? true;

  bool isRestrictedFood(String food) => 
      restrictedFoods?.contains(food) ?? false;

  bool canEdit(String userId) => createdBy == userId || !isPremium;

  bool get isExpired => 
      endDate != null && endDate!.isBefore(DateTime.now());

  int get totalMealsPerDay => meals.length;

  Map<int, List<ScheduledMeal>> getMealsByDay() {
    final mealsByDay = <int, List<ScheduledMeal>>{};
    for (var day = 1; day <= 7; day++) {
      mealsByDay[day] = meals.where((meal) => 
          meal.daysOfWeek.contains(day)).toList();
    }
    return mealsByDay;
  }
}

class ScheduledMeal {
  final String id;
  final String type;
  final TimeOfDay time;
  final List<int> daysOfWeek;
  final String? foodType;
  final double? amount;
  final String? unit;
  final String? notes;
  final Map<String, dynamic>? reminders;

  ScheduledMeal({
    required this.id,
    required this.type,
    required this.time,
    required this.daysOfWeek,
    this.foodType,
    this.amount,
    this.unit,
    this.notes,
    this.reminders,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'time': '${time.hour}:${time.minute}',
      'daysOfWeek': daysOfWeek,
      'foodType': foodType,
      'amount': amount,
      'unit': unit,
      'notes': notes,
      'reminders': reminders,
    };
  }

  factory ScheduledMeal.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['time'] as String).split(':');
    return ScheduledMeal(
      id: json['id'],
      type: json['type'],
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      daysOfWeek: List<int>.from(json['daysOfWeek']),
      foodType: json['foodType'],
      amount: json['amount']?.toDouble(),
      unit: json['unit'],
      notes: json['notes'],
      reminders: json['reminders'],
    );
  }

  String getFormattedTime() {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String getFormattedAmount() => 
      amount != null ? '$amount ${unit ?? ''}' : 'N/A';

  bool isScheduledForDay(int day) => daysOfWeek.contains(day);

  bool isUpcoming(DateTime now) {
    return time.hour > now.hour || 
        (time.hour == now.hour && time.minute > now.minute);
  }
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch: return 'Lunch';
      case MealType.dinner: return 'Dinner';
      case MealType.snack: return 'Snack';
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DietRecord {
  final String id;
  final String petId;
  final DateTime date;
  final String foodType;
  final double amount;
  final String unit;
  final MealType mealType;
  final String? brand;
  final String? notes;
  final bool wasEaten;
  final double? leftoverAmount;
  final String? feederId;
  final DateTime? timeServed;
  final DateTime? timeFinished;
  final Map<String, dynamic>? nutritionalInfo;
  // New fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final List<String>? allergies;
  final Map<String, dynamic>? reactions;
  final double? waterIntake;
  final List<String>? supplements;
  final FeedingMethod feedingMethod;
  final Map<String, dynamic>? customMeasurements;

  DietRecord({
    required this.id,
    required this.petId,
    required this.date,
    required this.foodType,
    required this.amount,
    this.unit = 'cups',
    this.mealType = MealType.mainMeal,
    this.brand,
    this.notes,
    this.wasEaten = true,
    this.leftoverAmount,
    this.feederId,
    this.timeServed,
    this.timeFinished,
    this.nutritionalInfo,
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.attachments,
    this.metadata,
    this.allergies,
    this.reactions,
    this.waterIntake,
    this.supplements,
    this.feedingMethod = FeedingMethod.manual,
    this.customMeasurements,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'date': date.toIso8601String(),
      'foodType': foodType,
      'amount': amount,
      'unit': unit,
      'mealType': mealType.toString(),
      'brand': brand,
      'notes': notes,
      'wasEaten': wasEaten,
      'leftoverAmount': leftoverAmount,
      'feederId': feederId,
      'timeServed': timeServed?.toIso8601String(),
      'timeFinished': timeFinished?.toIso8601String(),
      'nutritionalInfo': nutritionalInfo,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'attachments': attachments,
      'metadata': metadata,
      'allergies': allergies,
      'reactions': reactions,
      'waterIntake': waterIntake,
      'supplements': supplements,
      'feedingMethod': feedingMethod.toString(),
      'customMeasurements': customMeasurements,
    };
  }

  factory DietRecord.fromJson(Map<String, dynamic> json) {
    return DietRecord(
      id: json['id'],
      petId: json['petId'],
      date: DateTime.parse(json['date']),
      foodType: json['foodType'],
      amount: json['amount'].toDouble(),
      unit: json['unit'] ?? 'cups',
      mealType: MealType.values.firstWhere(
        (e) => e.toString() == json['mealType'],
        orElse: () => MealType.mainMeal,
      ),
      brand: json['brand'],
      notes: json['notes'],
      wasEaten: json['wasEaten'] ?? true,
      leftoverAmount: json['leftoverAmount']?.toDouble(),
      feederId: json['feederId'],
      timeServed: json['timeServed'] != null 
          ? DateTime.parse(json['timeServed'])
          : null,
      timeFinished: json['timeFinished'] != null 
          ? DateTime.parse(json['timeFinished'])
          : null,
      nutritionalInfo: json['nutritionalInfo'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : null,
      metadata: json['metadata'],
      allergies: json['allergies'] != null 
          ? List<String>.from(json['allergies'])
          : null,
      reactions: json['reactions'],
      waterIntake: json['waterIntake']?.toDouble(),
      supplements: json['supplements'] != null 
          ? List<String>.from(json['supplements'])
          : null,
      feedingMethod: FeedingMethod.values.firstWhere(
        (e) => e.toString() == json['feedingMethod'],
        orElse: () => FeedingMethod.manual,
      ),
      customMeasurements: json['customMeasurements'],
    );
  }

  double get consumedAmount => 
      wasEaten ? amount : (amount - (leftoverAmount ?? 0));

  Duration? get mealDuration {
    if (timeServed == null || timeFinished == null) return null;
    return timeFinished!.difference(timeServed!);
  }

  bool get isComplete => wasEaten || leftoverAmount != null;
  
  bool canEdit(String userId) => createdBy == userId || !isPremium;
  
  String getFormattedAmount() => '$amount $unit';
  
  bool get isRecent => 
      date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  treat,
  medication,
  supplement,
  mainMeal
}

enum FeedingMethod {
  manual,
  automatic,
  scheduled,
  assisted,
  other
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch: return 'Lunch';
      case MealType.dinner: return 'Dinner';
      case MealType.snack: return 'Snack';
      case MealType.treat: return 'Treat';
      case MealType.medication: return 'Medication';
      case MealType.supplement: return 'Supplement';
      case MealType.mainMeal: return 'Main Meal';
    }
  }
}

extension FeedingMethodExtension on FeedingMethod {
  String get displayName {
    switch (this) {
      case FeedingMethod.manual: return 'Manual';
      case FeedingMethod.automatic: return 'Automatic Feeder';
      case FeedingMethod.scheduled: return 'Scheduled';
      case FeedingMethod.assisted: return 'Assisted';
      case FeedingMethod.other: return 'Other';
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String id;
  final String petId;
  final DateTime dateTime;
  final String type;
  final double amount;
  final String unit;
  final String? foodType;
  final String? brand;
  final bool wasEaten;
  final double? leftoverAmount;
  final String? notes;
  final String? feederId;
  final DateTime? timeFinished;
  // Enhanced fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? nutritionalInfo;
  final List<String>? supplements;
  final Map<String, dynamic>? feedingBehavior;
  final String? location;
  final MealStatus status;
  final Map<String, dynamic>? customMeasurements;

  Meal({
    required this.id,
    required this.petId,
    required this.dateTime,
    required this.type,
    required this.amount,
    this.unit = 'cups',
    this.foodType,
    this.brand,
    this.wasEaten = true,
    this.leftoverAmount,
    this.notes,
    this.feederId,
    this.timeFinished,
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.attachments,
    this.metadata,
    this.nutritionalInfo,
    this.supplements,
    this.feedingBehavior,
    this.location,
    this.status = MealStatus.completed,
    this.customMeasurements,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'dateTime': dateTime.toIso8601String(),
      'type': type,
      'amount': amount,
      'unit': unit,
      'foodType': foodType,
      'brand': brand,
      'wasEaten': wasEaten,
      'leftoverAmount': leftoverAmount,
      'notes': notes,
      'feederId': feederId,
      'timeFinished': timeFinished?.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'attachments': attachments,
      'metadata': metadata,
      'nutritionalInfo': nutritionalInfo,
      'supplements': supplements,
      'feedingBehavior': feedingBehavior,
      'location': location,
      'status': status.toString(),
      'customMeasurements': customMeasurements,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      petId: json['petId'],
      dateTime: DateTime.parse(json['dateTime']),
      type: json['type'],
      amount: json['amount'].toDouble(),
      unit: json['unit'] ?? 'cups',
      foodType: json['foodType'],
      brand: json['brand'],
      wasEaten: json['wasEaten'] ?? true,
      leftoverAmount: json['leftoverAmount']?.toDouble(),
      notes: json['notes'],
      feederId: json['feederId'],
      timeFinished: json['timeFinished'] != null 
          ? DateTime.parse(json['timeFinished'])
          : null,
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : null,
      metadata: json['metadata'],
      nutritionalInfo: json['nutritionalInfo'],
      supplements: json['supplements'] != null 
          ? List<String>.from(json['supplements'])
          : null,
      feedingBehavior: json['feedingBehavior'],
      location: json['location'],
      status: MealStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MealStatus.completed,
      ),
      customMeasurements: json['customMeasurements'],
    );
  }

  double get consumedAmount => 
      wasEaten ? amount : (amount - (leftoverAmount ?? 0));

  Duration? get mealDuration {
    if (timeFinished == null) return null;
    return timeFinished!.difference(dateTime);
  }

  bool get isComplete => wasEaten || leftoverAmount != null;

  String getFormattedAmount() => '$amount $unit';

  bool get isRecent => 
      dateTime.isAfter(DateTime.now().subtract(const Duration(days: 1)));

  bool canEdit(String userId) => createdBy == userId || !isPremium;

  Map<String, dynamic> getNutritionalSummary() {
    if (nutritionalInfo == null) return {};
    
    final consumedRatio = consumedAmount / amount;
    final summary = <String, dynamic>{};
    
    nutritionalInfo!.forEach((nutrient, value) {
      if (value is num) {
        summary[nutrient] = value * consumedRatio;
      }
    });
    
    return summary;
  }

  bool hasSupplement(String supplement) => 
      supplements?.contains(supplement) ?? false;

  String getStatusDisplay() => status.displayName;

  bool get requiresAttention => 
      !wasEaten || status == MealStatus.skipped || leftoverAmount != null;
}

enum MealStatus {
  scheduled,
  inProgress,
  completed,
  skipped,
  delayed
}

extension MealStatusExtension on MealStatus {
  String get displayName {
    switch (this) {
      case MealStatus.scheduled: return 'Scheduled';
      case MealStatus.inProgress: return 'In Progress';
      case MealStatus.completed: return 'Completed';
      case MealStatus.skipped: return 'Skipped';
      case MealStatus.delayed: return 'Delayed';
    }
  }

  bool get isActive => 
      this == MealStatus.scheduled || this == MealStatus.inProgress;
}

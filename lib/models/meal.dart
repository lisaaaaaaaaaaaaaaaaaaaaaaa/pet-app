import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum FeedingBehavior {
  normal,
  eager,
  hesitant,
  distracted,
  aggressive,
  selective
}

enum PalatabilityLevel {
  excellent,
  good,
  fair,
  poor,
  refused
}

class Meal extends Equatable {
  final String id;
  final String petId;
  final String name;
  final DateTime scheduledTime;
  final double portion;
  final String unit;
  final String foodType;
  final List<String> ingredients;
  final Map<String, double> nutritionalInfo;
  final bool isCompleted;
  final String notes;
  final List<String> dietaryRestrictions;
  // Premium features
  final String? preparedBy;
  final DateTime? preparedAt;
  final String? servedBy;
  final DateTime? servedAt;
  final double? consumedAmount;
  final String? feedingLocation;
  final Map<String, dynamic>? feedingBehavior;
  final List<String>? feedingIssues;
  final Duration? feedingDuration;
  final Map<String, dynamic>? waterIntake;
  final List<String> supplements;
  final Map<String, dynamic>? medicationWithMeal;
  final Map<String, dynamic>? palatabilityScore;
  final String? foodBatchNumber;
  final DateTime? foodExpiryDate;
  final Map<String, dynamic>? environmentalFactors;
  final List<String>? images;
  final bool wasSubstituted;
  final String? substitutionReason;
  final Map<String, dynamic>? originalMeal;
  final bool requiresPreparation;
  final List<String> preparationSteps;
  final int preparationTimeMinutes;
  final Map<String, dynamic>? storageInstructions;
  final List<String>? allergies;
  final bool isVetApproved;

  const Meal({
    required this.id,
    required this.petId,
    required this.name,
    required this.scheduledTime,
    required this.portion,
    required this.unit,
    required this.foodType,
    this.ingredients = const [],
    this.nutritionalInfo = const {},
    this.isCompleted = false,
    this.notes = '',
    this.dietaryRestrictions = const [],
    // Premium features
    this.preparedBy,
    this.preparedAt,
    this.servedBy,
    this.servedAt,
    this.consumedAmount,
    this.feedingLocation,
    this.feedingBehavior,
    this.feedingIssues,
    this.feedingDuration,
    this.waterIntake,
    this.supplements = const [],
    this.medicationWithMeal,
    this.palatabilityScore,
    this.foodBatchNumber,
    this.foodExpiryDate,
    this.environmentalFactors,
    this.images,
    this.wasSubstituted = false,
    this.substitutionReason,
    this.originalMeal,
    this.requiresPreparation = false,
    this.preparationSteps = const [],
    this.preparationTimeMinutes = 0,
    this.storageInstructions,
    this.allergies,
    this.isVetApproved = false,
  });

  // Firestore serialization
  factory Meal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Meal.fromJson({
      ...data,
      'id': doc.id,
      'scheduledTime': (data['scheduledTime'] as Timestamp).toDate().toIso8601String(),
      'preparedAt': data['preparedAt'] != null 
          ? (data['preparedAt'] as Timestamp).toDate().toIso8601String()
          : null,
      'servedAt': data['servedAt'] != null 
          ? (data['servedAt'] as Timestamp).toDate().toIso8601String()
          : null,
      'foodExpiryDate': data['foodExpiryDate'] != null 
          ? (data['foodExpiryDate'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'preparedAt': preparedAt != null ? Timestamp.fromDate(preparedAt!) : null,
      'servedAt': servedAt != null ? Timestamp.fromDate(servedAt!) : null,
      'foodExpiryDate': foodExpiryDate != null ? Timestamp.fromDate(foodExpiryDate!) : null,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'scheduledTime': scheduledTime.toIso8601String(),
      'portion': portion,
      'unit': unit,
      'foodType': foodType,
      'ingredients': ingredients,
      'nutritionalInfo': nutritionalInfo,
      'isCompleted': isCompleted,
      'notes': notes,
      'dietaryRestrictions': dietaryRestrictions,
      'preparedBy': preparedBy,
      'preparedAt': preparedAt?.toIso8601String(),
      'servedBy': servedBy,
      'servedAt': servedAt?.toIso8601String(),
      'consumedAmount': consumedAmount,
      'feedingLocation': feedingLocation,
      'feedingBehavior': feedingBehavior,
      'feedingIssues': feedingIssues,
      'feedingDuration': feedingDuration?.inMinutes,
      'waterIntake': waterIntake,
      'supplements': supplements,
      'medicationWithMeal': medicationWithMeal,
      'palatabilityScore': palatabilityScore,
      'foodBatchNumber': foodBatchNumber,
      'foodExpiryDate': foodExpiryDate?.toIso8601String(),
      'environmentalFactors': environmentalFactors,
      'images': images,
      'wasSubstituted': wasSubstituted,
      'substitutionReason': substitutionReason,
      'originalMeal': originalMeal,
      'requiresPreparation': requiresPreparation,
      'preparationSteps': preparationSteps,
      'preparationTimeMinutes': preparationTimeMinutes,
      'storageInstructions': storageInstructions,
      'allergies': allergies,
      'isVetApproved': isVetApproved,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      petId: json['petId'],
      name: json['name'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      portion: json['portion'].toDouble(),
      unit: json['unit'],
      foodType: json['foodType'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
      nutritionalInfo: Map<String, double>.from(json['nutritionalInfo'] ?? {}),
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'] ?? '',
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions'] ?? []),
      preparedBy: json['preparedBy'],
      preparedAt: json['preparedAt'] != null 
          ? DateTime.parse(json['preparedAt']) 
          : null,
      servedBy: json['servedBy'],
      servedAt: json['servedAt'] != null 
          ? DateTime.parse(json['servedAt']) 
          : null,
      consumedAmount: json['consumedAmount']?.toDouble(),
      feedingLocation: json['feedingLocation'],
      feedingBehavior: json['feedingBehavior'],
      feedingIssues: json['feedingIssues'] != null 
          ? List<String>.from(json['feedingIssues']) 
          : null,
      feedingDuration: json['feedingDuration'] != null 
          ? Duration(minutes: json['feedingDuration']) 
          : null,
      waterIntake: json['waterIntake'],
      supplements: List<String>.from(json['supplements'] ?? []),
      medicationWithMeal: json['medicationWithMeal'],
      palatabilityScore: json['palatabilityScore'],
      foodBatchNumber: json['foodBatchNumber'],
      foodExpiryDate: json['foodExpiryDate'] != null 
          ? DateTime.parse(json['foodExpiryDate']) 
          : null,
      environmentalFactors: json['environmentalFactors'],
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : null,
      wasSubstituted: json['wasSubstituted'] ?? false,
      substitutionReason: json['substitutionReason'],
      originalMeal: json['originalMeal'],
      requiresPreparation: json['requiresPreparation'] ?? false,
      preparationSteps: List<String>.from(json['preparationSteps'] ?? []),
      preparationTimeMinutes: json['preparationTimeMinutes'] ?? 0,
      storageInstructions: json['storageInstructions'],
      allergies: json['allergies'] != null 
          ? List<String>.from(json['allergies']) 
          : null,
      isVetApproved: json['isVetApproved'] ?? false,
    );
  }

  // CopyWith method for immutability
  Meal copyWith({
    String? id,
    String? petId,
    String? name,
    DateTime? scheduledTime,
    double? portion,
    String? unit,
    String? foodType,
    List<String>? ingredients,
    Map<String, double>? nutritionalInfo,
    bool? isCompleted,
    String? notes,
    List<String>? dietaryRestrictions,
    String? preparedBy,
    DateTime? preparedAt,
    String? servedBy,
    DateTime? servedAt,
    double? consumedAmount,
    String? feedingLocation,
    Map<String, dynamic>? feedingBehavior,
    List<String>? feedingIssues,
    Duration? feedingDuration,
    Map<String, dynamic>? waterIntake,
    List<String>? supplements,
    Map<String, dynamic>? medicationWithMeal,
    Map<String, dynamic>? palatabilityScore,
    String? foodBatchNumber,
    DateTime? foodExpiryDate,
    Map<String, dynamic>? environmentalFactors,
    List<String>? images,
    bool? wasSubstituted,
    String? substitutionReason,
    Map<String, dynamic>? originalMeal,
    bool? requiresPreparation,
    List<String>? preparationSteps,
    int? preparationTimeMinutes,
    Map<String, dynamic>? storageInstructions,
    List<String>? allergies,
    bool? isVetApproved,
  }) {
    return Meal(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      portion: portion ?? this.portion,
      unit: unit ?? this.unit,
      foodType: foodType ?? this.foodType,
      ingredients: ingredients ?? this.ingredients,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      preparedBy: preparedBy ?? this.preparedBy,
      preparedAt: preparedAt ?? this.preparedAt,
      servedBy: servedBy ?? this.servedBy,
      servedAt: servedAt ?? this.servedAt,
      consumedAmount: consumedAmount ?? this.consumedAmount,
      feedingLocation: feedingLocation ?? this.feedingLocation,
      feedingBehavior: feedingBehavior ?? this.feedingBehavior,
      feedingIssues: feedingIssues ?? this.feedingIssues,
      feedingDuration: feedingDuration ?? this.feedingDuration,
      waterIntake: waterIntake ?? this.waterIntake,
      supplements: supplements ?? this.supplements,
      medicationWithMeal: medicationWithMeal ?? this.medicationWithMeal,
      palatabilityScore: palatabilityScore ?? this.palatabilityScore,
      foodBatchNumber: foodBatchNumber ?? this.foodBatchNumber,
      foodExpiryDate: foodExpiryDate ?? this.foodExpiryDate,
      environmentalFactors: environmentalFactors ?? this.environmentalFactors,
      images: images ?? this.images,
      wasSubstituted: wasSubstituted ?? this.wasSubstituted,
      substitutionReason: substitutionReason ?? this.substitutionReason,
      originalMeal: originalMeal ?? this.originalMeal,
      requiresPreparation: requiresPreparation ?? this.requiresPreparation,
      preparationSteps: preparationSteps ?? this.preparationSteps,
      preparationTimeMinutes: preparationTimeMinutes ?? this.preparationTimeMinutes,
      storageInstructions: storageInstructions ?? this.storageInstructions,
      allergies: allergies ?? this.allergies,
      isVetApproved: isVetApproved ?? this.isVetApproved,
    );
  }

  // Helper methods
  bool isOverdue() {
    return !isCompleted && DateTime.now().isAfter(scheduledTime);
  }

  double getConsumptionRate() {
    if (consumedAmount == null) return isCompleted ? 1.0 : 0.0;
    return consumedAmount! / portion;
  }

  bool hasAllergicIngredients() {
    if (allergies == null || allergies!.isEmpty) return false;
    return ingredients.any((ingredient) => 
        allergies!.any((allergen) => 
            ingredient.toLowerCase().contains(allergen.toLowerCase())));
  }

  bool needsPreparation() {
    return requiresPreparation && preparationTimeMinutes > 0;
  }

  DateTime getPreparationStartTime() {
    return scheduledTime.subtract(Duration(minutes: preparationTimeMinutes));
  }

  bool isFoodExpired() {
    if (foodExpiryDate == null) return false;
    return DateTime.now().isAfter(foodExpiryDate!);
  }

  bool hasCompleteFeedingRecord() {
    return isCompleted && 
           servedAt != null && 
           consumedAmount != null && 
           feedingDuration != null;
  }

  // Equatable implementation
  @override
  List<Object?> get props => [
    id,
    petId,
    name,
    scheduledTime,
    portion,
    unit,
    foodType,
    ingredients,
    nutritionalInfo,
    isCompleted,
    notes,
    dietaryRestrictions,
    preparedBy,
    preparedAt,
    servedBy,
    servedAt,
    consumedAmount,
    feedingLocation,
    feedingBehavior,
    feedingIssues,
    feedingDuration,
    waterIntake,
    supplements,
    medicationWithMeal,
    palatabilityScore,
    foodBatchNumber,
    foodExpiryDate,
    environmentalFactors,
    images,
    wasSubstituted,
    substitutionReason,
    originalMeal,
    requiresPreparation,
    preparationSteps,
    preparationTimeMinutes,
    storageInstructions,
    allergies,
    isVetApproved,
  ];

  // Additional helper methods for premium features
  bool get needsVetApproval => !isVetApproved && medicationWithMeal != null;

  bool get hasSpecialInstructions => 
    requiresPreparation || 
    storageInstructions != null || 
    preparationSteps.isNotEmpty;

  double get complianceScore {
    if (!isCompleted) return 0.0;
    
    int score = 0;
    int totalFactors = 0;

    // Check timing compliance
    if (servedAt != null) {
      final difference = servedAt!.difference(scheduledTime).abs();
      if (difference <= const Duration(minutes: 15)) score++;
      totalFactors++;
    }

    // Check portion compliance
    if (consumedAmount != null) {
      if (consumedAmount! >= portion * 0.8) score++;
      totalFactors++;
    }

    // Check preparation compliance
    if (requiresPreparation) {
      if (preparedAt != null && preparedBy != null) score++;
      totalFactors++;
    }

    // Check medication compliance
    if (medicationWithMeal != null) {
      if (medicationWithMeal!['administered'] == true) score++;
      totalFactors++;
    }

    return totalFactors > 0 ? score / totalFactors : 1.0;
  }

  Map<String, dynamic> generateFeedingReport() {
    return {
      'mealName': name,
      'scheduledTime': scheduledTime,
      'actualFeedingTime': servedAt,
      'timingDeviation': servedAt != null 
          ? servedAt!.difference(scheduledTime).inMinutes 
          : null,
      'portionServed': portion,
      'portionConsumed': consumedAmount,
      'consumptionRate': getConsumptionRate(),
      'feedingDuration': feedingDuration?.inMinutes,
      'feedingBehavior': feedingBehavior,
      'issues': feedingIssues,
      'waterIntake': waterIntake,
      'medications': medicationWithMeal,
      'palatability': palatabilityScore,
      'complianceScore': complianceScore,
      'environmentalFactors': environmentalFactors,
      'substitutions': wasSubstituted ? {
        'reason': substitutionReason,
        'originalMeal': originalMeal,
      } : null,
    };
  }

  static List<String> get mealTypes => [
    'Breakfast',
    'Morning Snack',
    'Lunch',
    'Afternoon Snack',
    'Dinner',
    'Evening Snack',
    'Medication Meal',
    'Special Diet Meal',
    'Recovery Meal',
    'Training Treats',
  ];

  static List<String> get unitTypes => [
    'cups',
    'grams',
    'ounces',
    'pieces',
    'servings',
    'tablespoons',
    'teaspoons',
    'milliliters',
  ];

  static List<String> get commonLocations => [
    'Regular Bowl',
    'Kitchen',
    'Living Room',
    'Outdoor',
    'Crate',
    'Medical Area',
    'Training Area',
  ];

  static Map<String, String> get behaviorDescriptions => {
    'normal': 'Eating at regular pace with normal interest',
    'eager': 'Shows high interest and eats quickly',
    'hesitant': 'Shows uncertainty or takes time to start eating',
    'distracted': 'Easily interrupted while eating',
    'aggressive': 'Guards food or shows aggressive behavior',
    'selective': 'Shows preference for specific food items',
  };

  // Validation methods
  bool isValidMealTime() {
    final now = DateTime.now();
    return scheduledTime.isBefore(now.add(const Duration(days: 30))) &&
           scheduledTime.isAfter(now.subtract(const Duration(days: 365)));
  }

  bool hasValidPortion() {
    return portion > 0 && portion <= 1000; // Reasonable maximum portion size
  }

  List<String> validate() {
    final errors = <String>[];

    if (!isValidMealTime()) {
      errors.add('Invalid meal time');
    }

    if (!hasValidPortion()) {
      errors.add('Invalid portion size');
    }

    if (medicationWithMeal != null && !isVetApproved) {
      errors.add('Meals with medication require vet approval');
    }

    if (hasAllergicIngredients()) {
      errors.add('Meal contains allergens');
    }

    if (isFoodExpired()) {
      errors.add('Food has expired');
    }

    return errors;
  }

  // Factory constructors for common meal types
  factory Meal.regular({
    required String id,
    required String petId,
    required String name,
    required DateTime scheduledTime,
    required double portion,
    required String unit,
    required String foodType,
  }) {
    return Meal(
      id: id,
      petId: petId,
      name: name,
      scheduledTime: scheduledTime,
      portion: portion,
      unit: unit,
      foodType: foodType,
      requiresPreparation: false,
      isVetApproved: true,
    );
  }

  factory Meal.medical({
    required String id,
    required String petId,
    required String name,
    required DateTime scheduledTime,
    required double portion,
    required String unit,
    required String foodType,
    required Map<String, dynamic> medication,
  }) {
    return Meal(
      id: id,
      petId: petId,
      name: name,
      scheduledTime: scheduledTime,
      portion: portion,
      unit: unit,
      foodType: foodType,
      medicationWithMeal: medication,
      requiresPreparation: true,
      isVetApproved: false,
    );
  }

  @override
  String toString() => 'Meal(id: $id, name: $name, time: $scheduledTime)';
}
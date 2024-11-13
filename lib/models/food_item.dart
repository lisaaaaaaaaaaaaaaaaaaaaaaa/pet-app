import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum FoodType {
  dryFood,
  wetFood,
  freshFood,
  rawFood,
  treats,
  supplement,
  prescription
}

extension FoodTypeExtension on FoodType {
  String get displayName {
    switch (this) {
      case FoodType.dryFood:
        return 'Dry Food';
      case FoodType.wetFood:
        return 'Wet Food';
      case FoodType.freshFood:
        return 'Fresh Food';
      case FoodType.rawFood:
        return 'Raw Food';
      case FoodType.treats:
        return 'Treats';
      case FoodType.supplement:
        return 'Supplement';
      case FoodType.prescription:
        return 'Prescription Diet';
    }
  }

  bool get requiresPrescription => this == FoodType.prescription;
  bool get requiresRefrigeration => [FoodType.freshFood, FoodType.rawFood].contains(this);
}

class FoodItem extends Equatable {
  final String id;
  final String name;
  final String brand;
  final String type;
  final double caloriesPerGram;
  final Map<String, double>? nutrients;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  // Premium features
  final List<String> ingredients;
  final String? manufacturerId;
  final String? batchNumber;
  final DateTime? expirationDate;
  final Map<String, String>? allergenInfo;
  final List<String> certifications;
  final String? countryOfOrigin;
  final Map<String, dynamic>? nutritionalAnalysis;
  final List<String> recommendedPetTypes;
  final Map<String, dynamic>? feedingGuidelines;
  final List<String> contraindicatedConditions;
  final double? moistureContent;
  final String? storageInstructions;
  final Map<String, dynamic>? qualityMetrics;
  final List<String>? images;
  final bool isVeterinaryApproved;
  final Map<String, dynamic>? palatabilityScores;
  final double? averageRating;
  final int reviewCount;

  const FoodItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.caloriesPerGram,
    this.nutrients,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
    this.isActive = true,
    // Premium features
    this.ingredients = const [],
    this.manufacturerId,
    this.batchNumber,
    this.expirationDate,
    this.allergenInfo,
    this.certifications = const [],
    this.countryOfOrigin,
    this.nutritionalAnalysis,
    this.recommendedPetTypes = const [],
    this.feedingGuidelines,
    this.contraindicatedConditions = const [],
    this.moistureContent,
    this.storageInstructions,
    this.qualityMetrics,
    this.images,
    this.isVeterinaryApproved = false,
    this.palatabilityScores,
    this.averageRating,
    this.reviewCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  // Firestore serialization
  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodItem.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.now(),
      'expirationDate': expirationDate != null 
          ? Timestamp.fromDate(expirationDate!) 
          : null,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'type': type,
      'caloriesPerGram': caloriesPerGram,
      'nutrients': nutrients,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
      'ingredients': ingredients,
      'manufacturerId': manufacturerId,
      'batchNumber': batchNumber,
      'expirationDate': expirationDate != null 
          ? Timestamp.fromDate(expirationDate!) 
          : null,
      'allergenInfo': allergenInfo,
      'certifications': certifications,
      'countryOfOrigin': countryOfOrigin,
      'nutritionalAnalysis': nutritionalAnalysis,
      'recommendedPetTypes': recommendedPetTypes,
      'feedingGuidelines': feedingGuidelines,
      'contraindicatedConditions': contraindicatedConditions,
      'moistureContent': moistureContent,
      'storageInstructions': storageInstructions,
      'qualityMetrics': qualityMetrics,
      'images': images,
      'isVeterinaryApproved': isVeterinaryApproved,
      'palatabilityScores': palatabilityScores,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      type: json['type'],
      caloriesPerGram: json['caloriesPerGram'].toDouble(),
      nutrients: json['nutrients'] != null
          ? Map<String, double>.from(json['nutrients'])
          : null,
      notes: json['notes'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      isActive: json['isActive'] ?? true,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      manufacturerId: json['manufacturerId'],
      batchNumber: json['batchNumber'],
      expirationDate: json['expirationDate'] != null
          ? (json['expirationDate'] as Timestamp).toDate()
          : null,
      allergenInfo: json['allergenInfo'] != null
          ? Map<String, String>.from(json['allergenInfo'])
          : null,
      certifications: List<String>.from(json['certifications'] ?? []),
      countryOfOrigin: json['countryOfOrigin'],
      nutritionalAnalysis: json['nutritionalAnalysis'],
      recommendedPetTypes: List<String>.from(json['recommendedPetTypes'] ?? []),
      feedingGuidelines: json['feedingGuidelines'],
      contraindicatedConditions: 
          List<String>.from(json['contraindicatedConditions'] ?? []),
      moistureContent: json['moistureContent']?.toDouble(),
      storageInstructions: json['storageInstructions'],
      qualityMetrics: json['qualityMetrics'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      isVeterinaryApproved: json['isVeterinaryApproved'] ?? false,
      palatabilityScores: json['palatabilityScores'],
      averageRating: json['averageRating']?.toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  // Helper methods
  bool isExpired() {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  bool isExpiringSoon({int daysThreshold = 30}) {
    if (expirationDate == null) return false;
    final daysUntilExpiry = expirationDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= daysThreshold && daysUntilExpiry > 0;
  }

  bool containsAllergen(String allergen) {
    return allergenInfo?.containsKey(allergen.toLowerCase()) ?? false ||
           ingredients.any((i) => i.toLowerCase().contains(allergen.toLowerCase()));
  }

  bool isRecommendedFor(String petType) {
    return recommendedPetTypes.isEmpty || 
           recommendedPetTypes.contains(petType.toLowerCase());
  }

  bool hasContraindication(String condition) {
    return contraindicatedConditions
        .any((c) => c.toLowerCase() == condition.toLowerCase());
  }

  String getFormattedRating() {
    if (averageRating == null) return 'Not rated';
    return '${averageRating!.toStringAsFixed(1)} ⭐ ($reviewCount reviews)';
  }

  bool meetsQualityStandard(String metric, double threshold) {
    return qualityMetrics?[metric]?.toDouble() ?? 0 >= threshold;
  }

  // New helper methods
  bool requiresSpecialHandling() {
    final foodType = FoodType.values.firstWhere(
      (e) => e.displayName.toLowerCase() == type.toLowerCase(),
      orElse: () => FoodType.dryFood,
    );
    return foodType.requiresRefrigeration || 
           moistureContent != null && moistureContent! > 20;
  }

  Map<String, dynamic> getNutritionalSummary() {
    return {
      'calories': caloriesPerGram,
      'nutrients': nutrients,
      'moisture': moistureContent,
      'analysis': nutritionalAnalysis,
    };
  }

  List<String> getWarnings() {
    final warnings = <String>[];
    
    if (isExpired()) {
      warnings.add('Food has expired');
    } else if (isExpiringSoon()) {
      warnings.add('Food is expiring soon');
    }

    if (requiresSpecialHandling()) {
      warnings.add('Requires special storage');
    }

    if (type.toLowerCase() == FoodType.prescription.displayName.toLowerCase() && 
        !isVeterinaryApproved) {
      warnings.add('Requires veterinary approval');
    }

    return warnings;
  }

  // Validation
  List<String> validate() {
    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('Name is required');
    }

    if (brand.isEmpty) {
      errors.add('Brand is required');
    }

    if (caloriesPerGram <= 0) {
      errors.add('Invalid calorie content');
    }

    if (isExpired()) {
      errors.add('Food has expired');
    }

    if (type.toLowerCase() == FoodType.prescription.displayName.toLowerCase() && 
        !isVeterinaryApproved) {
      errors.add('Prescription food requires veterinary approval');
    }

    return errors;
  }

  // CopyWith method
  FoodItem copyWith({
    String? id,
    String? name,
    String? brand,
    String? type,
    double? caloriesPerGram,
    Map<String, double>? nutrients,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? ingredients,
    String? manufacturerId,
    String? batchNumber,
    DateTime? expirationDate,
    Map<String, String>? allergenInfo,
    List<String>? certifications,
    String? countryOfOrigin,
    Map<String, dynamic>? nutritionalAnalysis,
    List<String>? recommendedPetTypes,
    Map<String, dynamic>? feedingGuidelines,
    List<String>? contraindicatedConditions,
    double? moistureContent,
    String? storageInstructions,
    Map<String, dynamic>? qualityMetrics,
    List<String>? images,
    bool? isVeterinaryApproved,
    Map<String, dynamic>? palatabilityScores,
    double? averageRating,
    int? reviewCount,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      type: type ?? this.type,
      caloriesPerGram: caloriesPerGram ?? this.caloriesPerGram,
      nutrients: nutrients ?? this.nutrients,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      ingredients: ingredients ?? this.ingredients,
      manufacturerId: manufacturerId ?? this.manufacturerId,
      batchNumber: batchNumber ?? this.batchNumber,
      expirationDate: expirationDate ?? this.expirationDate,
      allergenInfo: allergenInfo ?? this.allergenInfo,
      certifications: certifications ?? this.certifications,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      nutritionalAnalysis: nutritionalAnalysis ?? this.nutritionalAnalysis,
      recommendedPetTypes: recommendedPetTypes ?? this.recommendedPetTypes,
      feedingGuidelines: feedingGuidelines ?? this.feedingGuidelines,
      contraindicatedConditions: contraindicatedConditions ?? this.contraindicatedConditions,
      moistureContent: moistureContent ?? this.moistureContent,
      storageInstructions: storageInstructions ?? this.storageInstructions,
      qualityMetrics: qualityMetrics ?? this.qualityMetrics,
      images: images ?? this.images,
      isVeterinaryApproved: isVeterinaryApproved ?? this.isVeterinaryApproved,
      palatabilityScores: palatabilityScores ?? this.palatabilityScores,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  // Equatable
  @override
  List<Object?> get props => [
    id,
    name,
    brand,
    type,
    caloriesPerGram,
    nutrients,
    notes,
    createdAt,
    updatedAt,
    isActive,
    ingredients,
    manufacturerId,
    batchNumber,
    expirationDate,
    allergenInfo,
    certifications,
    countryOfOrigin,
    nutritionalAnalysis,
    recommendedPetTypes,
    feedingGuidelines,
    contraindicatedConditions,
    moistureContent,
    storageInstructions,
    qualityMetrics,
    images,
    isVeterinaryApproved,
    palatabilityScores,
    averageRating,
    reviewCount,
  ];
}
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String type;
  final Map<String, dynamic> nutritionalInfo;
  final List<String> ingredients;
  final List<String> allergens;
  final String? description;
  final String? imageUrl;
  final double? rating;
  final int reviewCount;
  final Map<String, bool> dietaryFlags;
  final List<String> lifestages;
  final List<String> specialNeeds;
  final Map<String, dynamic> servingInfo;
  // New fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final List<String>? certifications;
  final Map<String, dynamic>? metadata;
  final double? price;
  final String? currency;
  final Map<String, dynamic>? availability;
  final List<String>? variants;
  final Map<String, dynamic>? storageInfo;
  final DateTime? expirationDate;
  final String? batchNumber;
  final Map<String, dynamic>? qualityMetrics;

  FoodItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.type,
    required this.nutritionalInfo,
    required this.ingredients,
    this.allergens = const [],
    this.description,
    this.imageUrl,
    this.rating,
    this.reviewCount = 0,
    this.dietaryFlags = const {},
    this.lifestages = const [],
    this.specialNeeds = const [],
    this.servingInfo = const {},
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.certifications,
    this.metadata,
    this.price,
    this.currency,
    this.availability,
    this.variants,
    this.storageInfo,
    this.expirationDate,
    this.batchNumber,
    this.qualityMetrics,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'type': type,
      'nutritionalInfo': nutritionalInfo,
      'ingredients': ingredients,
      'allergens': allergens,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'dietaryFlags': dietaryFlags,
      'lifestages': lifestages,
      'specialNeeds': specialNeeds,
      'servingInfo': servingInfo,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'certifications': certifications,
      'metadata': metadata,
      'price': price,
      'currency': currency,
      'availability': availability,
      'variants': variants,
      'storageInfo': storageInfo,
      'expirationDate': expirationDate?.toIso8601String(),
      'batchNumber': batchNumber,
      'qualityMetrics': qualityMetrics,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      category: json['category'],
      type: json['type'],
      nutritionalInfo: Map<String, dynamic>.from(json['nutritionalInfo']),
      ingredients: List<String>.from(json['ingredients']),
      allergens: List<String>.from(json['allergens'] ?? []),
      description: json['description'],
      imageUrl: json['imageUrl'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      dietaryFlags: Map<String, bool>.from(json['dietaryFlags'] ?? {}),
      lifestages: List<String>.from(json['lifestages'] ?? []),
      specialNeeds: List<String>.from(json['specialNeeds'] ?? []),
      servingInfo: Map<String, dynamic>.from(json['servingInfo'] ?? {}),
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      certifications: json['certifications'] != null 
          ? List<String>.from(json['certifications'])
          : null,
      metadata: json['metadata'],
      price: json['price']?.toDouble(),
      currency: json['currency'],
      availability: json['availability'],
      variants: json['variants'] != null 
          ? List<String>.from(json['variants'])
          : null,
      storageInfo: json['storageInfo'],
      expirationDate: json['expirationDate'] != null 
          ? DateTime.parse(json['expirationDate'])
          : null,
      batchNumber: json['batchNumber'],
      qualityMetrics: json['qualityMetrics'],
    );
  }

  bool hasAllergen(String allergen) => 
      allergens.contains(allergen.toLowerCase());

  bool isGrainFree() => 
      !ingredients.any((i) => i.toLowerCase().contains('grain'));

  bool isDairyFree() => 
      !ingredients.any((i) => i.toLowerCase().contains('dairy'));

  bool isAppropriateFor(String lifestage) => 
      lifestages.contains(lifestage);

  bool meetsSpecialNeed(String need) => 
      specialNeeds.contains(need);

  String getFormattedPrice() => 
      price != null ? '$currency ${price!.toStringAsFixed(2)}' : 'N/A';

  bool isExpired() => 
      expirationDate != null && expirationDate!.isBefore(DateTime.now());

  bool canEdit(String userId) => createdBy == userId || !isPremium;

  double getServingSize(String petSize) => 
      (servingInfo[petSize] ?? servingInfo['default'] ?? 1.0).toDouble();

  List<String> getNutritionalHighlights() {
    final highlights = <String>[];
    final info = nutritionalInfo;
    
    if ((info['protein'] ?? 0) > 25) highlights.add('High Protein');
    if ((info['fiber'] ?? 0) > 5) highlights.add('High Fiber');
    if ((info['omega3'] ?? 0) > 0.5) highlights.add('Contains Omega-3');
    
    return highlights;
  }
}

enum FoodCategory {
  dryFood,
  wetFood,
  treats,
  supplements,
  prescription,
  raw,
  frozenRaw,
  dehydrated,
  freshCooked
}

extension FoodCategoryExtension on FoodCategory {
  String get displayName {
    switch (this) {
      case FoodCategory.dryFood: return 'Dry Food';
      case FoodCategory.wetFood: return 'Wet Food';
      case FoodCategory.treats: return 'Treats';
      case FoodCategory.supplements: return 'Supplements';
      case FoodCategory.prescription: return 'Prescription Diet';
      case FoodCategory.raw: return 'Raw Food';
      case FoodCategory.frozenRaw: return 'Frozen Raw';
      case FoodCategory.dehydrated: return 'Dehydrated';
      case FoodCategory.freshCooked: return 'Fresh Cooked';
    }
  }
}

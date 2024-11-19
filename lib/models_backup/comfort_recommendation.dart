// lib/models/comfort_recommendation.dart


class ComfortRecommendation {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final String category;
  final List<String> equipmentNeeded;
  final int difficultyLevel;
  final bool isVerified;
  final DateTime createdAt;
  final List<String> images;
  // New premium features
  final String createdBy;
  final List<String> approvedBy;
  final List<String> veterinaryNotes;
  final Map<String, dynamic>? contraindications;
  final List<String> applicablePetTypes;
  final List<String> applicableConditions;
  final Map<String, dynamic> steps;
  final Map<String, dynamic>? expectedOutcomes;
  final int recommendedFrequency;
  final String? videoUrl;
  final double? successRate;
  final List<String> precautions;
  final Map<String, dynamic>? scientificReferences;
  final bool isPremium;

  ComfortRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.category,
    this.equipmentNeeded = const [],
    this.difficultyLevel = 1,
    this.isVerified = false,
    required this.createdAt,
    this.images = const [],
    // New premium features
    required this.createdBy,
    this.approvedBy = const [],
    this.veterinaryNotes = const [],
    this.contraindications,
    this.applicablePetTypes = const [],
    this.applicableConditions = const [],
    required this.steps,
    this.expectedOutcomes,
    this.recommendedFrequency = 1,
    this.videoUrl,
    this.successRate,
    this.precautions = const [],
    this.scientificReferences,
    this.isPremium = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tags': tags,
      'category': category,
      'equipmentNeeded': equipmentNeeded,
      'difficultyLevel': difficultyLevel,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'images': images,
      // New premium features
      'createdBy': createdBy,
      'approvedBy': approvedBy,
      'veterinaryNotes': veterinaryNotes,
      'contraindications': contraindications,
      'applicablePetTypes': applicablePetTypes,
      'applicableConditions': applicableConditions,
      'steps': steps,
      'expectedOutcomes': expectedOutcomes,
      'recommendedFrequency': recommendedFrequency,
      'videoUrl': videoUrl,
      'successRate': successRate,
      'precautions': precautions,
      'scientificReferences': scientificReferences,
      'isPremium': isPremium,
    };
  }

  factory ComfortRecommendation.fromJson(Map<String, dynamic> json) {
    return ComfortRecommendation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
      equipmentNeeded: List<String>.from(json['equipmentNeeded'] ?? []),
      difficultyLevel: json['difficultyLevel'] ?? 1,
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      images: List<String>.from(json['images'] ?? []),
      // New premium features
      createdBy: json['createdBy'],
      approvedBy: List<String>.from(json['approvedBy'] ?? []),
      veterinaryNotes: List<String>.from(json['veterinaryNotes'] ?? []),
      contraindications: json['contraindications'],
      applicablePetTypes: List<String>.from(json['applicablePetTypes'] ?? []),
      applicableConditions: List<String>.from(json['applicableConditions'] ?? []),
      steps: Map<String, dynamic>.from(json['steps'] ?? {}),
      expectedOutcomes: json['expectedOutcomes'],
      recommendedFrequency: json['recommendedFrequency'] ?? 1,
      videoUrl: json['videoUrl'],
      successRate: json['successRate']?.toDouble(),
      precautions: List<String>.from(json['precautions'] ?? []),
      scientificReferences: json['scientificReferences'],
      isPremium: json['isPremium'] ?? false,
    );
  }

  // Helper methods
  bool isApprovedByVet() {
    return approvedBy.isNotEmpty;
  }

  String getDifficultyText() {
    switch (difficultyLevel) {
      case 1:
        return 'Easy';
      case 2:
        return 'Moderate';
      case 3:
        return 'Advanced';
      default:
        return 'Unknown';
    }
  }

  bool isApplicableForPetType(String petType) {
    return applicablePetTypes.isEmpty || 
           applicablePetTypes.contains(petType.toLowerCase());
  }

  bool hasContraindication(String condition) {
    if (contraindications == null) return false;
    return contraindications!.containsKey(condition.toLowerCase());
  }

  String getFrequencyText() {
    if (recommendedFrequency == 1) return 'Once daily';
    if (recommendedFrequency == 2) return 'Twice daily';
    return '$recommendedFrequency times daily';
  }

  String getSuccessRateText() {
    if (successRate == null) return 'Not rated';
    return '${(successRate! * 100).toStringAsFixed(1)}% success rate';
  }

  bool requiresProfessionalSupervision() {
    return difficultyLevel >= 3 || 
           precautions.any((p) => p.toLowerCase().contains('supervision'));
  }
}

enum ComfortCategory {
  exercise,
  massage,
  stretching,
  relaxation,
  therapy,
  environmental,
  dietary,
  behavioral,
  medical,
  other
}

extension ComfortCategoryExtension on ComfortCategory {
  String get displayName {
    switch (this) {
      case ComfortCategory.exercise:
        return 'Exercise';
      case ComfortCategory.massage:
        return 'Massage';
      case ComfortCategory.stretching:
        return 'Stretching';
      case ComfortCategory.relaxation:
        return 'Relaxation';
      case ComfortCategory.therapy:
        return 'Therapy';
      case ComfortCategory.environmental:
        return 'Environmental';
      case ComfortCategory.dietary:
        return 'Dietary';
      case ComfortCategory.behavioral:
        return 'Behavioral';
      case ComfortCategory.medical:
        return 'Medical';
      case ComfortCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ComfortCategory.exercise:
        return '🏃';
      case ComfortCategory.massage:
        return '💆';
      case ComfortCategory.stretching:
        return '🧘';
      case ComfortCategory.relaxation:
        return '😌';
      case ComfortCategory.therapy:
        return '🏥';
      case ComfortCategory.environmental:
        return '🏠';
      case ComfortCategory.dietary:
        return '🍽';
      case ComfortCategory.behavioral:
        return '🧠';
      case ComfortCategory.medical:
        return '💊';
      case ComfortCategory.other:
        return '❓';
    }
  }
}
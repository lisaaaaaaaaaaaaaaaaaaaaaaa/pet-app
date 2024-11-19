import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComfortRecommendation {
  final String id;
  final String petId;
  final String title;
  final String description;
  final String category;
  final int priority;
  final bool isActive;
  final DateTime createdAt;
  final String? createdBy;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final bool isPremium;
  final List<String>? attachments;
  final Map<String, dynamic>? customFields;
  final DateTime? lastUpdated;
  final String? updatedBy;
  final bool isAutomated;
  final Map<String, dynamic>? conditions;
  final List<String>? relatedRecommendations;
  final double? successRate;
  final int implementationCount;

  ComfortRecommendation({
    required this.id,
    required this.petId,
    required this.title,
    required this.description,
    required this.category,
    this.priority = 1,
    this.isActive = true,
    DateTime? createdAt,
    this.createdBy,
    this.tags = const [],
    this.metadata,
    this.isPremium = false,
    this.attachments,
    this.customFields,
    this.lastUpdated,
    this.updatedBy,
    this.isAutomated = false,
    this.conditions,
    this.relatedRecommendations,
    this.successRate,
    this.implementationCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'tags': tags,
      'metadata': metadata,
      'isPremium': isPremium,
      'attachments': attachments,
      'customFields': customFields,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'updatedBy': updatedBy,
      'isAutomated': isAutomated,
      'conditions': conditions,
      'relatedRecommendations': relatedRecommendations,
      'successRate': successRate,
      'implementationCount': implementationCount,
    };
  }

  factory ComfortRecommendation.fromJson(Map<String, dynamic> json) {
    return ComfortRecommendation(
      id: json['id'],
      petId: json['petId'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      priority: json['priority'] ?? 1,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      createdBy: json['createdBy'],
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'],
      isPremium: json['isPremium'] ?? false,
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : null,
      customFields: json['customFields'],
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : null,
      updatedBy: json['updatedBy'],
      isAutomated: json['isAutomated'] ?? false,
      conditions: json['conditions'],
      relatedRecommendations: json['relatedRecommendations'] != null 
          ? List<String>.from(json['relatedRecommendations'])
          : null,
      successRate: json['successRate']?.toDouble(),
      implementationCount: json['implementationCount'] ?? 0,
    );
  }

  ComfortRecommendation copyWith({
    String? id,
    String? petId,
    String? title,
    String? description,
    String? category,
    int? priority,
    bool? isActive,
    DateTime? createdAt,
    String? createdBy,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    bool? isPremium,
    List<String>? attachments,
    Map<String, dynamic>? customFields,
    DateTime? lastUpdated,
    String? updatedBy,
    bool? isAutomated,
    Map<String, dynamic>? conditions,
    List<String>? relatedRecommendations,
    double? successRate,
    int? implementationCount,
  }) {
    return ComfortRecommendation(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      isPremium: isPremium ?? this.isPremium,
      attachments: attachments ?? this.attachments,
      customFields: customFields ?? this.customFields,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
      isAutomated: isAutomated ?? this.isAutomated,
      conditions: conditions ?? this.conditions,
      relatedRecommendations: relatedRecommendations ?? this.relatedRecommendations,
      successRate: successRate ?? this.successRate,
      implementationCount: implementationCount ?? this.implementationCount,
    );
  }

  bool canEdit(String userId) => createdBy == userId || !isPremium;
  bool get isNew => createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7)));
  bool get isHighPriority => priority >= 4;
  String get priorityLabel {
    if (priority >= 4) return 'High';
    if (priority >= 2) return 'Medium';
    return 'Low';
  }
}

enum RecommendationCategory {
  environment,
  diet,
  exercise,
  medical,
  behavioral,
  social,
  grooming,
  other
}

extension RecommendationCategoryExtension on RecommendationCategory {
  String get displayName {
    switch (this) {
      case RecommendationCategory.environment: return 'Environment';
      case RecommendationCategory.diet: return 'Diet & Nutrition';
      case RecommendationCategory.exercise: return 'Exercise & Activity';
      case RecommendationCategory.medical: return 'Medical Care';
      case RecommendationCategory.behavioral: return 'Behavioral';
      case RecommendationCategory.social: return 'Social & Mental';
      case RecommendationCategory.grooming: return 'Grooming';
      case RecommendationCategory.other: return 'Other';
    }
  }
}

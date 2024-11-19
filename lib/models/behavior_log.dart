import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BehaviorLog {
  final String id;
  final String petId;
  final String behavior;
  final String context;
  final DateTime date;
  final String? trigger;
  final String? resolution;
  final List<String> interventions;
  final bool wasSuccessful;
  final Duration? duration;
  final BehaviorIntensity intensity;
  final List<String> symptoms;
  final String? notes;
  final String? location;
  final String? createdBy;
  final DateTime createdAt;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final bool isPremium;
  final List<String>? tags;
  final BehaviorCategory category;
  final Map<String, dynamic>? environmentalFactors;
  final double? stressLevel;

  BehaviorLog({
    required this.id,
    required this.petId,
    required this.behavior,
    required this.context,
    required this.date,
    this.trigger,
    this.resolution,
    this.interventions = const [],
    this.wasSuccessful = false,
    this.duration,
    this.intensity = BehaviorIntensity.moderate,
    this.symptoms = const [],
    this.notes,
    this.location,
    this.createdBy,
    DateTime? createdAt,
    this.attachments,
    this.metadata,
    this.isPremium = false,
    this.tags,
    this.category = BehaviorCategory.other,
    this.environmentalFactors,
    this.stressLevel,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'behavior': behavior,
      'context': context,
      'date': date.toIso8601String(),
      'trigger': trigger,
      'resolution': resolution,
      'interventions': interventions,
      'wasSuccessful': wasSuccessful,
      'duration': duration?.inMinutes,
      'intensity': intensity.toString(),
      'symptoms': symptoms,
      'notes': notes,
      'location': location,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'attachments': attachments,
      'metadata': metadata,
      'isPremium': isPremium,
      'tags': tags,
      'category': category.toString(),
      'environmentalFactors': environmentalFactors,
      'stressLevel': stressLevel,
    };
  }

  factory BehaviorLog.fromJson(Map<String, dynamic> json) {
    return BehaviorLog(
      id: json['id'],
      petId: json['petId'],
      behavior: json['behavior'],
      context: json['context'],
      date: DateTime.parse(json['date']),
      trigger: json['trigger'],
      resolution: json['resolution'],
      interventions: List<String>.from(json['interventions'] ?? []),
      wasSuccessful: json['wasSuccessful'] ?? false,
      duration: json['duration'] != null 
          ? Duration(minutes: json['duration'])
          : null,
      intensity: BehaviorIntensity.values.firstWhere(
        (e) => e.toString() == json['intensity'],
        orElse: () => BehaviorIntensity.moderate,
      ),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      notes: json['notes'],
      location: json['location'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : null,
      metadata: json['metadata'],
      isPremium: json['isPremium'] ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      category: BehaviorCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => BehaviorCategory.other,
      ),
      environmentalFactors: json['environmentalFactors'],
      stressLevel: json['stressLevel']?.toDouble(),
    );
  }

  String? getFormattedDuration() {
    if (duration == null) return null;
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    }
    return '$minutes min';
  }

  bool canEdit(String userId) => createdBy == userId || !isPremium;
  bool get isRecent => date.isAfter(DateTime.now().subtract(const Duration(days: 7)));
}

enum BehaviorIntensity { mild, moderate, severe }

enum BehaviorCategory {
  anxiety,
  aggression,
  eating,
  elimination,
  social,
  grooming,
  vocalization,
  destructive,
  other
}

extension BehaviorCategoryExtension on BehaviorCategory {
  String get displayName {
    switch (this) {
      case BehaviorCategory.anxiety: return 'Anxiety/Stress';
      case BehaviorCategory.aggression: return 'Aggression';
      case BehaviorCategory.eating: return 'Eating/Drinking';
      case BehaviorCategory.elimination: return 'Elimination';
      case BehaviorCategory.social: return 'Social Behavior';
      case BehaviorCategory.grooming: return 'Grooming';
      case BehaviorCategory.vocalization: return 'Vocalization';
      case BehaviorCategory.destructive: return 'Destructive Behavior';
      case BehaviorCategory.other: return 'Other';
    }
  }
}

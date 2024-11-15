import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionGoal {
  final String id;
  final String petId;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime? targetDate;
  final Map<String, dynamic> targets;
  final bool isActive;
  final String? notes;
  final GoalStatus status;
  // Enhanced fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final Map<String, dynamic>? metadata;
  final List<String>? dietaryRestrictions;
  final Map<String, dynamic>? progress;
  final List<String>? recommendedFoods;
  final List<String>? restrictedFoods;
  final Map<String, dynamic>? nutritionalRequirements;
  final String? veterinaryNotes;
  final List<String>? healthConditions;
  final Map<String, dynamic>? mealPlan;
  final List<String>? supplements;
  final Map<String, dynamic>? weeklyProgress;

  NutritionGoal({
    required this.id,
    required this.petId,
    required this.name,
    required this.description,
    required this.startDate,
    this.targetDate,
    required this.targets,
    this.isActive = true,
    this.notes,
    this.status = GoalStatus.inProgress,
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.metadata,
    this.dietaryRestrictions,
    this.progress,
    this.recommendedFoods,
    this.restrictedFoods,
    this.nutritionalRequirements,
    this.veterinaryNotes,
    this.healthConditions,
    this.mealPlan,
    this.supplements,
    this.weeklyProgress,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'targets': targets,
      'isActive': isActive,
      'notes': notes,
      'status': status.toString(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'metadata': metadata,
      'dietaryRestrictions': dietaryRestrictions,
      'progress': progress,
      'recommendedFoods': recommendedFoods,
      'restrictedFoods': restrictedFoods,
      'nutritionalRequirements': nutritionalRequirements,
      'veterinaryNotes': veterinaryNotes,
      'healthConditions': healthConditions,
      'mealPlan': mealPlan,
      'supplements': supplements,
      'weeklyProgress': weeklyProgress,
    };
  }

  factory NutritionGoal.fromJson(Map<String, dynamic> json) {
    return NutritionGoal(
      id: json['id'],
      petId: json['petId'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      targetDate: json['targetDate'] != null 
          ? DateTime.parse(json['targetDate'])
          : null,
      targets: Map<String, dynamic>.from(json['targets']),
      isActive: json['isActive'] ?? true,
      notes: json['notes'],
      status: GoalStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => GoalStatus.inProgress,
      ),
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      metadata: json['metadata'],
      dietaryRestrictions: json['dietaryRestrictions'] != null 
          ? List<String>.from(json['dietaryRestrictions'])
          : null,
      progress: json['progress'],
      recommendedFoods: json['recommendedFoods'] != null 
          ? List<String>.from(json['recommendedFoods'])
          : null,
      restrictedFoods: json['restrictedFoods'] != null 
          ? List<String>.from(json['restrictedFoods'])
          : null,
      nutritionalRequirements: json['nutritionalRequirements'],
      veterinaryNotes: json['veterinaryNotes'],
      healthConditions: json['healthConditions'] != null 
          ? List<String>.from(json['healthConditions'])
          : null,
      mealPlan: json['mealPlan'],
      supplements: json['supplements'] != null 
          ? List<String>.from(json['supplements'])
          : null,
      weeklyProgress: json['weeklyProgress'],
    );
  }

  bool isExpired() => 
      targetDate != null && targetDate!.isBefore(DateTime.now());

  double getProgressPercentage() {
    if (progress == null) return 0.0;
    
    int achievedTargets = 0;
    targets.forEach((key, target) {
      final currentValue = progress![key];
      if (currentValue != null && target != null) {
        if (currentValue >= target) achievedTargets++;
      }
    });
    
    return (achievedTargets / targets.length) * 100;
  }

  bool hasRestriction(String restriction) => 
      dietaryRestrictions?.contains(restriction.toLowerCase()) ?? false;

  bool isRecommendedFood(String food) => 
      recommendedFoods?.contains(food) ?? false;

  bool isRestrictedFood(String food) => 
      restrictedFoods?.contains(food) ?? false;

  bool hasHealthCondition(String condition) => 
      healthConditions?.contains(condition) ?? false;

  bool canEdit(String userId) => createdBy == userId || !isPremium;

  bool get isRecent => 
      startDate.isAfter(DateTime.now().subtract(const Duration(days: 7)));

  Map<String, dynamic> getWeeklyProgressSummary() {
    if (weeklyProgress == null) return {};
    
    final summary = <String, dynamic>{
      'totalWeeks': weeklyProgress!.length,
      'latestProgress': weeklyProgress![weeklyProgress!.keys.last],
      'trend': _calculateProgressTrend(),
    };
    
    return summary;
  }

  String _calculateProgressTrend() {
    if (weeklyProgress == null || weeklyProgress!.length < 2) return 'stable';
    
    final weeks = weeklyProgress!.keys.toList()..sort();
    final lastWeek = weeklyProgress![weeks.last];
    final previousWeek = weeklyProgress![weeks[weeks.length - 2]];
    
    if (lastWeek > previousWeek) return 'improving';
    if (lastWeek < previousWeek) return 'declining';
    return 'stable';
  }

  bool requiresAttention() =>
      status == GoalStatus.behindSchedule || 
      (targetDate != null && 
       targetDate!.difference(DateTime.now()).inDays <= 7 && 
       getProgressPercentage() < 80);
}

enum GoalStatus {
  notStarted,
  inProgress,
  onTrack,
  behindSchedule,
  completed,
  abandoned
}

extension GoalStatusExtension on GoalStatus {
  String get displayName {
    switch (this) {
      case GoalStatus.notStarted: return 'Not Started';
      case GoalStatus.inProgress: return 'In Progress';
      case GoalStatus.onTrack: return 'On Track';
      case GoalStatus.behindSchedule: return 'Behind Schedule';
      case GoalStatus.completed: return 'Completed';
      case GoalStatus.abandoned: return 'Abandoned';
    }
  }

  bool get isActive => 
      this == GoalStatus.inProgress || 
      this == GoalStatus.onTrack || 
      this == GoalStatus.behindSchedule;
}

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeightLog {
  final String id;
  final String petId;
  final DateTime date;
  final double weight;
  final String unit;
  final String? notes;
  final bool isManualEntry;
  final String? measuredBy;
  // Enhanced fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? bodyCondition;
  final Map<String, dynamic>? dietInfo;
  final Map<String, dynamic>? exerciseInfo;
  final Map<String, dynamic>? healthMetrics;
  final String? veterinaryNotes;
  final Map<String, dynamic>? trends;
  final WeightStatus status;
  final Map<String, dynamic>? goals;
  final Map<String, dynamic>? measurements;

  WeightLog({
    required this.id,
    required this.petId,
    required this.date,
    required this.weight,
    required this.unit,
    this.notes,
    this.isManualEntry = true,
    this.measuredBy,
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.metadata,
    this.bodyCondition,
    this.dietInfo,
    this.exerciseInfo,
    this.healthMetrics,
    this.veterinaryNotes,
    this.trends,
    this.status = WeightStatus.normal,
    this.goals,
    this.measurements,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'date': date.toIso8601String(),
      'weight': weight,
      'unit': unit,
      'notes': notes,
      'isManualEntry': isManualEntry,
      'measuredBy': measuredBy,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'metadata': metadata,
      'bodyCondition': bodyCondition,
      'dietInfo': dietInfo,
      'exerciseInfo': exerciseInfo,
      'healthMetrics': healthMetrics,
      'veterinaryNotes': veterinaryNotes,
      'trends': trends,
      'status': status.toString(),
      'goals': goals,
      'measurements': measurements,
    };
  }

  factory WeightLog.fromJson(Map<String, dynamic> json) {
    return WeightLog(
      id: json['id'],
      petId: json['petId'],
      date: DateTime.parse(json['date']),
      weight: json['weight'].toDouble(),
      unit: json['unit'],
      notes: json['notes'],
      isManualEntry: json['isManualEntry'] ?? true,
      measuredBy: json['measuredBy'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      metadata: json['metadata'],
      bodyCondition: json['bodyCondition'],
      dietInfo: json['dietInfo'],
      exerciseInfo: json['exerciseInfo'],
      healthMetrics: json['healthMetrics'],
      veterinaryNotes: json['veterinaryNotes'],
      trends: json['trends'],
      status: WeightStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => WeightStatus.normal,
      ),
      goals: json['goals'],
      measurements: json['measurements'],
    );
  }

  double convertTo(String targetUnit) {
    if (unit == targetUnit) return weight;
    
    if (unit == 'kg' && targetUnit == 'lbs') {
      return weight * 2.20462;
    } else if (unit == 'lbs' && targetUnit == 'kg') {
      return weight / 2.20462;
    }
    
    return weight;
  }

  String getFormattedWeight() => 
      '${weight.toStringAsFixed(1)} $unit';

  bool canEdit(String userId) => 
      createdBy == userId || !isPremium;

  bool get isRecent => 
      date.isAfter(DateTime.now().subtract(const Duration(days: 7)));

  Map<String, dynamic> getBodyConditionScore() {
    if (bodyCondition == null) return {};
    
    return {
      'score': bodyCondition!['score'],
      'assessment': bodyCondition!['assessment'],
      'notes': bodyCondition!['notes'],
      'evaluatedBy': bodyCondition!['evaluatedBy'],
      'date': bodyCondition!['date'],
    };
  }

  Map<String, dynamic> getDietInformation() {
    if (dietInfo == null) return {};
    
    return {
      'type': dietInfo!['type'],
      'amount': dietInfo!['amount'],
      'frequency': dietInfo!['frequency'],
      'changes': dietInfo!['changes'],
      'restrictions': dietInfo!['restrictions'],
    };
  }

  Map<String, dynamic> getExerciseInformation() {
    if (exerciseInfo == null) return {};
    
    return {
      'type': exerciseInfo!['type'],
      'duration': exerciseInfo!['duration'],
      'intensity': exerciseInfo!['intensity'],
      'frequency': exerciseInfo!['frequency'],
      'notes': exerciseInfo!['notes'],
    };
  }

  Map<String, dynamic> getHealthMetrics() {
    if (healthMetrics == null) return {};
    
    return {
      'muscleCondition': healthMetrics!['muscleCondition'],
      'hydration': healthMetrics!['hydration'],
      'appetite': healthMetrics!['appetite'],
      'energy': healthMetrics!['energy'],
      'concerns': healthMetrics!['concerns'],
    };
  }

  Map<String, dynamic> getWeightTrends() {
    if (trends == null) return {};
    
    return {
      'change': trends!['change'],
      'percentageChange': trends!['percentageChange'],
      'trend': trends!['trend'],
      'averageChange': trends!['averageChange'],
      'comparisonPeriod': trends!['comparisonPeriod'],
    };
  }

  Map<String, dynamic> getWeightGoals() {
    if (goals == null) return {};
    
    return {
      'target': goals!['target'],
      'timeline': goals!['timeline'],
      'weeklyGoal': goals!['weeklyGoal'],
      'progress': goals!['progress'],
      'adjustments': goals!['adjustments'],
    };
  }

  Map<String, dynamic> getBodyMeasurements() {
    if (measurements == null) return {};
    
    return {
      'neck': measurements!['neck'],
      'chest': measurements!['chest'],
      'waist': measurements!['waist'],
      'length': measurements!['length'],
      'height': measurements!['height'],
    };
  }

  bool requiresAttention() {
    if (trends == null) return false;
    
    final change = trends!['percentageChange'] as double? ?? 0;
    return change.abs() >= 5.0 || status == WeightStatus.concerning;
  }

  String getWeightTrend() {
    if (trends == null) return 'stable';
    
    final change = trends!['percentageChange'] as double? ?? 0;
    if (change > 2) return 'increasing';
    if (change < -2) return 'decreasing';
    return 'stable';
  }

  double? calculateBMI() {
    if (measurements == null || 
        measurements!['height'] == null || 
        measurements!['height'] == 0) return null;
    
    final heightInMeters = unit == 'kg' 
        ? measurements!['height'] / 100
        : measurements!['height'] * 0.0254;
    
    final weightInKg = unit == 'kg' 
        ? weight 
        : weight / 2.20462;
    
    return weightInKg / (heightInMeters * heightInMeters);
  }
}

enum WeightStatus {
  underweight,
  normal,
  overweight,
  obese,
  concerning
}

extension WeightStatusExtension on WeightStatus {
  String get displayName {
    switch (this) {
      case WeightStatus.underweight: return 'Underweight';
      case WeightStatus.normal: return 'Normal';
      case WeightStatus.overweight: return 'Overweight';
      case WeightStatus.obese: return 'Obese';
      case WeightStatus.concerning: return 'Concerning';
    }
  }

  bool get requiresMonitoring =>
      this == WeightStatus.underweight || 
      this == WeightStatus.overweight || 
      this == WeightStatus.obese || 
      this == WeightStatus.concerning;

  String get recommendation {
    switch (this) {
      case WeightStatus.underweight:
        return 'Increase caloric intake and consult veterinarian';
      case WeightStatus.normal:
        return 'Maintain current diet and exercise routine';
      case WeightStatus.overweight:
        return 'Reduce caloric intake and increase exercise';
      case WeightStatus.obese:
        return 'Urgent veterinary consultation required';
      case WeightStatus.concerning:
        return 'Immediate veterinary attention recommended';
    }
  }
}

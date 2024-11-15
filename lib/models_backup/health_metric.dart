// lib/models/health_metric.dart

import 'package:flutter/foundation.dart';

class HealthMetric {
  final String id;
  final String petId;
  final String name;
  final dynamic value;
  final String unit;
  final DateTime recordedAt;
  final String? notes;
  final List<String> tags;
  final bool isAbnormal;
  final Map<String, dynamic>? referenceRange;
  // New premium features
  final String recordedBy;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final List<String> symptoms;
  final Map<String, dynamic>? trendAnalysis;
  final String? measurementMethod;
  final String? deviceUsed;
  final String? location;
  final Map<String, dynamic>? environmentalFactors;
  final List<String>? relatedMetrics;
  final Map<String, dynamic>? previousReadings;
  final String? actionTaken;
  final DateTime? nextCheckDue;
  final Map<String, dynamic>? alerts;
  final bool requiresFollowUp;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;

  HealthMetric({
    required this.id,
    required this.petId,
    required this.name,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.notes,
    this.tags = const [],
    this.isAbnormal = false,
    this.referenceRange,
    // New premium features
    required this.recordedBy,
    this.verifiedBy,
    this.verifiedAt,
    this.symptoms = const [],
    this.trendAnalysis,
    this.measurementMethod,
    this.deviceUsed,
    this.location,
    this.environmentalFactors,
    this.relatedMetrics,
    this.previousReadings,
    this.actionTaken,
    this.nextCheckDue,
    this.alerts,
    this.requiresFollowUp = false,
    this.attachments,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'value': value,
      'unit': unit,
      'recordedAt': recordedAt.toIso8601String(),
      'notes': notes,
      'tags': tags,
      'isAbnormal': isAbnormal,
      'referenceRange': referenceRange,
      // New premium features
      'recordedBy': recordedBy,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'symptoms': symptoms,
      'trendAnalysis': trendAnalysis,
      'measurementMethod': measurementMethod,
      'deviceUsed': deviceUsed,
      'location': location,
      'environmentalFactors': environmentalFactors,
      'relatedMetrics': relatedMetrics,
      'previousReadings': previousReadings,
      'actionTaken': actionTaken,
      'nextCheckDue': nextCheckDue?.toIso8601String(),
      'alerts': alerts,
      'requiresFollowUp': requiresFollowUp,
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      id: json['id'],
      petId: json['petId'],
      name: json['name'],
      value: json['value'],
      unit: json['unit'],
      recordedAt: DateTime.parse(json['recordedAt']),
      notes: json['notes'],
      tags: List<String>.from(json['tags'] ?? []),
      isAbnormal: json['isAbnormal'] ?? false,
      referenceRange: json['referenceRange'],
      // New premium features
      recordedBy: json['recordedBy'],
      verifiedBy: json['verifiedBy'],
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt']) 
          : null,
      symptoms: List<String>.from(json['symptoms'] ?? []),
      trendAnalysis: json['trendAnalysis'],
      measurementMethod: json['measurementMethod'],
      deviceUsed: json['deviceUsed'],
      location: json['location'],
      environmentalFactors: json['environmentalFactors'],
      relatedMetrics: json['relatedMetrics'] != null 
          ? List<String>.from(json['relatedMetrics']) 
          : null,
      previousReadings: json['previousReadings'],
      actionTaken: json['actionTaken'],
      nextCheckDue: json['nextCheckDue'] != null 
          ? DateTime.parse(json['nextCheckDue']) 
          : null,
      alerts: json['alerts'],
      requiresFollowUp: json['requiresFollowUp'] ?? false,
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments']) 
          : null,
      metadata: json['metadata'],
    );
  }

  // Enhanced helper methods
  bool isVerified() {
    return verifiedBy != null && verifiedAt != null;
  }

  bool needsRecheck() {
    return nextCheckDue != null && 
           DateTime.now().isAfter(nextCheckDue!);
  }

  bool hasAbnormalTrend() {
    return trendAnalysis?['isAbnormal'] ?? false;
  }

  double? getChangeRate() {
    if (previousReadings == null || 
        !previousReadings!.containsKey('values') || 
        previousReadings!['values'].isEmpty) {
      return null;
    }
    
    final values = List<double>.from(previousReadings!['values']);
    if (values.length < 2) return null;
    
    final latestValue = double.tryParse(value.toString());
    if (latestValue == null) return null;
    
    return (latestValue - values.last) / values.last * 100;
  }

  String getStatusDescription() {
    if (isAbnormal) {
      return 'Abnormal - Requires attention';
    } else if (requiresFollowUp) {
      return 'Normal - Follow-up required';
    } else if (isVerified()) {
      return 'Normal - Verified';
    }
    return 'Normal';
  }

  bool hasActiveAlerts() {
    return alerts != null && alerts!.isNotEmpty;
  }
}

// Existing enums and extensions remain the same...
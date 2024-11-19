import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PainRecord {
  final String id;
  final String petId;
  final DateTime date;
  final int painLevel;
  final String location;
  final List<String> symptoms;
  final String? notes;
  final List<String> triggers;
  final Duration? duration;
  final String? medication;
  final bool wasRelieved;
  // Enhanced fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? behavioralChanges;
  final List<String>? interventions;
  final Map<String, dynamic>? activityLimitations;
  final String? veterinaryConsult;
  final Map<String, dynamic>? environmentalFactors;
  final List<String>? associatedConditions;
  final Map<String, dynamic>? treatmentResponse;
  final PainType painType;
  final Map<String, dynamic>? mobilityImpact;

  PainRecord({
    required this.id,
    required this.petId,
    required this.date,
    required this.painLevel,
    required this.location,
    this.symptoms = const [],
    this.notes,
    this.triggers = const [],
    this.duration,
    this.medication,
    this.wasRelieved = false,
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.attachments,
    this.metadata,
    this.behavioralChanges,
    this.interventions,
    this.activityLimitations,
    this.veterinaryConsult,
    this.environmentalFactors,
    this.associatedConditions,
    this.treatmentResponse,
    this.painType = PainType.acute,
    this.mobilityImpact,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'date': date.toIso8601String(),
      'painLevel': painLevel,
      'location': location,
      'symptoms': symptoms,
      'notes': notes,
      'triggers': triggers,
      'duration': duration?.inMinutes,
      'medication': medication,
      'wasRelieved': wasRelieved,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'attachments': attachments,
      'metadata': metadata,
      'behavioralChanges': behavioralChanges,
      'interventions': interventions,
      'activityLimitations': activityLimitations,
      'veterinaryConsult': veterinaryConsult,
      'environmentalFactors': environmentalFactors,
      'associatedConditions': associatedConditions,
      'treatmentResponse': treatmentResponse,
      'painType': painType.toString(),
      'mobilityImpact': mobilityImpact,
    };
  }

  factory PainRecord.fromJson(Map<String, dynamic> json) {
    return PainRecord(
      id: json['id'],
      petId: json['petId'],
      date: DateTime.parse(json['date']),
      painLevel: json['painLevel'],
      location: json['location'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      notes: json['notes'],
      triggers: List<String>.from(json['triggers'] ?? []),
      duration: json['duration'] != null 
          ? Duration(minutes: json['duration'])
          : null,
      medication: json['medication'],
      wasRelieved: json['wasRelieved'] ?? false,
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : null,
      metadata: json['metadata'],
      behavioralChanges: json['behavioralChanges'],
      interventions: json['interventions'] != null 
          ? List<String>.from(json['interventions'])
          : null,
      activityLimitations: json['activityLimitations'],
      veterinaryConsult: json['veterinaryConsult'],
      environmentalFactors: json['environmentalFactors'],
      associatedConditions: json['associatedConditions'] != null 
          ? List<String>.from(json['associatedConditions'])
          : null,
      treatmentResponse: json['treatmentResponse'],
      painType: PainType.values.firstWhere(
        (e) => e.toString() == json['painType'],
        orElse: () => PainType.acute,
      ),
      mobilityImpact: json['mobilityImpact'],
    );
  }

  String getPainSeverity() {
    if (painLevel <= 3) return 'Mild';
    if (painLevel <= 6) return 'Moderate';
    return 'Severe';
  }

  String getDurationFormatted() {
    if (duration == null) return 'N/A';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    }
    return '$minutes min';
  }

  bool hasSymptom(String symptom) => 
      symptoms.contains(symptom.toLowerCase());

  bool hasTrigger(String trigger) => 
      triggers.contains(trigger.toLowerCase());

  bool hasIntervention(String intervention) => 
      interventions?.contains(intervention) ?? false;

  bool hasCondition(String condition) => 
      associatedConditions?.contains(condition) ?? false;

  bool canEdit(String userId) => createdBy == userId || !isPremium;

  bool get isRecent => 
      date.isAfter(DateTime.now().subtract(const Duration(days: 1)));

  Map<String, dynamic> getMobilityAssessment() {
    if (mobilityImpact == null) return {};
    
    return {
      'walking': mobilityImpact!['walking'] ?? 'normal',
      'standing': mobilityImpact!['standing'] ?? 'normal',
      'jumping': mobilityImpact!['jumping'] ?? 'normal',
      'climbing': mobilityImpact!['climbing'] ?? 'normal',
      'overall': mobilityImpact!['overall'] ?? 'normal',
    };
  }

  bool requiresVeterinaryAttention() =>
      painLevel >= 7 || 
      duration?.inHours ?? 0 > 24 || 
      !wasRelieved;

  Map<String, dynamic> getTreatmentEffectiveness() {
    if (treatmentResponse == null) return {};
    
    return {
      'medication': treatmentResponse!['medicationEffective'] ?? false,
      'interventions': treatmentResponse!['interventionsEffective'] ?? false,
      'timeToRelief': treatmentResponse!['timeToRelief'],
      'sideEffects': treatmentResponse!['sideEffects'] ?? [],
    };
  }
}

enum PainType {
  acute,
  chronic,
  intermittent,
  referred,
  neuropathic
}

extension PainTypeExtension on PainType {
  String get displayName {
    switch (this) {
      case PainType.acute: return 'Acute';
      case PainType.chronic: return 'Chronic';
      case PainType.intermittent: return 'Intermittent';
      case PainType.referred: return 'Referred';
      case PainType.neuropathic: return 'Neuropathic';
    }
  }

  String get description {
    switch (this) {
      case PainType.acute: 
        return 'Sudden onset, typically from injury or illness';
      case PainType.chronic: 
        return 'Persistent pain lasting more than 3 months';
      case PainType.intermittent: 
        return 'Pain that comes and goes';
      case PainType.referred: 
        return 'Pain felt in a location other than the source';
      case PainType.neuropathic: 
        return 'Pain caused by nerve damage or dysfunction';
    }
  }
}

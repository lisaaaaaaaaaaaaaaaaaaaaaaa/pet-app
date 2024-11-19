import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthMetrics {
  final String id;
  final String petId;
  final DateTime date;
  final Map<String, dynamic> vitals;
  final Map<String, dynamic> measurements;
  final List<String> symptoms;
  final Map<String, dynamic> bloodwork;
  final Map<String, dynamic> urinalysis;
  final String? notes;
  final String? recordedBy;
  final String? location;
  final HealthStatus status;
  // New fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? medications;
  final Map<String, dynamic>? treatments;
  final List<String>? abnormalities;
  final Map<String, dynamic>? diagnosticTests;
  final String? vetNotes;
  final DateTime? followUpDate;

  HealthMetrics({
    required this.id,
    required this.petId,
    required this.date,
    required this.vitals,
    this.measurements = const {},
    this.symptoms = const [],
    this.bloodwork = const {},
    this.urinalysis = const {},
    this.notes,
    this.recordedBy,
    this.location,
    this.status = HealthStatus.normal,
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.attachments,
    this.metadata,
    this.medications,
    this.treatments,
    this.abnormalities,
    this.diagnosticTests,
    this.vetNotes,
    this.followUpDate,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'date': date.toIso8601String(),
      'vitals': vitals,
      'measurements': measurements,
      'symptoms': symptoms,
      'bloodwork': bloodwork,
      'urinalysis': urinalysis,
      'notes': notes,
      'recordedBy': recordedBy,
      'location': location,
      'status': status.toString(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'attachments': attachments,
      'metadata': metadata,
      'medications': medications,
      'treatments': treatments,
      'abnormalities': abnormalities,
      'diagnosticTests': diagnosticTests,
      'vetNotes': vetNotes,
      'followUpDate': followUpDate?.toIso8601String(),
    };
  }

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      id: json['id'],
      petId: json['petId'],
      date: DateTime.parse(json['date']),
      vitals: Map<String, dynamic>.from(json['vitals']),
      measurements: Map<String, dynamic>.from(json['measurements'] ?? {}),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      bloodwork: Map<String, dynamic>.from(json['bloodwork'] ?? {}),
      urinalysis: Map<String, dynamic>.from(json['urinalysis'] ?? {}),
      notes: json['notes'],
      recordedBy: json['recordedBy'],
      location: json['location'],
      status: HealthStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => HealthStatus.normal,
      ),
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : null,
      metadata: json['metadata'],
      medications: json['medications'],
      treatments: json['treatments'],
      abnormalities: json['abnormalities'] != null 
          ? List<String>.from(json['abnormalities'])
          : null,
      diagnosticTests: json['diagnosticTests'],
      vetNotes: json['vetNotes'],
      followUpDate: json['followUpDate'] != null 
          ? DateTime.parse(json['followUpDate'])
          : null,
    );
  }

  double? getVital(String name) => vitals[name]?.toDouble();
  
  bool isVitalNormal(String name, Map<String, dynamic> normalRanges) {
    final value = getVital(name);
    if (value == null || !normalRanges.containsKey(name)) return true;
    
    final range = normalRanges[name];
    return value >= range['min'] && value <= range['max'];
  }

  List<String> getAbnormalVitals(Map<String, dynamic> normalRanges) {
    return vitals.keys
        .where((name) => !isVitalNormal(name, normalRanges))
        .toList();
  }

  bool hasSymptom(String symptom) => 
      symptoms.contains(symptom.toLowerCase());

  bool needsFollowUp() => 
      followUpDate != null && followUpDate!.isAfter(DateTime.now());

  bool canEdit(String userId) => 
      createdBy == userId || !isPremium;

  bool get isRecent => 
      date.isAfter(DateTime.now().subtract(const Duration(days: 7)));

  String getFormattedVital(String name) {
    final value = vitals[name];
    if (value == null) return 'N/A';
    
    switch (name.toLowerCase()) {
      case 'temperature':
        return '${value.toStringAsFixed(1)}°F';
      case 'weight':
        return '${value.toStringAsFixed(1)} lbs';
      case 'heartrate':
        return '${value.round()} bpm';
      case 'respiratory_rate':
        return '${value.round()} rpm';
      default:
        return value.toString();
    }
  }
}

enum HealthStatus {
  normal,
  attention,
  urgent,
  critical,
  recovering,
  unknown
}

extension HealthStatusExtension on HealthStatus {
  String get displayName {
    switch (this) {
      case HealthStatus.normal: return 'Normal';
      case HealthStatus.attention: return 'Needs Attention';
      case HealthStatus.urgent: return 'Urgent';
      case HealthStatus.critical: return 'Critical';
      case HealthStatus.recovering: return 'Recovering';
      case HealthStatus.unknown: return 'Unknown';
    }
  }

  bool get needsAttention => 
      this == HealthStatus.attention || 
      this == HealthStatus.urgent || 
      this == HealthStatus.critical;
}

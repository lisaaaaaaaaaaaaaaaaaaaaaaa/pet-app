import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecord {
  final String id;
  final String petId;
  final DateTime date;
  final String type;
  final String condition;
  final String treatment;
  final String? veterinarian;
  final String? clinic;
  final String notes;
  final List<String> medications;
  final List<String> vaccinations;
  final Map<String, dynamic> vitals;
  final List<String> symptoms;
  final String? diagnosis;
  final List<String>? attachments;
  final double? cost;
  final String? insuranceClaim;
  final bool isEmergency;
  final String? followUpInstructions;
  // New enhanced fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? labResults;
  final Map<String, dynamic>? procedures;
  final List<String>? prescriptions;
  final DateTime? followUpDate;
  final Map<String, dynamic>? diagnosticTests;
  final RecordStatus status;

  HealthRecord({
    required this.id,
    required this.petId,
    required this.date,
    required this.type,
    required this.condition,
    required this.treatment,
    this.veterinarian,
    this.clinic,
    this.notes = '',
    this.medications = const [],
    this.vaccinations = const [],
    this.vitals = const {},
    this.symptoms = const [],
    this.diagnosis,
    this.attachments,
    this.cost,
    this.insuranceClaim,
    this.isEmergency = false,
    this.followUpInstructions,
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.metadata,
    this.labResults,
    this.procedures,
    this.prescriptions,
    this.followUpDate,
    this.diagnosticTests,
    this.status = RecordStatus.completed,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'date': date.toIso8601String(),
      'type': type,
      'condition': condition,
      'treatment': treatment,
      'veterinarian': veterinarian,
      'clinic': clinic,
      'notes': notes,
      'medications': medications,
      'vaccinations': vaccinations,
      'vitals': vitals,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'attachments': attachments,
      'cost': cost,
      'insuranceClaim': insuranceClaim,
      'isEmergency': isEmergency,
      'followUpInstructions': followUpInstructions,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'metadata': metadata,
      'labResults': labResults,
      'procedures': procedures,
      'prescriptions': prescriptions,
      'followUpDate': followUpDate?.toIso8601String(),
      'diagnosticTests': diagnosticTests,
      'status': status.toString(),
    };
  }

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      petId: json['petId'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      condition: json['condition'],
      treatment: json['treatment'],
      veterinarian: json['veterinarian'],
      clinic: json['clinic'],
      notes: json['notes'] ?? '',
      medications: List<String>.from(json['medications'] ?? []),
      vaccinations: List<String>.from(json['vaccinations'] ?? []),
      vitals: Map<String, dynamic>.from(json['vitals'] ?? {}),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      diagnosis: json['diagnosis'],
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : null,
      cost: json['cost']?.toDouble(),
      insuranceClaim: json['insuranceClaim'],
      isEmergency: json['isEmergency'] ?? false,
      followUpInstructions: json['followUpInstructions'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      metadata: json['metadata'],
      labResults: json['labResults'],
      procedures: json['procedures'],
      prescriptions: json['prescriptions'] != null 
          ? List<String>.from(json['prescriptions'])
          : null,
      followUpDate: json['followUpDate'] != null 
          ? DateTime.parse(json['followUpDate'])
          : null,
      diagnosticTests: json['diagnosticTests'],
      status: RecordStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => RecordStatus.completed,
      ),
    );
  }

  bool needsFollowUp() => 
      followUpDate != null && followUpDate!.isAfter(DateTime.now());

  String getFormattedCost() => 
      cost != null ? '\$${cost!.toStringAsFixed(2)}' : 'N/A';

  bool hasSymptom(String symptom) => 
      symptoms.contains(symptom.toLowerCase());

  bool hasMedication(String medication) => 
      medications.contains(medication);

  bool hasVaccination(String vaccination) => 
      vaccinations.contains(vaccination);

  bool canEdit(String userId) => 
      createdBy == userId || !isPremium;

  bool get isRecent => 
      date.isAfter(DateTime.now().subtract(const Duration(days: 7)));

  bool get requiresAttention =>
      isEmergency || status == RecordStatus.pending || needsFollowUp();
}

enum RecordStatus {
  pending,
  inProgress,
  completed,
  cancelled,
  followUpRequired
}

extension RecordStatusExtension on RecordStatus {
  String get displayName {
    switch (this) {
      case RecordStatus.pending: return 'Pending';
      case RecordStatus.inProgress: return 'In Progress';
      case RecordStatus.completed: return 'Completed';
      case RecordStatus.cancelled: return 'Cancelled';
      case RecordStatus.followUpRequired: return 'Follow-up Required';
    }
  }
}

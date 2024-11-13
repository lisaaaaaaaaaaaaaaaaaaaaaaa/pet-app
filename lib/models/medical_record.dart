// lib/models/medical_record.dart

import 'package:flutter/foundation.dart';

class MedicalRecord {
  final String id;
  final String petId;
  final DateTime date;
  final String condition;
  final String treatment;
  final String veterinarian;
  final String clinic;
  final List<String> medications;
  final List<String> vaccinations;
  final List<String> labResults;
  final List<String> attachments;
  final double weight;
  final Map<String, dynamic> vitals;
  final String notes;
  final bool followUpRequired;
  final DateTime? followUpDate;
  // New premium features
  final String vetId;
  final String clinicId;
  final bool isEmergency;
  final String visitType;
  final List<String> symptoms;
  final Map<String, dynamic> diagnosis;
  final List<String> diagnosticTests;
  final Map<String, dynamic> testResults;
  final Map<String, dynamic> treatmentPlan;
  final List<String> prescriptions;
  final Map<String, dynamic> medicationSchedule;
  final double cost;
  final String? insuranceClaim;
  final Map<String, dynamic> insuranceDetails;
  final List<String> dietaryRestrictions;
  final List<String> activityRestrictions;
  final Map<String, dynamic> progressNotes;
  final List<String> complications;
  final bool requiresHospitalization;
  final Map<String, dynamic>? hospitalizationDetails;
  final List<String> referrals;
  final Map<String, dynamic> prognosis;
  final List<String> preventiveMeasures;
  final bool isSharedWithTeam;
  final List<String> careTeam;
  final Map<String, dynamic> chronicConditions;
  final List<String> allergies;
  final Map<String, dynamic> surgicalHistory;
  final Map<String, dynamic> anesthesiaDetails;
  final Map<String, dynamic> recoveryInstructions;
  final DateTime? nextAppointment;

  MedicalRecord({
    required this.id,
    required this.petId,
    required this.date,
    required this.condition,
    required this.treatment,
    required this.veterinarian,
    required this.clinic,
    this.medications = const [],
    this.vaccinations = const [],
    this.labResults = const [],
    this.attachments = const [],
    required this.weight,
    this.vitals = const {},
    this.notes = '',
    this.followUpRequired = false,
    this.followUpDate,
    // New premium features
    required this.vetId,
    required this.clinicId,
    this.isEmergency = false,
    required this.visitType,
    this.symptoms = const [],
    this.diagnosis = const {},
    this.diagnosticTests = const [],
    this.testResults = const {},
    this.treatmentPlan = const {},
    this.prescriptions = const [],
    this.medicationSchedule = const {},
    this.cost = 0.0,
    this.insuranceClaim,
    this.insuranceDetails = const {},
    this.dietaryRestrictions = const [],
    this.activityRestrictions = const [],
    this.progressNotes = const {},
    this.complications = const [],
    this.requiresHospitalization = false,
    this.hospitalizationDetails,
    this.referrals = const [],
    this.prognosis = const {},
    this.preventiveMeasures = const [],
    this.isSharedWithTeam = false,
    this.careTeam = const [],
    this.chronicConditions = const {},
    this.allergies = const [],
    this.surgicalHistory = const {},
    this.anesthesiaDetails = const {},
    this.recoveryInstructions = const {},
    this.nextAppointment,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'date': date.toIso8601String(),
      'condition': condition,
      'treatment': treatment,
      'veterinarian': veterinarian,
      'clinic': clinic,
      'medications': medications,
      'vaccinations': vaccinations,
      'labResults': labResults,
      'attachments': attachments,
      'weight': weight,
      'vitals': vitals,
      'notes': notes,
      'followUpRequired': followUpRequired,
      'followUpDate': followUpDate?.toIso8601String(),
      // New premium features
      'vetId': vetId,
      'clinicId': clinicId,
      'isEmergency': isEmergency,
      'visitType': visitType,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'diagnosticTests': diagnosticTests,
      'testResults': testResults,
      'treatmentPlan': treatmentPlan,
      'prescriptions': prescriptions,
      'medicationSchedule': medicationSchedule,
      'cost': cost,
      'insuranceClaim': insuranceClaim,
      'insuranceDetails': insuranceDetails,
      'dietaryRestrictions': dietaryRestrictions,
      'activityRestrictions': activityRestrictions,
      'progressNotes': progressNotes,
      'complications': complications,
      'requiresHospitalization': requiresHospitalization,
      'hospitalizationDetails': hospitalizationDetails,
      'referrals': referrals,
      'prognosis': prognosis,
      'preventiveMeasures': preventiveMeasures,
      'isSharedWithTeam': isSharedWithTeam,
      'careTeam': careTeam,
      'chronicConditions': chronicConditions,
      'allergies': allergies,
      'surgicalHistory': surgicalHistory,
      'anesthesiaDetails': anesthesiaDetails,
      'recoveryInstructions': recoveryInstructions,
      'nextAppointment': nextAppointment?.toIso8601String(),
    };
  }

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      petId: json['petId'],
      date: DateTime.parse(json['date']),
      condition: json['condition'],
      treatment: json['treatment'],
      veterinarian: json['veterinarian'],
      clinic: json['clinic'],
      medications: List<String>.from(json['medications'] ?? []),
      vaccinations: List<String>.from(json['vaccinations'] ?? []),
      labResults: List<String>.from(json['labResults'] ?? []),
      attachments: List<String>.from(json['attachments'] ?? []),
      weight: json['weight'].toDouble(),
      vitals: Map<String, dynamic>.from(json['vitals'] ?? {}),
      notes: json['notes'] ?? '',
      followUpRequired: json['followUpRequired'] ?? false,
      followUpDate: json['followUpDate'] != null 
          ? DateTime.parse(json['followUpDate']) 
          : null,
      // New premium features
      vetId: json['vetId'],
      clinicId: json['clinicId'],
      isEmergency: json['isEmergency'] ?? false,
      visitType: json['visitType'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      diagnosis: Map<String, dynamic>.from(json['diagnosis'] ?? {}),
      diagnosticTests: List<String>.from(json['diagnosticTests'] ?? []),
      testResults: Map<String, dynamic>.from(json['testResults'] ?? {}),
      treatmentPlan: Map<String, dynamic>.from(json['treatmentPlan'] ?? {}),
      prescriptions: List<String>.from(json['prescriptions'] ?? []),
      medicationSchedule: Map<String, dynamic>.from(json['medicationSchedule'] ?? {}),
      cost: json['cost']?.toDouble() ?? 0.0,
      insuranceClaim: json['insuranceClaim'],
      insuranceDetails: Map<String, dynamic>.from(json['insuranceDetails'] ?? {}),
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions'] ?? []),
      activityRestrictions: List<String>.from(json['activityRestrictions'] ?? []),
      progressNotes: Map<String, dynamic>.from(json['progressNotes'] ?? {}),
      complications: List<String>.from(json['complications'] ?? []),
      requiresHospitalization: json['requiresHospitalization'] ?? false,
      hospitalizationDetails: json['hospitalizationDetails'],
      referrals: List<String>.from(json['referrals'] ?? []),
      prognosis: Map<String, dynamic>.from(json['prognosis'] ?? {}),
      preventiveMeasures: List<String>.from(json['preventiveMeasures'] ?? []),
      isSharedWithTeam: json['isSharedWithTeam'] ?? false,
      careTeam: List<String>.from(json['careTeam'] ?? []),
      chronicConditions: Map<String, dynamic>.from(json['chronicConditions'] ?? {}),
      allergies: List<String>.from(json['allergies'] ?? []),
      surgicalHistory: Map<String, dynamic>.from(json['surgicalHistory'] ?? {}),
      anesthesiaDetails: Map<String, dynamic>.from(json['anesthesiaDetails'] ?? {}),
      recoveryInstructions: Map<String, dynamic>.from(json['recoveryInstructions'] ?? {}),
      nextAppointment: json['nextAppointment'] != null 
          ? DateTime.parse(json['nextAppointment']) 
          : null,
    );
  }

  // Helper methods
  bool needsFollowUp() {
    return followUpRequired && 
           followUpDate != null && 
           DateTime.now().isBefore(followUpDate!);
  }

  bool hasAbnormalResults() {
    return testResults.values.any((result) => 
        result['isAbnormal'] == true);
  }

  List<String> getActiveRestrictions() {
    return [...dietaryRestrictions, ...activityRestrictions];
  }

  String getFormattedCost() {
    return '\$${cost.toStringAsFixed(2)}';
  }

  bool hasComplications() {
    return complications.isNotEmpty;
  }

  bool isHospitalized() {
    return requiresHospitalization && 
           hospitalizationDetails != null &&
           hospitalizationDetails!['dischargeDate'] == null;
  }

  bool needsMedication() {
    return medications.isNotEmpty || prescriptions.isNotEmpty;
  }

  List<String> getUpcomingVaccinations() {
    final due = <String>[];
    vaccinations.forEach((vaccination) {
      final dueDate = DateTime.parse(vaccination['dueDate']);
      if (DateTime.now().isBefore(dueDate)) {
        due.add(vaccination['name']);
      }
    });
    return due;
  }
}

enum VisitType {
  routine,
  emergency,
  followUp,
  surgery,
  vaccination,
  dental,
  specialist,
  laboratory,
  imaging,
  other
}

enum MedicalRecordStatus {
  active,
  completed,
  cancelled,
  transferred,
  archived
}
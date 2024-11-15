import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Vaccination {
  final String id;
  final String petId;
  final String name;
  final DateTime dateAdministered;
  final DateTime? expirationDate;
  final String? serialNumber;
  final String manufacturer;
  final String veterinarianId;
  final String clinicId;
  final String? notes;
  final bool isRequired;
  final bool isBooster;
  // Enhanced fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final Map<String, dynamic>? metadata;
  final List<String>? attachments;
  final Map<String, dynamic>? reactions;
  final Map<String, dynamic>? effectiveness;
  final Map<String, dynamic>? schedule;
  final List<String>? reminders;
  final Map<String, dynamic>? batchInfo;
  final VaccinationStatus status;
  final Map<String, dynamic>? administrationDetails;
  final Map<String, dynamic>? compliance;
  final List<String>? contraindications;

  Vaccination({
    required this.id,
    required this.petId,
    required this.name,
    required this.dateAdministered,
    this.expirationDate,
    this.serialNumber,
    required this.manufacturer,
    required this.veterinarianId,
    required this.clinicId,
    this.notes,
    this.isRequired = false,
    this.isBooster = false,
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.metadata,
    this.attachments,
    this.reactions,
    this.effectiveness,
    this.schedule,
    this.reminders,
    this.batchInfo,
    this.status = VaccinationStatus.valid,
    this.administrationDetails,
    this.compliance,
    this.contraindications,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'dateAdministered': dateAdministered.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'serialNumber': serialNumber,
      'manufacturer': manufacturer,
      'veterinarianId': veterinarianId,
      'clinicId': clinicId,
      'notes': notes,
      'isRequired': isRequired,
      'isBooster': isBooster,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'metadata': metadata,
      'attachments': attachments,
      'reactions': reactions,
      'effectiveness': effectiveness,
      'schedule': schedule,
      'reminders': reminders,
      'batchInfo': batchInfo,
      'status': status.toString(),
      'administrationDetails': administrationDetails,
      'compliance': compliance,
      'contraindications': contraindications,
    };
  }

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'],
      petId: json['petId'],
      name: json['name'],
      dateAdministered: DateTime.parse(json['dateAdministered']),
      expirationDate: json['expirationDate'] != null 
          ? DateTime.parse(json['expirationDate'])
          : null,
      serialNumber: json['serialNumber'],
      manufacturer: json['manufacturer'],
      veterinarianId: json['veterinarianId'],
      clinicId: json['clinicId'],
      notes: json['notes'],
      isRequired: json['isRequired'] ?? false,
      isBooster: json['isBooster'] ?? false,
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      metadata: json['metadata'],
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : null,
      reactions: json['reactions'],
      effectiveness: json['effectiveness'],
      schedule: json['schedule'],
      reminders: json['reminders'] != null 
          ? List<String>.from(json['reminders'])
          : null,
      batchInfo: json['batchInfo'],
      status: VaccinationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => VaccinationStatus.valid,
      ),
      administrationDetails: json['administrationDetails'],
      compliance: json['compliance'],
      contraindications: json['contraindications'] != null 
          ? List<String>.from(json['contraindications'])
          : null,
    );
  }

  bool isExpired() => 
      expirationDate != null && expirationDate!.isBefore(DateTime.now());

  bool isExpiringSoon() {
    if (expirationDate == null) return false;
    final now = DateTime.now();
    return expirationDate!.isAfter(now) && 
           expirationDate!.isBefore(now.add(const Duration(days: 30)));
  }

  bool hasReaction(String reaction) => 
      reactions?['types']?.contains(reaction) ?? false;

  bool hasContraindication(String contraindication) => 
      contraindications?.contains(contraindication) ?? false;

  bool canEdit(String userId) => 
      createdBy == userId || !isPremium;

  bool get isValid => 
      status == VaccinationStatus.valid && !isExpired();

  Map<String, dynamic> getReactionDetails() {
    if (reactions == null) return {};
    
    return {
      'types': reactions!['types'] ?? [],
      'severity': reactions!['severity'],
      'onset': reactions!['onset'],
      'duration': reactions!['duration'],
      'treatment': reactions!['treatment'],
    };
  }

  Map<String, dynamic> getEffectivenessData() {
    if (effectiveness == null) return {};
    
    return {
      'level': effectiveness!['level'],
      'duration': effectiveness!['duration'],
      'boosterNeeded': effectiveness!['boosterNeeded'] ?? false,
      'nextBoosterDate': effectiveness!['nextBoosterDate'],
      'notes': effectiveness!['notes'],
    };
  }

  Map<String, dynamic> getScheduleDetails() {
    if (schedule == null) return {};
    
    return {
      'series': schedule!['series'],
      'doseNumber': schedule!['doseNumber'],
      'totalDoses': schedule!['totalDoses'],
      'interval': schedule!['interval'],
      'nextDueDate': schedule!['nextDueDate'],
    };
  }

  Map<String, dynamic> getBatchInformation() {
    if (batchInfo == null) return {};
    
    return {
      'number': batchInfo!['number'],
      'manufactureDate': batchInfo!['manufactureDate'],
      'expiryDate': batchInfo!['expiryDate'],
      'storageConditions': batchInfo!['storageConditions'],
      'quality': batchInfo!['quality'],
    };
  }

  Map<String, dynamic> getAdministrationDetails() {
    if (administrationDetails == null) return {};
    
    return {
      'route': administrationDetails!['route'],
      'site': administrationDetails!['site'],
      'dose': administrationDetails!['dose'],
      'administrator': administrationDetails!['administrator'],
      'technique': administrationDetails!['technique'],
    };
  }

  Map<String, dynamic> getComplianceInfo() {
    if (compliance == null) return {};
    
    return {
      'status': compliance!['status'],
      'requirements': compliance!['requirements'] ?? [],
      'validations': compliance!['validations'] ?? [],
      'exceptions': compliance!['exceptions'],
    };
  }

  bool requiresAttention() =>
      isExpiringSoon() || 
      status == VaccinationStatus.pending || 
      (isRequired && status != VaccinationStatus.valid);

  String getFormattedDate() => 
      '${dateAdministered.year}-${dateAdministered.month.toString().padLeft(2, '0')}-${dateAdministered.day.toString().padLeft(2, '0')}';

  bool isPartOfSeries() => 
      schedule != null && 
      schedule!['series'] != null && 
      schedule!['totalDoses'] != null && 
      schedule!['totalDoses'] > 1;

  DateTime? getNextDueDate() {
    if (schedule == null || schedule!['nextDueDate'] == null) return null;
    return DateTime.parse(schedule!['nextDueDate']);
  }
}

enum VaccinationStatus {
  valid,
  pending,
  expired,
  invalid,
  recalled,
  incomplete
}

extension VaccinationStatusExtension on VaccinationStatus {
  String get displayName {
    switch (this) {
      case VaccinationStatus.valid: return 'Valid';
      case VaccinationStatus.pending: return 'Pending';
      case VaccinationStatus.expired: return 'Expired';
      case VaccinationStatus.invalid: return 'Invalid';
      case VaccinationStatus.recalled: return 'Recalled';
      case VaccinationStatus.incomplete: return 'Incomplete';
    }
  }

  bool get requiresAction =>
      this == VaccinationStatus.pending || 
      this == VaccinationStatus.expired || 
      this == VaccinationStatus.recalled || 
      this == VaccinationStatus.incomplete;

  String get recommendation {
    switch (this) {
      case VaccinationStatus.valid:
        return 'No action needed';
      case VaccinationStatus.pending:
        return 'Schedule vaccination';
      case VaccinationStatus.expired:
        return 'Renewal required';
      case VaccinationStatus.invalid:
        return 'Consult veterinarian';
      case VaccinationStatus.recalled:
        return 'Immediate revaccination needed';
      case VaccinationStatus.incomplete:
        return 'Complete vaccination series';
    }
  }
}

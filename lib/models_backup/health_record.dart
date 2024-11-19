// lib/models/health_record.dart


class HealthRecord {
  final String id;
  final String petId;
  final DateTime date;
  final String type;
  final String description;
  final Map<String, dynamic> vitals;
  final List<String> attachments;
  final String vetName;
  final String diagnosis;
  final List<String> prescriptions;
  final List<String> treatments;
  final String notes;
  // New premium features
  final String vetId;  // Links to CareTeamMember
  final String clinicId;
  final String clinicName;
  final bool isEmergency;
  final Map<String, dynamic> labResults;
  final List<String> symptoms;
  final List<String> diagnosticTests;
  final Map<String, dynamic> vaccinations;
  final double cost;
  final String? insuranceClaim;
  final DateTime? followUpDate;
  final List<String> dietaryRestrictions;
  final List<String> activityRestrictions;
  final Map<String, dynamic> progressNotes;
  final List<String> complications;
  final bool requiresHospitalization;
  final Map<String, dynamic> hospitalizationDetails;
  final List<String> referrals;
  final Map<String, dynamic> prognosis;
  final List<String> preventiveMeasures;
  final bool isSharedWithTeam;

  HealthRecord({
    required this.id,
    required this.petId,
    required this.date,
    required this.type,
    required this.description,
    this.vitals = const {},
    this.attachments = const [],
    required this.vetName,
    required this.diagnosis,
    this.prescriptions = const [],
    this.treatments = const [],
    this.notes = '',
    // New premium features
    required this.vetId,
    required this.clinicId,
    required this.clinicName,
    this.isEmergency = false,
    this.labResults = const {},
    this.symptoms = const [],
    this.diagnosticTests = const [],
    this.vaccinations = const {},
    this.cost = 0.0,
    this.insuranceClaim,
    this.followUpDate,
    this.dietaryRestrictions = const [],
    this.activityRestrictions = const [],
    this.progressNotes = const {},
    this.complications = const [],
    this.requiresHospitalization = false,
    this.hospitalizationDetails = const {},
    this.referrals = const [],
    this.prognosis = const {},
    this.preventiveMeasures = const [],
    this.isSharedWithTeam = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'date': date.toIso8601String(),
      'type': type,
      'description': description,
      'vitals': vitals,
      'attachments': attachments,
      'vetName': vetName,
      'diagnosis': diagnosis,
      'prescriptions': prescriptions,
      'treatments': treatments,
      'notes': notes,
      // New premium features
      'vetId': vetId,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'isEmergency': isEmergency,
      'labResults': labResults,
      'symptoms': symptoms,
      'diagnosticTests': diagnosticTests,
      'vaccinations': vaccinations,
      'cost': cost,
      'insuranceClaim': insuranceClaim,
      'followUpDate': followUpDate?.toIso8601String(),
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
    };
  }

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      petId: json['petId'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      description: json['description'],
      vitals: Map<String, dynamic>.from(json['vitals'] ?? {}),
      attachments: List<String>.from(json['attachments'] ?? []),
      vetName: json['vetName'],
      diagnosis: json['diagnosis'],
      prescriptions: List<String>.from(json['prescriptions'] ?? []),
      treatments: List<String>.from(json['treatments'] ?? []),
      notes: json['notes'] ?? '',
      // New premium features
      vetId: json['vetId'],
      clinicId: json['clinicId'],
      clinicName: json['clinicName'],
      isEmergency: json['isEmergency'] ?? false,
      labResults: Map<String, dynamic>.from(json['labResults'] ?? {}),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      diagnosticTests: List<String>.from(json['diagnosticTests'] ?? []),
      vaccinations: Map<String, dynamic>.from(json['vaccinations'] ?? {}),
      cost: json['cost']?.toDouble() ?? 0.0,
      insuranceClaim: json['insuranceClaim'],
      followUpDate: json['followUpDate'] != null 
          ? DateTime.parse(json['followUpDate']) 
          : null,
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions'] ?? []),
      activityRestrictions: List<String>.from(json['activityRestrictions'] ?? []),
      progressNotes: Map<String, dynamic>.from(json['progressNotes'] ?? {}),
      complications: List<String>.from(json['complications'] ?? []),
      requiresHospitalization: json['requiresHospitalization'] ?? false,
      hospitalizationDetails: 
          Map<String, dynamic>.from(json['hospitalizationDetails'] ?? {}),
      referrals: List<String>.from(json['referrals'] ?? []),
      prognosis: Map<String, dynamic>.from(json['prognosis'] ?? {}),
      preventiveMeasures: List<String>.from(json['preventiveMeasures'] ?? []),
      isSharedWithTeam: json['isSharedWithTeam'] ?? false,
    );
  }

  // Helper methods
  bool needsFollowUp() {
    return followUpDate != null && 
           DateTime.now().isBefore(followUpDate!);
  }

  bool hasAbnormalLabResults() {
    return labResults.values.any((result) => 
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

  Map<String, dynamic> getVaccinationsDue() {
    final due = <String, dynamic>{};
    vaccinations.forEach((vaccine, details) {
      if (details['nextDue'] != null) {
        final nextDue = DateTime.parse(details['nextDue']);
        if (DateTime.now().isAfter(nextDue)) {
          due[vaccine] = details;
        }
      }
    });
    return due;
  }
}

enum HealthRecordType {
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

extension HealthRecordTypeExtension on HealthRecordType {
  String get displayName {
    switch (this) {
      case HealthRecordType.routine:
        return 'Routine Check-up';
      case HealthRecordType.emergency:
        return 'Emergency Visit';
      case HealthRecordType.followUp:
        return 'Follow-up Visit';
      case HealthRecordType.surgery:
        return 'Surgery';
      case HealthRecordType.vaccination:
        return 'Vaccination';
      case HealthRecordType.dental:
        return 'Dental Care';
      case HealthRecordType.specialist:
        return 'Specialist Visit';
      case HealthRecordType.laboratory:
        return 'Laboratory Tests';
      case HealthRecordType.imaging:
        return 'Imaging';
      case HealthRecordType.other:
        return 'Other';
    }
  }
}
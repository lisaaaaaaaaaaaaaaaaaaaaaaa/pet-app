// lib/models/pain_record.dart


class PainRecord {
  final String id;
  final String petId;
  final DateTime date;
  final int painLevel; // 1-10 scale
  final String location;
  final List<String> symptoms;
  final String description;
  final List<String> triggers;
  final List<String> reliefMethods;
  final bool affectsMobility;
  final bool affectsAppetite;
  final bool affectsSleep;
  final String notes;
  final List<String> medications;
  // New premium features
  final String recordedBy;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final Map<String, dynamic> painCharacteristics;
  final Map<String, dynamic> associatedConditions;
  final Map<String, int> activityLimitations;
  final Map<String, dynamic> behavioralChanges;
  final List<String> environmentalFactors;
  final Map<String, dynamic> treatmentResponses;
  final Map<String, dynamic> painPattern;
  final List<String> aggravatingFactors;
  final List<String> alleviatingFactors;
  final Map<String, dynamic> moodImpact;
  final Map<String, dynamic> socialImpact;
  final Map<String, dynamic> qualityOfLife;
  final List<String> images;
  final Map<String, dynamic> physicalExamFindings;
  final Map<String, dynamic> diagnosticResults;
  final List<String> recommendedInterventions;
  final Map<String, dynamic> painHistory;
  final bool requiresImmediateAttention;
  final Map<String, dynamic> vetConsultation;
  final List<String> preventiveMeasures;
  final Map<String, dynamic> recoveryProgress;
  final DateTime? nextAssessmentDate;

  PainRecord({
    required this.id,
    required this.petId,
    required this.date,
    required this.painLevel,
    required this.location,
    this.symptoms = const [],
    required this.description,
    this.triggers = const [],
    this.reliefMethods = const [],
    this.affectsMobility = false,
    this.affectsAppetite = false,
    this.affectsSleep = false,
    this.notes = '',
    this.medications = const [],
    // New premium features
    required this.recordedBy,
    this.verifiedBy,
    this.verifiedAt,
    this.painCharacteristics = const {},
    this.associatedConditions = const {},
    this.activityLimitations = const {},
    this.behavioralChanges = const {},
    this.environmentalFactors = const [],
    this.treatmentResponses = const {},
    this.painPattern = const {},
    this.aggravatingFactors = const [],
    this.alleviatingFactors = const [],
    this.moodImpact = const {},
    this.socialImpact = const {},
    this.qualityOfLife = const {},
    this.images = const [],
    this.physicalExamFindings = const {},
    this.diagnosticResults = const {},
    this.recommendedInterventions = const [],
    this.painHistory = const {},
    this.requiresImmediateAttention = false,
    this.vetConsultation = const {},
    this.preventiveMeasures = const [],
    this.recoveryProgress = const {},
    this.nextAssessmentDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'date': date.toIso8601String(),
      'painLevel': painLevel,
      'location': location,
      'symptoms': symptoms,
      'description': description,
      'triggers': triggers,
      'reliefMethods': reliefMethods,
      'affectsMobility': affectsMobility,
      'affectsAppetite': affectsAppetite,
      'affectsSleep': affectsSleep,
      'notes': notes,
      'medications': medications,
      // New premium features
      'recordedBy': recordedBy,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'painCharacteristics': painCharacteristics,
      'associatedConditions': associatedConditions,
      'activityLimitations': activityLimitations,
      'behavioralChanges': behavioralChanges,
      'environmentalFactors': environmentalFactors,
      'treatmentResponses': treatmentResponses,
      'painPattern': painPattern,
      'aggravatingFactors': aggravatingFactors,
      'alleviatingFactors': alleviatingFactors,
      'moodImpact': moodImpact,
      'socialImpact': socialImpact,
      'qualityOfLife': qualityOfLife,
      'images': images,
      'physicalExamFindings': physicalExamFindings,
      'diagnosticResults': diagnosticResults,
      'recommendedInterventions': recommendedInterventions,
      'painHistory': painHistory,
      'requiresImmediateAttention': requiresImmediateAttention,
      'vetConsultation': vetConsultation,
      'preventiveMeasures': preventiveMeasures,
      'recoveryProgress': recoveryProgress,
      'nextAssessmentDate': nextAssessmentDate?.toIso8601String(),
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
      description: json['description'],
      triggers: List<String>.from(json['triggers'] ?? []),
      reliefMethods: List<String>.from(json['reliefMethods'] ?? []),
      affectsMobility: json['affectsMobility'] ?? false,
      affectsAppetite: json['affectsAppetite'] ?? false,
      affectsSleep: json['affectsSleep'] ?? false,
      notes: json['notes'] ?? '',
      medications: List<String>.from(json['medications'] ?? []),
      // New premium features
      recordedBy: json['recordedBy'],
      verifiedBy: json['verifiedBy'],
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt']) 
          : null,
      painCharacteristics: 
          Map<String, dynamic>.from(json['painCharacteristics'] ?? {}),
      associatedConditions: 
          Map<String, dynamic>.from(json['associatedConditions'] ?? {}),
      activityLimitations: 
          Map<String, int>.from(json['activityLimitations'] ?? {}),
      behavioralChanges: 
          Map<String, dynamic>.from(json['behavioralChanges'] ?? {}),
      environmentalFactors: 
          List<String>.from(json['environmentalFactors'] ?? []),
      treatmentResponses: 
          Map<String, dynamic>.from(json['treatmentResponses'] ?? {}),
      painPattern: Map<String, dynamic>.from(json['painPattern'] ?? {}),
      aggravatingFactors: List<String>.from(json['aggravatingFactors'] ?? []),
      alleviatingFactors: List<String>.from(json['alleviatingFactors'] ?? []),
      moodImpact: Map<String, dynamic>.from(json['moodImpact'] ?? {}),
      socialImpact: Map<String, dynamic>.from(json['socialImpact'] ?? {}),
      qualityOfLife: Map<String, dynamic>.from(json['qualityOfLife'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      physicalExamFindings: 
          Map<String, dynamic>.from(json['physicalExamFindings'] ?? {}),
      diagnosticResults: 
          Map<String, dynamic>.from(json['diagnosticResults'] ?? {}),
      recommendedInterventions: 
          List<String>.from(json['recommendedInterventions'] ?? []),
      painHistory: Map<String, dynamic>.from(json['painHistory'] ?? {}),
      requiresImmediateAttention: 
          json['requiresImmediateAttention'] ?? false,
      vetConsultation: Map<String, dynamic>.from(json['vetConsultation'] ?? {}),
      preventiveMeasures: List<String>.from(json['preventiveMeasures'] ?? []),
      recoveryProgress: Map<String, dynamic>.from(json['recoveryProgress'] ?? {}),
      nextAssessmentDate: json['nextAssessmentDate'] != null 
          ? DateTime.parse(json['nextAssessmentDate']) 
          : null,
    );
  }

  // Helper methods
  bool isVerified() {
    return verifiedBy != null && verifiedAt != null;
  }

  bool isPainSevere() {
    return painLevel >= 7;
  }

  bool needsVetAttention() {
    return isPainSevere() || requiresImmediateAttention;
  }

  List<String> getSignificantImpacts() {
    final impacts = <String>[];
    if (affectsMobility) impacts.add('Mobility');
    if (affectsAppetite) impacts.add('Appetite');
    if (affectsSleep) impacts.add('Sleep');
    return impacts;
  }

  Map<String, dynamic> getTreatmentEffectiveness() {
    final effectiveness = <String, dynamic>{};
    for (var treatment in treatmentResponses.entries) {
      effectiveness[treatment.key] = {
        'effective': treatment.value['painReduction'] > 3,
        'reduction': treatment.value['painReduction'],
        'duration': treatment.value['duration'],
      };
    }
    return effectiveness;
  }

  bool hasImprovedOverTime() {
    if (painHistory.isEmpty) return false;
    final previousPain = painHistory.values.last['level'] as int;
    return painLevel < previousPain;
  }

  String getPainCategory() {
    if (painLevel <= 3) return 'Mild';
    if (painLevel <= 6) return 'Moderate';
    return 'Severe';
  }

  bool needsFollowUp() {
    return nextAssessmentDate != null && 
           DateTime.now().isBefore(nextAssessmentDate!);
  }
}

enum PainType {
  acute,
  chronic,
  intermittent,
  progressive
}

enum PainCharacteristic {
  sharp,
  dull,
  throbbing,
  burning,
  stabbing,
  aching,
  cramping,
  other
}
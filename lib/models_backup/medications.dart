// lib/models/medication.dart


class Medication {
  final String id;
  final String petId;
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String purpose;
  final String prescribedBy;
  final List<DateTime> scheduledTimes;
  final List<DateTime> takenTimes;
  final bool isActive;
  final String notes;
  final List<String> sideEffects;
  final bool requiresRefill;
  final DateTime? refillDate;
  // New premium features
  final String vetId;
  final String clinicId;
  final String prescriptionNumber;
  final String medicationType;
  final String manufacturer;
  final String batchNumber;
  final DateTime expiryDate;
  final double concentration;
  final String administrationRoute;
  final Map<String, dynamic> administrationInstructions;
  final List<String> precautions;
  final List<String> contraindications;
  final List<String> interactions;
  final Map<String, dynamic> storage;
  final double remainingQuantity;
  final String unit;
  final double dosagePerAdministration;
  final Map<String, dynamic> missedDoseInstructions;
  final bool requiresSpecialHandling;
  final Map<String, dynamic> handlingInstructions;
  final List<String> foodInteractions;
  final bool requiresFasting;
  final int fastingHours;
  final Map<String, dynamic> effectiveness;
  final List<String> adverseReactions;
  final bool isControlledSubstance;
  final int refillsRemaining;
  final double cost;
  final String? insuranceDetails;
  final List<String> alternatives;
  final Map<String, dynamic> complianceHistory;
  final bool requiresAuthorization;
  final String? authorizationStatus;

  Medication({
    required this.id,
    required this.petId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.purpose,
    required this.prescribedBy,
    required this.scheduledTimes,
    this.takenTimes = const [],
    this.isActive = true,
    this.notes = '',
    this.sideEffects = const [],
    this.requiresRefill = false,
    this.refillDate,
    // New premium features
    required this.vetId,
    required this.clinicId,
    required this.prescriptionNumber,
    required this.medicationType,
    required this.manufacturer,
    required this.batchNumber,
    required this.expiryDate,
    required this.concentration,
    required this.administrationRoute,
    this.administrationInstructions = const {},
    this.precautions = const [],
    this.contraindications = const [],
    this.interactions = const [],
    this.storage = const {},
    required this.remainingQuantity,
    required this.unit,
    required this.dosagePerAdministration,
    this.missedDoseInstructions = const {},
    this.requiresSpecialHandling = false,
    this.handlingInstructions = const {},
    this.foodInteractions = const [],
    this.requiresFasting = false,
    this.fastingHours = 0,
    this.effectiveness = const {},
    this.adverseReactions = const [],
    this.isControlledSubstance = false,
    this.refillsRemaining = 0,
    this.cost = 0.0,
    this.insuranceDetails,
    this.alternatives = const [],
    this.complianceHistory = const {},
    this.requiresAuthorization = false,
    this.authorizationStatus,
  });

  bool get isCompleted => endDate != null && DateTime.now().isAfter(endDate!);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'purpose': purpose,
      'prescribedBy': prescribedBy,
      'scheduledTimes': scheduledTimes.map((dt) => dt.toIso8601String()).toList(),
      'takenTimes': takenTimes.map((dt) => dt.toIso8601String()).toList(),
      'isActive': isActive,
      'notes': notes,
      'sideEffects': sideEffects,
      'requiresRefill': requiresRefill,
      'refillDate': refillDate?.toIso8601String(),
      // New premium features
      'vetId': vetId,
      'clinicId': clinicId,
      'prescriptionNumber': prescriptionNumber,
      'medicationType': medicationType,
      'manufacturer': manufacturer,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate.toIso8601String(),
      'concentration': concentration,
      'administrationRoute': administrationRoute,
      'administrationInstructions': administrationInstructions,
      'precautions': precautions,
      'contraindications': contraindications,
      'interactions': interactions,
      'storage': storage,
      'remainingQuantity': remainingQuantity,
      'unit': unit,
      'dosagePerAdministration': dosagePerAdministration,
      'missedDoseInstructions': missedDoseInstructions,
      'requiresSpecialHandling': requiresSpecialHandling,
      'handlingInstructions': handlingInstructions,
      'foodInteractions': foodInteractions,
      'requiresFasting': requiresFasting,
      'fastingHours': fastingHours,
      'effectiveness': effectiveness,
      'adverseReactions': adverseReactions,
      'isControlledSubstance': isControlledSubstance,
      'refillsRemaining': refillsRemaining,
      'cost': cost,
      'insuranceDetails': insuranceDetails,
      'alternatives': alternatives,
      'complianceHistory': complianceHistory,
      'requiresAuthorization': requiresAuthorization,
      'authorizationStatus': authorizationStatus,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      petId: json['petId'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      purpose: json['purpose'],
      prescribedBy: json['prescribedBy'],
      scheduledTimes: (json['scheduledTimes'] as List)
          .map((dt) => DateTime.parse(dt))
          .toList(),
      takenTimes: (json['takenTimes'] as List)
          .map((dt) => DateTime.parse(dt))
          .toList(),
      isActive: json['isActive'] ?? true,
      notes: json['notes'] ?? '',
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
      requiresRefill: json['requiresRefill'] ?? false,
      refillDate: json['refillDate'] != null 
          ? DateTime.parse(json['refillDate']) 
          : null,
      // New premium features
      vetId: json['vetId'],
      clinicId: json['clinicId'],
      prescriptionNumber: json['prescriptionNumber'],
      medicationType: json['medicationType'],
      manufacturer: json['manufacturer'],
      batchNumber: json['batchNumber'],
      expiryDate: DateTime.parse(json['expiryDate']),
      concentration: json['concentration'].toDouble(),
      administrationRoute: json['administrationRoute'],
      administrationInstructions: 
          Map<String, dynamic>.from(json['administrationInstructions'] ?? {}),
      precautions: List<String>.from(json['precautions'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      interactions: List<String>.from(json['interactions'] ?? []),
      storage: Map<String, dynamic>.from(json['storage'] ?? {}),
      remainingQuantity: json['remainingQuantity'].toDouble(),
      unit: json['unit'],
      dosagePerAdministration: json['dosagePerAdministration'].toDouble(),
      missedDoseInstructions: 
          Map<String, dynamic>.from(json['missedDoseInstructions'] ?? {}),
      requiresSpecialHandling: json['requiresSpecialHandling'] ?? false,
      handlingInstructions: 
          Map<String, dynamic>.from(json['handlingInstructions'] ?? {}),
      foodInteractions: List<String>.from(json['foodInteractions'] ?? []),
      requiresFasting: json['requiresFasting'] ?? false,
      fastingHours: json['fastingHours'] ?? 0,
      effectiveness: Map<String, dynamic>.from(json['effectiveness'] ?? {}),
      adverseReactions: List<String>.from(json['adverseReactions'] ?? []),
      isControlledSubstance: json['isControlledSubstance'] ?? false,
      refillsRemaining: json['refillsRemaining'] ?? 0,
      cost: json['cost']?.toDouble() ?? 0.0,
      insuranceDetails: json['insuranceDetails'],
      alternatives: List<String>.from(json['alternatives'] ?? []),
      complianceHistory: Map<String, dynamic>.from(json['complianceHistory'] ?? {}),
      requiresAuthorization: json['requiresAuthorization'] ?? false,
      authorizationStatus: json['authorizationStatus'],
    );
  }

  // Helper methods
  bool isExpired() {
    return DateTime.now().isAfter(expiryDate);
  }

  bool needsRefill() {
    return remainingQuantity <= dosagePerAdministration * 3; // 3 doses remaining
  }

  bool canRefill() {
    return refillsRemaining > 0;
  }

  double getComplianceRate() {
    if (scheduledTimes.isEmpty) return 1.0;
    return takenTimes.length / scheduledTimes.length;
  }

  bool hasDrugInteraction(List<String> otherMedications) {
    return interactions.any((interaction) => 
        otherMedications.contains(interaction));
  }

  bool requiresFastingNow() {
    if (!requiresFasting) return false;
    final nextDose = getNextScheduledDose();
    if (nextDose == null) return false;
    final fastingStart = nextDose.subtract(Duration(hours: fastingHours));
    return DateTime.now().isAfter(fastingStart) && 
           DateTime.now().isBefore(nextDose);
  }

  DateTime? getNextScheduledDose() {
    final now = DateTime.now();
    return scheduledTimes
        .firstWhere((time) => time.isAfter(now), 
                    orElse: () => DateTime(0));
  }

  bool hasAdverseReactions() {
    return adverseReactions.isNotEmpty;
  }

  String getFormattedCost() {
    return '\$${cost.toStringAsFixed(2)}';
  }

  bool isAuthorized() {
    return !requiresAuthorization || 
           authorizationStatus == 'approved';
  }
}

enum MedicationType {
  oral,
  topical,
  injectable,
  inhaled,
  drops,
  other
}

enum AdministrationRoute {
  oral,
  topical,
  subcutaneous,
  intramuscular,
  intravenous,
  inhaled,
  ophthalmic,
  otic,
  other
}
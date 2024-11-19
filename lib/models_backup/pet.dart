// lib/models/pet.dart


class Pet {
  // Basic Information
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final DateTime dateOfBirth;
  final double weight;
  final String gender;
  final String photoUrl;
  final PetStatus status;
  final List<String> sharedWith;
  
  // Detailed Information
  final Map<String, dynamic> breedInfo;
  final Map<String, dynamic> genetics;
  final Map<String, dynamic> microchipDetails;
  final Map<String, dynamic> reproductiveHistory;
  final Map<String, dynamic> insurance;
  
  // Health Information
  final List<Vaccination> vaccinations;
  final List<String> allergies;
  final List<Medication> medications;
  final String medicalNotes;
  final DateTime? lastVetVisit;
  final String vetName;
  final String vetPhone;
  final Map<String, dynamic> dentalCare;
  final Map<String, dynamic> preventiveCare;
  
  // Lifestyle Information
  final ActivityLevel activityLevel;
  final DietType dietType;
  final List<String> dietaryRestrictions;
  final double dailyFoodAmount;
  final int feedingsPerDay;
  final List<String> favoriteActivities;
  final List<String> favoriteTreats;
  final Map<String, dynamic> exerciseRoutine;
  final Map<String, dynamic> sleepPattern;
  final Map<String, dynamic> hydrationTracking;
  
  // Care Management
  final List<CareTask> careTasks;
  final List<Reminder> reminders;
  final Map<String, dynamic> groomingSchedule;
  final Map<String, dynamic> nutritionPlan;
  final Map<String, dynamic> seasonalCare;
  
  // Behavioral & Training
  final Map<String, dynamic> socialBehavior;
  final Map<String, dynamic> trainingProgress;
  final Map<String, dynamic> behavioralAssessments;
  final Map<String, dynamic> environmentalFactors;
  
  // Emergency Information
  final List<EmergencyContact> emergencyContacts;
  
  // Achievement & History
  final List<String> achievements;
  final Map<String, dynamic> competitions;
  final Map<String, dynamic> certifications;
  final List<String> travelHistory;
  
  // Premium Features
  final List<PainAssessment> painAssessments;
  final List<MobilityRecord> mobilityRecords;
  final WellnessScore? wellnessScore;
  final List<HealthMetric> healthMetrics;
  final List<BehaviorLog> behaviorLogs;
  final List<CareTeamMember> careTeam;
  final List<PetDocument> documents;
  
  // Business & Analytics
  final Map<String, dynamic> costTracking;
  final Map<String, dynamic> subscriptionDetails;

  Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.dateOfBirth,
    required this.weight,
    required this.gender,
    this.photoUrl = '',
    this.status = PetStatus.active,
    this.sharedWith = const [],
    this.breedInfo = const {},
    this.genetics = const {},
    this.microchipDetails = const {},
    this.reproductiveHistory = const {},
    this.insurance = const {},
    this.vaccinations = const [],
    this.allergies = const [],
    this.medications = const [],
    this.medicalNotes = '',
    this.lastVetVisit,
    this.vetName = '',
    this.vetPhone = '',
    this.dentalCare = const {},
    this.preventiveCare = const {},
    this.activityLevel = ActivityLevel.moderate,
    this.dietType = DietType.commercial,
    this.dietaryRestrictions = const [],
    this.dailyFoodAmount = 0.0,
    this.feedingsPerDay = 2,
    this.favoriteActivities = const [],
    this.favoriteTreats = const [],
    this.exerciseRoutine = const {},
    this.sleepPattern = const {},
    this.hydrationTracking = const {},
    this.careTasks = const [],
    this.reminders = const [],
    this.groomingSchedule = const {},
    this.nutritionPlan = const {},
    this.seasonalCare = const {},
    this.socialBehavior = const {},
    this.trainingProgress = const {},
    this.behavioralAssessments = const {},
    this.environmentalFactors = const {},
    this.emergencyContacts = const [],
    this.achievements = const [],
    this.competitions = const {},
    this.certifications = const {},
    this.travelHistory = const [],
    this.painAssessments = const [],
    this.mobilityRecords = const [],
    this.wellnessScore,
    this.healthMetrics = const [],
    this.behaviorLogs = const [],
    this.careTeam = const [],
    this.documents = const [],
    this.costTracking = const {},
    this.subscriptionDetails = const {},
  });
  // Continuing lib/models/pet.dart

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'weight': weight,
      'gender': gender,
      'photoUrl': photoUrl,
      'status': status.toString(),
      'sharedWith': sharedWith,
      'breedInfo': breedInfo,
      'genetics': genetics,
      'microchipDetails': microchipDetails,
      'reproductiveHistory': reproductiveHistory,
      'insurance': insurance,
      'vaccinations': vaccinations.map((v) => v.toJson()).toList(),
      'allergies': allergies,
      'medications': medications.map((m) => m.toJson()).toList(),
      'medicalNotes': medicalNotes,
      'lastVetVisit': lastVetVisit?.toIso8601String(),
      'vetName': vetName,
      'vetPhone': vetPhone,
      'dentalCare': dentalCare,
      'preventiveCare': preventiveCare,
      'activityLevel': activityLevel.toString(),
      'dietType': dietType.toString(),
      'dietaryRestrictions': dietaryRestrictions,
      'dailyFoodAmount': dailyFoodAmount,
      'feedingsPerDay': feedingsPerDay,
      'favoriteActivities': favoriteActivities,
      'favoriteTreats': favoriteTreats,
      'exerciseRoutine': exerciseRoutine,
      'sleepPattern': sleepPattern,
      'hydrationTracking': hydrationTracking,
      'careTasks': careTasks.map((t) => t.toJson()).toList(),
      'reminders': reminders.map((r) => r.toJson()).toList(),
      'groomingSchedule': groomingSchedule,
      'nutritionPlan': nutritionPlan,
      'seasonalCare': seasonalCare,
      'socialBehavior': socialBehavior,
      'trainingProgress': trainingProgress,
      'behavioralAssessments': behavioralAssessments,
      'environmentalFactors': environmentalFactors,
      'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
      'achievements': achievements,
      'competitions': competitions,
      'certifications': certifications,
      'travelHistory': travelHistory,
      'painAssessments': painAssessments.map((p) => p.toJson()).toList(),
      'mobilityRecords': mobilityRecords.map((m) => m.toJson()).toList(),
      'wellnessScore': wellnessScore?.toJson(),
      'healthMetrics': healthMetrics.map((h) => h.toJson()).toList(),
      'behaviorLogs': behaviorLogs.map((b) => b.toJson()).toList(),
      'careTeam': careTeam.map((c) => c.toJson()).toList(),
      'documents': documents.map((d) => d.toJson()).toList(),
      'costTracking': costTracking,
      'subscriptionDetails': subscriptionDetails,
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      ownerId: json['ownerId'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      weight: json['weight'].toDouble(),
      gender: json['gender'],
      photoUrl: json['photoUrl'] ?? '',
      status: PetStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PetStatus.active,
      ),
      sharedWith: List<String>.from(json['sharedWith'] ?? []),
      breedInfo: Map<String, dynamic>.from(json['breedInfo'] ?? {}),
      genetics: Map<String, dynamic>.from(json['genetics'] ?? {}),
      microchipDetails: Map<String, dynamic>.from(json['microchipDetails'] ?? {}),
      reproductiveHistory: Map<String, dynamic>.from(json['reproductiveHistory'] ?? {}),
      insurance: Map<String, dynamic>.from(json['insurance'] ?? {}),
      vaccinations: (json['vaccinations'] as List?)
          ?.map((v) => Vaccination.fromJson(v))
          .toList() ?? [],
      allergies: List<String>.from(json['allergies'] ?? []),
      medications: (json['medications'] as List?)
          ?.map((m) => Medication.fromJson(m))
          .toList() ?? [],
      medicalNotes: json['medicalNotes'] ?? '',
      lastVetVisit: json['lastVetVisit'] != null 
          ? DateTime.parse(json['lastVetVisit'])
          : null,
      vetName: json['vetName'] ?? '',
      vetPhone: json['vetPhone'] ?? '',
      dentalCare: Map<String, dynamic>.from(json['dentalCare'] ?? {}),
      preventiveCare: Map<String, dynamic>.from(json['preventiveCare'] ?? {}),
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.toString() == json['activityLevel'],
        orElse: () => ActivityLevel.moderate,
      ),
      dietType: DietType.values.firstWhere(
        (e) => e.toString() == json['dietType'],
        orElse: () => DietType.commercial,
      ),
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions'] ?? []),
      dailyFoodAmount: json['dailyFoodAmount']?.toDouble() ?? 0.0,
      feedingsPerDay: json['feedingsPerDay'] ?? 2,
      favoriteActivities: List<String>.from(json['favoriteActivities'] ?? []),
      favoriteTreats: List<String>.from(json['favoriteTreats'] ?? []),
      exerciseRoutine: Map<String, dynamic>.from(json['exerciseRoutine'] ?? {}),
      sleepPattern: Map<String, dynamic>.from(json['sleepPattern'] ?? {}),
      hydrationTracking: Map<String, dynamic>.from(json['hydrationTracking'] ?? {}),
      careTasks: (json['careTasks'] as List?)
          ?.map((t) => CareTask.fromJson(t))
          .toList() ?? [],
      reminders: (json['reminders'] as List?)
          ?.map((r) => Reminder.fromJson(r))
          .toList() ?? [],
      groomingSchedule: Map<String, dynamic>.from(json['groomingSchedule'] ?? {}),
      nutritionPlan: Map<String, dynamic>.from(json['nutritionPlan'] ?? {}),
      seasonalCare: Map<String, dynamic>.from(json['seasonalCare'] ?? {}),
      socialBehavior: Map<String, dynamic>.from(json['socialBehavior'] ?? {}),
      trainingProgress: Map<String, dynamic>.from(json['trainingProgress'] ?? {}),
      behavioralAssessments: Map<String, dynamic>.from(json['behavioralAssessments'] ?? {}),
      environmentalFactors: Map<String, dynamic>.from(json['environmentalFactors'] ?? {}),
      emergencyContacts: (json['emergencyContacts'] as List?)
          ?.map((e) => EmergencyContact.fromJson(e))
          .toList() ?? [],
      achievements: List<String>.from(json['achievements'] ?? []),
      competitions: Map<String, dynamic>.from(json['competitions'] ?? {}),
      certifications: Map<String, dynamic>.from(json['certifications'] ?? {}),
      travelHistory: List<String>.from(json['travelHistory'] ?? []),
      painAssessments: (json['painAssessments'] as List?)
          ?.map((p) => PainAssessment.fromJson(p))
          .toList() ?? [],
      mobilityRecords: (json['mobilityRecords'] as List?)
          ?.map((m) => MobilityRecord.fromJson(m))
          .toList() ?? [],
      wellnessScore: json['wellnessScore'] != null
          ? WellnessScore.fromJson(json['wellnessScore'])
          : null,
      healthMetrics: (json['healthMetrics'] as List?)
          ?.map((h) => HealthMetric.fromJson(h))
          .toList() ?? [],
      behaviorLogs: (json['behaviorLogs'] as List?)
          ?.map((b) => BehaviorLog.fromJson(b))
          .toList() ?? [],
      careTeam: (json['careTeam'] as List?)
          ?.map((c) => CareTeamMember.fromJson(c))
          .toList() ?? [],
      documents: (json['documents'] as List?)
          ?.map((d) => PetDocument.fromJson(d))
          .toList() ?? [],
      costTracking: Map<String, dynamic>.from(json['costTracking'] ?? {}),
      subscriptionDetails: Map<String, dynamic>.from(json['subscriptionDetails'] ?? {}),
    );
  }
  // Continuing lib/models/pet.dart

  // Age Calculations
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String getAgeDisplay() {
    final years = age;
    if (years == 0) {
      final months = DateTime.now().difference(dateOfBirth).inDays ~/ 30;
      return '$months months';
    }
    return '$years years';
  }

  // Health Management
  bool needsVaccination() {
    return vaccinations.any((vaccine) => 
      vaccine.nextDueDate != null && 
      DateTime.now().isAfter(vaccine.nextDueDate!));
  }

  List<Vaccination> getUpcomingVaccinations({int daysThreshold = 30}) {
    final now = DateTime.now();
    return vaccinations.where((vaccine) => 
      vaccine.nextDueDate != null &&
      vaccine.nextDueDate!.difference(now).inDays <= daysThreshold &&
      vaccine.nextDueDate!.isAfter(now)
    ).toList();
  }

  bool hasActiveMedications() {
    return medications.any((med) => 
      med.endDate == null || 
      DateTime.now().isBefore(med.endDate!));
  }

  List<Medication> getActiveMedications() {
    final now = DateTime.now();
    return medications.where((med) => 
      med.endDate == null || now.isBefore(med.endDate!)).toList();
  }

  // Task Management
  List<CareTask> getOverdueTasks() {
    return careTasks.where((task) => 
      !task.isCompleted && 
      DateTime.now().isAfter(task.dueDate)).toList();
  }

  List<CareTask> getUpcomingTasks({int daysThreshold = 7}) {
    final now = DateTime.now();
    return careTasks.where((task) => 
      !task.isCompleted &&
      task.dueDate.difference(now).inDays <= daysThreshold &&
      task.dueDate.isAfter(now)
    ).toList();
  }

  // Care Compliance
  double calculateComplianceScore() {
    int totalTasks = 0;
    int completedTasks = 0;

    // Medication compliance
    for (var med in medications) {
      if (med.administeredDates.isNotEmpty) {
        totalTasks++;
        if (med.endDate == null || DateTime.now().isBefore(med.endDate!)) {
          completedTasks++;
        }
      }
    }

    // Task compliance
    totalTasks += careTasks.length;
    completedTasks += careTasks.where((task) => task.isCompleted).length;

    // Vaccination compliance
    for (var vaccine in vaccinations) {
      totalTasks++;
      if (vaccine.nextDueDate == null || 
          DateTime.now().isBefore(vaccine.nextDueDate!)) {
        completedTasks++;
      }
    }

    return totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 100;
  }

  // Health Summary
  Map<String, dynamic> getHealthSummary() {
    return {
      'vaccinations': {
        'total': vaccinations.length,
        'upToDate': vaccinations.where((v) => 
          v.nextDueDate == null || 
          DateTime.now().isBefore(v.nextDueDate!)).length,
      },
      'medications': {
        'active': getActiveMedications().length,
        'total': medications.length,
      },
      'allergies': allergies.length,
      'conditions': medicalNotes,
      'lastVetVisit': lastVetVisit?.toIso8601String(),
      'weight': weight,
      'painLevel': painAssessments.isNotEmpty 
          ? painAssessments.last.painLevel 
          : null,
      'mobilityScore': mobilityRecords.isNotEmpty 
          ? mobilityRecords.last.mobilityScore 
          : null,
      'wellnessScore': wellnessScore?.score,
    };
  }

  // Insurance Management
  bool isInsuranceValid() {
    if (insurance.isEmpty || insurance['expiryDate'] == null) return false;
    final expiryDate = DateTime.parse(insurance['expiryDate']);
    return DateTime.now().isBefore(expiryDate);
  }

  // Appointment Management
  List<Map<String, dynamic>> getUpcomingAppointments() {
    final appointments = <Map<String, dynamic>>[];
    
    // Add vet appointments from reminders
    appointments.addAll(
      reminders.where((r) => 
        r.type == ReminderType.veterinary && 
        !r.isCompleted &&
        r.dateTime.isAfter(DateTime.now())
      ).map((r) => {
        'type': 'Veterinary',
        'date': r.dateTime,
        'title': r.title,
        'notes': r.notes,
      })
    );

    // Add grooming appointments
    if (groomingSchedule.containsKey('nextAppointment')) {
      final nextGrooming = DateTime.parse(groomingSchedule['nextAppointment']);
      if (nextGrooming.isAfter(DateTime.now())) {
        appointments.add({
          'type': 'Grooming',
          'date': nextGrooming,
          'title': 'Grooming Appointment',
          'notes': groomingSchedule['notes'],
        });
      }
    }

    appointments.sort((a, b) => 
      (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    return appointments;
  }

  // Cost Analysis
  Map<String, dynamic> getAnnualCostAnalysis() {
    if (costTracking.isEmpty) return {};

    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final costs = {
      'veterinary': 0.0,
      'medications': 0.0,
      'food': 0.0,
      'grooming': 0.0,
      'insurance': 0.0,
      'supplies': 0.0,
      'other': 0.0,
    };

    for (var entry in costTracking.entries) {
      final date = DateTime.parse(entry['date']);
      if (date.isAfter(yearStart)) {
        costs[entry['category']] += entry['amount'];
      }
    }

    costs['total'] = costs.values.reduce((a, b) => a + b);
    return costs;
  }

  // Grooming Management
  bool needsGrooming() {
    if (groomingSchedule.isEmpty || 
        !groomingSchedule.containsKey('lastGrooming')) return false;
    
    final lastGrooming = DateTime.parse(groomingSchedule['lastGrooming']);
    final frequency = groomingSchedule['frequency'] ?? 30; // days
    return DateTime.now().difference(lastGrooming).inDays >= frequency;
  }

  // Care Team Management
  List<CareTeamMember> getActiveCaretakers() {
    return careTeam.where((member) => 
      member.isActive && 
      member.id != ownerId).toList();
  }

  // Special Needs Assessment
  bool hasSpecialNeeds() {
    return allergies.isNotEmpty || 
           medicalNotes.isNotEmpty || 
           dietaryRestrictions.isNotEmpty ||
           medications.isNotEmpty;
  }
  // Continuing lib/models/pet.dart

// Enums
enum PetStatus {
  active,
  deceased,
  rehomed,
  lost,
  fostered,
  boarding,
  temporary
}

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive,
  athletic
}

enum DietType {
  commercial,
  homemade,
  raw,
  prescription,
  mixed,
  special
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
  critical
}

enum ReminderType {
  medication,
  vaccination,
  grooming,
  veterinary,
  feeding,
  exercise,
  training,
  socialization,
  general,
  custom
}

enum RecurrenceInterval {
  once,
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly,
  custom
}

enum DocumentType {
  medicalRecord,
  vaccination,
  prescription,
  insurance,
  registration,
  behavior,
  training,
  grooming,
  nutrition,
  other
}

enum AccessLevel {
  viewer,
  caregiver,
  manager,
  owner,
  veterinarian,
  administrator
}

enum MetricType {
  weight,
  temperature,
  bloodPressure,
  heartRate,
  respiratoryRate,
  bloodSugar,
  hydration,
  painLevel,
  mobility,
  appetite,
  energy,
  mood,
  other
}

// Extension Methods
extension PetStatusExtension on PetStatus {
  String get displayName {
    switch (this) {
      case PetStatus.active:
        return 'Active';
      case PetStatus.deceased:
        return 'Deceased';
      case PetStatus.rehomed:
        return 'Rehomed';
      case PetStatus.lost:
        return 'Lost';
      case PetStatus.fostered:
        return 'Fostered';
      case PetStatus.boarding:
        return 'Boarding';
      case PetStatus.temporary:
        return 'Temporary';
    }
  }

  String get icon {
    switch (this) {
      case PetStatus.active:
        return '🐾';
      case PetStatus.deceased:
        return '🌈';
      case PetStatus.rehomed:
        return '🏠';
      case PetStatus.lost:
        return '❓';
      case PetStatus.fostered:
        return '💝';
      case PetStatus.boarding:
        return '🏨';
      case PetStatus.temporary:
        return '⏳';
    }
  }
}

extension ActivityLevelExtension on ActivityLevel {
  String get displayName {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.light:
        return 'Light';
      case ActivityLevel.moderate:
        return 'Moderate';
      case ActivityLevel.active:
        return 'Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.athletic:
        return 'Athletic';
    }
  }

  int get recommendedExerciseMinutes {
    switch (this) {
      case ActivityLevel.sedentary:
        return 15;
      case ActivityLevel.light:
        return 30;
      case ActivityLevel.moderate:
        return 45;
      case ActivityLevel.active:
        return 60;
      case ActivityLevel.veryActive:
        return 90;
      case ActivityLevel.athletic:
        return 120;
    }
  }
}

// Utility Classes
class PetAnalytics {
  static double calculateHealthIndex(Pet pet) {
    double score = 100;
    
    // Deduct points for overdue vaccinations
    if (pet.needsVaccination()) {
      score -= 10;
    }

    // Deduct points for overdue tasks
    final overdueTasks = pet.getOverdueTasks();
    score -= overdueTasks.length * 5;

    // Add points for good compliance
    final complianceScore = pet.calculateComplianceScore();
    score += (complianceScore - 50) / 10;

    // Consider wellness score if available
    if (pet.wellnessScore != null) {
      score = (score + pet.wellnessScore!.score) / 2;
    }

    return score.clamp(0, 100);
  }

  static Map<String, dynamic> generateMonthlyReport(Pet pet) {
    return {
      'healthIndex': calculateHealthIndex(pet),
      'compliance': pet.calculateComplianceScore(),
      'costs': pet.getAnnualCostAnalysis(),
      'appointments': pet.getUpcomingAppointments(),
      'medications': pet.getActiveMedications().length,
      'tasks': {
        'completed': pet.careTasks.where((task) => task.isCompleted).length,
        'pending': pet.careTasks.where((task) => !task.isCompleted).length,
        'overdue': pet.getOverdueTasks().length,
      },
      'wellness': pet.wellnessScore?.score,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }
}

class PetNotificationService {
  static List<Map<String, dynamic>> getNotifications(Pet pet) {
    final notifications = <Map<String, dynamic>>[];

    // Check vaccinations
    if (pet.needsVaccination()) {
      notifications.add({
        'type': 'vaccination',
        'priority': 'high',
        'message': 'Vaccination due',
        'data': pet.getUpcomingVaccinations(),
      });
    }

    // Check medications
    final activeMeds = pet.getActiveMedications();
    if (activeMeds.isNotEmpty) {
      notifications.add({
        'type': 'medication',
        'priority': 'high',
        'message': 'Active medications',
        'data': activeMeds,
      });
    }

    // Check tasks
    final overdueTasks = pet.getOverdueTasks();
    if (overdueTasks.isNotEmpty) {
      notifications.add({
        'type': 'tasks',
        'priority': 'medium',
        'message': 'Overdue tasks',
        'data': overdueTasks,
      });
    }

    // Check grooming
    if (pet.needsGrooming()) {
      notifications.add({
        'type': 'grooming',
        'priority': 'low',
        'message': 'Grooming needed',
        'data': pet.groomingSchedule,
      });
    }

    return notifications;
  }
}
// Continuing lib/models/pet.dart

class PetHealthTracker {
  static Map<String, dynamic> calculateHealthTrends(Pet pet, {int days = 30}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    // Weight tracking
    final weightTrend = pet.healthMetrics
        .where((metric) => 
          metric.name == 'weight' && 
          metric.recordedAt.isAfter(startDate))
        .map((metric) => {
          'date': metric.recordedAt.toIso8601String(),
          'value': metric.value,
        })
        .toList();

    // Pain levels
    final painTrend = pet.painAssessments
        .where((assessment) => assessment.date.isAfter(startDate))
        .map((assessment) => {
          'date': assessment.date.toIso8601String(),
          'value': assessment.painLevel,
        })
        .toList();

    // Mobility scores
    final mobilityTrend = pet.mobilityRecords
        .where((record) => record.date.isAfter(startDate))
        .map((record) => {
          'date': record.date.toIso8601String(),
          'value': record.mobilityScore,
        })
        .toList();

    return {
      'weight': weightTrend,
      'pain': painTrend,
      'mobility': mobilityTrend,
      'startDate': startDate.toIso8601String(),
      'endDate': now.toIso8601String(),
    };
  }

  static Map<String, dynamic> generateHealthReport(Pet pet) {
    return {
      'basicInfo': {
        'age': pet.age,
        'weight': pet.weight,
        'activityLevel': pet.activityLevel.displayName,
      },
      'healthMetrics': {
        'currentMetrics': pet.healthMetrics.isNotEmpty 
            ? pet.healthMetrics.last.toJson() 
            : null,
        'trends': calculateHealthTrends(pet),
      },
      'medicalStatus': {
        'activeConditions': pet.medicalNotes,
        'allergies': pet.allergies,
        'activeMedications': pet.getActiveMedications()
            .map((med) => med.toJson()).toList(),
        'recentVaccinations': pet.vaccinations
            .where((v) => v.date.isAfter(
              DateTime.now().subtract(const Duration(days: 90))))
            .map((v) => v.toJson()).toList(),
      },
      'wellnessIndicators': {
        'painLevel': pet.painAssessments.isNotEmpty 
            ? pet.painAssessments.last.toJson() 
            : null,
        'mobilityScore': pet.mobilityRecords.isNotEmpty 
            ? pet.mobilityRecords.last.toJson() 
            : null,
        'wellnessScore': pet.wellnessScore?.toJson(),
      },
      'careCompliance': {
        'score': pet.calculateComplianceScore(),
        'overdueTasks': pet.getOverdueTasks()
            .map((task) => task.toJson()).toList(),
        'upcomingTasks': pet.getUpcomingTasks()
            .map((task) => task.toJson()).toList(),
      },
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}

class PetCareScheduler {
  static List<Map<String, dynamic>> generateCareSchedule(Pet pet) {
    final schedule = <Map<String, dynamic>>[];
    final now = DateTime.now();

    // Add medication schedules
    for (var med in pet.getActiveMedications()) {
      schedule.add({
        'type': 'Medication',
        'title': '${med.name} - ${med.dosage}',
        'frequency': med.frequency,
        'startDate': med.startDate.toIso8601String(),
        'endDate': med.endDate?.toIso8601String(),
        'notes': med.notes,
        'priority': 'high',
      });
    }

    // Add upcoming vaccinations
    for (var vaccine in pet.getUpcomingVaccinations()) {
      schedule.add({
        'type': 'Vaccination',
        'title': vaccine.name,
        'dueDate': vaccine.nextDueDate?.toIso8601String(),
        'veterinarian': vaccine.veterinarian,
        'notes': vaccine.notes,
        'priority': 'high',
      });
    }

    // Add grooming schedule
    if (pet.groomingSchedule.isNotEmpty) {
      schedule.add({
        'type': 'Grooming',
        'title': 'Regular Grooming',
        'frequency': pet.groomingSchedule['frequency'],
        'lastGrooming': pet.groomingSchedule['lastGrooming'],
        'nextDue': pet.groomingSchedule['nextAppointment'],
        'notes': pet.groomingSchedule['notes'],
        'priority': 'medium',
      });
    }

    // Add exercise routine
    if (pet.exerciseRoutine.isNotEmpty) {
      schedule.add({
        'type': 'Exercise',
        'title': 'Daily Exercise',
        'duration': pet.activityLevel.recommendedExerciseMinutes,
        'activities': pet.favoriteActivities,
        'notes': pet.exerciseRoutine['notes'],
        'priority': 'medium',
      });
    }

    // Add feeding schedule
    schedule.add({
      'type': 'Feeding',
      'title': 'Daily Feeding',
      'frequency': pet.feedingsPerDay,
      'amount': pet.dailyFoodAmount,
      'dietType': pet.dietType.toString(),
      'restrictions': pet.dietaryRestrictions,
      'priority': 'high',
    });

    return schedule;
  }

  static Map<String, dynamic> generateReminders(Pet pet) {
    final now = DateTime.now();
    final reminders = <String, List<Map<String, dynamic>>>{
      'today': [],
      'tomorrow': [],
      'thisWeek': [],
      'upcoming': [],
    };

    // Process all care tasks and reminders
    final allTasks = [
      ...pet.careTasks.map((task) => {
        'type': 'Task',
        'data': task.toJson(),
        'dueDate': task.dueDate,
      }),
      ...pet.reminders.map((reminder) => {
        'type': 'Reminder',
        'data': reminder.toJson(),
        'dueDate': reminder.dateTime,
      }),
    ];

    for (var item in allTasks) {
      final dueDate = item['dueDate'] as DateTime;
      final difference = dueDate.difference(now).inDays;

      if (difference == 0) {
        reminders['today']!.add(item);
      } else if (difference == 1) {
        reminders['tomorrow']!.add(item);
      } else if (difference <= 7) {
        reminders['thisWeek']!.add(item);
      } else {
        reminders['upcoming']!.add(item);
      }
    }

    return reminders;
  }
}
// Continuing lib/models/pet.dart

class PetBehaviorAnalytics {
  static Map<String, dynamic> analyzeBehaviorTrends(Pet pet, {int days = 30}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    // Filter behavior logs within the time range
    final recentLogs = pet.behaviorLogs
        .where((log) => log.date.isAfter(startDate))
        .toList();

    // Analyze behavior patterns
    final behaviorFrequency = <String, int>{};
    final successRates = <String, double>{};
    final triggerAnalysis = <String, int>{};

    for (var log in recentLogs) {
      // Count behavior frequencies
      behaviorFrequency[log.behavior] = 
          (behaviorFrequency[log.behavior] ?? 0) + 1;

      // Calculate success rates
      if (successRates[log.behavior] == null) {
        successRates[log.behavior] = 0;
      }
      if (log.wasSuccessful) {
        successRates[log.behavior] = 
            (successRates[log.behavior]! + 1);
      }

      // Analyze triggers
      if (log.trigger != null) {
        triggerAnalysis[log.trigger!] = 
            (triggerAnalysis[log.trigger!] ?? 0) + 1;
      }
    }

    // Calculate final success rates
    successRates.forEach((behavior, successes) {
      successRates[behavior] = 
          (successes / behaviorFrequency[behavior]!) * 100;
    });

    return {
      'period': {
        'start': startDate.toIso8601String(),
        'end': now.toIso8601String(),
      },
      'totalLogs': recentLogs.length,
      'behaviorFrequency': behaviorFrequency,
      'successRates': successRates,
      'commonTriggers': triggerAnalysis,
      'recommendations': _generateBehaviorRecommendations(
        behaviorFrequency,
        successRates,
        triggerAnalysis,
      ),
    };
  }

  static List<String> _generateBehaviorRecommendations(
    Map<String, int> frequency,
    Map<String, double> successRates,
    Map<String, int> triggers,
  ) {
    final recommendations = <String>[];

    // Analyze problematic behaviors
    frequency.forEach((behavior, count) {
      final successRate = successRates[behavior] ?? 0;
      if (successRate < 50 && count > 5) {
        recommendations.add(
          'Consider professional training for "$behavior" - '
          'current success rate is ${successRate.toStringAsFixed(1)}%'
        );
      }
    });

    // Analyze triggers
    triggers.forEach((trigger, count) {
      if (count > 3) {
        recommendations.add(
          'Common trigger identified: "$trigger" - '
          'consider environmental modifications'
        );
      }
    });

    return recommendations;
  }
}

class PetCostAnalytics {
  static Map<String, dynamic> analyzeExpenses(
    Pet pet, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    startDate ??= DateTime(DateTime.now().year, 1, 1);
    endDate ??= DateTime.now();

    final expenses = <String, double>{
      'veterinary': 0,
      'medications': 0,
      'food': 0,
      'grooming': 0,
      'supplies': 0,
      'insurance': 0,
      'training': 0,
      'other': 0,
    };

    var totalExpenses = 0.0;
    final monthlyTrends = <String, double>{};

    // Process all costs within date range
    for (var entry in pet.costTracking.entries) {
      final date = DateTime.parse(entry['date']);
      if (date.isAfter(startDate) && date.isBefore(endDate)) {
        final amount = entry['amount'] as double;
        final category = entry['category'] as String;
        
        // Add to category total
        expenses[category] = (expenses[category] ?? 0) + amount;
        totalExpenses += amount;

        // Add to monthly trends
        final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        monthlyTrends[monthKey] = (monthlyTrends[monthKey] ?? 0) + amount;
      }
    }

    // Calculate percentages
    final expensePercentages = <String, double>{};
    expenses.forEach((category, amount) {
      expensePercentages[category] = totalExpenses > 0 
          ? (amount / totalExpenses) * 100 
          : 0;
    });

    return {
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'totalExpenses': totalExpenses,
      'categoryBreakdown': expenses,
      'percentages': expensePercentages,
      'monthlyTrends': monthlyTrends,
      'averageMonthly': totalExpenses / monthlyTrends.length,
      'projectedAnnual': (totalExpenses / monthlyTrends.length) * 12,
      'recommendations': _generateCostRecommendations(
        expenses,
        expensePercentages,
        pet.insurance.isNotEmpty,
      ),
    };
  }

  static List<String> _generateCostRecommendations(
    Map<String, double> expenses,
    Map<String, double> percentages,
    bool hasInsurance,
  ) {
    final recommendations = <String>[];

    // Insurance recommendations
    if (!hasInsurance && expenses['veterinary']! > 500) {
      recommendations.add(
        'Consider pet insurance to help manage veterinary expenses'
      );
    }

    // High expense categories
    percentages.forEach((category, percentage) {
      if (percentage > 40) {
        recommendations.add(
          'High percentage of expenses (${percentage.toStringAsFixed(1)}%) '
          'in $category category - consider cost-saving alternatives'
        );
      }
    });

    return recommendations;
  }
}

/// Documentation for the Pet model
/// 
/// The [Pet] class represents a comprehensive pet profile with various features:
/// 
/// Basic Information:
/// - Personal details (name, species, breed, etc.)
/// - Physical characteristics
/// - Status and ownership information
/// 
/// Health Management:
/// - Vaccination records
/// - Medical history
/// - Medications
/// - Health metrics
/// 
/// Care Management:
/// - Tasks and reminders
/// - Grooming schedule
/// - Exercise routine
/// - Feeding schedule
/// 
/// Premium Features:
/// - Behavior tracking
/// - Cost analysis
/// - Health analytics
/// - Care team management
/// 
/// Example usage:
/// ```dart
/// final pet = Pet(
///   id: 'pet123',
///   ownerId: 'owner123',
///   name: 'Max',
///   species: 'Dog',
///   breed: 'Golden Retriever',
///   dateOfBirth: DateTime(2020, 1, 1),
///   weight: 30.5,
///   gender: 'Male',
/// );
/// 
/// // Check if vaccinations are needed
/// if (pet.needsVaccination()) {
///   final upcomingVaccinations = pet.getUpcomingVaccinations();
///   // Schedule vaccinations
/// }
/// 
/// // Generate health report
/// final healthReport = PetHealthTracker.generateHealthReport(pet);
/// 
/// // Analyze expenses
/// final costAnalysis = PetCostAnalytics.analyzeExpenses(pet);
/// ```
// Continuing lib/models/pet.dart

/// Test utilities for the Pet model
class PetTestUtils {
  /// Creates a sample pet for testing purposes
  static Pet createSamplePet({
    String? id,
    String? ownerId,
    String? name,
  }) {
    return Pet(
      id: id ?? 'test-pet-${DateTime.now().millisecondsSinceEpoch}',
      ownerId: ownerId ?? 'test-owner-1',
      name: name ?? 'Test Pet',
      species: 'Dog',
      breed: 'Mixed',
      dateOfBirth: DateTime.now().subtract(const Duration(days: 365)),
      weight: 20.0,
      gender: 'Male',
      photoUrl: 'https://example.com/pet.jpg',
      vaccinations: [
        Vaccination(
          name: 'Rabies',
          date: DateTime.now().subtract(const Duration(days: 180)),
          nextDueDate: DateTime.now().add(const Duration(days: 180)),
          veterinarian: 'Dr. Smith',
        ),
      ],
      medications: [
        Medication(
          name: 'Heartworm Prevention',
          dosage: '1 tablet',
          frequency: 'Monthly',
          startDate: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ],
    );
  }

  /// Creates a complete pet profile with all fields populated
  static Pet createCompletePetProfile() {
    final pet = createSamplePet();
    
    // Add health records
    pet.painAssessments.add(PainAssessment(
      date: DateTime.now(),
      painLevel: 1,
      location: 'None',
      description: 'Regular checkup',
      symptoms: [],
    ));

    pet.mobilityRecords.add(MobilityRecord(
      date: DateTime.now(),
      mobilityScore: 9,
      description: 'Excellent mobility',
    ));

    pet.healthMetrics.add(HealthMetric(
      name: 'weight',
      value: pet.weight,
      recordedAt: DateTime.now(),
      unit: 'kg',
    ));

    // Add care tasks
    pet.careTasks.add(CareTask(
      title: 'Monthly Checkup',
      description: 'Regular health assessment',
      dueDate: DateTime.now().add(const Duration(days: 30)),
    ));

    // Add behavior logs
    pet.behaviorLogs.add(BehaviorLog(
      date: DateTime.now(),
      behavior: 'Playing',
      context: 'At home',
      wasSuccessful: true,
    ));

    return pet;
  }

  /// Validates a pet profile for completeness
  static Map<String, bool> validatePetProfile(Pet pet) {
    return {
      'hasBasicInfo': _validateBasicInfo(pet),
      'hasHealthRecords': _validateHealthRecords(pet),
      'hasCarePlan': _validateCarePlan(pet),
      'hasBehaviorRecords': _validateBehaviorRecords(pet),
      'hasEmergencyContacts': pet.emergencyContacts.isNotEmpty,
      'hasDocuments': pet.documents.isNotEmpty,
      'hasCareTeam': pet.careTeam.isNotEmpty,
    };
  }

  static bool _validateBasicInfo(Pet pet) {
    return pet.id.isNotEmpty &&
           pet.name.isNotEmpty &&
           pet.species.isNotEmpty &&
           pet.breed.isNotEmpty &&
           pet.dateOfBirth != null &&
           pet.weight > 0;
  }

  static bool _validateHealthRecords(Pet pet) {
    return pet.vaccinations.isNotEmpty ||
           pet.medications.isNotEmpty ||
           pet.healthMetrics.isNotEmpty;
  }

  static bool _validateCarePlan(Pet pet) {
    return pet.careTasks.isNotEmpty ||
           pet.reminders.isNotEmpty ||
           pet.groomingSchedule.isNotEmpty;
  }

  static bool _validateBehaviorRecords(Pet pet) {
    return pet.behaviorLogs.isNotEmpty ||
           pet.trainingProgress.isNotEmpty;
  }
}

/// Utility class for data migration and updates
class PetDataMigration {
  static Pet migrateFromOldFormat(Map<String, dynamic> oldData) {
    // Handle migration from older versions of the pet model
    final newData = <String, dynamic>{};

    // Migrate basic info
    newData['id'] = oldData['id'] ?? '';
    newData['ownerId'] = oldData['userId'] ?? oldData['ownerId'] ?? '';
    newData['name'] = oldData['name'] ?? '';
    newData['species'] = oldData['type'] ?? oldData['species'] ?? '';
    newData['breed'] = oldData['breed'] ?? '';
    
    // Migrate dates
    try {
      newData['dateOfBirth'] = DateTime.parse(oldData['birthDate'] ?? 
                                            oldData['dateOfBirth'] ?? 
                                            DateTime.now().toIso8601String());
    } catch (e) {
      newData['dateOfBirth'] = DateTime.now();
    }

    // Migrate health records
    newData['vaccinations'] = (oldData['vaccines'] ?? oldData['vaccinations'] ?? [])
        .map((v) => _migrateVaccination(v))
        .toList();

    newData['medications'] = (oldData['medicines'] ?? oldData['medications'] ?? [])
        .map((m) => _migrateMedication(m))
        .toList();

    return Pet.fromJson(newData);
  }

  static Map<String, dynamic> _migrateVaccination(Map<String, dynamic> oldVaccine) {
    return {
      'name': oldVaccine['name'] ?? '',
      'date': oldVaccine['date'] ?? DateTime.now().toIso8601String(),
      'nextDueDate': oldVaccine['nextDate'] ?? oldVaccine['nextDueDate'],
      'veterinarian': oldVaccine['vet'] ?? oldVaccine['veterinarian'],
      'notes': oldVaccine['notes'] ?? '',
    };
  }

  static Map<String, dynamic> _migrateMedication(Map<String, dynamic> oldMed) {
    return {
      'name': oldMed['name'] ?? '',
      'dosage': oldMed['dose'] ?? oldMed['dosage'] ?? '',
      'frequency': oldMed['freq'] ?? oldMed['frequency'] ?? '',
      'startDate': oldMed['start'] ?? DateTime.now().toIso8601String(),
      'endDate': oldMed['end'] ?? oldMed['endDate'],
      'notes': oldMed['notes'] ?? '',
    };
  }
}

/// Utility class for data validation
class PetDataValidator {
  static List<String> validatePetData(Map<String, dynamic> data) {
    final errors = <String>[];

    // Validate required fields
    _validateRequired(data, errors);
    
    // Validate dates
    _validateDates(data, errors);
    
    // Validate numeric values
    _validateNumeric(data, errors);
    
    // Validate arrays
    _validateArrays(data, errors);

    return errors;
  }

  static void _validateRequired(Map<String, dynamic> data, List<String> errors) {
    final requiredFields = ['id', 'name', 'species', 'breed', 'dateOfBirth', 'gender'];
    for (var field in requiredFields) {
      if (data[field] == null || data[field].toString().isEmpty) {
        errors.add('Missing required field: $field');
      }
    }
  }

  static void _validateDates(Map<String, dynamic> data, List<String> errors) {
    try {
      final dob = DateTime.parse(data['dateOfBirth']);
      if (dob.isAfter(DateTime.now())) {
        errors.add('Date of birth cannot be in the future');
      }
    } catch (e) {
      errors.add('Invalid date of birth format');
    }
  }

  static void _validateNumeric(Map<String, dynamic> data, List<String> errors) {
    if (data['weight'] != null) {
      final weight = double.tryParse(data['weight'].toString());
      if (weight == null || weight <= 0) {
        errors.add('Invalid weight value');
      }
    }
  }

  static void _validateArrays(Map<String, dynamic> data, List<String> errors) {
    if (data['vaccinations'] != null && data['vaccinations'] is! List) {
      errors.add('Vaccinations must be an array');
    }
    if (data['medications'] != null && data['medications'] is! List) {
      errors.add('Medications must be an array');
    }
  }
}
// Continuing lib/models/pet.dart

/// Utility class for diet and nutrition tracking
class PetNutritionTracker {
  static Map<String, dynamic> analyzeDiet(Pet pet) {
    return {
      'currentDiet': {
        'type': pet.dietType,
        'dailyAmount': pet.dailyFoodAmount,
        'mealsPerDay': pet.feedingsPerDay,
        'restrictions': pet.dietaryRestrictions,
      },
      'nutritionPlan': pet.nutritionPlan,
      'recommendations': _generateDietRecommendations(pet),
    };
  }

  static List<String> _generateDietRecommendations(Pet pet) {
    final recommendations = <String>[];
    
    // Age-based recommendations
    if (pet.age < 1) {
      recommendations.add('Consider puppy/kitten-specific nutrition');
    } else if (pet.age > 7) {
      recommendations.add('Consider senior pet dietary needs');
    }

    // Weight-based recommendations
    if (pet.healthMetrics.isNotEmpty) {
      final weightTrend = pet.healthMetrics
          .where((m) => m.name == 'weight')
          .toList();
      if (weightTrend.length >= 2) {
        final latestWeight = weightTrend.last.value;
        final previousWeight = weightTrend[weightTrend.length - 2].value;
        if (latestWeight > previousWeight * 1.1) {
          recommendations.add('Weight gain detected - review portion sizes');
        }
      }
    }

    return recommendations;
  }
}

/// Utility class for activity and exercise tracking
class PetActivityTracker {
  static Map<String, dynamic> analyzeActivity(Pet pet) {
    final activityLogs = pet.behaviorLogs
        .where((log) => log.behavior == 'exercise')
        .toList();

    return {
      'recommendedDaily': pet.activityLevel.recommendedExerciseMinutes,
      'actualDaily': _calculateAverageDaily(activityLogs),
      'activityTypes': pet.favoriteActivities,
      'exerciseRoutine': pet.exerciseRoutine,
      'recommendations': _generateActivityRecommendations(pet, activityLogs),
    };
  }

  static double _calculateAverageDaily(List<BehaviorLog> logs) {
    if (logs.isEmpty) return 0;
    final recentLogs = logs
        .where((log) => log.date.isAfter(
          DateTime.now().subtract(const Duration(days: 7))))
        .toList();
    if (recentLogs.isEmpty) return 0;
    
    final totalMinutes = recentLogs.fold<double>(
      0, 
      (sum, log) => sum + (log.context == 'duration' ? double.parse(log.description) : 0)
    );
    return totalMinutes / 7;
  }

  static List<String> _generateActivityRecommendations(
    Pet pet,
    List<BehaviorLog> logs,
  ) {
    final recommendations = <String>[];
    final averageDaily = _calculateAverageDaily(logs);
    
    if (averageDaily < pet.activityLevel.recommendedExerciseMinutes) {
      recommendations.add(
        'Increase daily activity to reach ${pet.activityLevel.recommendedExerciseMinutes} minutes'
      );
    }

    return recommendations;
  }
}

/// Integration helper for veterinary systems
class VetSystemIntegration {
  static Map<String, dynamic> generateVetReport(Pet pet) {
    return {
      'petInfo': {
        'id': pet.id,
        'name': pet.name,
        'species': pet.species,
        'breed': pet.breed,
        'age': pet.age,
        'weight': pet.weight,
      },
      'medicalHistory': {
        'vaccinations': pet.vaccinations.map((v) => v.toJson()).toList(),
        'medications': pet.medications.map((m) => m.toJson()).toList(),
        'allergies': pet.allergies,
        'conditions': pet.medicalNotes,
      },
      'recentMetrics': pet.healthMetrics
          .where((m) => m.recordedAt.isAfter(
            DateTime.now().subtract(const Duration(days: 90))))
          .map((m) => m.toJson())
          .toList(),
      'documents': pet.documents
          .where((d) => d.type == 'medicalRecord')
          .map((d) => d.toJson())
          .toList(),
    };
  }
}

/// Integration helper for pet insurance providers
class InsuranceIntegration {
  static Map<String, dynamic> generateInsuranceClaim(
    Pet pet,
    Map<String, dynamic> expenseDetails,
  ) {
    return {
      'policyInfo': pet.insurance,
      'petInfo': {
        'id': pet.id,
        'name': pet.name,
        'species': pet.species,
        'breed': pet.breed,
        'dateOfBirth': pet.dateOfBirth.toIso8601String(),
      },
      'claim': {
        'date': DateTime.now().toIso8601String(),
        'type': expenseDetails['type'],
        'amount': expenseDetails['amount'],
        'description': expenseDetails['description'],
        'provider': expenseDetails['provider'],
        'documents': expenseDetails['documents'],
      },
      'medicalHistory': VetSystemIntegration.generateVetReport(pet),
    };
  }
}

/// Utility class for data export
class PetDataExport {
  static Map<String, dynamic> exportFullProfile(Pet pet) {
    return {
      'basicInfo': {
        'id': pet.id,
        'ownerId': pet.ownerId,
        'name': pet.name,
        'species': pet.species,
        'breed': pet.breed,
        'dateOfBirth': pet.dateOfBirth.toIso8601String(),
        'weight': pet.weight,
        'gender': pet.gender,
        'photoUrl': pet.photoUrl,
        'status': pet.status.toString(),
      },
      'health': {
        'vaccinations': pet.vaccinations.map((v) => v.toJson()).toList(),
        'medications': pet.medications.map((m) => m.toJson()).toList(),
        'metrics': pet.healthMetrics.map((h) => h.toJson()).toList(),
        'assessments': {
          'pain': pet.painAssessments.map((p) => p.toJson()).toList(),
          'mobility': pet.mobilityRecords.map((m) => m.toJson()).toList(),
        },
      },
      'care': {
        'tasks': pet.careTasks.map((t) => t.toJson()).toList(),
        'reminders': pet.reminders.map((r) => r.toJson()).toList(),
        'schedule': PetCareScheduler.generateCareSchedule(pet),
      },
      'behavior': {
        'logs': pet.behaviorLogs.map((b) => b.toJson()).toList(),
        'analysis': PetBehaviorAnalytics.analyzeBehaviorTrends(pet),
      },
      'expenses': PetCostAnalytics.analyzeExpenses(pet),
      'documents': pet.documents.map((d) => d.toJson()).toList(),
      'careTeam': pet.careTeam.map((c) => c.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }
}
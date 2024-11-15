// lib/models/pet_profile.dart

import 'package:flutter/foundation.dart';

class PetProfile {
  final String id;
  final String name;
  final String species;
  final String breed;
  final DateTime dateOfBirth;
  final String gender;
  final double weight;
  final String color;
  final String microchipNumber;
  final String photoUrl;
  final List<String> allergies;
  final List<String> medicalConditions;
  final List<String> medications;
  final Map<String, String> dietaryRestrictions;
  final String veterinarianInfo;
  final String emergencyContact;
  final String insuranceInfo;
  final List<String> vaccinations;
  final String notes;
  // New premium features
  final String ownerId;
  final List<String> caregivers;
  final Map<String, dynamic> vetDetails;
  final Map<String, dynamic> insuranceDetails;
  final Map<String, dynamic> medicalHistory;
  final Map<String, dynamic> behavioralHistory;
  final Map<String, dynamic> nutritionPlan;
  final Map<String, dynamic> exerciseRoutine;
  final Map<String, dynamic> groomingNeeds;
  final List<String> medications_detailed;
  final Map<String, dynamic> vaccineSchedule;
  final Map<String, dynamic> preventativeCare;
  final List<String> chronicConditions;
  final Map<String, dynamic> vitals;
  final Map<String, dynamic> growthHistory;
  final List<String> allergies_detailed;
  final Map<String, dynamic> dietaryPreferences;
  final List<String> temperament;
  final Map<String, dynamic> training;
  final Map<String, dynamic> socialBehavior;
  final List<String> photos;
  final Map<String, dynamic> documents;
  final Map<String, dynamic> appointments;
  final Map<String, dynamic> reminders;
  final String bloodType;
  final Map<String, dynamic> reproductiveStatus;
  final Map<String, dynamic> identificationMarks;
  final Map<String, dynamic> licenses;
  final Map<String, dynamic> awards;
  final Map<String, dynamic> travelHistory;
  final Map<String, dynamic> environmentalFactors;
  final bool isDeceased;
  final DateTime? deceasedDate;
  final String? causeOfDeath;

  PetProfile({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.dateOfBirth,
    required this.gender,
    required this.weight,
    required this.color,
    this.microchipNumber = '',
    this.photoUrl = '',
    this.allergies = const [],
    this.medicalConditions = const [],
    this.medications = const [],
    this.dietaryRestrictions = const {},
    required this.veterinarianInfo,
    required this.emergencyContact,
    this.insuranceInfo = '',
    this.vaccinations = const [],
    this.notes = '',
    // New premium features
    required this.ownerId,
    this.caregivers = const [],
    this.vetDetails = const {},
    this.insuranceDetails = const {},
    this.medicalHistory = const {},
    this.behavioralHistory = const {},
    this.nutritionPlan = const {},
    this.exerciseRoutine = const {},
    this.groomingNeeds = const {},
    this.medications_detailed = const [],
    this.vaccineSchedule = const {},
    this.preventativeCare = const {},
    this.chronicConditions = const [],
    this.vitals = const {},
    this.growthHistory = const {},
    this.allergies_detailed = const [],
    this.dietaryPreferences = const {},
    this.temperament = const [],
    this.training = const {},
    this.socialBehavior = const {},
    this.photos = const [],
    this.documents = const {},
    this.appointments = const {},
    this.reminders = const {},
    this.bloodType = '',
    this.reproductiveStatus = const {},
    this.identificationMarks = const {},
    this.licenses = const {},
    this.awards = const {},
    this.travelHistory = const {},
    this.environmentalFactors = const {},
    this.isDeceased = false,
    this.deceasedDate,
    this.causeOfDeath,
  });

  int get age {
    if (isDeceased && deceasedDate != null) {
      return deceasedDate!.year - dateOfBirth.year;
    }
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toJson() {
    return {
      // Existing fields...
      'ownerId': ownerId,
      'caregivers': caregivers,
      'vetDetails': vetDetails,
      'insuranceDetails': insuranceDetails,
      'medicalHistory': medicalHistory,
      'behavioralHistory': behavioralHistory,
      'nutritionPlan': nutritionPlan,
      'exerciseRoutine': exerciseRoutine,
      'groomingNeeds': groomingNeeds,
      'medications_detailed': medications_detailed,
      'vaccineSchedule': vaccineSchedule,
      'preventativeCare': preventativeCare,
      'chronicConditions': chronicConditions,
      'vitals': vitals,
      'growthHistory': growthHistory,
      'allergies_detailed': allergies_detailed,
      'dietaryPreferences': dietaryPreferences,
      'temperament': temperament,
      'training': training,
      'socialBehavior': socialBehavior,
      'photos': photos,
      'documents': documents,
      'appointments': appointments,
      'reminders': reminders,
      'bloodType': bloodType,
      'reproductiveStatus': reproductiveStatus,
      'identificationMarks': identificationMarks,
      'licenses': licenses,
      'awards': awards,
      'travelHistory': travelHistory,
      'environmentalFactors': environmentalFactors,
      'isDeceased': isDeceased,
      'deceasedDate': deceasedDate?.toIso8601String(),
      'causeOfDeath': causeOfDeath,
    };
  }

  factory PetProfile.fromJson(Map<String, dynamic> json) {
    return PetProfile(
      // Existing fields...
      ownerId: json['ownerId'],
      caregivers: List<String>.from(json['caregivers'] ?? []),
      vetDetails: Map<String, dynamic>.from(json['vetDetails'] ?? {}),
      insuranceDetails: Map<String, dynamic>.from(json['insuranceDetails'] ?? {}),
      medicalHistory: Map<String, dynamic>.from(json['medicalHistory'] ?? {}),
      behavioralHistory: Map<String, dynamic>.from(json['behavioralHistory'] ?? {}),
      nutritionPlan: Map<String, dynamic>.from(json['nutritionPlan'] ?? {}),
      exerciseRoutine: Map<String, dynamic>.from(json['exerciseRoutine'] ?? {}),
      groomingNeeds: Map<String, dynamic>.from(json['groomingNeeds'] ?? {}),
      medications_detailed: List<String>.from(json['medications_detailed'] ?? []),
      vaccineSchedule: Map<String, dynamic>.from(json['vaccineSchedule'] ?? {}),
      preventativeCare: Map<String, dynamic>.from(json['preventativeCare'] ?? {}),
      chronicConditions: List<String>.from(json['chronicConditions'] ?? []),
      vitals: Map<String, dynamic>.from(json['vitals'] ?? {}),
      growthHistory: Map<String, dynamic>.from(json['growthHistory'] ?? {}),
      allergies_detailed: List<String>.from(json['allergies_detailed'] ?? []),
      dietaryPreferences: Map<String, dynamic>.from(json['dietaryPreferences'] ?? {}),
      temperament: List<String>.from(json['temperament'] ?? []),
      training: Map<String, dynamic>.from(json['training'] ?? {}),
      socialBehavior: Map<String, dynamic>.from(json['socialBehavior'] ?? {}),
      photos: List<String>.from(json['photos'] ?? []),
      documents: Map<String, dynamic>.from(json['documents'] ?? {}),
      appointments: Map<String, dynamic>.from(json['appointments'] ?? {}),
      reminders: Map<String, dynamic>.from(json['reminders'] ?? {}),
      bloodType: json['bloodType'] ?? '',
      reproductiveStatus: Map<String, dynamic>.from(json['reproductiveStatus'] ?? {}),
      identificationMarks: Map<String, dynamic>.from(json['identificationMarks'] ?? {}),
      licenses: Map<String, dynamic>.from(json['licenses'] ?? {}),
      awards: Map<String, dynamic>.from(json['awards'] ?? {}),
      travelHistory: Map<String, dynamic>.from(json['travelHistory'] ?? {}),
      environmentalFactors: Map<String, dynamic>.from(json['environmentalFactors'] ?? {}),
      isDeceased: json['isDeceased'] ?? false,
      deceasedDate: json['deceasedDate'] != null 
          ? DateTime.parse(json['deceasedDate']) 
          : null,
      causeOfDeath: json['causeOfDeath'],
    );
  }

  // Helper methods
  bool needsVaccination() {
    return vaccineSchedule.entries.any((vaccine) {
      final dueDate = DateTime.parse(vaccine.value['dueDate']);
      return DateTime.now().isAfter(dueDate);
    });
  }

  List<String> getUpcomingAppointments() {
    final upcoming = <String>[];
    appointments.forEach((key, value) {
      final appointmentDate = DateTime.parse(value['date']);
      if (DateTime.now().isBefore(appointmentDate)) {
        upcoming.add(key);
      }
    });
    return upcoming;
  }

  bool hasActiveMedicalConditions() {
    return chronicConditions.isNotEmpty;
  }

  Map<String, dynamic> getGrowthTrend() {
    return growthHistory;
  }

  bool needsGrooming() {
    if (groomingNeeds.isEmpty) return false;
    final lastGrooming = DateTime.parse(groomingNeeds['lastGrooming']);
    final frequency = groomingNeeds['frequency'] ?? 30; // days
    return DateTime.now().difference(lastGrooming).inDays >= frequency;
  }

  List<String> getActiveCaretakers() {
    return caregivers.where((caregiver) => 
        caregiver != ownerId).toList();
  }

  bool hasSpecialNeeds() {
    return chronicConditions.isNotEmpty || 
           allergies_detailed.isNotEmpty || 
           dietaryRestrictions.isNotEmpty;
  }

  bool isInsuranceValid() {
    if (insuranceDetails.isEmpty) return false;
    final expiryDate = DateTime.parse(insuranceDetails['expiryDate']);
    return DateTime.now().isBefore(expiryDate);
  }
}

enum PetGender {
  male,
  female,
  unknown
}

enum PetStatus {
  active,
  deceased,
  rehomed,
  lost
}

enum TemperamentType {
  friendly,
  shy,
  aggressive,
  playful,
  calm,
  anxious,
  protective,
  independent
}
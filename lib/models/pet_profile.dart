import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetProfile {
  final String id;
  final String name;
  final String species;
  final String breed;
  final DateTime dateOfBirth;
  final String gender;
  final double weight;
  final String color;
  final String? microchipNumber;
  final String? registrationNumber;
  final String? profileImageUrl;
  final Map<String, dynamic> medicalInfo;
  final List<String> allergies;
  final List<String> medications;
  final Map<String, bool> vaccinations;
  // Enhanced fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? dietaryNeeds;
  final Map<String, dynamic>? behavioralTraits;
  final Map<String, dynamic>? exerciseNeeds;
  final List<String>? specialNeeds;
  final Map<String, dynamic>? grooming;
  final Map<String, dynamic>? socialBehavior;
  final Map<String, dynamic>? trainingProgress;
  final List<String>? preferredActivities;
  final Map<String, dynamic>? schedule;
  final bool isActive;
  final String? insuranceInfo;
  final Map<String, dynamic>? emergencyContacts;

  PetProfile({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.dateOfBirth,
    required this.gender,
    required this.weight,
    required this.color,
    this.microchipNumber,
    this.registrationNumber,
    this.profileImageUrl,
    this.medicalInfo = const {},
    this.allergies = const [],
    this.medications = const [],
    this.vaccinations = const {},
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.metadata,
    this.dietaryNeeds,
    this.behavioralTraits,
    this.exerciseNeeds,
    this.specialNeeds,
    this.grooming,
    this.socialBehavior,
    this.trainingProgress,
    this.preferredActivities,
    this.schedule,
    this.isActive = true,
    this.insuranceInfo,
    this.emergencyContacts,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'weight': weight,
      'color': color,
      'microchipNumber': microchipNumber,
      'registrationNumber': registrationNumber,
      'profileImageUrl': profileImageUrl,
      'medicalInfo': medicalInfo,
      'allergies': allergies,
      'medications': medications,
      'vaccinations': vaccinations,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'metadata': metadata,
      'dietaryNeeds': dietaryNeeds,
      'behavioralTraits': behavioralTraits,
      'exerciseNeeds': exerciseNeeds,
      'specialNeeds': specialNeeds,
      'grooming': grooming,
      'socialBehavior': socialBehavior,
      'trainingProgress': trainingProgress,
      'preferredActivities': preferredActivities,
      'schedule': schedule,
      'isActive': isActive,
      'insuranceInfo': insuranceInfo,
      'emergencyContacts': emergencyContacts,
    };
  }

  factory PetProfile.fromJson(Map<String, dynamic> json) {
    return PetProfile(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      weight: json['weight'].toDouble(),
      color: json['color'],
      microchipNumber: json['microchipNumber'],
      registrationNumber: json['registrationNumber'],
      profileImageUrl: json['profileImageUrl'],
      medicalInfo: Map<String, dynamic>.from(json['medicalInfo'] ?? {}),
      allergies: List<String>.from(json['allergies'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      vaccinations: Map<String, bool>.from(json['vaccinations'] ?? {}),
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      metadata: json['metadata'],
      dietaryNeeds: json['dietaryNeeds'],
      behavioralTraits: json['behavioralTraits'],
      exerciseNeeds: json['exerciseNeeds'],
      specialNeeds: json['specialNeeds'] != null 
          ? List<String>.from(json['specialNeeds'])
          : null,
      grooming: json['grooming'],
      socialBehavior: json['socialBehavior'],
      trainingProgress: json['trainingProgress'],
      preferredActivities: json['preferredActivities'] != null 
          ? List<String>.from(json['preferredActivities'])
          : null,
      schedule: json['schedule'],
      isActive: json['isActive'] ?? true,
      insuranceInfo: json['insuranceInfo'],
      emergencyContacts: json['emergencyContacts'],
    );
  }

  int getAge() {
    final now = DateTime.now();
    var age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String getAgeDisplay() {
    final age = getAge();
    if (age == 0) {
      final months = DateTime.now().difference(dateOfBirth).inDays ~/ 30;
      return '$months months';
    }
    return '$age years';
  }

  bool hasAllergy(String allergy) => 
      allergies.contains(allergy.toLowerCase());

  bool hasMedication(String medication) => 
      medications.contains(medication);

  bool hasVaccination(String vaccination) => 
      vaccinations[vaccination] ?? false;

  bool hasSpecialNeed(String need) => 
      specialNeeds?.contains(need) ?? false;

  bool canEdit(String userId) => createdBy == userId || !isPremium;

  Map<String, dynamic> getDietarySummary() {
    if (dietaryNeeds == null) return {};
    
    return {
      'restrictions': dietaryNeeds!['restrictions'] ?? [],
      'preferences': dietaryNeeds!['preferences'] ?? [],
      'schedule': dietaryNeeds!['schedule'],
      'portions': dietaryNeeds!['portions'],
    };
  }

  Map<String, dynamic> getExerciseSummary() {
    if (exerciseNeeds == null) return {};
    
    return {
      'recommendedDaily': exerciseNeeds!['recommendedDaily'],
      'intensity': exerciseNeeds!['intensity'],
      'restrictions': exerciseNeeds!['restrictions'] ?? [],
      'preferredActivities': preferredActivities ?? [],
    };
  }

  Map<String, dynamic> getGroomingNeeds() {
    if (grooming == null) return {};
    
    return {
      'frequency': grooming!['frequency'],
      'specialInstructions': grooming!['specialInstructions'] ?? [],
      'lastGroomed': grooming!['lastGroomed'],
      'nextAppointment': grooming!['nextAppointment'],
    };
  }

  List<Map<String, String>> getEmergencyContactsList() {
    if (emergencyContacts == null) return [];
    
    return emergencyContacts!.entries.map((entry) {
      final contact = entry.value as Map<String, dynamic>;
      return {
        'name': entry.key,
        'phone': contact['phone'] ?? '',
        'relationship': contact['relationship'] ?? '',
        'priority': contact['priority']?.toString() ?? '1',
      };
    }).toList()
      ..sort((a, b) => int.parse(a['priority']!).compareTo(int.parse(b['priority']!)));
  }

  bool requiresAttention() {
    final now = DateTime.now();
    final vaccinesDue = vaccinations.entries
        .where((entry) => entry.value == false)
        .isNotEmpty;
    
    final medicalCheckNeeded = medicalInfo['lastCheckup'] != null &&
        DateTime.parse(medicalInfo['lastCheckup']).isBefore(
          now.subtract(const Duration(days: 365))
        );
    
    return vaccinesDue || medicalCheckNeeded;
  }
}

enum PetGender {
  male,
  female,
  unknown
}

extension PetGenderExtension on PetGender {
  String get displayName {
    switch (this) {
      case PetGender.male: return 'Male';
      case PetGender.female: return 'Female';
      case PetGender.unknown: return 'Unknown';
    }
  }
}

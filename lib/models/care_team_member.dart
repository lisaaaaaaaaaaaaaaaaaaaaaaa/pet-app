import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CareTeamMember {
  final String id;
  final String petId;
  final String name;
  final String role;
  final List<String> permissions;
  final String? email;
  final String? phone;
  final bool isActive;
  final DateTime dateAdded;
  final DateTime? lastAccess;
  final Map<String, bool> accessLevels;
  final String? profileImage;
  final String? specialization;
  final Map<String, dynamic>? availability;
  final String? notes;
  final String? createdBy;
  final bool isPremium;
  final Map<String, dynamic>? metadata;
  final List<String>? certifications;
  final Map<String, dynamic>? schedule;
  final List<String>? preferredContactMethods;
  final Map<String, dynamic>? notificationPreferences;

  CareTeamMember({
    required this.id,
    required this.petId,
    required this.name,
    required this.role,
    required this.permissions,
    this.email,
    this.phone,
    this.isActive = true,
    required this.dateAdded,
    this.lastAccess,
    this.accessLevels = const {},
    this.profileImage,
    this.specialization,
    this.availability,
    this.notes,
    this.createdBy,
    this.isPremium = false,
    this.metadata,
    this.certifications,
    this.schedule,
    this.preferredContactMethods,
    this.notificationPreferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'role': role,
      'permissions': permissions,
      'email': email,
      'phone': phone,
      'isActive': isActive,
      'dateAdded': dateAdded.toIso8601String(),
      'lastAccess': lastAccess?.toIso8601String(),
      'accessLevels': accessLevels,
      'profileImage': profileImage,
      'specialization': specialization,
      'availability': availability,
      'notes': notes,
      'createdBy': createdBy,
      'isPremium': isPremium,
      'metadata': metadata,
      'certifications': certifications,
      'schedule': schedule,
      'preferredContactMethods': preferredContactMethods,
      'notificationPreferences': notificationPreferences,
    };
  }

  factory CareTeamMember.fromJson(Map<String, dynamic> json) {
    return CareTeamMember(
      id: json['id'],
      petId: json['petId'],
      name: json['name'],
      role: json['role'],
      permissions: List<String>.from(json['permissions'] ?? []),
      email: json['email'],
      phone: json['phone'],
      isActive: json['isActive'] ?? true,
      dateAdded: DateTime.parse(json['dateAdded']),
      lastAccess: json['lastAccess'] != null 
          ? DateTime.parse(json['lastAccess'])
          : null,
      accessLevels: Map<String, bool>.from(json['accessLevels'] ?? {}),
      profileImage: json['profileImage'],
      specialization: json['specialization'],
      availability: json['availability'],
      notes: json['notes'],
      createdBy: json['createdBy'],
      isPremium: json['isPremium'] ?? false,
      metadata: json['metadata'],
      certifications: json['certifications'] != null 
          ? List<String>.from(json['certifications'])
          : null,
      schedule: json['schedule'],
      preferredContactMethods: json['preferredContactMethods'] != null 
          ? List<String>.from(json['preferredContactMethods'])
          : null,
      notificationPreferences: json['notificationPreferences'],
    );
  }

  bool hasPermission(String permission) => permissions.contains(permission);
  bool hasAccess(String feature) => accessLevels[feature] ?? false;
  bool canEdit(String userId) => createdBy == userId || !isPremium;
  
  String getInitials() {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}

enum CareTeamRole {
  primaryCaregiver,
  veterinarian,
  trainer,
  groomer,
  walker,
  sitter,
  familyMember,
  specialist,
  other
}

extension CareTeamRoleExtension on CareTeamRole {
  String get displayName {
    switch (this) {
      case CareTeamRole.primaryCaregiver: return 'Primary Caregiver';
      case CareTeamRole.veterinarian: return 'Veterinarian';
      case CareTeamRole.trainer: return 'Trainer';
      case CareTeamRole.groomer: return 'Groomer';
      case CareTeamRole.walker: return 'Walker';
      case CareTeamRole.sitter: return 'Pet Sitter';
      case CareTeamRole.familyMember: return 'Family Member';
      case CareTeamRole.specialist: return 'Specialist';
      case CareTeamRole.other: return 'Other';
    }
  }
}

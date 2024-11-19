// lib/models/care_team_member.dart


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
  });

  CareTeamMember copyWith({
    String? id,
    String? petId,
    String? name,
    String? role,
    List<String>? permissions,
    String? email,
    String? phone,
    bool? isActive,
    DateTime? dateAdded,
    DateTime? lastAccess,
    Map<String, bool>? accessLevels,
    String? profileImage,
    String? specialization,
    Map<String, dynamic>? availability,
    String? notes,
  }) {
    return CareTeamMember(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      dateAdded: dateAdded ?? this.dateAdded,
      lastAccess: lastAccess ?? this.lastAccess,
      accessLevels: accessLevels ?? this.accessLevels,
      profileImage: profileImage ?? this.profileImage,
      specialization: specialization ?? this.specialization,
      availability: availability ?? this.availability,
      notes: notes ?? this.notes,
    );
  }

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
    );
  }

  // Helper methods
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  bool hasAccess(String feature) {
    return accessLevels[feature] ?? false;
  }

  String getFormattedRole() {
    return CareTeamRole.values
        .firstWhere(
          (role) => role.toString().split('.').last == this.role.toLowerCase(),
          orElse: () => CareTeamRole.other,
        )
        .displayName;
  }

  bool isVeterinary() {
    return role.toLowerCase().contains('vet') ||
           specialization?.toLowerCase().contains('vet') == true;
  }

  bool isPrimaryCaregiver() {
    return role.toLowerCase() == 'primary caregiver';
  }

  String getInitials() {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
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
      case CareTeamRole.primaryCaregiver:
        return 'Primary Caregiver';
      case CareTeamRole.veterinarian:
        return 'Veterinarian';
      case CareTeamRole.trainer:
        return 'Trainer';
      case CareTeamRole.groomer:
        return 'Groomer';
      case CareTeamRole.walker:
        return 'Walker';
      case CareTeamRole.sitter:
        return 'Pet Sitter';
      case CareTeamRole.familyMember:
        return 'Family Member';
      case CareTeamRole.specialist:
        return 'Specialist';
      case CareTeamRole.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case CareTeamRole.primaryCaregiver:
        return '👤';
      case CareTeamRole.veterinarian:
        return '👨‍⚕️';
      case CareTeamRole.trainer:
        return '🏋️';
      case CareTeamRole.groomer:
        return '✂️';
      case CareTeamRole.walker:
        return '🚶';
      case CareTeamRole.sitter:
        return '🏠';
      case CareTeamRole.familyMember:
        return '👨‍👩‍👧‍👦';
      case CareTeamRole.specialist:
        return '👨‍🔬';
      case CareTeamRole.other:
        return '❓';
    }
  }
}

// Common permission types
class CareTeamPermission {
  static const String viewHealth = 'view_health';
  static const String editHealth = 'edit_health';
  static const String viewDocuments = 'view_documents';
  static const String editDocuments = 'edit_documents';
  static const String scheduleAppointments = 'schedule_appointments';
  static const String manageTeam = 'manage_team';
  static const String viewAnalytics = 'view_analytics';
  static const String adminAccess = 'admin_access';
}
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final Map<String, dynamic> settings;
  final List<String> pets;
  final List<String> roles;
  final bool isActive;
  final DateTime lastLogin;
  // Enhanced fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? notifications;
  final List<String>? devices;
  final Map<String, dynamic>? subscription;
  final Map<String, dynamic>? permissions;
  final Map<String, dynamic>? profile;
  final List<String>? connections;
  final Map<String, dynamic>? activity;
  final UserStatus status;
  final Map<String, dynamic>? security;
  final Map<String, dynamic>? communication;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.settings = const {},
    this.pets = const [],
    this.roles = const [],
    this.isActive = true,
    DateTime? lastLogin,
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.metadata,
    this.preferences,
    this.notifications,
    this.devices,
    this.subscription,
    this.permissions,
    this.profile,
    this.connections,
    this.activity,
    this.status = UserStatus.active,
    this.security,
    this.communication,
  }) : this.lastLogin = lastLogin ?? DateTime.now(),
       this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'settings': settings,
      'pets': pets,
      'roles': roles,
      'isActive': isActive,
      'lastLogin': lastLogin.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'metadata': metadata,
      'preferences': preferences,
      'notifications': notifications,
      'devices': devices,
      'subscription': subscription,
      'permissions': permissions,
      'profile': profile,
      'connections': connections,
      'activity': activity,
      'status': status.toString(),
      'security': security,
      'communication': communication,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      phoneNumber: json['phoneNumber'],
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      pets: List<String>.from(json['pets'] ?? []),
      roles: List<String>.from(json['roles'] ?? []),
      isActive: json['isActive'] ?? true,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'])
          : null,
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      metadata: json['metadata'],
      preferences: json['preferences'],
      notifications: json['notifications'],
      devices: json['devices'] != null 
          ? List<String>.from(json['devices'])
          : null,
      subscription: json['subscription'],
      permissions: json['permissions'],
      profile: json['profile'],
      connections: json['connections'] != null 
          ? List<String>.from(json['connections'])
          : null,
      activity: json['activity'],
      status: UserStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => UserStatus.active,
      ),
      security: json['security'],
      communication: json['communication'],
    );
  }

  bool hasRole(String role) => roles.contains(role);

  bool hasPet(String petId) => pets.contains(petId);

  bool hasPermission(String permission) => 
      permissions?[permission] == true;

  bool hasDevice(String deviceId) => 
      devices?.contains(deviceId) ?? false;

  bool hasConnection(String userId) => 
      connections?.contains(userId) ?? false;

  Map<String, dynamic> getNotificationSettings() {
    if (notifications == null) return {};
    
    return {
      'email': notifications!['email'] ?? true,
      'push': notifications!['push'] ?? true,
      'sms': notifications!['sms'] ?? false,
      'frequency': notifications!['frequency'] ?? 'immediate',
      'quiet_hours': notifications!['quiet_hours'],
    };
  }

  Map<String, dynamic> getSubscriptionDetails() {
    if (subscription == null) return {};
    
    return {
      'plan': subscription!['plan'],
      'status': subscription!['status'],
      'validUntil': subscription!['validUntil'],
      'features': subscription!['features'] ?? [],
      'paymentMethod': subscription!['paymentMethod'],
    };
  }

  Map<String, dynamic> getProfileInfo() {
    if (profile == null) return {};
    
    return {
      'firstName': profile!['firstName'],
      'lastName': profile!['lastName'],
      'address': profile!['address'],
      'timezone': profile!['timezone'],
      'language': profile!['language'],
      'bio': profile!['bio'],
    };
  }

  Map<String, dynamic> getSecuritySettings() {
    if (security == null) return {};
    
    return {
      'twoFactorEnabled': security!['twoFactorEnabled'] ?? false,
      'lastPasswordChange': security!['lastPasswordChange'],
      'loginAttempts': security!['loginAttempts'] ?? 0,
      'trustedDevices': security!['trustedDevices'] ?? [],
    };
  }

  Map<String, dynamic> getCommunicationPreferences() {
    if (communication == null) return {};
    
    return {
      'marketing': communication!['marketing'] ?? false,
      'newsletter': communication!['newsletter'] ?? false,
      'updates': communication!['updates'] ?? true,
      'reminders': communication!['reminders'] ?? true,
    };
  }

  List<Map<String, dynamic>> getRecentActivity() {
    if (activity == null) return [];
    
    final activities = activity!.entries.map((entry) {
      return {
        'date': DateTime.parse(entry.key),
        'type': entry.value['type'],
        'details': entry.value['details'],
      };
    }).toList();
    
    activities.sort((a, b) => 
        (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return activities;
  }

  bool requiresPasswordChange() {
    if (security == null || security!['lastPasswordChange'] == null) return true;
    
    final lastChange = DateTime.parse(security!['lastPasswordChange']);
    return DateTime.now().difference(lastChange).inDays > 90;
  }

  bool get isVerified => 
      security?['emailVerified'] == true;

  bool get hasCompletedProfile =>
      profile != null && 
      profile!['firstName'] != null && 
      profile!['lastName'] != null;

  String getFullName() {
    if (profile == null) return displayName;
    return '${profile!['firstName'] ?? ''} ${profile!['lastName'] ?? ''}'.trim();
  }

  bool canAccessPremiumFeature(String feature) =>
      isPremium && subscription?['features']?.contains(feature) == true;
}

enum UserStatus {
  active,
  inactive,
  suspended,
  pending,
  blocked
}

extension UserStatusExtension on UserStatus {
  String get displayName {
    switch (this) {
      case UserStatus.active: return 'Active';
      case UserStatus.inactive: return 'Inactive';
      case UserStatus.suspended: return 'Suspended';
      case UserStatus.pending: return 'Pending';
      case UserStatus.blocked: return 'Blocked';
    }
  }

  bool get canLogin =>
      this == UserStatus.active || 
      this == UserStatus.pending;
}

enum UserRole {
  user,
  admin,
  moderator,
  veterinarian,
  premium
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.user: return 'User';
      case UserRole.admin: return 'Administrator';
      case UserRole.moderator: return 'Moderator';
      case UserRole.veterinarian: return 'Veterinarian';
      case UserRole.premium: return 'Premium User';
    }
  }

  List<String> get permissions {
    switch (this) {
      case UserRole.user:
        return ['read:own', 'write:own'];
      case UserRole.admin:
        return ['read:all', 'write:all', 'manage:users', 'manage:content'];
      case UserRole.moderator:
        return ['read:all', 'moderate:content'];
      case UserRole.veterinarian:
        return ['read:assigned', 'write:medical', 'manage:prescriptions'];
      case UserRole.premium:
        return ['read:own', 'write:own', 'access:premium'];
    }
  }
}

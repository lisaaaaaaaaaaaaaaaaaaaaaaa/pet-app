// lib/models/user.dart


class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String address;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isActive;
  final List<String> petIds;
  final Map<String, dynamic> preferences;
  final List<String> favoriteVets;
  final EmergencyContact emergencyContact;
  // New fields
  final UserRole role;
  final String? subscriptionId;
  final List<UserNotificationSetting> notificationSettings;
  final Map<String, bool> permissions;
  final List<UserAddress> addresses;
  final PaymentInfo? paymentInfo;
  final List<DeviceInfo> devices;
  final Map<String, dynamic> metadata;
  final bool emailVerified;
  final bool phoneVerified;
  final String? language;
  final String? timezone;
  final List<UserActivity> activityLog;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.address = '',
    this.photoUrl = '',
    required this.createdAt,
    required this.lastLogin,
    this.isActive = true,
    this.petIds = const [],
    this.preferences = const {},
    this.favoriteVets = const [],
    required this.emergencyContact,
    this.role = UserRole.petOwner,
    this.subscriptionId,
    this.notificationSettings = const [],
    this.permissions = const {},
    this.addresses = const [],
    this.paymentInfo,
    this.devices = const [],
    this.metadata = const {},
    this.emailVerified = false,
    this.phoneVerified = false,
    this.language = 'en',
    this.timezone = 'UTC',
    this.activityLog = const [],
  });

  String get fullName => '$firstName $lastName';
  
  bool get isSubscribed => subscriptionId != null;
  
  bool get hasVerifiedContacts => emailVerified && phoneVerified;

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    List<String>? petIds,
    Map<String, dynamic>? preferences,
    List<String>? favoriteVets,
    EmergencyContact? emergencyContact,
    UserRole? role,
    String? subscriptionId,
    List<UserNotificationSetting>? notificationSettings,
    Map<String, bool>? permissions,
    List<UserAddress>? addresses,
    PaymentInfo? paymentInfo,
    List<DeviceInfo>? devices,
    Map<String, dynamic>? metadata,
    bool? emailVerified,
    bool? phoneVerified,
    String? language,
    String? timezone,
    List<UserActivity>? activityLog,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      petIds: petIds ?? this.petIds,
      preferences: preferences ?? this.preferences,
      favoriteVets: favoriteVets ?? this.favoriteVets,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      role: role ?? this.role,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      permissions: permissions ?? this.permissions,
      addresses: addresses ?? this.addresses,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      devices: devices ?? this.devices,
      metadata: metadata ?? this.metadata,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      activityLog: activityLog ?? this.activityLog,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'address': address,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'isActive': isActive,
      'petIds': petIds,
      'preferences': preferences,
      'favoriteVets': favoriteVets,
      'emergencyContact': emergencyContact.toJson(),
      'role': role.toString(),
      'subscriptionId': subscriptionId,
      'notificationSettings': notificationSettings.map((s) => s.toJson()).toList(),
      'permissions': permissions,
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'paymentInfo': paymentInfo?.toJson(),
      'devices': devices.map((d) => d.toJson()).toList(),
      'metadata': metadata,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'language': language,
      'timezone': timezone,
      'activityLog': activityLog.map((a) => a.toJson()).toList(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      address: json['address'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
      isActive: json['isActive'] ?? true,
      petIds: List<String>.from(json['petIds'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      favoriteVets: List<String>.from(json['favoriteVets'] ?? []),
      emergencyContact: EmergencyContact.fromJson(json['emergencyContact']),
      role: UserRole.values.firstWhere(
        (r) => r.toString() == json['role'],
        orElse: () => UserRole.petOwner,
      ),
      subscriptionId: json['subscriptionId'],
      notificationSettings: (json['notificationSettings'] as List?)
          ?.map((s) => UserNotificationSetting.fromJson(s))
          .toList() ?? [],
      permissions: Map<String, bool>.from(json['permissions'] ?? {}),
      addresses: (json['addresses'] as List?)
          ?.map((a) => UserAddress.fromJson(a))
          .toList() ?? [],
      paymentInfo: json['paymentInfo'] != null
          ? PaymentInfo.fromJson(json['paymentInfo'])
          : null,
      devices: (json['devices'] as List?)
          ?.map((d) => DeviceInfo.fromJson(d))
          .toList() ?? [],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      language: json['language'] ?? 'en',
      timezone: json['timezone'] ?? 'UTC',
      activityLog: (json['activityLog'] as List?)
          ?.map((a) => UserActivity.fromJson(a))
          .toList() ?? [],
    );
  }
}
// Continuing lib/models/user.dart

enum UserRole {
  petOwner,
  veterinarian,
  petSitter,
  admin,
  moderator,
  support
}

class UserNotificationSetting {
  final String type; // 'push', 'email', 'sms'
  final bool enabled;
  final Map<String, bool> preferences;
  final List<String> quietHours;
  final bool emergencyOverride;

  const UserNotificationSetting({
    required this.type,
    this.enabled = true,
    this.preferences = const {},
    this.quietHours = const [],
    this.emergencyOverride = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'enabled': enabled,
      'preferences': preferences,
      'quietHours': quietHours,
      'emergencyOverride': emergencyOverride,
    };
  }

  factory UserNotificationSetting.fromJson(Map<String, dynamic> json) {
    return UserNotificationSetting(
      type: json['type'],
      enabled: json['enabled'] ?? true,
      preferences: Map<String, bool>.from(json['preferences'] ?? {}),
      quietHours: List<String>.from(json['quietHours'] ?? []),
      emergencyOverride: json['emergencyOverride'] ?? true,
    );
  }
}

class UserAddress {
  final String id;
  final String type; // 'home', 'work', 'other'
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isPrimary;
  final Map<String, double>? coordinates;

  const UserAddress({
    required this.id,
    required this.type,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isPrimary = false,
    this.coordinates,
  });

  String get fullAddress => 
      '$street, $city, $state $postalCode, $country';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isPrimary': isPrimary,
      'coordinates': coordinates,
    };
  }

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'],
      type: json['type'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      isPrimary: json['isPrimary'] ?? false,
      coordinates: json['coordinates'] != null
          ? Map<String, double>.from(json['coordinates'])
          : null,
    );
  }
}

class PaymentInfo {
  final String id;
  final String type; // 'card', 'bank_account', etc.
  final String lastFour;
  final String brand;
  final String? holderName;
  final DateTime expiryDate;
  final bool isDefault;
  final Map<String, dynamic> metadata;

  const PaymentInfo({
    required this.id,
    required this.type,
    required this.lastFour,
    required this.brand,
    this.holderName,
    required this.expiryDate,
    this.isDefault = false,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'lastFour': lastFour,
      'brand': brand,
      'holderName': holderName,
      'expiryDate': expiryDate.toIso8601String(),
      'isDefault': isDefault,
      'metadata': metadata,
    };
  }

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['id'],
      type: json['type'],
      lastFour: json['lastFour'],
      brand: json['brand'],
      holderName: json['holderName'],
      expiryDate: DateTime.parse(json['expiryDate']),
      isDefault: json['isDefault'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class DeviceInfo {
  final String id;
  final String type; // 'ios', 'android', 'web'
  final String name;
  final String token;
  final DateTime lastUsed;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const DeviceInfo({
    required this.id,
    required this.type,
    required this.name,
    required this.token,
    required this.lastUsed,
    this.isActive = true,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'token': token,
      'lastUsed': lastUsed.toIso8601String(),
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      token: json['token'],
      lastUsed: DateTime.parse(json['lastUsed']),
      isActive: json['isActive'] ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class UserActivity {
  final String id;
  final String type;
  final DateTime timestamp;
  final String? deviceId;
  final String? location;
  final Map<String, dynamic> details;

  const UserActivity({
    required this.id,
    required this.type,
    required this.timestamp,
    this.deviceId,
    this.location,
    this.details = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'deviceId': deviceId,
      'location': location,
      'details': details,
    };
  }

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      deviceId: json['deviceId'],
      location: json['location'],
      details: Map<String, dynamic>.from(json['details'] ?? {}),
    );
  }
}

// Utility class for user-related operations
class UserUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d-]{10,}$').hasMatch(phone);
  }

  static bool hasRequiredFields(User user) {
    return user.email.isNotEmpty &&
           user.firstName.isNotEmpty &&
           user.lastName.isNotEmpty &&
           user.phoneNumber.isNotEmpty;
  }

  static bool canAccessFeature(User user, String feature) {
    return user.permissions[feature] ?? false;
  }

  static List<UserActivity> getRecentActivity(User user, {int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return user.activityLog
        .where((activity) => activity.timestamp.isAfter(cutoff))
        .toList();
  }

  static Map<String, dynamic> generateUserSummary(User user) {
    return {
      'profile': {
        'name': user.fullName,
        'email': user.email,
        'phone': user.phoneNumber,
        'role': user.role.toString(),
      },
      'pets': user.petIds.length,
      'accountAge': DateTime.now().difference(user.createdAt).inDays,
      'lastActive': DateTime.now().difference(user.lastLogin).inHours,
      'verificationStatus': {
        'email': user.emailVerified,
        'phone': user.phoneVerified,
      },
      'subscription': user.isSubscribed,
      'devices': user.devices.where((d) => d.isActive).length,
      'addresses': user.addresses.length,
    };
  }
}
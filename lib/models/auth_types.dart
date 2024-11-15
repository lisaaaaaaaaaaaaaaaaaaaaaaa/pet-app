enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error
}

enum AuthProvider {
  email,
  google,
  apple,
  facebook
}

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) : 
    preferences = preferences ?? {},
    createdAt = createdAt ?? DateTime.now(),
    lastLogin = lastLogin ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'preferences': preferences,
    'createdAt': createdAt.toIso8601String(),
    'lastLogin': lastLogin.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    email: json['email'],
    displayName: json['displayName'],
    photoUrl: json['photoUrl'],
    preferences: json['preferences'] ?? {},
    createdAt: DateTime.parse(json['createdAt']),
    lastLogin: DateTime.parse(json['lastLogin']),
  );
}

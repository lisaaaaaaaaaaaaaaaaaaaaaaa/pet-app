class UserPreferences {
  final double textScaleFactor;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;

  UserPreferences({
    this.textScaleFactor = 1.0,
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
  });

  UserPreferences copyWith({
    double? textScaleFactor,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
  }) {
    return UserPreferences(
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
    );
  }
}

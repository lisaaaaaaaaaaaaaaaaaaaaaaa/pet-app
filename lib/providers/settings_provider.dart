import 'package:flutter/material.dart';
import '../models/user_preferences.dart';

class SettingsProvider with ChangeNotifier {
  UserPreferences _userPreferences = UserPreferences();

  UserPreferences get userPreferences => _userPreferences;

  void updateTextSize(double size) {
    _userPreferences = _userPreferences.copyWith(textScaleFactor: size);
    notifyListeners();
  }

  void updatePushNotifications(bool enabled) {
    _userPreferences = _userPreferences.copyWith(pushNotificationsEnabled: enabled);
    notifyListeners();
  }

  void updateEmailNotifications(bool enabled) {
    _userPreferences = _userPreferences.copyWith(emailNotificationsEnabled: enabled);
    notifyListeners();
  }
}

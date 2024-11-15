import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> logout() async {
    // Add your logout logic here
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    // Add your account deletion logic here
    _isAuthenticated = false;
    notifyListeners();
  }
}

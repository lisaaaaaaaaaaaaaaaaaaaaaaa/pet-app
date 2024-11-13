// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _userId;
  String? _userEmail;
  String? _userName;
  DateTime? _lastLogin;
  String? _authToken;
  bool _biometricsEnabled = false;
  Map<String, dynamic>? _userProfile;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  DateTime? get lastLogin => _lastLogin;
  bool get biometricsEnabled => _biometricsEnabled;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get hasValidSession => _authToken != null && !_isTokenExpired();

  Future<void> initialize() async {
    try {
      // Load auth state from secure storage
      final token = await _storage.read(key: 'authToken');
      final userId = await _storage.read(key: 'userId');
      final email = await _storage.read(key: 'userEmail');
      final lastLogin = await _storage.read(key: 'lastLogin');
      final biometrics = await _storage.read(key: 'biometricsEnabled');

      if (token != null && !_isTokenExpired()) {
        _authToken = token;
        _userId = userId;
        _userEmail = email;
        _lastLogin = lastLogin != null ? DateTime.parse(lastLogin) : null;
        _biometricsEnabled = biometrics == 'true';
        _isAuthenticated = true;
        
        // Load user profile
        await _loadUserProfile();
      } else {
        await _clearAuthData();
      }
    } catch (e) {
      debugPrint('Error initializing auth state: $e');
      await _clearAuthData();
    } finally {
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Validate input
      _validateCredentials(email, password);

      // Hash password for security
      final hashedPassword = _hashPassword(password);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Replace with actual API authentication
      final authResponse = await _authenticateWithApi(email, hashedPassword);
      
      // Store auth data securely
      await _storeAuthData(
        authResponse['token'],
        authResponse['userId'],
        email,
        rememberMe,
      );

      _authToken = authResponse['token'];
      _userId = authResponse['userId'];
      _userEmail = email;
      _lastLogin = DateTime.now();
      _isAuthenticated = true;

      // Load user profile after successful login
      await _loadUserProfile();
      
    } catch (e) {
      _isAuthenticated = false;
      throw AuthException(_getErrorMessage(e));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Validate input
      _validateSignUpData(email, password, name);

      // Hash password
      final hashedPassword = _hashPassword(password);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Replace with actual API registration
      final registrationResponse = await _registerWithApi(email, hashedPassword, name);

      // Store auth data
      await _storeAuthData(
        registrationResponse['token'],
        registrationResponse['userId'],
        email,
        true,
      );

      _authToken = registrationResponse['token'];
      _userId = registrationResponse['userId'];
      _userEmail = email;
      _userName = name;
      _lastLogin = DateTime.now();
      _isAuthenticated = true;

      // Initialize user profile
      await _createUserProfile(name);
      
    } catch (e) {
      _isAuthenticated = false;
      throw AuthException(_getErrorMessage(e));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Add API logout call if needed
      await _clearAuthData();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods
  void _validateCredentials(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Email and password cannot be empty');
    }
    if (!_isValidEmail(email)) {
      throw AuthException('Invalid email format');
    }
  }

  void _validateSignUpData(String email, String password, String name) {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw AuthException('All fields are required');
    }
    if (!_isValidEmail(email)) {
      throw AuthException('Invalid email format');
    }
    if (password.length < 8) {
      throw AuthException('Password must be at least 8 characters');
    }
    if (!_isStrongPassword(password)) {
      throw AuthException('Password must contain letters, numbers, and symbols');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$')
        .hasMatch(password);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  bool _isTokenExpired() {
    if (_lastLogin == null) return true;
    return DateTime.now().difference(_lastLogin!) > const Duration(hours: 24);
  }
// Continuing lib/providers/auth_provider.dart

  // API Integration Methods
  Future<Map<String, dynamic>> _authenticateWithApi(
    String email, 
    String hashedPassword,
  ) async {
    try {
      // TODO: Replace with actual API call
      // Simulated API response
      return {
        'token': 'jwt_${DateTime.now().millisecondsSinceEpoch}',
        'userId': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'expiresIn': 86400, // 24 hours in seconds
      };
    } catch (e) {
      throw AuthException('Authentication failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> _registerWithApi(
    String email,
    String hashedPassword,
    String name,
  ) async {
    try {
      // TODO: Replace with actual API call
      // Simulated API response
      return {
        'token': 'jwt_${DateTime.now().millisecondsSinceEpoch}',
        'userId': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'expiresIn': 86400,
      };
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  // Secure Storage Methods
  Future<void> _storeAuthData(
    String token,
    String userId,
    String email,
    bool rememberMe,
  ) async {
    try {
      await _storage.write(key: 'authToken', value: token);
      await _storage.write(key: 'userId', value: userId);
      await _storage.write(key: 'userEmail', value: email);
      await _storage.write(
        key: 'lastLogin',
        value: DateTime.now().toIso8601String(),
      );
      
      if (rememberMe) {
        await _storage.write(key: 'rememberMe', value: 'true');
      }
    } catch (e) {
      throw AuthException('Failed to store auth data: ${e.toString()}');
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await _storage.deleteAll();
      _isAuthenticated = false;
      _userId = null;
      _userEmail = null;
      _userName = null;
      _lastLogin = null;
      _authToken = null;
      _userProfile = null;
      _biometricsEnabled = false;
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }

  // User Profile Methods
  Future<void> _loadUserProfile() async {
    try {
      // TODO: Replace with actual API call
      final profile = await _storage.read(key: 'userProfile');
      if (profile != null) {
        _userProfile = json.decode(profile);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> _createUserProfile(String name) async {
    try {
      final profile = {
        'name': name,
        'email': _userEmail,
        'createdAt': DateTime.now().toIso8601String(),
        'preferences': {
          'notifications': true,
          'theme': 'light',
          'language': 'en',
        },
      };

      await _storage.write(
        key: 'userProfile',
        value: json.encode(profile),
      );
      _userProfile = profile;
    } catch (e) {
      debugPrint('Error creating user profile: $e');
    }
  }

  // Session Management Methods
  Future<void> refreshSession() async {
    if (!_isAuthenticated || _authToken == null) return;

    try {
      // TODO: Replace with actual token refresh API call
      final refreshResponse = await _refreshTokenWithApi();
      
      await _storeAuthData(
        refreshResponse['token'],
        _userId!,
        _userEmail!,
        true,
      );

      _authToken = refreshResponse['token'];
      _lastLogin = DateTime.now();
    } catch (e) {
      await signOut();
      throw AuthException('Session expired. Please sign in again.');
    }
  }

  Future<Map<String, dynamic>> _refreshTokenWithApi() async {
    // TODO: Replace with actual API call
    return {
      'token': 'jwt_${DateTime.now().millisecondsSinceEpoch}',
      'expiresIn': 86400,
    };
  }

  // Biometric Authentication Methods
  Future<void> enableBiometrics() async {
    try {
      // TODO: Add actual biometric authentication
      await _storage.write(key: 'biometricsEnabled', value: 'true');
      _biometricsEnabled = true;
      notifyListeners();
    } catch (e) {
      throw AuthException('Failed to enable biometric authentication');
    }
  }

  Future<void> disableBiometrics() async {
    try {
      await _storage.delete(key: 'biometricsEnabled');
      _biometricsEnabled = false;
      notifyListeners();
    } catch (e) {
      throw AuthException('Failed to disable biometric authentication');
    }
  }

  // Password Management
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (!_isStrongPassword(newPassword)) {
        throw AuthException('New password does not meet security requirements');
      }

      // TODO: Add actual password change API call
      await Future.delayed(const Duration(seconds: 1));

      // Simulate success
      await _storage.delete(key: 'authToken');
      _authToken = 'new_token_${DateTime.now().millisecondsSinceEpoch}';
      await _storage.write(key: 'authToken', value: _authToken!);
    } catch (e) {
      throw AuthException('Failed to change password: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Error Handling
  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
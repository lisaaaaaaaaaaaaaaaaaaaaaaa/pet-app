import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_user.dart';
import '../models/auth_token.dart';
import '../utils/api_response.dart';
import '../utils/api_error.dart';
import '../utils/secure_storage.dart';
import '../utils/validators.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'https://api.example.com/v1';
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  
  final SecureStorage _secureStorage;
  
  AuthService({SecureStorage? secureStorage}) 
      : _secureStorage = secureStorage ?? SecureStorage();

  // User Authentication
  Future<ApiResponse<AppUser>> login(String email, String password) async {
    try {
      // Validate inputs
      if (!Validators.isValidEmail(email)) {
        return ApiResponse.error(ApiError('Invalid email format'));
      }
      
      if (!Validators.isValidPassword(password)) {
        return ApiResponse.error(ApiError('Password must be at least 8 characters'));
      }

      // Make API call
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = AppUser.fromJson(data['user']);
        final token = AuthToken.fromJson(data['token']);

        // Save user data and token
        await Future.wait([
          _saveUserData(user),
          _saveToken(token),
        ]);

        return ApiResponse.success(user);
      } else {
        final error = _parseErrorResponse(response);
        return ApiResponse.error(error);
      }
    } catch (e) {
      return ApiResponse.error(ApiError('Login failed', e.toString()));
    }
  }

  Future<ApiResponse<AppUser>> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      // Validate inputs
      if (!Validators.isValidEmail(email)) {
        return ApiResponse.error(ApiError('Invalid email format'));
      }
      
      if (!Validators.isValidPassword(password)) {
        return ApiResponse.error(ApiError('Password must be at least 8 characters'));
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        body: {
          'email': email,
          'password': password,
          'name': name,
          if (phoneNumber != null) 'phone_number': phoneNumber,
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final user = AppUser.fromJson(data['user']);
        final token = AuthToken.fromJson(data['token']);

        await Future.wait([
          _saveUserData(user),
          _saveToken(token),
        ]);

        return ApiResponse.success(user);
      } else {
        final error = _parseErrorResponse(response);
        return ApiResponse.error(error);
      }
    } catch (e) {
      return ApiResponse.error(ApiError('Registration failed', e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        // Make API call to invalidate token
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (e) {
      debugPrint('Logout API call failed: $e');
    } finally {
      // Clear local storage regardless of API call success
      await Future.wait([
        _secureStorage.delete(_tokenKey),
        _clearUserData(),
      ]);
    }
  }

  // Password Management
  Future<ApiResponse<void>> resetPassword(String email) async {
    try {
      if (!Validators.isValidEmail(email)) {
        return ApiResponse.error(ApiError('Invalid email format'));
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        final error = _parseErrorResponse(response);
        return ApiResponse.error(error);
      }
    } catch (e) {
      return ApiResponse.error(ApiError('Password reset failed', e.toString()));
    }
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error(ApiError('Not authenticated'));
      }

      if (!Validators.isValidPassword(newPassword)) {
        return ApiResponse.error(ApiError('New password must be at least 8 characters'));
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/change-password'),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        final error = _parseErrorResponse(response);
        return ApiResponse.error(error);
      }
    } catch (e) {
      return ApiResponse.error(ApiError('Password change failed', e.toString()));
    }
  }

  // User Management
  Future<AppUser?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      if (userData != null) {
        return AppUser.fromJson(json.decode(userData));
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  Future<ApiResponse<AppUser>> updateProfile({
    String? name,
    String? phoneNumber,
    String? profilePicture,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse.error(ApiError('Not authenticated'));
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          if (name != null) 'name': name,
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (profilePicture != null) 'profile_picture': profilePicture,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedUser = AppUser.fromJson(data);
        await _saveUserData(updatedUser);
        return ApiResponse.success(updatedUser);
      } else {
        final error = _parseErrorResponse(response);
        return ApiResponse.error(error);
      }
    } catch (e) {
      return ApiResponse.error(ApiError('Profile update failed', e.toString()));
    }
  }

  // Token Management
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(_tokenKey);
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Helper Methods
  Future<void> _saveUserData(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<void> _saveToken(AuthToken token) async {
    await _secureStorage.write(_tokenKey, token.accessToken);
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  ApiError _parseErrorResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      return ApiError(
        data['message'] ?? 'Unknown error',
        data['details'],
      );
    } catch (e) {
      return ApiError('Request failed', 'Status code: ${response.statusCode}');
    }
  }

  // Session Management
  Stream<bool> get authStateChanges {
    // Implement auth state monitoring
    return Stream.periodic(const Duration(seconds: 1))
        .asyncMap((_) => isAuthenticated());
  }

  Future<void> refreshToken() async {
    try {
      final token = await getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newToken = AuthToken.fromJson(data);
        await _saveToken(newToken);
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }
  }
}
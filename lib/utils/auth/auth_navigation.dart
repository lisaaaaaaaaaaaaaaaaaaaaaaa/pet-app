import 'package:flutter/material.dart';
import '../../constants/route_constants.dart';
import '../../services/auth_service.dart';

class AuthNavigation {
  static final AuthService _authService = AuthService();

  static Future<void> handleAuthStateChange(BuildContext context) async {
    _authService.authStateChanges.listen((user) {
      if (user == null) {
        // User is signed out, navigate to login
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteConstants.login,
          (route) => false,
        );
      } else if (!user.emailVerified) {
        // Email not verified
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteConstants.verifyEmail,
          (route) => false,
        );
      } else {
        // User is signed in and verified
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteConstants.home,
          (route) => false,
        );
      }
    });
  }

  static Future<void> signOut(BuildContext context) async {
    try {
      await _authService.signOut();
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteConstants.login,
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> navigateToForgotPassword(BuildContext context) async {
    Navigator.pushNamed(context, RouteConstants.forgotPassword);
  }

  static Future<void> navigateToRegister(BuildContext context) async {
    Navigator.pushNamed(context, RouteConstants.register);
  }

  static Future<void> navigateToLogin(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteConstants.login,
      (route) => false,
    );
  }

  static Future<void> handleSuccessfulAuth(BuildContext context) async {
    final user = _authService.currentUser;
    if (user != null && !user.emailVerified) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteConstants.verifyEmail,
        (route) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteConstants.home,
        (route) => false,
      );
    }
  }

  static Future<void> handleAuthError(
    BuildContext context,
    String errorMessage,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class AuthErrorHandler {
  static String handleError(dynamic error) {
    String errorMessage;

    switch (error.code) {
      // Firebase Auth Errors
      case 'email-already-in-use':
        errorMessage = 'This email is already registered. Please try logging in or use a different email.';
        break;
      case 'invalid-email':
        errorMessage = 'The email address is not valid. Please check and try again.';
        break;
      case 'operation-not-allowed':
        errorMessage = 'This sign-in method is not enabled. Please contact support.';
        break;
      case 'weak-password':
        errorMessage = 'The password is too weak. Please use a stronger password.';
        break;
      case 'user-disabled':
        errorMessage = 'This account has been disabled. Please contact support.';
        break;
      case 'user-not-found':
        errorMessage = 'No account found with this email. Please sign up first.';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password. Please try again or reset your password.';
        break;
      case 'invalid-verification-code':
        errorMessage = 'Invalid verification code. Please try again.';
        break;
      case 'invalid-verification-id':
        errorMessage = 'Invalid verification. Please request a new code.';
        break;
      case 'quota-exceeded':
        errorMessage = 'Too many requests. Please try again later.';
        break;
      case 'provider-already-linked':
        errorMessage = 'This account is already linked with another provider.';
        break;
      case 'requires-recent-login':
        errorMessage = 'This operation requires recent authentication. Please log in again.';
        break;
      case 'credential-already-in-use':
        errorMessage = 'This credential is already associated with another account.';
        break;
      case 'account-exists-with-different-credential':
        errorMessage = 'An account already exists with the same email but different sign-in credentials.';
        break;
      case 'invalid-credential':
        errorMessage = 'The provided credential is invalid. Please try again.';
        break;
      case 'invalid-continue-uri':
        errorMessage = 'The continue URL provided is invalid.';
        break;
      case 'unauthorized-continue-uri':
        errorMessage = 'The domain of the continue URL is not authorized.';
        break;
      case 'network-request-failed':
        errorMessage = 'Network error. Please check your connection and try again.';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many attempts. Please try again later.';
        break;
      case 'user-token-expired':
        errorMessage = 'Your session has expired. Please log in again.';
        break;
      case 'web-storage-unsupported':
        errorMessage = 'Web storage is not supported by your browser.';
        break;
      case 'popup-blocked':
        errorMessage = 'Pop-up blocked by browser. Please allow pop-ups and try again.';
        break;
      case 'popup-closed-by-user':
        errorMessage = 'Pop-up closed before authentication was completed.';
        break;
      case 'cancelled-popup-request':
        errorMessage = 'Authentication cancelled. Please try again.';
        break;

      // Social Auth Errors
      case 'google-sign-in-failed':
        errorMessage = 'Google sign-in failed. Please try again.';
        break;
      case 'facebook-sign-in-failed':
        errorMessage = 'Facebook sign-in failed. Please try again.';
        break;
      case 'apple-sign-in-failed':
        errorMessage = 'Apple sign-in failed. Please try again.';
        break;
      case 'twitter-sign-in-failed':
        errorMessage = 'Twitter sign-in failed. Please try again.';
        break;

      // Password Reset Errors
      case 'expired-action-code':
        errorMessage = 'The password reset link has expired. Please request a new one.';
        break;
      case 'invalid-action-code':
        errorMessage = 'The password reset link is invalid. Please request a new one.';
        break;
      case 'missing-android-pkg-name':
        errorMessage = 'Android package name must be provided for Android installation.';
        break;
      case 'missing-continue-uri':
        errorMessage = 'A continue URL must be provided in the request.';
        break;
      case 'missing-ios-bundle-id':
        errorMessage = 'iOS bundle ID must be provided for iOS installation.';
        break;

      // Generic Errors
      case 'operation-cancelled':
        errorMessage = 'Operation cancelled by user.';
        break;
      case 'timeout':
        errorMessage = 'The operation has timed out. Please try again.';
        break;

      default:
        if (error.message != null) {
          errorMessage = error.message;
        } else {
          errorMessage = 'An unexpected error occurred. Please try again.';
        }
    }

    return errorMessage;
  }

  static bool isNetworkError(dynamic error) {
    return error.code == 'network-request-failed';
  }

  static bool requiresReauthentication(dynamic error) {
    return error.code == 'requires-recent-login';
  }

  static bool isUserNotFound(dynamic error) {
    return error.code == 'user-not-found';
  }

  static bool isEmailAlreadyInUse(dynamic error) {
    return error.code == 'email-already-in-use';
  }

  static bool isWeakPassword(dynamic error) {
    return error.code == 'weak-password';
  }

  static bool isInvalidEmail(dynamic error) {
    return error.code == 'invalid-email';
  }

  static bool isTooManyRequests(dynamic error) {
    return error.code == 'too-many-requests';
  }

  static bool isUserDisabled(dynamic error) {
    return error.code == 'user-disabled';
  }

  static bool isOperationNotAllowed(dynamic error) {
    return error.code == 'operation-not-allowed';
  }

  static bool isPopupClosed(dynamic error) {
    return error.code == 'popup-closed-by-user';
  }

  static String getPasswordRequirements() {
    return '''
Password must:
• Be at least 8 characters long
• Contain at least one uppercase letter
• Contain at least one lowercase letter
• Contain at least one number
• Contain at least one special character
''';
  }

  static String getSocialAuthError(String provider) {
    return 'Failed to sign in with $provider. Please try again or use another method.';
  }

  static String getReauthenticationMessage() {
    return 'For security reasons, please log in again to continue.';
  }
}
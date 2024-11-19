import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      notifyListeners();
      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      notifyListeners();
      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting account: $e');
    }
  }
}

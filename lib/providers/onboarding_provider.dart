import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider with ChangeNotifier {
  bool _canPop = false;
  Future<bool> Function()? _onPop;
  bool _onboardingComplete = false;

  bool get canPop => _canPop;
  bool get onboardingComplete => _onboardingComplete;

  void setCanPop(bool value, {Future<bool> Function()? onPop}) {
    _canPop = value;
    _onPop = onPop;
    notifyListeners();
  }

  Future<bool> handlePop() async {
    if (_onPop != null) {
      return await _onPop!();
    }
    return _canPop;
  }

  Future<void> markOnboardingComplete() async {
    _onboardingComplete = true;
    await SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool('onboardingComplete', true),
    );
    notifyListeners();
  }

  Future<void> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    _onboardingComplete = false;
    await SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool('onboardingComplete', false),
    );
    notifyListeners();
  }
}

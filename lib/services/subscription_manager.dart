import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Fixed import
import '../models/subscription.dart';
import 'dart:convert';

class SubscriptionManager extends ChangeNotifier {
  static const String _storageKey = 'subscription_data';
  Subscription? _currentSubscription;
  DateTime? _expiryDate;
  final SharedPreferences _prefs;

  SubscriptionManager(this._prefs) {
    _loadSubscription();
  }

  Subscription? get currentSubscription => _currentSubscription;
  DateTime? get expiryDate => _expiryDate;
  bool get isActive => _currentSubscription != null && 
    _expiryDate != null && 
    _expiryDate!.isAfter(DateTime.now());

  void _loadSubscription() {
    final String? savedData = _prefs.getString(_storageKey);
    if (savedData != null) {
      final Map<String, dynamic> data = json.decode(savedData);
      _currentSubscription = Subscription.fromJson(data['subscription']);
      _expiryDate = DateTime.parse(data['expiry_date']);
      notifyListeners();
    }
  }

  Future<void> activateSubscription(Subscription subscription) async {
    _currentSubscription = subscription;
    _expiryDate = DateTime.now().add(subscription.duration);
    
    await _prefs.setString(_storageKey, json.encode({
      'subscription': subscription.toJson(),
      'expiry_date': _expiryDate!.toIso8601String(),
    }));
    
    notifyListeners();
  }

  Future<void> cancelSubscription() async {
    _currentSubscription = null;
    _expiryDate = null;
    await _prefs.remove(_storageKey);
    notifyListeners();
  }
}

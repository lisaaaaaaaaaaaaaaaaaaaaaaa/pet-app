import 'package:flutter/foundation.dart';
import 'package:shared_preferences.dart';

class SubscriptionManager extends ChangeNotifier {
  static const String _subscriptionKey = 'subscription_status';
  static const String _subscriptionIdKey = 'subscription_id';
  static const String _expiryDateKey = 'subscription_expiry';

  bool _isSubscribed = false;
  String? _subscriptionId;
  DateTime? _expiryDate;

  bool get isSubscribed => _isSubscribed;
  String? get subscriptionId => _subscriptionId;
  DateTime? get expiryDate => _expiryDate;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isSubscribed = prefs.getBool(_subscriptionKey) ?? false;
    _subscriptionId = prefs.getString(_subscriptionIdKey);
    final expiryMillis = prefs.getInt(_expiryDateKey);
    _expiryDate = expiryMillis != null 
        ? DateTime.fromMillisecondsSinceEpoch(expiryMillis)
        : null;
    notifyListeners();
  }

  Future<void> activateSubscription(String subscriptionId) async {
    final prefs = await SharedPreferences.getInstance();
    _isSubscribed = true;
    _subscriptionId = subscriptionId;
    _expiryDate = DateTime.now().add(const Duration(days: 30));
    
    await prefs.setBool(_subscriptionKey, true);
    await prefs.setString(_subscriptionIdKey, subscriptionId);
    await prefs.setInt(_expiryDateKey, _expiryDate!.millisecondsSinceEpoch);
    
    notifyListeners();
  }

  Future<void> cancelSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    _isSubscribed = false;
    _subscriptionId = null;
    _expiryDate = null;
    
    await prefs.setBool(_subscriptionKey, false);
    await prefs.remove(_subscriptionIdKey);
    await prefs.remove(_expiryDateKey);
    
    notifyListeners();
  }

  bool get isExpired {
    if (_expiryDate == null) return true;
    return DateTime.now().isAfter(_expiryDate!);
  }
}

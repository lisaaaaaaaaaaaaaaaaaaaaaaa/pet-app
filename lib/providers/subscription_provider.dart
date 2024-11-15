import 'package:flutter/foundation.dart';
import '../services/subscription_service.dart';
import '../models/subscription.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _subscriptionService;
  Subscription? _subscription;
  bool _isLoading = false;

  SubscriptionProvider(this._subscriptionService);

  bool get isSubscribed => _subscription?.isActive ?? false;
  bool get isLoading => _isLoading;
  Subscription? get subscription => _subscription;

  Future<void> startFreeTrial() async {
    _isLoading = true;
    notifyListeners();

    try {
      _subscription = await _subscriptionService.startTrial();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> subscribe() async {
    _isLoading = true;
    notifyListeners();

    try {
      _subscription = await _subscriptionService.subscribe();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelSubscription() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _subscriptionService.cancel();
      _subscription = null;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkSubscriptionStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _subscription = await _subscriptionService.getCurrentSubscription();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

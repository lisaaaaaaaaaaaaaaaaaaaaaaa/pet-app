// lib/providers/subscription_provider.dart

import 'package:flutter/foundation.dart';
import '../services/pet_service.dart';
import '../models/subscription.dart';
import 'dart:async';

class SubscriptionProvider with ChangeNotifier {
  final PetService _petService = PetService();
  Map<String, Subscription> _subscriptions = {};
  Map<String, DateTime> _lastUpdated = {};
  Map<String, Map<String, dynamic>> _subscriptionAnalytics = {};
  bool _isLoading = false;
  String? _error;
  Timer? _autoRefreshTimer;
  Timer? _expiryCheckTimer;
  Duration _cacheExpiration = const Duration(minutes: 30);
  bool _isInitialized = false;

  // Enhanced Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  SubscriptionProvider() {
    _setupTimers();
  }

  void _setupTimers() {
    // Refresh subscription data periodically
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _refreshAllSubscriptions(silent: true),
    );

    // Check for expiring subscriptions
    _expiryCheckTimer?.cancel();
    _expiryCheckTimer = Timer.periodic(
      const Duration(hours: 12),
      (_) => _checkExpiringSubscriptions(),
    );
  }

  // Enhanced subscription retrieval
  Future<Subscription?> getSubscriptionForPet(
    String petId, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh || _needsRefresh(petId)) {
      await loadSubscriptionStatus(petId);
    }
    return _subscriptions[petId];
  }

  // Check if data needs refresh
  bool _needsRefresh(String petId) {
    final lastUpdate = _lastUpdated[petId];
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) > _cacheExpiration;
  }

  // Enhanced subscription loading
  Future<void> loadSubscriptionStatus(
    String petId, {
    bool silent = false,
  }) async {
    try {
      if (!silent) {
        _isLoading = true;
        notifyListeners();
      }

      final subscriptionData = await _petService.getSubscriptionDetails(petId);
      final features = await _getAvailableFeatures(
        subscriptionData['level'] == 'premium',
        customFeatures: subscriptionData['customFeatures'],
      );

      _subscriptions[petId] = Subscription(
        petId: petId,
        level: subscriptionData['level'],
        expiryDate: subscriptionData['expiryDate']?.toDate(),
        features: features,
        autoRenew: subscriptionData['autoRenew'] ?? false,
        startDate: subscriptionData['startDate']?.toDate(),
        lastBillingDate: subscriptionData['lastBillingDate']?.toDate(),
        price: subscriptionData['price']?.toDouble(),
        currency: subscriptionData['currency'],
        paymentMethod: subscriptionData['paymentMethod'],
        status: subscriptionData['status'],
        customFeatures: subscriptionData['customFeatures'],
      );

      _lastUpdated[petId] = DateTime.now();
      await _updateSubscriptionAnalytics(petId);
      
      if (!silent) _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Failed to load subscription', e, stackTrace);
      if (!silent) rethrow;
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Enhanced premium upgrade
  Future<void> upgradeToPremium(
    String petId, {
    String? promoCode,
    String? paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validate current subscription status
      await _validateUpgradeEligibility(petId);

      final upgradeResult = await _petService.upgradeToPremium(
        petId: petId,
        promoCode: promoCode,
        paymentMethod: paymentMethod,
        metadata: {
          ...?metadata,
          'upgradedAt': DateTime.now().toIso8601String(),
          'platform': 'mobile',
          'previousLevel': _subscriptions[petId]?.level,
        },
      );

      await _processUpgradeResult(petId, upgradeResult);
      await loadSubscriptionStatus(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Failed to upgrade subscription', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ... (continued in next part)
  // Continuing lib/providers/subscription_provider.dart

  // Subscription validation and processing
  Future<void> _validateUpgradeEligibility(String petId) async {
    final currentSub = _subscriptions[petId];
    if (currentSub == null) {
      throw SubscriptionException('No subscription found for this pet');
    }
    if (currentSub.level == 'premium' && currentSub.status == 'active') {
      throw SubscriptionException('Already on premium plan');
    }
    if (currentSub.status == 'suspended') {
      throw SubscriptionException('Subscription is currently suspended');
    }
  }

  Future<void> _processUpgradeResult(
    String petId,
    Map<String, dynamic> result,
  ) async {
    if (result['status'] != 'success') {
      throw SubscriptionException(
        result['error'] ?? 'Upgrade failed: Unknown error'
      );
    }

    // Track upgrade analytics
    await _trackSubscriptionEvent(petId, 'upgrade', {
      'fromLevel': _subscriptions[petId]?.level,
      'toLevel': 'premium',
      'promoApplied': result['promoApplied'],
      'price': result['price'],
    });
  }

  // Enhanced subscription cancellation
  Future<void> cancelPremium(
    String petId, {
    required String reason,
    String? feedback,
    bool immediateEffect = false,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final cancellationResult = await _petService.cancelSubscription(
        petId: petId,
        reason: reason,
        feedback: feedback,
        immediateEffect: immediateEffect,
        metadata: {
          'cancelledAt': DateTime.now().toIso8601String(),
          'remainingDays': getDaysUntilExpiry(petId),
          'features': _subscriptions[petId]?.features,
        },
      );

      await _processCancellationResult(petId, cancellationResult);
      await loadSubscriptionStatus(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Failed to cancel subscription', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enhanced auto-renewal management
  Future<void> toggleAutoRenewal(
    String petId, {
    String? reason,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentSub = _subscriptions[petId];
      if (currentSub == null) {
        throw SubscriptionException('Subscription not found');
      }

      final newAutoRenewStatus = !currentSub.autoRenew;
      await _petService.updateAutoRenewal(
        petId: petId,
        autoRenew: newAutoRenewStatus,
        metadata: {
          'updatedAt': DateTime.now().toIso8601String(),
          'reason': reason,
          'previousStatus': currentSub.autoRenew,
        },
      );

      await _trackSubscriptionEvent(
        petId,
        'autoRenewal',
        {'status': newAutoRenewStatus},
      );

      await loadSubscriptionStatus(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Failed to update auto-renewal', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enhanced analytics methods
  Future<void> _updateSubscriptionAnalytics(String petId) async {
    try {
      final subscription = _subscriptions[petId];
      if (subscription == null) return;

      _subscriptionAnalytics[petId] = {
        'overview': {
          'status': subscription.status,
          'daysRemaining': getDaysUntilExpiry(petId),
          'totalFeatures': subscription.features.length,
          'usageStats': await _getFeatureUsageStats(petId),
        },
        'billing': {
          'currentPeriod': _getCurrentBillingPeriod(subscription),
          'lifetime': await _getLifetimeValue(petId),
          'nextBilling': _getNextBillingDate(subscription),
        },
        'features': await _analyzeFeatureUsage(petId),
        'trends': await _analyzeSubscriptionTrends(petId),
        'recommendations': _generateRecommendations(subscription),
      };
    } catch (e) {
      debugPrint('Failed to update subscription analytics: $e');
    }
  }

  Map<String, dynamic> generateSubscriptionReport(String petId) {
    final analytics = _subscriptionAnalytics[petId];
    if (analytics == null) return {};

    return {
      'summary': analytics['overview'],
      'billing': analytics['billing'],
      'features': analytics['features'],
      'trends': analytics['trends'],
      'recommendations': analytics['recommendations'],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Subscription monitoring
  Future<void> _checkExpiringSubscriptions() async {
    for (var entry in _subscriptions.entries) {
      if (isExpiringSoon(entry.key)) {
        await _handleExpiringSoon(entry.key);
      }
      if (isExpired(entry.key)) {
        await _handleExpired(entry.key);
      }
    }
  }

  Future<void> _handleExpiringSoon(String petId) async {
    final subscription = _subscriptions[petId];
    if (subscription == null) return;

    // Notify relevant systems about expiring subscription
    await _petService.notifySubscriptionExpiringSoon(
      petId: petId,
      daysRemaining: getDaysUntilExpiry(petId) ?? 0,
      autoRenewStatus: subscription.autoRenew,
    );
  }

  String _handleError(String operation, dynamic error, StackTrace stackTrace) {
    debugPrint('SubscriptionProvider Error: $operation');
    debugPrint('Error: $error');
    debugPrint('StackTrace: $stackTrace');
    return 'Failed to $operation: ${error.toString()}';
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _expiryCheckTimer?.cancel();
    super.dispose();
  }
}

class SubscriptionException implements Exception {
  final String message;
  SubscriptionException(this.message);

  @override
  String toString() => message;
}
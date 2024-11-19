import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logSubscription({
    required String id,
    required int amount,
    required String currency,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_started',
      parameters: {
        'subscription_id': id,
        'amount': amount,
        'currency': currency,
      },
    );
  }

  Future<void> logCancellation({
    required String id,
    required String reason,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_cancelled',
      parameters: {
        'subscription_id': id,
        'reason': reason,
      },
    );
  }
}

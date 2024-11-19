import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      if (!kDebugMode) {
        await _analytics.logEvent(
          name: name,
          parameters: parameters,
        );
      }
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> setUserProperties({
    String? userId,
    String? userRole,
    bool? isPremium,
  }) async {
    try {
      if (!kDebugMode) {
        if (userId != null) {
          await _analytics.setUserId(id: userId);
        }
        if (userRole != null) {
          await _analytics.setUserProperty(
            name: 'user_role',
            value: userRole,
          );
        }
        if (isPremium != null) {
          await _analytics.setUserProperty(
            name: 'is_premium',
            value: isPremium.toString(),
          );
        }
      }
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      if (!kDebugMode) {
        await _analytics.logScreenView(
          screenName: screenName,
          screenClass: screenClass,
        );
      }
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logPetAction({
    required String action,
    required String petId,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      final params = {
        'pet_id': petId,
        ...?additionalParams,
      };
      await logEvent('pet_$action', parameters: params);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logHealthEvent({
    required String eventType,
    required String petId,
    String? condition,
    Map<String, dynamic>? metrics,
  }) async {
    try {
      final params = {
        'pet_id': petId,
        if (condition != null) 'condition': condition,
        if (metrics != null) ...metrics,
      };
      await logEvent('health_$eventType', parameters: params);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logAppointment({
    required String action,
    required String appointmentId,
    required String petId,
    String? vetId,
    String? status,
  }) async {
    try {
      final params = {
        'appointment_id': appointmentId,
        'pet_id': petId,
        if (vetId != null) 'vet_id': vetId,
        if (status != null) 'status': status,
      };
      await logEvent('appointment_$action', parameters: params);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logSubscriptionEvent({
    required String action,
    required String userId,
    required String planType,
    String? source,
  }) async {
    try {
      final params = {
        'user_id': userId,
        'plan_type': planType,
        if (source != null) 'source': source,
      };
      await logEvent('subscription_$action', parameters: params);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logError({
    required String errorType,
    String? errorMessage,
    String? stackTrace,
  }) async {
    try {
      final params = {
        'error_type': errorType,
        if (errorMessage != null) 'error_message': errorMessage,
        if (stackTrace != null) 'stack_trace': stackTrace,
      };
      await logEvent('app_error', parameters: params);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logFeatureUsage({
    required String featureName,
    String? source,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      final params = {
        'feature_name': featureName,
        if (source != null) 'source': source,
        ...?additionalParams,
      };
      await logEvent('feature_used', parameters: params);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logSearch({
    required String searchTerm,
    required String searchType,
    int? resultCount,
  }) async {
    try {
      final params = {
        'search_term': searchTerm,
        'search_type': searchType,
        if (resultCount != null) 'result_count': resultCount,
      };
      await logEvent('search_performed', parameters: params);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logShare({
    required String contentType,
    required String contentId,
    String? platform,
  }) async {
    try {
      final params = {
        'content_type': contentType,
        'content_id': contentId,
        if (platform != null) 'platform': platform,
      };
      await logEvent('content_shared', parameters: params);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> setCurrentScreen(String screenName) async {
    try {
      if (!kDebugMode) {
        await _analytics.setCurrentScreen(screenName: screenName);
      }
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> resetAnalyticsData() async {
    try {
      if (!kDebugMode) {
        await _analytics.resetAnalyticsData();
      }
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }
}

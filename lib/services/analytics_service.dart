import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/analytics_helper.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logPetProfile({
    required String petId,
    required String petType,
    required String breed,
  }) async {
    await AnalyticsHelper.logEvent(
      name: 'pet_profile_created',
      parameters: {
        'pet_id': petId,
        'pet_type': petType,
        'breed': breed,
      },
    );
  }

  Future<void> logAppointment({
    required String appointmentId,
    required String type,
    required double cost,
  }) async {
    await AnalyticsHelper.logEvent(
      name: 'appointment_created',
      parameters: {
        'appointment_id': appointmentId,
        'type': type,
        'cost': cost,
      },
    );
  }

  Future<void> logSubscription({
    required String planId,
    required String planName,
    required double amount,
  }) async {
    await AnalyticsHelper.logEvent(
      name: 'subscription_purchased',
      parameters: {
        'plan_id': planId,
        'plan_name': planName,
        'amount': amount,
      },
    );
  }

  Future<void> setUserProperties({
    required String userId,
    String? userType,
    int? petCount,
  }) async {
    await _analytics.setUserId(id: userId);
    if (userType != null) {
      await _analytics.setUserProperty(name: 'user_type', value: userType);
    }
    if (petCount != null) {
      await _analytics.setUserProperty(
        name: 'pet_count',
        value: petCount.toString(),
      );
    }
  }
}

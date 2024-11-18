// import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHelper {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  static Future<void> setUserProperties({
    required String userId,
    String? userRole,
  }) async {
    await _analytics.setUserId(id: userId);
    if (userRole != null) {
      await _analytics.setUserProperty(name: 'user_role', value: userRole);
    }
  }

  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  static Future<void> logPetAdded({
    required String petType,
    required String breed,
  }) async {
    await logEvent(
      name: 'pet_added',
      parameters: {
        'pet_type': petType,
        'breed': breed,
      },
    );
  }

  static Future<void> logAppointmentBooked({
    required String appointmentType,
    required DateTime appointmentDate,
  }) async {
    await logEvent(
      name: 'appointment_booked',
      parameters: {
        'appointment_type': appointmentType,
        'appointment_date': appointmentDate.toIso8601String(),
      },
    );
  }

  static Future<void> logError({
    required String error,
    StackTrace? stackTrace,
  }) async {
    await logEvent(
      name: 'app_error',
      parameters: {
        'error_message': error,
        'stack_trace': stackTrace?.toString(),
      },
    );
  }
}

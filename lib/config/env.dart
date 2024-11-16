// lib/config/env.dart

class Environment {
  // API URLs
  static const String apiUrl = 'http://localhost:3000';
  
  // Stripe Keys
  static const String stripePublishableKey = 'pk_test_51QKRqqP3QmxDRtPcQyG5hVRo39SKi66wGJ7MfT3saHsXtWI5IYe2YCNE9knxHRJdIE4Y7Wnv4g414xfKMDQAUBFW0064OHkea7';
  
  // Feature Flags
  static const bool enableSubscriptions = true;
  static const bool enableTrialPeriod = true;
  
  // Subscription Settings
  static const int trialPeriodDays = 7;
  static const double monthlySubscriptionPrice = 10.0;
  
  // API Endpoints
  static String get createSubscriptionUrl => '$apiUrl/create-subscription';
  static String get cancelSubscriptionUrl => '$apiUrl/cancel-subscription';
  static String get updatePaymentMethodUrl => '$apiUrl/update-payment-method';
}
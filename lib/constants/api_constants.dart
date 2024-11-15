class ApiConstants {
  // Base URLs
  static const String productionBaseUrl = 'https://api.goldenyears.com';
  static const String stagingBaseUrl = 'https://staging-api.goldenyears.com';
  static const String developmentBaseUrl = 'https://dev-api.goldenyears.com';

  // API Versions
  static const String apiV1 = '/api/v1';
  static const String apiV2 = '/api/v2';

  // Authentication Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // User Endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String changePassword = '/user/password/change';
  static const String deleteAccount = '/user/delete';

  // Pet Endpoints
  static const String pets = '/pets';
  static const String petDetails = '/pets/{id}';
  static const String petHealth = '/pets/{id}/health';
  static const String petVaccinations = '/pets/{id}/vaccinations';
  static const String petMedications = '/pets/{id}/medications';

  // Health Record Endpoints
  static const String healthRecords = '/health-records';
  static const String healthRecordDetails = '/health-records/{id}';
  static const String healthTimeline = '/health-records/timeline';

  // Appointment Endpoints
  static const String appointments = '/appointments';
  static const String appointmentDetails = '/appointments/{id}';
  static const String appointmentTypes = '/appointments/types';

  // Care Team Endpoints
  static const String careTeam = '/care-team';
  static const String careProviderDetails = '/care-team/{id}';
  static const String providerTypes = '/care-team/provider-types';

  // Reminder Endpoints
  static const String reminders = '/reminders';
  static const String reminderDetails = '/reminders/{id}';
  static const String reminderTypes = '/reminders/types';

  // Payment Endpoints
  static const String payments = '/payments';
  static const String paymentMethods = '/payments/methods';
  static const String subscriptions = '/subscriptions';
  static const String subscriptionPlans = '/subscriptions/plans';

  // Headers
  static const String authHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';
  static const String apiKeyHeader = 'X-API-Key';

  // Content Types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormData = 'multipart/form-data';

  // Error Codes
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int serverError = 500;
}

class RouteConstants {
  // Authentication Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';

  // Main App Routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Pet Management
  static const String pets = '/pets';
  static const String addPet = '/pets/add';
  static const String editPet = '/pets/edit';
  static const String petDetails = '/pets/details';
  static const String petHealth = '/pets/health';
  static const String petVaccinations = '/pets/vaccinations';

  // Health Records
  static const String healthRecords = '/health-records';
  static const String addHealthRecord = '/health-records/add';
  static const String editHealthRecord = '/health-records/edit';
  static const String healthTimeline = '/health-records/timeline';

  // Appointments
  static const String appointments = '/appointments';
  static const String addAppointment = '/appointments/add';
  static const String editAppointment = '/appointments/edit';
  static const String appointmentDetails = '/appointments/details';

  // Care Team
  static const String careTeam = '/care-team';
  static const String addCareProvider = '/care-team/add';
  static const String editCareProvider = '/care-team/edit';
  static const String providerDetails = '/care-team/details';

  // Reminders
  static const String reminders = '/reminders';
  static const String addReminder = '/reminders/add';
  static const String editReminder = '/reminders/edit';

  // Subscription & Payment
  static const String subscription = '/subscription';
  static const String payment = '/payment';
  static const String paymentHistory = '/payment/history';
  static const String addPaymentMethod = '/payment/add-method';
}

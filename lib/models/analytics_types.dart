enum AnalyticsEventType {
  petAdded,
  appointmentBooked,
  medicationAdded,
  reminderSet,
  profileUpdated,
  subscriptionPurchased,
  healthRecordAdded,
  careTeamMemberAdded,
  feedingScheduleUpdated,
  weightRecorded,
  activityLogged,
  documentUploaded,
  vaccineRecorded,
  behaviorLogged,
  mealLogged
}

class AnalyticsParameters {
  static const String userId = 'user_id';
  static const String petId = 'pet_id';
  static const String petType = 'pet_type';
  static const String breed = 'breed';
  static const String appointmentType = 'appointment_type';
  static const String medicationType = 'medication_type';
  static const String reminderType = 'reminder_type';
  static const String subscriptionPlan = 'subscription_plan';
  static const String amount = 'amount';
  static const String currency = 'currency';
  static const String duration = 'duration';
  static const String success = 'success';
  static const String errorMessage = 'error_message';
  static const String source = 'source';
  static const String category = 'category';
  static const String action = 'action';
  static const String value = 'value';
  static const String method = 'method';
}

class AnalyticsEvents {
  static const String appOpen = 'app_open';
  static const String signUp = 'sign_up';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String addPet = 'add_pet';
  static const String updatePet = 'update_pet';
  static const String deletePet = 'delete_pet';
  static const String bookAppointment = 'book_appointment';
  static const String addMedication = 'add_medication';
  static const String setReminder = 'set_reminder';
  static const String updateProfile = 'update_profile';
  static const String purchaseSubscription = 'purchase_subscription';
  static const String cancelSubscription = 'cancel_subscription';
  static const String addHealthRecord = 'add_health_record';
  static const String addCareTeamMember = 'add_care_team_member';
  static const String updateFeedingSchedule = 'update_feeding_schedule';
  static const String recordWeight = 'record_weight';
  static const String logActivity = 'log_activity';
  static const String uploadDocument = 'upload_document';
  static const String recordVaccine = 'record_vaccine';
  static const String logBehavior = 'log_behavior';
  static const String logMeal = 'log_meal';
  static const String shareRecord = 'share_record';
  static const String exportData = 'export_data';
  static const String searchPerformed = 'search_performed';
  static const String filterApplied = 'filter_applied';
  static const String errorOccurred = 'error_occurred';
}

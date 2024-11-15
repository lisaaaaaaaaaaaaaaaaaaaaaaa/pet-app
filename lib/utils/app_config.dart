class AppConfig {
  // App Information
  static const String appName = 'PawTracker';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appPackageName = 'com.pawtracker.app';

  // API Configuration
  static const String apiBaseUrl = 'https://api.pawtracker.com';
  static const int apiTimeout = 30; // seconds
  static const int maxRetries = 3;

  // Firebase Configuration
  static const String firebaseRegion = 'us-central1';
  static const int cacheDuration = 7; // days
  static const int maxCacheSize = 10 * 1024 * 1024; // 10MB
  static const bool enableFirebaseLogging = false;

  // Authentication
  static const int otpTimeout = 60; // seconds
  static const int sessionTimeout = 30; // days
  static const int maxLoginAttempts = 5;
  static const int lockoutDuration = 15; // minutes
  static const bool requireEmailVerification = true;

  // Storage
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxImageDimension = 2048; // pixels
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const String defaultAvatarUrl = 'assets/images/default_avatar.png';

  // Cache Configuration
  static const Duration defaultCacheDuration = Duration(hours: 24);
  static const int maxCacheEntries = 100;
  static const bool enableOfflineCache = true;

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashScreenDuration = Duration(seconds: 2);
  static const Duration toastDuration = Duration(seconds: 3);
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;

  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableEmailNotifications = true;
  static const bool enableInAppMessaging = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePerformanceMonitoring = true;

  // Social Integration
  static const bool enableGoogleSignIn = true;
  static const bool enableFacebookSignIn = true;
  static const bool enableAppleSignIn = true;
  static const bool enableTwitterSignIn = false;

  // App Limits
  static const int maxPetsPerUser = 10;
  static const int maxPhotosPerPet = 50;
  static const int maxRemindersPerPet = 20;
  static const int maxNotesPerPet = 100;

  // Date Formats
  static const String defaultDateFormat = 'MMM dd, yyyy';
  static const String defaultTimeFormat = 'hh:mm a';
  static const String defaultDateTimeFormat = 'MMM dd, yyyy hh:mm a';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiTimeFormat = 'HH:mm:ss';
  static const String apiDateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'';

  // Error Messages
  static const String defaultErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String sessionExpiredMessage = 'Your session has expired. Please log in again.';
  static const String maintenanceMessage = 'We\'re under maintenance. Please try again later.';

  // Support
  static const String supportEmail = 'support@pawtracker.com';
  static const String privacyPolicyUrl = 'https://pawtracker.com/privacy';
  static const String termsOfServiceUrl = 'https://pawtracker.com/terms';
  static const String helpCenterUrl = 'https://pawtracker.com/help';
  static const String appStoreUrl = 'https://apps.apple.com/app/pawtracker';
  static const String playStoreUrl = 'https://play.google.com/store/apps/pawtracker';

  // Analytics Events
  static const String eventAppOpen = 'app_open';
  static const String eventLogin = 'user_login';
  static const String eventSignUp = 'user_signup';
  static const String eventAddPet = 'add_pet';
  static const String eventAddRecord = 'add_record';
  static const String eventShareRecord = 'share_record';

  // Cache Keys
  static const String userCacheKey = 'user_data';
  static const String petsCacheKey = 'pets_data';
  static const String settingsCacheKey = 'app_settings';
  static const String themeCacheKey = 'app_theme';

  // Notification Channels
  static const String reminderChannelId = 'reminders';
  static const String reminderChannelName = 'Reminders';
  static const String alertChannelId = 'alerts';
  static const String alertChannelName = 'Alerts';
  static const String updateChannelId = 'updates';
  static const String updateChannelName = 'Updates';

  // App Settings
  static const bool defaultNotificationsEnabled = true;
  static const bool defaultDarkModeEnabled = false;
  static const String defaultLanguage = 'en';
    // ... continuing from defaultTimeZone
  static const String defaultTimeZone = 'UTC';
  static const int defaultReminderTime = 30; // minutes before
  static const String defaultCurrency = 'USD';
  static const int defaultPageSize = 20;

  // Media Limits
  static const int maxVideoLength = 60; // seconds
  static const int maxAudioLength = 300; // seconds
  static const int maxFileSize = 15 * 1024 * 1024; // 15MB
  static const List<String> allowedFileTypes = ['pdf', 'doc', 'docx', 'txt'];

  // Security
  static const bool enforceStrongPassword = true;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int maxLoginSessionDuration = 30; // days
  static const bool enableBiometricAuth = true;
  static const bool enableTwoFactorAuth = true;

  // Performance
  static const int imageCacheMaxSize = 100;
  static const bool enableImageCompression = true;
  static const double imageCompressionQuality = 0.8;
  static const bool enableLazyLoading = true;
  static const int lazyLoadingThreshold = 5;

  // Development
  static const bool isDevelopment = !bool.fromEnvironment('dart.vm.product');
  static const bool enableDebugLogs = isDevelopment;
  static const bool showDebugBanner = isDevelopment;
  static const bool mockServices = isDevelopment;
  static const bool enableTestMode = isDevelopment;

  // Regional
  static const List<String> supportedLocales = ['en', 'es', 'fr', 'de'];
  static const List<String> supportedCountries = ['US', 'CA', 'GB', 'AU'];
  static const Map<String, String> countryDialCodes = {
    'US': '+1',
    'CA': '+1',
    'GB': '+44',
    'AU': '+61',
  };

  // App Store Review
  static const int reviewPromptThreshold = 5;
  static const Duration reviewPromptInterval = Duration(days: 30);
  static const int minimumDaysBeforeReview = 3;

  // Deep Linking
  static const String appScheme = 'pawtracker';
  static const String universalLinkDomain = 'pawtracker.page.link';
  static const Map<String, String> deepLinkPaths = {
    'pet': '/pet/:id',
    'record': '/record/:id',
    'reminder': '/reminder/:id',
    'profile': '/profile',
    'settings': '/settings',
  };

  // Rate Limiting
  static const int maxApiRequestsPerMinute = 60;
  static const int maxFileUploadsPerDay = 50;
  static const int maxSearchQueriesPerMinute = 10;

  // Health Metrics
  static const List<String> weightUnits = ['kg', 'lbs'];
  static const List<String> heightUnits = ['cm', 'in'];
  static const List<String> temperatureUnits = ['°C', '°F'];
  static const Map<String, double> unitConversions = {
    'kg_to_lbs': 2.20462,
    'cm_to_in': 0.393701,
    'c_to_f': 1.8, // Plus 32
  };

  // Pet Categories
  static const List<String> petTypes = ['Dog', 'Cat', 'Bird', 'Fish', 'Other'];
  static const List<String> petSizes = ['Small', 'Medium', 'Large'];
  static const List<String> petGenders = ['Male', 'Female'];
  static const List<String> petAgeGroups = ['Puppy/Kitten', 'Adult', 'Senior'];

  // Reminder Types
  static const List<String> reminderTypes = [
    'Medication',
    'Vaccination',
    'Grooming',
    'Vet Visit',
    'Food',
    'Exercise',
    'Other',
  ];

  // Health Record Categories
  static const List<String> healthCategories = [
    'Vaccination',
    'Medication',
    'Surgery',
    'Checkup',
    'Test Results',
    'Allergies',
    'Conditions',
  ];

  // App Routes
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String petProfileRoute = '/pet/:id';
  static const String addPetRoute = '/add-pet';
  static const String addRecordRoute = '/add-record';
  static const String viewRecordRoute = '/record/:id';

  // Do not instantiate this class
  AppConfig._();
}
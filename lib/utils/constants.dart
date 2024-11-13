class Constants {
  // API endpoints
  static const String baseUrl = 'your_api_base_url';
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String isFirstTimeKey = 'is_first_time';
  
  // Validation
  static const int minPasswordLength = 6;
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
}
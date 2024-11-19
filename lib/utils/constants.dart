
class Constants {
  // App Dimensions
  static const double appBarHeight = 56.0;
  static const double bottomNavBarHeight = 60.0;
  static const double fabSize = 56.0;
  static const double toolbarHeight = 56.0;
  static const double statusBarHeight = 24.0;

  // Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 40.0;

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 48.0;

  // Font Sizes
  static const double fontXS = 12.0;
  static const double fontS = 14.0;
  static const double fontM = 16.0;
  static const double fontL = 18.0;
  static const double fontXL = 20.0;
  static const double fontXXL = 24.0;
  static const double fontHuge = 32.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 2);

  // Card Dimensions
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 12.0;
  static const double cardPadding = 16.0;
  static const double cardImageHeight = 200.0;
  static const double cardAvatarSize = 40.0;

  // Button Dimensions
  static const double buttonHeight = 48.0;
  static const double buttonBorderRadius = 12.0;
  static const double buttonElevation = 0.0;
  static const double buttonIconSize = 24.0;

  // Input Field Dimensions
  static const double inputHeight = 48.0;
  static const double inputBorderRadius = 12.0;
  static const double inputIconSize = 24.0;

  // List Item Dimensions
  static const double listItemHeight = 72.0;
  static const double listItemPadding = 16.0;
  static const double listDividerHeight = 1.0;

  // Image Dimensions
  static const double avatarSizeS = 32.0;
  static const double avatarSizeM = 48.0;
  static const double avatarSizeL = 64.0;
  static const double avatarSizeXL = 96.0;
  static const double thumbnailSize = 80.0;

  // Bottom Sheet
  static const double bottomSheetBorderRadius = 24.0;
  static const double bottomSheetHandleWidth = 40.0;
  static const double bottomSheetHandleHeight = 4.0;
  static const double bottomSheetMinHeight = 0.2;
  static const double bottomSheetMaxHeight = 0.9;

  // Dialog
  static const double dialogBorderRadius = 24.0;
  static const double dialogWidth = 320.0;
  static const double dialogPadding = 24.0;
  static const double dialogIconSize = 64.0;

  // Progress Indicators
  static const double progressIndicatorSize = 24.0;
  static const double progressIndicatorStrokeWidth = 2.0;
  static const double linearProgressHeight = 4.0;

  // Grid
  static const int gridCrossAxisCount = 2;
  static const double gridSpacing = 16.0;
  static const double gridAspectRatio = 1.0;

  // Scroll
  static const double scrollThreshold = 200.0;
  static const double scrollBarThickness = 6.0;
  static const Duration scrollDuration = Duration(milliseconds: 300);

  // Shimmer Effect
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const double shimmerOpacity = 0.3;

  // Pet Profile
  static const double petProfileImageHeight = 250.0;
  static const double petProfileAvatarSize = 120.0;
  static const double petStatsCardHeight = 100.0;

  // Health Records
  static const double healthTimelineWidth = 2.0;
  static const double healthTimelineDotSize = 16.0;
  static const double healthCardHeight = 120.0;

  // Charts
  static const double chartHeight = 200.0;
  static const double chartBarWidth = 16.0;
  static const double chartLineWidth = 2.0;
  static const int chartAnimationDuration = 500;

  // Map
  static const double mapHeight = 200.0;
  static const double mapZoomLevel = 15.0;
  static const double mapMarkerSize = 32.0;

  // Assets Paths
  static const String imagePath = 'assets/images';
  static const String iconPath = 'assets/icons';
  static const String lottiePath = 'assets/lottie';
  static const String svgPath = 'assets/svg';

  // Asset Names
  static const String logoImage = '$imagePath/logo.png';
  static const String placeholderImage = '$imagePath/placeholder.png';
  static const String errorImage = '$imagePath/error.png';
  static const String emptyImage = '$imagePath/empty.png';
  static const String successAnimation = '$lottiePath/success.json';
  static const String loadingAnimation = '$lottiePath/loading.json';

  // Regular Expressions
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );
  static final RegExp phoneRegex = RegExp(
    r'^\+?[\d\s-]{10,}$',
  );
  static final RegExp urlRegex = RegExp(
    r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
  );

  // Do not instantiate this class
  Constants._();
}
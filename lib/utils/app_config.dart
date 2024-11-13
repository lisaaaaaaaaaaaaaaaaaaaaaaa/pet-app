import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static late PackageInfo packageInfo;
  static late SharedPreferences prefs;
  static late String deviceId;
  static late Map<String, dynamic> deviceInfo;

  static Future<void> initialize() async {
    try {
      // Initialize PackageInfo
      packageInfo = await PackageInfo.fromPlatform();

      // Initialize SharedPreferences
      prefs = await SharedPreferences.getInstance();

      // Get Device Info
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Theme.of(GetPlatformContext().context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
        deviceInfo = {
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'model': iosInfo.model,
          'localizedModel': iosInfo.localizedModel,
        };
      } else {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id;
        deviceInfo = {
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'manufacturer': androidInfo.manufacturer,
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
      }
    } catch (e) {
      debugPrint('Error initializing AppConfig: $e');
      rethrow;
    }
  }

  // Getters for package info
  static String get appName => packageInfo.appName;
  static String get packageName => packageInfo.packageName;
  static String get version => packageInfo.version;
  static String get buildNumber => packageInfo.buildNumber;
  
  // Preference helpers
  static Future<void> setFirstTime(bool value) async {
    await prefs.setBool('isFirstTime', value);
  }
  
  static bool get isFirstTime => prefs.getBool('isFirstTime') ?? true;
  
  static Future<void> clearPreferences() async {
    await prefs.clear();
  }
}

// Helper class to get platform context
class GetPlatformContext {
  static final GetPlatformContext _instance = GetPlatformContext._internal();
  late BuildContext _context;

  factory GetPlatformContext() {
    return _instance;
  }

  GetPlatformContext._internal();

  void init(BuildContext context) {
    _context = context;
  }

  BuildContext get context => _context;
}
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as log_package;

class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  final log_package.Logger _logger = log_package.Logger(
    printer: log_package.PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: kDebugMode ? log_package.Level.verbose : log_package.Level.nothing,
  );

  // Debug log
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _instance._logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  // Info log
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _instance._logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  // Warning log
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _instance._logger.w(message, error: error, stackTrace: stackTrace);
    }
    _logToCrashlytics(
      message,
      error: error,
      stackTrace: stackTrace,
      severity: 'WARNING',
    );
  }

  // Error log
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _instance._logger.e(message, error: error, stackTrace: stackTrace);
    }
    _logToCrashlytics(
      message,
      error: error,
      stackTrace: stackTrace,
      severity: 'ERROR',
    );
  }

  // Fatal log
  static void f(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _instance._logger.f(message, error: error, stackTrace: stackTrace);
    }
    _logToCrashlytics(
      message,
      error: error,
      stackTrace: stackTrace,
      severity: 'FATAL',
    );
  }

  // Log to Crashlytics
  static Future<void> _logToCrashlytics(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    String severity = 'INFO',
  }) async {
    try {
      // Only log to Crashlytics in production
      if (!kDebugMode) {
        await FirebaseCrashlytics.instance.recordError(
          error ?? message,
          stackTrace,
          reason: message,
          fatal: severity == 'FATAL',
        );

        // Add custom keys to Crashlytics report
        await FirebaseCrashlytics.instance.setCustomKey('severity', severity);
        await FirebaseCrashlytics.instance.setCustomKey('timestamp', DateTime.now().toIso8601String());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log to Crashlytics: $e');
      }
    }
  }

  // Log network request
  static void logRequest(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (kDebugMode) {
      _instance._logger.i(
        'API Request:\n'
        'Method: $method\n'
        'URL: $url\n'
        'Headers: ${headers ?? 'None'}\n'
        'Body: ${body ?? 'None'}',
      );
    }
  }

  // Log network response
  static void logResponse(
    String url,
    int statusCode,
    dynamic body, {
    Map<String, dynamic>? headers,
  }) {
    if (kDebugMode) {
      _instance._logger.i(
        'API Response:\n'
        'URL: $url\n'
        'Status Code: $statusCode\n'
        'Headers: ${headers ?? 'None'}\n'
        'Body: $body',
      );
    }
  }

  // Log user action
  static void logUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) {
    if (kDebugMode) {
      _instance._logger.i(
        'User Action:\n'
        'Action: $action\n'
        'Parameters: ${parameters ?? 'None'}',
      );
    }
  }

  // Log app lifecycle event
  static void logLifecycleEvent(String event) {
    if (kDebugMode) {
      _instance._logger.i('Lifecycle Event: $event');
    }
  }

  // Log performance metric
  static void logPerformance(String operation, int durationMs) {
    if (kDebugMode) {
      _instance._logger.i(
        'Performance:\n'
        'Operation: $operation\n'
        'Duration: ${durationMs}ms',
      );
    }
  }

  // Clear logs (for testing purposes)
  static void clearLogs() {
    // Implementation depends on how you're storing logs
    if (kDebugMode) {
      print('Logs cleared');
    }
  }

  // Enable/disable logging
  static void setLoggingEnabled(bool enabled) {
    _instance._logger.level = enabled
        ? log_package.Level.verbose
        : log_package.Level.nothing;
  }
}
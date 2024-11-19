import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../monitoring/analytics_service.dart';
import '../cache/cache_service.dart';

abstract class BaseService {
  final Logger logger = Logger();
  final AnalyticsService analytics = AnalyticsService();
  final CacheService cache = CacheService();
  
  Future<void> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw ServiceException('No internet connection');
    }
  }

  Future<T> withRetry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e, stackTrace) {
        attempts++;
        if (attempts == maxAttempts) {
          logger.e('Operation failed after $maxAttempts attempts', e, stackTrace);
          FirebaseCrashlytics.instance.recordError(e, stackTrace);
          rethrow;
        }
        await Future.delayed(delay * attempts);
      }
    }
    throw ServiceException('Retry operation failed');
  }

  Future<T> withCache<T>({
    required String key,
    required Future<T> Function() fetchData,
    Duration? duration,
  }) async {
    try {
      final cachedData = await cache.get<T>(key);
      if (cachedData != null) {
        logger.d('Cache hit for key: $key');
        return cachedData;
      }
      final data = await fetchData();
      await cache.set(key, data, duration: duration);
      return data;
    } catch (e, stackTrace) {
      logger.e('Cache operation failed', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      rethrow;
    }
  }

  Future<void> clearCache(String key) async {
    await cache.delete(key);
  }
}

class ServiceException implements Exception {
  final String message;
  ServiceException(this.message);

  @override
  String toString() => message;
}

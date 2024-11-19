import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/base_service.dart';
import '../models/pain_record.dart';
import '../models/pain_location.dart';
import '../models/pain_intensity.dart';
import '../utils/exceptions.dart';

class PainTrackingService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static final PainTrackingService _instance = PainTrackingService._internal();
  factory PainTrackingService() => _instance;
  PainTrackingService._internal();

  // Collection References
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference _petPainRef(String userId, String petId) =>
      _usersRef.doc(userId).collection('pets').doc(petId).collection('pain_records');

  // Pain Record Management
  Future<void> addPainRecord(String userId, String petId, PainRecord record) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petPainRef(userId, petId)
            .doc(record.id)
            .set(record.toJson());
            
        await _updatePainMetrics(userId, petId);
        logger.i('Added pain record: ${record.id}');
        analytics.logEvent('pain_record_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding pain record', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PainTrackingException('Error adding pain record: $e');
    }
  }

  Future<List<PainRecord>> getPainHistory(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
    PainLocation? location,
    int? limit,
  }) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'pain_history_${userId}_$petId',
        duration: const Duration(hours: 1),
        fetchData: () async {
          var query = _petPainRef(userId, petId)
              .orderBy('timestamp', descending: true);

          if (startDate != null) {
            query = query.where('timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
          }

          if (endDate != null) {
            query = query.where('timestamp',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate));
          }

          if (location != null) {
            query = query.where('location', isEqualTo: location.toString());
          }

          if (limit != null) {
            query = query.limit(limit);
          }

          final snapshot = await query.get();
          return snapshot.docs
              .map((doc) => PainRecord.fromJson(doc.data()))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting pain history', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PainTrackingException('Error getting pain history: $e');
    }
  }

  Stream<List<PainRecord>> streamPainRecords(String userId, String petId) {
    try {
      return _petPainRef(userId, petId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => PainRecord.fromJson(doc.data()))
              .toList());
    } catch (e, stackTrace) {
      logger.e('Error streaming pain records', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PainTrackingException('Error streaming pain records: $e');
    }
  }

  // Pain Analysis
  Future<Map<String, dynamic>> getPainAnalytics(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await checkConnectivity();
      
      final records = await getPainHistory(
        userId,
        petId,
        startDate: startDate,
        endDate: endDate,
      );

      return _calculatePainAnalytics(records);
    } catch (e, stackTrace) {
      logger.e('Error getting pain analytics', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PainTrackingException('Error getting pain analytics: $e');
    }
  }

  Future<Map<PainLocation, int>> getPainLocationFrequency(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final records = await getPainHistory(
        userId,
        petId,
        startDate: startDate,
        endDate: endDate,
      );

      return _calculateLocationFrequency(records);
    } catch (e, stackTrace) {
      logger.e('Error getting pain location frequency', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PainTrackingException('Error getting pain location frequency: $e');
    }
  }

  Future<List<PainIntensityTrend>> getPainIntensityTrends(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
    PainLocation? location,
  }) async {
    try {
      final records = await getPainHistory(
        userId,
        petId,
        startDate: startDate,
        endDate: endDate,
        location: location,
      );

      return _calculateIntensityTrends(records);
    } catch (e, stackTrace) {
      logger.e('Error getting pain intensity trends', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PainTrackingException('Error getting pain intensity trends: $e');
    }
  }

  // Helper Methods
  Future<void> _updatePainMetrics(String userId, String petId) async {
    try {
      final recentRecords = await getPainHistory(
        userId,
        petId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );

      final metrics = _calculatePainAnalytics(recentRecords);

      await _petPainRef(userId, petId).doc('metrics').set({
        'lastUpdated': FieldValue.serverTimestamp(),
        'averageIntensity': metrics['averageIntensity'],
        'mostFrequentLocation': metrics['mostFrequentLocation'],
        'painFrequency': metrics['painFrequency'],
        'trendDirection': metrics['trendDirection'],
      });
    } catch (e) {
      logger.e('Error updating pain metrics', e);
    }
  }

  Map<String, dynamic> _calculatePainAnalytics(List<PainRecord> records) {
    if (records.isEmpty) {
      return {
        'averageIntensity': 0.0,
        'mostFrequentLocation': null,
        'painFrequency': 0.0,
        'trendDirection': 'stable',
      };
    }

    // Calculate average intensity
    final totalIntensity = records.fold<double>(
      0,
      (sum, record) => sum + record.intensity.value,
    );
    final averageIntensity = totalIntensity / records.length;

    // Find most frequent location
    final locationFrequency = _calculateLocationFrequency(records);
    final mostFrequentLocation = locationFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Calculate pain frequency (episodes per week)
    final duration = records.first.timestamp.difference(records.last.timestamp);
    final weeks = duration.inDays / 7;
    final painFrequency = records.length / (weeks > 0 ? weeks : 1);

    // Determine trend direction
    final trendDirection = _calculateTrendDirection(records);

    return {
      'averageIntensity': averageIntensity,
      'mostFrequentLocation': mostFrequentLocation.toString(),
      'painFrequency': painFrequency,
      'trendDirection': trendDirection,
    };
  }

  Map<PainLocation, int> _calculateLocationFrequency(List<PainRecord> records) {
    final frequency = <PainLocation, int>{};
    for (var record in records) {
      frequency[record.location] = (frequency[record.location] ?? 0) + 1;
    }
    return frequency;
  }

  List<PainIntensityTrend> _calculateIntensityTrends(List<PainRecord> records) {
    if (records.isEmpty) return [];

    // Group records by day
    final dailyRecords = <DateTime, List<PainRecord>>{};
    for (var record in records) {
      final date = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      dailyRecords[date] = [...(dailyRecords[date] ?? []), record];
    }

    // Calculate daily averages
    return dailyRecords.entries.map((entry) {
      final averageIntensity = entry.value.fold<double>(
            0,
            (sum, record) => sum + record.intensity.value,
          ) /
          entry.value.length;

      return PainIntensityTrend(
        date: entry.key,
        averageIntensity: averageIntensity,
        recordCount: entry.value.length,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  String _calculateTrendDirection(List<PainRecord> records) {
    if (records.length < 2) return 'stable';

    // Calculate linear regression
    final xValues = records
        .map((r) => r.timestamp.millisecondsSinceEpoch.toDouble())
        .toList();
    final yValues = records.map((r) => r.intensity.value.toDouble()).toList();

    final slope = _calculateSlope(xValues, yValues);

    if (slope > 0.1) {
      return 'increasing';
    } else if (slope < -0.1) {
      return 'decreasing';
    } else {
      return 'stable';
    }
  }

  double _calculateSlope(List<double> x, List<double> y) {
    final n = x.length;
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumXX = List.generate(n, (i) => x[i] * x[i]).reduce((a, b) => a + b);

    return (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
  }
}

class PainTrackingException implements Exception {
  final String message;
  PainTrackingException(this.message);

  @override
  String toString() => message;
}

class PainIntensityTrend {
  final DateTime date;
  final double averageIntensity;
  final int recordCount;

  PainIntensityTrend({
    required this.date,
    required this.averageIntensity,
    required this.recordCount,
  });
}

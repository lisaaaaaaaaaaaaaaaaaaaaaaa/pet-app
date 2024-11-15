import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../services/pet_service.dart';
import '../models/pet.dart';
import '../utils/logger.dart';
import 'dart:async';
import 'dart:math';

class AnalyticsProvider with ChangeNotifier {
  final PetService _petService;
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;
  final Logger _logger;
  
  Map<String, Map<String, dynamic>> _analyticsData = {};
  Map<String, DateTime> _lastUpdated = {};
  Map<String, bool> _isRefreshing = {};
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  final Duration _cacheExpiration;
  final Duration _refreshInterval;

  AnalyticsProvider({
    PetService? petService,
    FirebaseFirestore? firestore,
    FirebaseAnalytics? analytics,
    Logger? logger,
    Duration? cacheExpiration,
    Duration? refreshInterval,
  }) : _petService = petService ?? PetService(),
       _firestore = firestore ?? FirebaseFirestore.instance,
       _analytics = analytics ?? FirebaseAnalytics.instance,
       _logger = logger ?? Logger(),
       _cacheExpiration = cacheExpiration ?? const Duration(hours: 1),
       _refreshInterval = refreshInterval ?? const Duration(minutes: 15) {
    _setupPeriodicRefresh();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, DateTime> get lastUpdated => _lastUpdated;

  void _setupPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      _refreshAllAnalytics(silent: true);
    });
  }

  Future<void> _refreshAllAnalytics({bool silent = false}) async {
    try {
      for (var petId in _analyticsData.keys) {
        if (_needsRefresh(petId)) {
          await loadAnalytics(petId, silent: silent);
        }
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to refresh analytics', e, stackTrace);
    }
  }

  bool _needsRefresh(String petId) {
    final lastUpdate = _lastUpdated[petId];
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) > _cacheExpiration;
  }

  Future<Map<String, dynamic>?> getAnalyticsForPet(
    String petId, {
    bool forceRefresh = false,
    AnalyticsConfig? config,
  }) async {
    try {
      if (forceRefresh || _needsRefresh(petId)) {
        await loadAnalytics(petId, config: config);
      }
      return _analyticsData[petId];
    } catch (e, stackTrace) {
      _logger.error('Failed to get analytics for pet', e, stackTrace);
      rethrow;
    }
  }

  Future<void> loadAnalytics(
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
    bool silent = false,
    AnalyticsConfig? config,
  }) async {
    if (_isRefreshing[petId] == true) return;

    try {
      if (!silent) {
        _isLoading = true;
        notifyListeners();
      }

      _isRefreshing[petId] = true;

      // Load from Firestore first
      final firestoreData = await _loadFromFirestore(petId);
      
      // If Firestore data is fresh enough, use it
      if (firestoreData != null && 
          _isDataFresh(firestoreData['timestamp'] as Timestamp?)) {
        _updateAnalyticsData(petId, firestoreData['data'] as Map<String, dynamic>);
      } else {
        // Otherwise fetch fresh data
        final analytics = await _petService.getAnalytics(
          petId: petId,
          startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
          endDate: endDate ?? DateTime.now(),
        );

        _validateAnalyticsData(analytics);
        final processedData = _processAnalyticsData(analytics);
        
        // Store in Firestore for caching
        await _saveToFirestore(petId, processedData);
        
        _updateAnalyticsData(petId, processedData);
      }

      // Log successful analytics load
      await _analytics.logEvent(
        name: 'analytics_loaded',
        parameters: {
          'pet_id': petId,
          'data_source': firestoreData != null ? 'cache' : 'fresh',
        },
      );

      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError(e, stackTrace);
      _logger.error('Failed to load analytics', e, stackTrace);
    } finally {
      _isRefreshing[petId] = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> _loadFromFirestore(String petId) async {
    try {
      final doc = await _firestore
          .collection('pet_analytics')
          .doc(petId)
          .get();
      
      return doc.data();
    } catch (e, stackTrace) {
      _logger.error('Failed to load from Firestore', e, stackTrace);
      return null;
    }
  }

  Future<void> _saveToFirestore(
    String petId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection('pet_analytics')
          .doc(petId)
          .set({
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      _logger.error('Failed to save to Firestore', e, stackTrace);
    }
  }

  bool _isDataFresh(Timestamp? timestamp) {
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp.toDate()) <= _cacheExpiration;
  }

  void _updateAnalyticsData(String petId, Map<String, dynamic> data) {
    _analyticsData[petId] = data;
    _lastUpdated[petId] = DateTime.now();
  }

  void _validateAnalyticsData(Map<String, dynamic> data) {
    final requiredFields = [
      'wellnessScore',
      'healthTrends',
      'behaviorTrends',
    ];

    for (var field in requiredFields) {
      if (!data.containsKey(field)) {
        throw AnalyticsException('Missing required field: $field');
      }
    }
  }

  Map<String, dynamic> _processAnalyticsData(Map<String, dynamic> raw) {
    return {
      ...raw,
      'wellnessScore': _normalizeWellnessScore(raw['wellnessScore']),
      'healthTrends': _normalizeHealthTrends(raw['healthTrends']),
      'behaviorTrends': _processBehaviorTrends(raw['behaviorTrends']),
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': {
        'processingVersion': '2.0',
        'dataPoints': raw['dataPoints'] ?? 0,
        'confidence': _calculateConfidenceScore(raw),
      },
    };
  }

  double _normalizeWellnessScore(dynamic score) {
    if (score is! num) return 0.0;
    return score.clamp(0.0, 100.0).toDouble();
  }

  Map<String, dynamic> _normalizeHealthTrends(Map<String, dynamic> trends) {
    return trends.map((key, value) {
      if (value is num) {
        return MapEntry(key, value.toDouble());
      }
      return MapEntry(key, value);
    });
  }

  Map<String, dynamic> _processBehaviorTrends(Map<String, dynamic> trends) {
    final processed = <String, dynamic>{};
    
    for (var entry in trends.entries) {
      if (entry.value is List) {
        processed[entry.key] = _calculateTrendMetrics(entry.value as List);
      } else {
        processed[entry.key] = entry.value;
      }
    }
    
    return processed;
  }

  Map<String, dynamic> _calculateTrendMetrics(List data) {
    if (data.isEmpty) return {'trend': 'insufficient_data'};

    final numericData = data
        .whereType<num>()
        .map((e) => e.toDouble())
        .toList();

    if (numericData.isEmpty) return {'trend': 'invalid_data'};

    return {
      'mean': _calculateMean(numericData),
      'median': _calculateMedian(numericData),
      'stdDev': _calculateStandardDeviation(numericData),
      'trend': _determineTrend(numericData),
      'confidence': _calculateConfidence(numericData),
    };
  }

  double _calculateMean(List<double> values) {
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _calculateMedian(List<double> values) {
    final sorted = List<double>.from(values)..sort();
    final middle = sorted.length ~/ 2;
    
    if (sorted.length.isOdd) {
      return sorted[middle];
    }
    
    return (sorted[middle - 1] + sorted[middle]) / 2;
  }

  double _calculateStandardDeviation(List<double> values) {
    final mean = _calculateMean(values);
    final squaredDiffs = values.map((value) => pow(value - mean, 2));
    return sqrt(squaredDiffs.reduce((a, b) => a + b) / values.length);
  }

  String _determineTrend(List<double> values) {
    if (values.length < 2) return 'insufficient_data';

    final changes = List.generate(
      values.length - 1,
      (i) => values[i + 1] - values[i],
    );

    final positiveChanges = changes.where((c) => c > 0).length;
    final negativeChanges = changes.where((c) => c < 0).length;
    final totalChanges = changes.length;

    if (positiveChanges / totalChanges > 0.7) return 'strongly_improving';
    if (positiveChanges / totalChanges > 0.5) return 'improving';
    if (negativeChanges / totalChanges > 0.7) return 'strongly_declining';
    if (negativeChanges / totalChanges > 0.5) return 'declining';
    return 'stable';
  }

  double _calculateConfidence(List<double> values) {
    final stdDev = _calculateStandardDeviation(values);
    final mean = _calculateMean(values);
    
    // Coefficient of variation
    final cv = (stdDev / mean).abs();
    
    // Convert to confidence score (0-1)
    return (1 - cv).clamp(0.0, 1.0);
  }

  double _calculateConfidenceScore(Map<String, dynamic> data) {
    final factors = <double>[];
    
    // Data completeness
    final requiredFields = ['wellnessScore', 'healthTrends', 'behaviorTrends'];
    final completeness = requiredFields
        .where((field) => data.containsKey(field))
        .length / requiredFields.length;
    factors.add(completeness);
    
    // Data freshness
    if (data.containsKey('timestamp')) {
      final age = DateTime.now().difference(
        DateTime.parse(data['timestamp'] as String)
      ).inHours;
      factors.add(1 - (age / 24).clamp(0.0, 1.0));
    }
    
    // Data volume
    final dataPoints = data['dataPoints'] as int? ?? 0;
    factors.add((dataPoints / 100).clamp(0.0, 1.0));
    
    return factors.reduce((a, b) => a + b) / factors.length;
  }

  String _handleError(dynamic error, StackTrace stackTrace) {
    _logger.error('Analytics Error', error, stackTrace);

    if (error is AnalyticsException) {
      return error.message;
    }

    return 'Failed to process analytics: ${error.toString()}';
  }

  // Public methods for accessing processed analytics
  Map<String, dynamic> getWellnessTrends(String petId) {
    final analytics = _analyticsData[petId];
    if (analytics == null) return _getEmptyWellnessTrends();

    return {
      'currentScore': analytics['wellnessScore'] ?? 0.0,
      'trend': analytics['wellnessTrend'] ?? 'stable',
      'components': analytics['scoreComponents'] ?? {},
      'history': analytics['scoreHistory'] ?? [],
      'lastUpdated': analytics['timestamp'],
      'confidence': analytics['metadata']?['confidence'] ?? 0.0,
    };
  }

  Map<String, dynamic> _getEmptyWellnessTrends() {
    return {
      'currentScore': 0.0,
      'trend': 'unavailable',
      'components': {},
      'history': [],
      'lastUpdated': null,
      'confidence': 0.0,
    };
  }

  Map<String, dynamic> getHealthMetricsAnalysis(String petId) {
    final analytics = _analyticsData[petId];
    if (analytics == null) return {};

    return analytics['healthTrends'] ?? {};
  }

  Map<String, dynamic> getBehaviorAnalysis(String petId) {
    final analytics = _analyticsData[petId];
    if (analytics == null) return {};

    return analytics['behaviorTrends'] ?? {};
  }

  Future<Map<String, dynamic>> generateComprehensiveReport(String petId) async {
    try {
      await loadAnalytics(petId, forceRefresh: true);
      
      final analytics = _analyticsData[petId];
      if (analytics == null) return {};

      final report = {
        'summary': _generateSummary(analytics),
        'wellnessScore': getWellnessTrends(petId),
        'healthMetrics': getHealthMetricsAnalysis(petId),
        'behavior': getBehaviorAnalysis(petId),
        'recommendations': await _generateRecommendations(analytics),
        'metadata': {
          'generatedAt': DateTime.now().toIso8601String(),
          'reportVersion': '2.0',
          'confidence': analytics['metadata']?['confidence'] ?? 0.0,
        },
      };

      // Log report generation
      await _analytics.logEvent(
        name: 'report_generated',
        parameters: {
          'pet_id': petId,
          'report_type': 'comprehensive',
          'confidence': report['metadata']['confidence'],
        },
      );

      return report;
    } catch (e, stackTrace) {
      _logger.error('Failed to generate report', e, stackTrace);
      rethrow;
    }
  }

  Map<String, dynamic> _generateSummary(Map<String, dynamic> analytics) {
    return {
      'overallHealth': analytics['wellnessScore'] ?? 0.0,
      'keyFindings': _extractKeyFindings(analytics),
      'alerts': _extractAlerts(analytics),
      'improvements': _extractImprovements(analytics),
      'concerns': _extractConcerns(analytics),
    };
  }

  Future<List<Map<String, dynamic>>> _generateRecommendations(
    Map<String, dynamic> analytics,
  ) async {
    final recommendations = <Map<String, dynamic>>[];
    
    // Health-based recommendations
    if (analytics['wellnessScore'] != null) {
      recommendations.addAll(
        _generateHealthRecommendations(analytics['wellnessScore'] as num)
      );
    }

    // Behavior-based recommendations
    if (analytics['behaviorTrends'] != null) {
      recommendations.addAll(
        _generateBehaviorRecommendations(
          analytics['behaviorTrends'] as Map<String, dynamic>
        )
      );
    }

    // Store recommendations in Firestore for tracking
    try {
      await _firestore
          .collection('pet_recommendations')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'recommendations': recommendations,
        'analyticsSnapshot': analytics,
      });
    } catch (e, stackTrace) {
      _logger.error('Failed to store recommendations', e, stackTrace);
    }

    return recommendations;
  }

  List<Map<String, dynamic>> _generateHealthRecommendations(num wellnessScore) {
    final recommendations = <Map<String, dynamic>>[];
    
    if (wellnessScore < 60) {
      recommendations.add({
        'type': 'urgent',
        'category': 'health',
        'action': 'Schedule veterinary check-up',
        'reason': 'Low wellness score indicates potential health concerns',
      });
    }
    
    return recommendations;
  }

  List<Map<String, dynamic>> _generateBehaviorRecommendations(
    Map<String, dynamic> behaviorTrends,
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    for (var trend in behaviorTrends.entries) {
      if (trend.value['trend'] == 'strongly_declining') {
        recommendations.add({
          'type': 'warning',
          'category': 'behavior',
          'action': 'Monitor ${trend.key} behavior',
          'reason': 'Significant decline in ${trend.key} observed',
        });
      }
    }
    
    return recommendations;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

class AnalyticsException implements Exception {
  final String message;
  AnalyticsException(this.message);

  @override
  String toString() => 'AnalyticsException: $message';
}

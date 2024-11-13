// lib/providers/analytics_provider.dart

import 'package:flutter/foundation.dart';
import '../services/pet_service.dart';
import '../models/pet.dart';

class AnalyticsProvider with ChangeNotifier {
  final PetService _petService = PetService();
  Map<String, Map<String, dynamic>> _analyticsData = {};
  Map<String, DateTime> _lastUpdated = {};
  Map<String, bool> _isRefreshing = {};
  bool _isLoading = false;
  String? _error;
  Duration _cacheExpiration = const Duration(hours: 1);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, DateTime> get lastUpdated => _lastUpdated;

  // Check if analytics need refresh
  bool _needsRefresh(String petId) {
    final lastUpdate = _lastUpdated[petId];
    if (lastUpdate == null) return true;
    
    return DateTime.now().difference(lastUpdate) > _cacheExpiration;
  }

  // Get analytics with optional refresh
  Future<Map<String, dynamic>?> getAnalyticsForPet(
    String petId, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh || _needsRefresh(petId)) {
      await loadAnalytics(petId);
    }
    return _analyticsData[petId];
  }

  // Load analytics with improved error handling
  Future<void> loadAnalytics(
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
    bool silent = false,
  }) async {
    if (_isRefreshing[petId] == true) return;

    try {
      if (!silent) {
        _isLoading = true;
        notifyListeners();
      }

      _isRefreshing[petId] = true;

      final analytics = await _petService.getAnalytics(
        petId: petId,
        startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        endDate: endDate ?? DateTime.now(),
      );

      _validateAnalyticsData(analytics);
      
      _analyticsData[petId] = _processAnalyticsData(analytics);
      _lastUpdated[petId] = DateTime.now();
      _error = null;

    } catch (e, stackTrace) {
      _error = _handleError(e, stackTrace);
    } finally {
      _isRefreshing[petId] = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Validate analytics data
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

  // Process and normalize analytics data
  Map<String, dynamic> _processAnalyticsData(Map<String, dynamic> raw) {
    return {
      ...raw,
      'wellnessScore': _normalizeWellnessScore(raw['wellnessScore']),
      'healthTrends': _normalizeHealthTrends(raw['healthTrends']),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Normalize wellness score
  double _normalizeWellnessScore(dynamic score) {
    if (score is! num) return 0.0;
    return score.clamp(0.0, 100.0).toDouble();
  }

  // Normalize health trends
  Map<String, dynamic> _normalizeHealthTrends(Map<String, dynamic> trends) {
    return trends.map((key, value) {
      if (value is num) {
        return MapEntry(key, value.toDouble());
      }
      return MapEntry(key, value);
    });
  }

  // Error handling
  String _handleError(dynamic error, StackTrace stackTrace) {
    // Log error for debugging
    debugPrint('Analytics Error: $error');
    debugPrint('StackTrace: $stackTrace');

    if (error is AnalyticsException) {
      return error.message;
    }

    return 'Failed to load analytics: ${error.toString()}';
  }

  // Get wellness score trends with validation
  Map<String, dynamic> getWellnessTrends(String petId) {
    final analytics = _analyticsData[petId];
    if (analytics == null) return _getEmptyWellnessTrends();

    return {
      'currentScore': analytics['wellnessScore'] ?? 0.0,
      'trend': analytics['wellnessTrend'] ?? 'stable',
      'components': analytics['scoreComponents'] ?? {},
      'history': analytics['scoreHistory'] ?? [],
      'lastUpdated': analytics['timestamp'],
    };
  }

  Map<String, dynamic> _getEmptyWellnessTrends() {
    return {
      'currentScore': 0.0,
      'trend': 'unavailable',
      'components': {},
      'history': [],
      'lastUpdated': null,
    };
  }

  // Additional methods remain the same...
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

  Map<String, dynamic> getCareTeamEffectiveness(String petId) {
    final analytics = _analyticsData[petId];
    if (analytics == null) return {};

    return {
      'memberEngagement': analytics['memberEngagement'] ?? {},
      'taskCompletion': analytics['taskCompletion'] ?? {},
      'responseTime': analytics['responseTime'] ?? {},
    };
  }

  // ... (rest of the methods)
}

class AnalyticsException implements Exception {
  final String message;
  AnalyticsException(this.message);

  @override
  String toString() => 'AnalyticsException: $message';
}
// Continuing lib/providers/analytics_provider.dart

class AnalyticsProvider with ChangeNotifier {
  // ... (previous code remains the same)

  // Enhanced medication adherence analysis
  Map<String, dynamic> getMedicationAdherence(String petId) {
    final analytics = _analyticsData[petId];
    if (analytics == null) return _getEmptyMedicationAdherence();

    final adherenceData = analytics['medicationAdherence'] ?? {};
    return {
      'overall': _calculateOverallAdherence(adherenceData),
      'byMedication': adherenceData['byMedication'] ?? {},
      'trends': _processMedicationTrends(adherenceData['trends'] ?? []),
      'missedDoses': adherenceData['missedDoses'] ?? [],
      'schedule': {
        'morning': adherenceData['schedule']?['morning'] ?? 0,
        'afternoon': adherenceData['schedule']?['afternoon'] ?? 0,
        'evening': adherenceData['schedule']?['evening'] ?? 0,
      },
      'recommendations': _generateMedicationRecommendations(adherenceData),
    };
  }

  Map<String, dynamic> _getEmptyMedicationAdherence() {
    return {
      'overall': 0.0,
      'byMedication': {},
      'trends': [],
      'missedDoses': [],
      'schedule': {
        'morning': 0,
        'afternoon': 0,
        'evening': 0,
      },
      'recommendations': [],
    };
  }

  double _calculateOverallAdherence(Map<String, dynamic> data) {
    final medications = data['byMedication'] as Map<String, dynamic>? ?? {};
    if (medications.isEmpty) return 0.0;

    final total = medications.values
        .map((v) => (v['adherence'] as num?)?.toDouble() ?? 0.0)
        .reduce((a, b) => a + b);
    
    return (total / medications.length).clamp(0.0, 100.0);
  }

  List<Map<String, dynamic>> _processMedicationTrends(List<dynamic> trends) {
    return trends.map((trend) {
      return {
        'date': trend['date'],
        'adherence': (trend['adherence'] as num).toDouble().clamp(0.0, 100.0),
        'medications': trend['medications'] ?? [],
      };
    }).toList();
  }

  List<String> _generateMedicationRecommendations(Map<String, dynamic> data) {
    final recommendations = <String>[];
    final adherence = _calculateOverallAdherence(data);

    if (adherence < 80) {
      recommendations.add('Consider setting up medication reminders');
    }
    if (data['missedDoses']?.length > 3) {
      recommendations.add('Review medication schedule with your vet');
    }
    return recommendations;
  }

  // Enhanced comparative analytics
  Map<String, dynamic> getComparativeAnalytics(String petId) {
    final analytics = _analyticsData[petId];
    if (analytics == null) return _getEmptyComparativeAnalytics();

    return {
      'speciesAverage': _processComparativeMetrics(
        analytics['speciesAverage'] ?? {}
      ),
      'breedAverage': _processComparativeMetrics(
        analytics['breedAverage'] ?? {}
      ),
      'ageGroupAverage': _processComparativeMetrics(
        analytics['ageGroupAverage'] ?? {}
      ),
      'percentile': _calculatePercentiles(analytics),
      'recommendations': _generateComparativeRecommendations(analytics),
    };
  }

  Map<String, dynamic> _getEmptyComparativeAnalytics() {
    return {
      'speciesAverage': {},
      'breedAverage': {},
      'ageGroupAverage': {},
      'percentile': {},
      'recommendations': [],
    };
  }

  Map<String, dynamic> _processComparativeMetrics(Map<String, dynamic> metrics) {
    return {
      'weight': metrics['weight']?.toDouble() ?? 0.0,
      'activity': metrics['activity']?.toDouble() ?? 0.0,
      'nutrition': metrics['nutrition']?.toDouble() ?? 0.0,
      'wellness': metrics['wellness']?.toDouble() ?? 0.0,
    };
  }

  Map<String, int> _calculatePercentiles(Map<String, dynamic> analytics) {
    final percentiles = analytics['percentiles'] as Map<String, dynamic>? ?? {};
    return percentiles.map((key, value) => 
        MapEntry(key, (value as num).toInt().clamp(0, 100)));
  }

  // Generate comprehensive report
  Map<String, dynamic> generateReport(String petId) {
    final analytics = _analyticsData[petId];
    if (analytics == null) return {};

    return {
      'summary': _generateSummary(analytics),
      'wellnessScore': getWellnessTrends(petId),
      'healthMetrics': getHealthMetricsAnalysis(petId),
      'behavior': getBehaviorAnalysis(petId),
      'careTeam': getCareTeamEffectiveness(petId),
      'medications': getMedicationAdherence(petId),
      'comparative': getComparativeAnalytics(petId),
      'recommendations': _generateRecommendations(analytics),
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': {
        'petId': petId,
        'reportId': 'RPT-${DateTime.now().millisecondsSinceEpoch}',
        'version': '1.0',
      },
    };
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

  List<String> _extractKeyFindings(Map<String, dynamic> analytics) {
    final findings = <String>[];
    final score = analytics['wellnessScore'] as num? ?? 0;
    
    if (score > 80) {
      findings.add('Excellent overall health status');
    } else if (score < 60) {
      findings.add('Health status needs attention');
    }

    // Add more specific findings based on other metrics
    return findings;
  }

  List<Map<String, dynamic>> _extractAlerts(Map<String, dynamic> analytics) {
    final alerts = <Map<String, dynamic>>[];
    final healthTrends = analytics['healthTrends'] as Map<String, dynamic>? ?? {};

    for (var metric in healthTrends.entries) {
      if (_isMetricCritical(metric.value)) {
        alerts.add({
          'type': 'critical',
          'metric': metric.key,
          'value': metric.value,
          'message': 'Critical value detected for ${metric.key}',
        });
      }
    }

    return alerts;
  }

  bool _isMetricCritical(dynamic value) {
    if (value is! num) return false;
    return value < 30.0; // Example threshold
  }

  List<String> _generateRecommendations(Map<String, dynamic> analytics) {
    final recommendations = <String>[];
    final score = analytics['wellnessScore'] as num? ?? 0;

    // Add general recommendations based on wellness score
    if (score < 60) {
      recommendations.add('Schedule a comprehensive health check-up');
    }
    if (score < 80) {
      recommendations.add('Review current diet and exercise routine');
    }

    // Add specific recommendations based on other metrics
    final healthTrends = analytics['healthTrends'] as Map<String, dynamic>? ?? {};
    for (var metric in healthTrends.entries) {
      if (_needsImprovement(metric.value)) {
        recommendations.add('Focus on improving ${metric.key}');
      }
    }

    return recommendations;
  }

  bool _needsImprovement(dynamic value) {
    if (value is! num) return false;
    return value < 70.0; // Example threshold
  }

  // Helper methods for trend analysis
  List<Map<String, dynamic>> _extractImprovements(Map<String, dynamic> analytics) {
    // Implementation for extracting improvements
    return [];
  }

  List<Map<String, dynamic>> _extractConcerns(Map<String, dynamic> analytics) {
    // Implementation for extracting concerns
    return [];
  }
}
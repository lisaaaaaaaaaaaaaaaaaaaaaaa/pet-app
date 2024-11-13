// lib/providers/health_metrics_provider.dart

import 'package:flutter/foundation.dart';
import '../services/pet_service.dart';
import '../models/pet.dart';
import 'dart:math';

class HealthMetricsProvider with ChangeNotifier {
  final PetService _petService = PetService();
  Map<String, List<HealthMetric>> _healthMetrics = {};
  Map<String, DateTime> _lastUpdated = {};
  Map<String, Map<String, dynamic>> _healthAnalytics = {};
  bool _isLoading = false;
  String? _error;
  Duration _cacheExpiration = const Duration(hours: 1);

  // Reference ranges for different species and breeds
  final Map<String, Map<String, Map<String, dynamic>>> _referenceRanges = {
    'dog': {
      'temperature': {'min': 37.2, 'max': 39.2, 'unit': '°C'},
      'heart_rate': {'min': 60, 'max': 140, 'unit': 'bpm'},
      'respiratory_rate': {'min': 10, 'max': 30, 'unit': 'bpm'},
      'weight': {'unit': 'kg'}, // Varies by breed
    },
    'cat': {
      'temperature': {'min': 37.5, 'max': 39.5, 'unit': '°C'},
      'heart_rate': {'min': 120, 'max': 140, 'unit': 'bpm'},
      'respiratory_rate': {'min': 20, 'max': 30, 'unit': 'bpm'},
      'weight': {'unit': 'kg'}, // Varies by breed
    },
  };

  // Enhanced Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, DateTime> get lastUpdated => _lastUpdated;

  // Check if data needs refresh
  bool _needsRefresh(String petId) {
    final lastUpdate = _lastUpdated[petId];
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) > _cacheExpiration;
  }

  // Enhanced metrics retrieval
  Future<List<HealthMetric>> getMetricsForPet(
    String petId, {
    bool forceRefresh = false,
    String? metricType,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
  }) async {
    if (forceRefresh || _needsRefresh(petId)) {
      await loadHealthMetrics(petId);
    }

    var metrics = _healthMetrics[petId] ?? [];

    // Apply filters
    if (metricType != null) {
      metrics = metrics.where((m) => m.name == metricType).toList();
    }

    if (startDate != null) {
      metrics = metrics.where((m) => m.recordedAt.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      metrics = metrics.where((m) => m.recordedAt.isBefore(endDate)).toList();
    }

    if (tags != null && tags.isNotEmpty) {
      metrics = metrics.where(
        (m) => tags.any((tag) => m.tags.contains(tag))
      ).toList();
    }

    return metrics;
  }

  // Enhanced health metrics loading
  Future<void> loadHealthMetrics(
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final metrics = await _petService.getHealthMetrics(
        petId: petId,
        startDate: startDate ?? DateTime.now().subtract(const Duration(days: 365)),
        endDate: endDate ?? DateTime.now(),
      );

      _healthMetrics[petId] = metrics
          .map((data) => HealthMetric.fromJson(data))
          .toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

      _lastUpdated[petId] = DateTime.now();
      await _updateHealthAnalytics(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Failed to load metrics', e, stackTrace);
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Enhanced metric addition with validation
  Future<void> addHealthMetric({
    required String petId,
    required String name,
    required dynamic value,
    required String unit,
    String? notes,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? measuredBy,
    String? method,
    bool validateRange = true,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validate metric
      if (validateRange) {
        _validateMetricValue(
          petId: petId,
          name: name,
          value: value,
          unit: unit,
        );
      }

      final metric = await _petService.addHealthMetric(
        petId: petId,
        name: name,
        value: value,
        recordedAt: DateTime.now(),
        unit: unit,
        notes: notes,
        tags: tags,
        metadata: {
          ...?metadata,
          'measuredBy': measuredBy,
          'method': method,
          'deviceInfo': await _getDeviceInfo(),
        },
      );

      // Update local cache
      final metrics = _healthMetrics[petId] ?? [];
      metrics.insert(0, HealthMetric.fromJson(metric));
      _healthMetrics[petId] = metrics;

      await _updateHealthAnalytics(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Failed to add metric', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ... (continued in next part)
  // Continuing lib/providers/health_metrics_provider.dart

  // Validate metric value against reference ranges
  void _validateMetricValue({
    required String petId,
    required String name,
    required dynamic value,
    required String unit,
  }) {
    final pet = _petService.getPet(petId);
    if (pet == null) throw HealthMetricException('Pet not found');

    final speciesRanges = _referenceRanges[pet.species.toLowerCase()];
    if (speciesRanges == null) return; // Skip validation for unknown species

    final metricRanges = speciesRanges[name.toLowerCase()];
    if (metricRanges == null) return; // Skip validation for unknown metrics

    // Convert value to double for comparison
    final numericValue = double.tryParse(value.toString());
    if (numericValue == null) {
      throw HealthMetricException('Invalid numeric value');
    }

    // Check unit compatibility
    if (unit != metricRanges['unit']) {
      throw HealthMetricException(
        'Invalid unit. Expected: ${metricRanges['unit']}, Got: $unit'
      );
    }

    // Validate against ranges if defined
    if (metricRanges.containsKey('min') && 
        metricRanges.containsKey('max')) {
      if (numericValue < metricRanges['min'] || 
          numericValue > metricRanges['max']) {
        throw HealthMetricException(
          'Value outside normal range (${metricRanges['min']}-${metricRanges['max']} ${metricRanges['unit']})'
        );
      }
    }
  }

  // Enhanced trend analysis
  Map<String, dynamic> calculateTrends(
    String petId,
    String metricType, {
    Duration? period,
    bool normalized = false,
  }) async {
    final metrics = await getMetricsForPet(
      petId,
      metricType: metricType,
      startDate: period != null ? DateTime.now().subtract(period) : null,
    );

    if (metrics.length < 2) {
      return _getEmptyTrendData();
    }

    metrics.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    
    final values = metrics
        .map((m) => double.tryParse(m.value.toString()) ?? 0)
        .toList();
    
    final timestamps = metrics.map((m) => m.recordedAt).toList();
    
    return {
      'summary': _calculateTrendSummary(values),
      'statistics': _calculateStatistics(values),
      'correlation': await _calculateCorrelations(petId, metricType, metrics),
      'seasonality': _analyzeSeasonality(timestamps, values),
      'forecast': _generateForecast(timestamps, values),
      'anomalies': _detectAnomalies(values, normalized),
    };
  }

  Map<String, dynamic> _calculateTrendSummary(List<double> values) {
    final first = values.first;
    final last = values.last;
    final change = last - first;
    final changePercentage = (change / first) * 100;

    return {
      'trend': change > 0 ? 'increasing' : change < 0 ? 'decreasing' : 'stable',
      'change': change,
      'changePercentage': changePercentage,
      'volatility': _calculateVolatility(values),
    };
  }

  Map<String, dynamic> _calculateStatistics(List<double> values) {
    values.sort();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final median = values.length.isOdd
        ? values[values.length ~/ 2]
        : (values[(values.length - 1) ~/ 2] + values[values.length ~/ 2]) / 2;
    
    return {
      'mean': mean,
      'median': median,
      'min': values.first,
      'max': values.last,
      'standardDeviation': _calculateStandardDeviation(values, mean),
    };
  }

  double _calculateStandardDeviation(List<double> values, double mean) {
    final squaredDiffs = values.map((value) => pow(value - mean, 2));
    return sqrt(squaredDiffs.reduce((a, b) => a + b) / values.length);
  }

  double _calculateVolatility(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final changes = List.generate(values.length - 1,
        (i) => ((values[i + 1] - values[i]) / values[i]).abs());
    
    return changes.reduce((a, b) => a + b) / changes.length;
  }

  List<Map<String, dynamic>> _detectAnomalies(
    List<double> values,
    bool normalized,
  ) {
    final anomalies = <Map<String, dynamic>>[];
    if (values.length < 3) return anomalies;

    final stats = _calculateStatistics(values);
    final threshold = normalized ? 2 : stats['standardDeviation'] * 2;

    for (var i = 0; i < values.length; i++) {
      final diff = (values[i] - stats['mean']).abs();
      if (diff > threshold) {
        anomalies.add({
          'index': i,
          'value': values[i],
          'deviation': diff,
          'severity': diff / threshold,
        });
      }
    }

    return anomalies;
  }

  // Health Analytics
  Future<void> _updateHealthAnalytics(String petId) async {
    final metrics = _healthMetrics[petId] ?? [];
    
    _healthAnalytics[petId] = {
      'overview': {
        'totalMetrics': metrics.length,
        'uniqueMetricTypes': metrics.map((m) => m.name).toSet().length,
        'lastRecorded': metrics.isEmpty ? null : metrics.first.recordedAt,
      },
      'trends': await _analyzeTrends(petId, metrics),
      'anomalies': _findAnomalies(metrics),
      'compliance': _analyzeComplianceAndFrequency(metrics),
      'correlations': await _analyzeCorrelations(petId, metrics),
      'recommendations': await _generateHealthRecommendations(petId),
    };
  }

  Map<String, dynamic> generateHealthReport(String petId) {
    final analytics = _healthAnalytics[petId];
    if (analytics == null) return {};

    return {
      'summary': analytics['overview'],
      'trends': analytics['trends'],
      'anomalies': analytics['anomalies'],
      'compliance': analytics['compliance'],
      'correlations': analytics['correlations'],
      'recommendations': analytics['recommendations'],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  String _handleError(String operation, dynamic error, StackTrace stackTrace) {
    debugPrint('Health Metrics Error: $operation');
    debugPrint('Error: $error');
    debugPrint('StackTrace: $stackTrace');
    return 'Failed to $operation: ${error.toString()}';
  }
}

class HealthMetricException implements Exception {
  final String message;
  HealthMetricException(this.message);

  @override
  String toString() => message;
}
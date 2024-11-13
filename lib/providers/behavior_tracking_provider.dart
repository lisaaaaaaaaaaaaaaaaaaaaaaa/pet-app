// lib/providers/behavior_tracking_provider.dart

import 'package:flutter/foundation.dart';
import '../services/pet_service.dart';
import '../models/pet.dart';

class BehaviorTrackingProvider with ChangeNotifier {
  final PetService _petService = PetService();
  Map<String, List<BehaviorLog>> _behaviorLogs = {};
  Map<String, DateTime> _lastUpdated = {};
  Map<String, Map<String, dynamic>> _behaviorAnalytics = {};
  bool _isLoading = false;
  String? _error;
  Duration _cacheExpiration = const Duration(hours: 1);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, DateTime> get lastUpdated => _lastUpdated;

  // Check if data needs refresh
  bool _needsRefresh(String petId) {
    final lastUpdate = _lastUpdated[petId];
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) > _cacheExpiration;
  }

  // Get logs with optional refresh
  Future<List<BehaviorLog>> getLogsForPet(
    String petId, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh || _needsRefresh(petId)) {
      await loadBehaviorLogs(petId);
    }
    return _behaviorLogs[petId] ?? [];
  }

  // Enhanced load behavior logs
  Future<void> loadBehaviorLogs(
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
      final logs = await _petService.getBehaviorLogs(
        petId: petId,
        startDate: startDate ?? DateTime.now().subtract(const Duration(days: 90)),
        endDate: endDate ?? DateTime.now(),
      );

      _behaviorLogs[petId] = logs
          .map((data) => BehaviorLog.fromJson(data))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      _lastUpdated[petId] = DateTime.now();
      await _updateAnalytics(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError(e, stackTrace);
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Enhanced add behavior log
  Future<void> addBehaviorLog({
    required String petId,
    required String behavior,
    required String context,
    String? trigger,
    String? resolution,
    List<String>? interventions,
    bool wasSuccessful = false,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? severity,
    Duration? duration,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newLog = await _petService.addBehaviorLog(
        petId: petId,
        behavior: behavior,
        context: context,
        date: DateTime.now(),
        trigger: trigger,
        resolution: resolution,
        interventions: interventions,
        wasSuccessful: wasSuccessful,
        metadata: metadata,
        tags: tags,
        severity: severity,
        duration: duration,
      );

      // Update local cache
      final logs = _behaviorLogs[petId] ?? [];
      logs.insert(0, BehaviorLog.fromJson(newLog));
      _behaviorLogs[petId] = logs;

      await _updateAnalytics(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError(e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get filtered logs
  List<BehaviorLog> getFilteredLogs(
    String petId, {
    String? behaviorType,
    bool? wasSuccessful,
    String? trigger,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    String? severity,
  }) {
    final logs = _behaviorLogs[petId] ?? [];
    return logs.where((log) {
      if (behaviorType != null && 
          log.behavior.toLowerCase() != behaviorType.toLowerCase()) {
        return false;
      }
      if (wasSuccessful != null && log.wasSuccessful != wasSuccessful) {
        return false;
      }
      if (trigger != null && log.trigger != trigger) {
        return false;
      }
      if (startDate != null && log.date.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && log.date.isAfter(endDate)) {
        return false;
      }
      if (tags != null && !tags.every((tag) => log.tags.contains(tag))) {
        return false;
      }
      if (severity != null && log.severity != severity) {
        return false;
      }
      return true;
    }).toList();
  }

  // Enhanced behavior trends calculation
  Future<Map<String, dynamic>> calculateBehaviorTrends(
    String petId, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh || _needsRefresh(petId)) {
      await _updateAnalytics(petId);
    }
    return _behaviorAnalytics[petId] ?? _getEmptyTrends();
  }

  Map<String, dynamic> _getEmptyTrends() {
    return {
      'totalLogs': 0,
      'successRate': 0.0,
      'commonBehaviors': <String, int>{},
      'commonTriggers': <String, int>{},
      'trend': 'insufficient_data',
      'severityDistribution': <String, int>{},
      'timeOfDayDistribution': <String, int>{},
      'averageDuration': Duration.zero,
      'behaviorPatterns': [],
    };
  }
// Continuing lib/providers/behavior_tracking_provider.dart

  // Update analytics
  Future<void> _updateAnalytics(String petId) async {
    final logs = _behaviorLogs[petId] ?? [];
    if (logs.isEmpty) {
      _behaviorAnalytics[petId] = _getEmptyTrends();
      return;
    }

    final analytics = {
      'totalLogs': logs.length,
      'successRate': _calculateSuccessRate(logs),
      'commonBehaviors': _analyzeFrequencies(logs, (log) => log.behavior),
      'commonTriggers': _analyzeFrequencies(
        logs.where((log) => log.trigger != null).toList(),
        (log) => log.trigger!,
      ),
      'trend': _calculateTrend(logs),
      'severityDistribution': _analyzeSeverityDistribution(logs),
      'timeOfDayDistribution': _analyzeTimeDistribution(logs),
      'averageDuration': _calculateAverageDuration(logs),
      'behaviorPatterns': _identifyPatterns(logs),
      'interventionEffectiveness': _calculateInterventionEffectiveness(logs),
      'contextualAnalysis': _analyzeContexts(logs),
      'weekdayDistribution': _analyzeWeekdayDistribution(logs),
      'monthlyTrends': _analyzeMonthlyTrends(logs),
      'correlations': _analyzeCorrelations(logs),
    };

    _behaviorAnalytics[petId] = analytics;
  }

  double _calculateSuccessRate(List<BehaviorLog> logs) {
    if (logs.isEmpty) return 0.0;
    final successfulLogs = logs.where((log) => log.wasSuccessful).length;
    return (successfulLogs / logs.length) * 100;
  }

  Map<String, int> _analyzeFrequencies(
    List<BehaviorLog> logs,
    String Function(BehaviorLog) selector,
  ) {
    final frequencies = <String, int>{};
    for (var log in logs) {
      final key = selector(log);
      frequencies[key] = (frequencies[key] ?? 0) + 1;
    }
    return Map.fromEntries(
      frequencies.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
  }

  Map<String, int> _analyzeSeverityDistribution(List<BehaviorLog> logs) {
    return _analyzeFrequencies(
      logs.where((log) => log.severity != null).toList(),
      (log) => log.severity!,
    );
  }

  Map<String, int> _analyzeTimeDistribution(List<BehaviorLog> logs) {
    final distribution = <String, int>{};
    for (var log in logs) {
      final hour = log.date.hour;
      final timeSlot = _getTimeSlot(hour);
      distribution[timeSlot] = (distribution[timeSlot] ?? 0) + 1;
    }
    return distribution;
  }

  String _getTimeSlot(int hour) {
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 22) return 'evening';
    return 'night';
  }

  Duration _calculateAverageDuration(List<BehaviorLog> logs) {
    final logsWithDuration = logs.where((log) => log.duration != null).toList();
    if (logsWithDuration.isEmpty) return Duration.zero;

    final totalMinutes = logsWithDuration.fold<int>(
      0,
      (sum, log) => sum + log.duration!.inMinutes,
    );
    return Duration(minutes: totalMinutes ~/ logsWithDuration.length);
  }

  List<Map<String, dynamic>> _identifyPatterns(List<BehaviorLog> logs) {
    final patterns = <Map<String, dynamic>>[];
    
    // Time-based patterns
    final timePatterns = _findTimePatterns(logs);
    if (timePatterns.isNotEmpty) {
      patterns.add({
        'type': 'time',
        'patterns': timePatterns,
      });
    }

    // Trigger-based patterns
    final triggerPatterns = _findTriggerPatterns(logs);
    if (triggerPatterns.isNotEmpty) {
      patterns.add({
        'type': 'trigger',
        'patterns': triggerPatterns,
      });
    }

    return patterns;
  }

  List<Map<String, dynamic>> _findTimePatterns(List<BehaviorLog> logs) {
    final timeSlotCounts = _analyzeTimeDistribution(logs);
    final totalLogs = logs.length;
    
    return timeSlotCounts.entries
        .where((entry) => entry.value / totalLogs > 0.3) // 30% threshold
        .map((entry) => {
          'timeSlot': entry.key,
          'frequency': entry.value,
          'percentage': (entry.value / totalLogs * 100).toStringAsFixed(1),
        })
        .toList();
  }

  List<Map<String, dynamic>> _findTriggerPatterns(List<BehaviorLog> logs) {
    final triggerCounts = _analyzeFrequencies(
      logs.where((log) => log.trigger != null).toList(),
      (log) => log.trigger!,
    );
    
    return triggerCounts.entries
        .take(3)
        .map((entry) => {
          'trigger': entry.key,
          'count': entry.value,
          'successRate': _calculateTriggerSuccessRate(logs, entry.key),
        })
        .toList();
  }

  double _calculateTriggerSuccessRate(List<BehaviorLog> logs, String trigger) {
    final triggerLogs = logs.where((log) => log.trigger == trigger).toList();
    if (triggerLogs.isEmpty) return 0.0;
    
    final successfulLogs = triggerLogs.where((log) => log.wasSuccessful).length;
    return (successfulLogs / triggerLogs.length) * 100;
  }

  Map<String, double> _analyzeCorrelations(List<BehaviorLog> logs) {
    final correlations = <String, double>{};

    // Time of day correlation
    correlations['timeOfDay'] = _calculateTimeCorrelation(logs);

    // Weather correlation (if available in metadata)
    correlations['weather'] = _calculateWeatherCorrelation(logs);

    // Activity level correlation
    correlations['activityLevel'] = _calculateActivityCorrelation(logs);

    return correlations;
  }

  double _calculateTimeCorrelation(List<BehaviorLog> logs) {
    if (logs.length < 2) return 0.0;
    
    final timeSlotCounts = _analyzeTimeDistribution(logs);
    final maxCount = timeSlotCounts.values.reduce(max);
    final totalLogs = logs.length;
    
    return (maxCount / totalLogs) * 100;
  }

  double _calculateWeatherCorrelation(List<BehaviorLog> logs) {
    // Implementation depends on weather data availability in metadata
    return 0.0;
  }

  double _calculateActivityCorrelation(List<BehaviorLog> logs) {
    // Implementation depends on activity data availability
    return 0.0;
  }

  // Generate comprehensive report
  Map<String, dynamic> generateBehaviorReport(String petId) {
    final logs = _behaviorLogs[petId] ?? [];
    final analytics = _behaviorAnalytics[petId] ?? _getEmptyTrends();

    return {
      'summary': {
        'totalLogs': logs.length,
        'dateRange': {
          'start': logs.isNotEmpty ? logs.last.date : null,
          'end': logs.isNotEmpty ? logs.first.date : null,
        },
        'successRate': analytics['successRate'],
        'trend': analytics['trend'],
      },
      'patterns': analytics['behaviorPatterns'],
      'distributions': {
        'severity': analytics['severityDistribution'],
        'timeOfDay': analytics['timeOfDayDistribution'],
        'weekday': analytics['weekdayDistribution'],
      },
      'effectiveness': analytics['interventionEffectiveness'],
      'correlations': analytics['correlations'],
      'recommendations': generateRecommendations(petId),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  List<String> generateRecommendations(String petId) {
    final analytics = _behaviorAnalytics[petId];
    if (analytics == null) return ['Insufficient data for recommendations'];

    final recommendations = <String>[];
    final successRate = analytics['successRate'] as double;
    final patterns = analytics['behaviorPatterns'] as List;

    if (successRate < 50) {
      recommendations.add('Consider consulting a professional behaviorist');
    }

    if (patterns.isNotEmpty) {
      recommendations.add('Review identified behavior patterns and adjust routine accordingly');
    }

    // Add more specific recommendations based on analytics

    return recommendations;
  }

  String _handleError(dynamic error, StackTrace stackTrace) {
    debugPrint('BehaviorTracking Error: $error');
    debugPrint('StackTrace: $stackTrace');
    return 'Failed to process behavior data: ${error.toString()}';
  }

  void clear() {
    _behaviorLogs = {};
    _behaviorAnalytics = {};
    _lastUpdated = {};
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
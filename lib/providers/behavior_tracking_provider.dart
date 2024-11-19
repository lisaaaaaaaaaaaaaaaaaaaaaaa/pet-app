import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../services/pet_service.dart';
import '../models/pet.dart';
import '../utils/logger.dart';
import 'dart:async';
import 'dart:math';

class BehaviorTrackingProvider with ChangeNotifier {
  final PetService _petService;
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;
  final Logger _logger;

  final Map<String, List<BehaviorLog>> _behaviorLogs = {};
  final Map<String, Map<String, dynamic>> _behaviorAnalytics = {};
  final Map<String, DateTime> _lastUpdated = {};
  final Map<String, bool> _isRefreshing = {};
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  final Duration _cacheExpiration;
  final Duration _refreshInterval;

  BehaviorTrackingProvider({
    PetService? petService,
    FirebaseFirestore? firestore,
    FirebaseAnalytics? analytics,
    Logger? logger,
    Duration? cacheExpiration,
    Duration? refreshInterval,
  }) : 
    _petService = petService ?? PetService(),
    _firestore = firestore ?? FirebaseFirestore.instance,
    _analytics = analytics ?? FirebaseAnalytics.instance,
    _logger = logger ?? Logger(),
    _cacheExpiration = cacheExpiration ?? const Duration(hours: 1),
    _refreshInterval = refreshInterval ?? const Duration(minutes: 15) {
    _setupPeriodicRefresh();
    _initializeFirebaseListeners();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, DateTime> get lastUpdated => _lastUpdated;

  void _setupPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      _refreshAllBehaviorLogs(silent: true);
    });
  }

  void _initializeFirebaseListeners() {
    _firestore.collection('behavior_logs')
        .snapshots()
        .listen(_handleBehaviorUpdates);
  }

  Future<void> _handleBehaviorUpdates(QuerySnapshot snapshot) async {
    for (var change in snapshot.docChanges) {
      final data = change.doc.data() as Map<String, dynamic>;
      final petId = data['petId'] as String;

      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          await loadBehaviorLogs(petId, silent: true);
          break;
        case DocumentChangeType.removed:
          _removeBehaviorLog(petId, change.doc.id);
          break;
      }
    }
    notifyListeners();
  }

  Future<List<BehaviorLog>> getBehaviorLogs(
    String petId, {
    bool forceRefresh = false,
    DateTime? startDate,
    DateTime? endDate,
    String? behaviorType,
    String? severity,
    bool? isResolved,
  }) async {
    if (forceRefresh || _needsRefresh(petId)) {
      await loadBehaviorLogs(petId);
    }

    var logs = _behaviorLogs[petId] ?? [];

    // Apply filters
    if (startDate != null) {
      logs = logs.where((log) => log.timestamp.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      logs = logs.where((log) => log.timestamp.isBefore(endDate)).toList();
    }
    if (behaviorType != null) {
      logs = logs.where((log) => log.type == behaviorType).toList();
    }
    if (severity != null) {
      logs = logs.where((log) => log.severity == severity).toList();
    }
    if (isResolved != null) {
      logs = logs.where((log) => log.isResolved == isResolved).toList();
    }

    return logs;
  }

  Future<void> addBehaviorLog({
    required String petId,
    required String type,
    required String description,
    String? severity,
    String? trigger,
    String? resolution,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final log = BehaviorLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: petId,
        type: type,
        description: description,
        severity: severity ?? 'normal',
        trigger: trigger,
        resolution: resolution,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
        tags: tags ?? [],
        isResolved: false,
      );

      await _firestore.collection('behavior_logs').add(log.toJson());
      
      final logs = _behaviorLogs[petId] ?? [];
      logs.insert(0, log);
      _behaviorLogs[petId] = logs;

      await _updateBehaviorAnalytics(petId);
      
      _error = null;
      
      // Track event
      await _analytics.logEvent(
        name: 'behavior_log_added',
        parameters: {
          'pet_id': petId,
          'behavior_type': type,
          'severity': severity,
        },
      );

    } catch (e, stackTrace) {
      _error = _handleError('Failed to add behavior log', e, stackTrace);
      _logger.error('Failed to add behavior log', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBehaviorLog({
    required String petId,
    required String logId,
    String? type,
    String? description,
    String? severity,
    String? trigger,
    String? resolution,
    bool? isResolved,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updates = <String, dynamic>{
        if (type != null) 'type': type,
        if (description != null) 'description': description,
        if (severity != null) 'severity': severity,
        if (trigger != null) 'trigger': trigger,
        if (resolution != null) 'resolution': resolution,
        if (isResolved != null) 'isResolved': isResolved,
        if (metadata != null) 'metadata': metadata,
        if (tags != null) 'tags': tags,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('behavior_logs')
          .doc(logId)
          .update(updates);

      // Update local cache
      final logs = _behaviorLogs[petId] ?? [];
      final index = logs.indexWhere((log) => log.id == logId);
      if (index != -1) {
        logs[index] = logs[index].copyWith(
          type: type,
          description: description,
          severity: severity,
          trigger: trigger,
          resolution: resolution,
          isResolved: isResolved,
          metadata: metadata,
          tags: tags,
        );
        _behaviorLogs[petId] = logs;
      }

      await _updateBehaviorAnalytics(petId);
      _error = null;

    } catch (e, stackTrace) {
      _error = _handleError('Failed to update behavior log', e, stackTrace);
      _logger.error('Failed to update behavior log', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBehaviorLog(String petId, String logId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('behavior_logs')
          .doc(logId)
          .delete();

      _removeBehaviorLog(petId, logId);
      await _updateBehaviorAnalytics(petId);
      _error = null;

    } catch (e, stackTrace) {
      _error = _handleError('Failed to delete behavior log', e, stackTrace);
      _logger.error('Failed to delete behavior log', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _removeBehaviorLog(String petId, String logId) {
    final logs = _behaviorLogs[petId] ?? [];
    logs.removeWhere((log) => log.id == logId);
    _behaviorLogs[petId] = logs;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getBehaviorAnalytics(String petId) async {
    if (_needsRefresh(petId)) {
      await _updateBehaviorAnalytics(petId);
    }
    return _behaviorAnalytics[petId] ?? {};
  }

  Future<void> _updateBehaviorAnalytics(String petId) async {
    try {
      final logs = _behaviorLogs[petId] ?? [];
      
      _behaviorAnalytics[petId] = {
        'overview': _generateOverview(logs),
        'trends': await _analyzeTrends(logs),
        'patterns': _identifyPatterns(logs),
        'triggers': _analyzeTriggers(logs),
        'resolutions': _analyzeResolutions(logs),
        'recommendations': await _generateRecommendations(logs),
      };

    } catch (e, stackTrace) {
      _logger.error('Failed to update behavior analytics', e, stackTrace);
    }
  }

  Map<String, dynamic> _generateOverview(List<BehaviorLog> logs) {
    return {
      'totalLogs': logs.length,
      'unresolvedCount': logs.where((log) => !log.isResolved).length,
      'severityDistribution': _calculateSeverityDistribution(logs),
      'recentBehaviors': _getRecentBehaviors(logs),
      'mostCommonTypes': _getMostCommonTypes(logs),
    };
  }

  Future<Map<String, dynamic>> _analyzeTrends(List<BehaviorLog> logs) async {
    // Implement trend analysis logic
    return {};
  }

  Map<String, dynamic> _identifyPatterns(List<BehaviorLog> logs) {
    // Implement pattern identification logic
    return {};
  }

  Map<String, dynamic> _analyzeTriggers(List<BehaviorLog> logs) {
    // Implement trigger analysis logic
    return {};
  }

  Map<String, dynamic> _analyzeResolutions(List<BehaviorLog> logs) {
    // Implement resolution analysis logic
    return {};
  }

  Future<List<Map<String, dynamic>>> _generateRecommendations(
    List<BehaviorLog> logs,
  ) async {
    // Implement recommendation generation logic
    return [];
  }

  bool _needsRefresh(String petId) {
    final lastUpdate = _lastUpdated[petId];
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) > _cacheExpiration;
  }

  String _handleError(String operation, dynamic error, StackTrace stackTrace) {
    return 'Failed to $operation: ${error.toString()}';
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

class BehaviorLog {
  final String id;
  final String petId;
  final String type;
  final String description;
  final String severity;
  final String? trigger;
  final String? resolution;
  final DateTime timestamp;
  final bool isResolved;
  final Map<String, dynamic> metadata;
  final List<String> tags;

  BehaviorLog({
    required this.id,
    required this.petId,
    required this.type,
    required this.description,
    required this.severity,
    this.trigger,
    this.resolution,
    required this.timestamp,
    this.isResolved = false,
    this.metadata = const {},
    this.tags = const [],
  });

  BehaviorLog copyWith({
    String? type,
    String? description,
    String? severity,
    String? trigger,
    String? resolution,
    bool? isResolved,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) {
    return BehaviorLog(
      id: id,
      petId: petId,
      type: type ?? this.type,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      trigger: trigger ?? this.trigger,
      resolution: resolution ?? this.resolution,
      timestamp: timestamp,
      isResolved: isResolved ?? this.isResolved,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'type': type,
    'description': description,
    'severity': severity,
    'trigger': trigger,
    'resolution': resolution,
    'timestamp': timestamp.toIso8601String(),
    'isResolved': isResolved,
    'metadata': metadata,
    'tags': tags,
  };

  factory BehaviorLog.fromJson(Map<String, dynamic> json) => BehaviorLog(
    id: json['id'],
    petId: json['petId'],
    type: json['type'],
    description: json['description'],
    severity: json['severity'],
    trigger: json['trigger'],
    resolution: json['resolution'],
    timestamp: DateTime.parse(json['timestamp']),
    isResolved: json['isResolved'] ?? false,
    metadata: json['metadata'] ?? {},
    tags: List<String>.from(json['tags'] ?? []),
  );
}

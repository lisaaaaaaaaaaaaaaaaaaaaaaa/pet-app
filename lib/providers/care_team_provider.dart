import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../services/pet_service.dart';
import '../models/care_team_member.dart';
import '../utils/logger.dart';
import 'dart:async';

class CareTeamProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;
  final PetService _petService;
  final Logger _logger;

  final Map<String, List<CareTeamMember>> _careTeams = {};
  final Map<String, Map<String, dynamic>> _teamAnalytics = {};
  final Map<String, DateTime> _lastUpdated = {};
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

  CareTeamProvider({
    FirebaseFirestore? firestore,
    FirebaseAnalytics? analytics,
    PetService? petService,
    Logger? logger,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _analytics = analytics ?? FirebaseAnalytics.instance,
    _petService = petService ?? PetService(),
    _logger = logger ?? Logger() {
    _initializeListeners();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, DateTime> get lastUpdated => _lastUpdated;

  void _initializeListeners() {
    _firestore.collection('care_teams')
        .snapshots()
        .listen(_handleTeamUpdates);
  }

  Future<void> _handleTeamUpdates(QuerySnapshot snapshot) async {
    for (var change in snapshot.docChanges) {
      final data = change.doc.data() as Map<String, dynamic>;
      final petId = data['petId'] as String;

      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          await loadCareTeam(petId, silent: true);
          break;
        case DocumentChangeType.removed:
          _removeCareTeamMember(petId, change.doc.id);
          break;
      }
    }
    notifyListeners();
  }

  Future<List<CareTeamMember>> getCareTeam(
    String petId, {
    bool forceRefresh = false,
    String? role,
    bool? isActive,
  }) async {
    if (forceRefresh || _needsRefresh(petId)) {
      await loadCareTeam(petId);
    }

    var team = _careTeams[petId] ?? [];

    if (role != null) {
      team = team.where((member) => member.role == role).toList();
    }
    if (isActive != null) {
      team = team.where((member) => member.isActive == isActive).toList();
    }

    return team;
  }

  Future<void> addTeamMember({
    required String petId,
    required String userId,
    required String role,
    required String name,
    String? email,
    String? phone,
    Map<String, dynamic>? permissions,
    Map<String, dynamic>? schedule,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final member = CareTeamMember(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: petId,
        userId: userId,
        role: role,
        name: name,
        email: email,
        phone: phone,
        permissions: permissions ?? _getDefaultPermissions(role),
        schedule: schedule ?? {},
        metadata: metadata ?? {},
        isActive: true,
        joinedAt: DateTime.now(),
      );

      await _firestore.collection('care_teams').add(member.toJson());
      
      final team = _careTeams[petId] ?? [];
      team.add(member);
      _careTeams[petId] = team;

      await _updateTeamAnalytics(petId);
      _error = null;

      await _analytics.logEvent(
        name: 'care_team_member_added',
        parameters: {
          'pet_id': petId,
          'role': role,
        },
      );

    } catch (e, stackTrace) {
      _error = _handleError('Failed to add team member', e, stackTrace);
      _logger.error('Failed to add team member', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTeamMember({
    required String petId,
    required String memberId,
    String? role,
    String? name,
    String? email,
    String? phone,
    Map<String, dynamic>? permissions,
    Map<String, dynamic>? schedule,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updates = <String, dynamic>{
        if (role != null) 'role': role,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (permissions != null) 'permissions': permissions,
        if (schedule != null) 'schedule': schedule,
        if (isActive != null) 'isActive': isActive,
        if (metadata != null) 'metadata': metadata,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('care_teams')
          .doc(memberId)
          .update(updates);

      final team = _careTeams[petId] ?? [];
      final index = team.indexWhere((m) => m.id == memberId);
      if (index != -1) {
        team[index] = team[index].copyWith(
          role: role,
          name: name,
          email: email,
          phone: phone,
          permissions: permissions,
          schedule: schedule,
          isActive: isActive,
          metadata: metadata,
        );
        _careTeams[petId] = team;
      }

      await _updateTeamAnalytics(petId);
      _error = null;

    } catch (e, stackTrace) {
      _error = _handleError('Failed to update team member', e, stackTrace);
      _logger.error('Failed to update team member', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeTeamMember(String petId, String memberId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('care_teams')
          .doc(memberId)
          .delete();

      _removeCareTeamMember(petId, memberId);
      await _updateTeamAnalytics(petId);
      _error = null;

    } catch (e, stackTrace) {
      _error = _handleError('Failed to remove team member', e, stackTrace);
      _logger.error('Failed to remove team member', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _removeCareTeamMember(String petId, String memberId) {
    final team = _careTeams[petId] ?? [];
    team.removeWhere((member) => member.id == memberId);
    _careTeams[petId] = team;
    notifyListeners();
  }

  Map<String, dynamic> _getDefaultPermissions(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return {
          'canEdit': true,
          'canDelete': true,
          'canInvite': true,
          'canManageTeam': true,
        };
      case 'veterinarian':
        return {
          'canEdit': true,
          'canDelete': false,
          'canInvite': false,
          'canManageTeam': false,
          'canAddMedicalRecords': true,
        };
      case 'caretaker':
        return {
          'canEdit': false,
          'canDelete': false,
          'canInvite': false,
          'canManageTeam': false,
          'canAddCareNotes': true,
        };
      default:
        return {
          'canEdit': false,
          'canDelete': false,
          'canInvite': false,
          'canManageTeam': false,
        };
    }
  }

  Future<Map<String, dynamic>> getTeamAnalytics(String petId) async {
    if (_needsRefresh(petId)) {
      await _updateTeamAnalytics(petId);
    }
    return _teamAnalytics[petId] ?? {};
  }

  Future<void> _updateTeamAnalytics(String petId) async {
    try {
      final team = _careTeams[petId] ?? [];
      
      _teamAnalytics[petId] = {
        'overview': _generateTeamOverview(team),
        'roleDistribution': _calculateRoleDistribution(team),
        'activityMetrics': await _calculateActivityMetrics(petId, team),
        'scheduleAnalysis': _analyzeScheduleCoverage(team),
        'performanceMetrics': await _calculatePerformanceMetrics(petId, team),
      };

    } catch (e, stackTrace) {
      _logger.error('Failed to update team analytics', e, stackTrace);
    }
  }

  Map<String, dynamic> _generateTeamOverview(List<CareTeamMember> team) {
    return {
      'totalMembers': team.length,
      'activeMembers': team.where((m) => m.isActive).length,
      'roles': team.map((m) => m.role).toSet().toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  Map<String, int> _calculateRoleDistribution(List<CareTeamMember> team) {
    final distribution = <String, int>{};
    for (var member in team) {
      distribution[member.role] = (distribution[member.role] ?? 0) + 1;
    }
    return distribution;
  }

  Future<Map<String, dynamic>> _calculateActivityMetrics(
    String petId,
    List<CareTeamMember> team,
  ) async {
    // Implement activity metrics calculation
    return {};
  }

  Map<String, dynamic> _analyzeScheduleCoverage(List<CareTeamMember> team) {
    // Implement schedule coverage analysis
    return {};
  }

  Future<Map<String, dynamic>> _calculatePerformanceMetrics(
    String petId,
    List<CareTeamMember> team,
  ) async {
    // Implement performance metrics calculation
    return {};
  }

  bool _needsRefresh(String petId) {
    final lastUpdate = _lastUpdated[petId];
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) > const Duration(minutes: 15);
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

class CareTeamMember {
  final String id;
  final String petId;
  final String userId;
  final String role;
  final String name;
  final String? email;
  final String? phone;
  final Map<String, dynamic> permissions;
  final Map<String, dynamic> schedule;
  final Map<String, dynamic> metadata;
  final bool isActive;
  final DateTime joinedAt;

  CareTeamMember({
    required this.id,
    required this.petId,
    required this.userId,
    required this.role,
    required this.name,
    this.email,
    this.phone,
    required this.permissions,
    required this.schedule,
    required this.metadata,
    required this.isActive,
    required this.joinedAt,
  });

  CareTeamMember copyWith({
    String? role,
    String? name,
    String? email,
    String? phone,
    Map<String, dynamic>? permissions,
    Map<String, dynamic>? schedule,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return CareTeamMember(
      id: id,
      petId: petId,
      userId: userId,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      permissions: permissions ?? this.permissions,
      schedule: schedule ?? this.schedule,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
      joinedAt: joinedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'userId': userId,
    'role': role,
    'name': name,
    'email': email,
    'phone': phone,
    'permissions': permissions,
    'schedule': schedule,
    'metadata': metadata,
    'isActive': isActive,
    'joinedAt': joinedAt.toIso8601String(),
  };

  factory CareTeamMember.fromJson(Map<String, dynamic> json) => CareTeamMember(
    id: json['id'],
    petId: json['petId'],
    userId: json['userId'],
    role: json['role'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    permissions: json['permissions'] ?? {},
    schedule: json['schedule'] ?? {},
    metadata: json['metadata'] ?? {},
    isActive: json['isActive'] ?? true,
    joinedAt: DateTime.parse(json['joinedAt']),
  );
}

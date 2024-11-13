// lib/providers/care_team_provider.dart

import 'package:flutter/foundation.dart';
import '../services/pet_service.dart';
import '../models/pet.dart';

class CareTeamProvider with ChangeNotifier {
  final PetService _petService = PetService();
  Map<String, List<CareTeamMember>> _careTeamMembers = {};
  Map<String, List<CareTeamInvite>> _pendingInvites = {};
  Map<String, DateTime> _lastUpdated = {};
  Map<String, Map<String, dynamic>> _teamAnalytics = {};
  bool _isLoading = false;
  String? _error;
  Duration _cacheExpiration = const Duration(hours: 1);

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

  // Get care team with optional refresh
  Future<List<CareTeamMember>> getCareTeamForPet(
    String petId, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh || _needsRefresh(petId)) {
      await loadCareTeam(petId);
    }
    return _careTeamMembers[petId] ?? [];
  }

  // Enhanced load care team
  Future<void> loadCareTeam(
    String petId, {
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final members = await _petService.getCareTeamMembers(petId);
      final invites = await _petService.getPendingInvites(petId);

      _careTeamMembers[petId] = members
          .map((data) => CareTeamMember.fromJson(data))
          .toList();
      
      _pendingInvites[petId] = invites
          .map((data) => CareTeamInvite.fromJson(data))
          .toList();

      _lastUpdated[petId] = DateTime.now();
      await _updateTeamAnalytics(petId);
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

  // Enhanced add care team member
  Future<void> addCareTeamMember({
    required String petId,
    required String name,
    required String role,
    required List<String> permissions,
    String? email,
    String? phone,
    Map<String, bool>? accessLevels,
    String? specialization,
    String? organization,
    Map<String, dynamic>? availability,
    Map<String, dynamic>? notifications,
    String? emergencyContact,
    List<String>? certifications,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validate member data
      _validateMemberData(
        name: name,
        role: role,
        permissions: permissions,
        email: email,
        phone: phone,
      );

      final newMember = await _petService.addCareTeamMember(
        petId: petId,
        name: name,
        role: role,
        permissions: permissions,
        email: email,
        phone: phone,
        accessLevels: accessLevels,
        specialization: specialization,
        organization: organization,
        availability: availability,
        notifications: notifications,
        emergencyContact: emergencyContact,
        certifications: certifications,
        metadata: metadata,
      );

      // Update local cache
      final members = _careTeamMembers[petId] ?? [];
      members.add(CareTeamMember.fromJson(newMember));
      _careTeamMembers[petId] = members;

      await _updateTeamAnalytics(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError(e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Validate member data
  void _validateMemberData({
    required String name,
    required String role,
    required List<String> permissions,
    String? email,
    String? phone,
  }) {
    if (name.isEmpty) {
      throw CareTeamException('Name is required');
    }
    if (role.isEmpty) {
      throw CareTeamException('Role is required');
    }
    if (permissions.isEmpty) {
      throw CareTeamException('At least one permission is required');
    }
    if (email != null && !_isValidEmail(email)) {
      throw CareTeamException('Invalid email format');
    }
    if (phone != null && !_isValidPhone(phone)) {
      throw CareTeamException('Invalid phone format');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone);
  }

  // ... (continued in next part)
  // Continuing lib/providers/care_team_provider.dart

  // Enhanced update care team member
  Future<void> updateCareTeamMember({
    required String petId,
    required String memberId,
    String? name,
    String? role,
    List<String>? permissions,
    String? email,
    String? phone,
    Map<String, bool>? accessLevels,
    String? specialization,
    String? organization,
    Map<String, dynamic>? availability,
    Map<String, dynamic>? notifications,
    String? emergencyContact,
    List<String>? certifications,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validate existing member
      final existingMember = getMemberById(petId, memberId);
      if (existingMember == null) {
        throw CareTeamException('Member not found');
      }

      final updatedMember = await _petService.updateCareTeamMember(
        petId: petId,
        memberId: memberId,
        name: name,
        role: role,
        permissions: permissions,
        email: email,
        phone: phone,
        accessLevels: accessLevels,
        specialization: specialization,
        organization: organization,
        availability: availability,
        notifications: notifications,
        emergencyContact: emergencyContact,
        certifications: certifications,
        metadata: metadata,
      );

      // Update local cache
      final members = _careTeamMembers[petId] ?? [];
      final index = members.indexWhere((m) => m.id == memberId);
      if (index != -1) {
        members[index] = CareTeamMember.fromJson(updatedMember);
        _careTeamMembers[petId] = members;
      }

      await _updateTeamAnalytics(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError(e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enhanced invitation management
  Future<void> sendInvitation({
    required String petId,
    required String email,
    required String role,
    required List<String> permissions,
    String? message,
    Duration? expiresIn,
    Map<String, bool>? accessLevels,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (!_isValidEmail(email)) {
        throw CareTeamException('Invalid email format');
      }

      final invite = await _petService.sendInvitation(
        petId: petId,
        email: email,
        role: role,
        permissions: permissions,
        message: message,
        expiresIn: expiresIn ?? const Duration(days: 7),
        accessLevels: accessLevels,
        metadata: metadata,
      );

      // Update pending invites
      final invites = _pendingInvites[petId] ?? [];
      invites.add(CareTeamInvite.fromJson(invite));
      _pendingInvites[petId] = invites;

      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError(e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel invitation
  Future<void> cancelInvitation(String petId, String inviteId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _petService.cancelInvitation(petId, inviteId);

      // Update local cache
      final invites = _pendingInvites[petId] ?? [];
      _pendingInvites[petId] = invites
          .where((invite) => invite.id != inviteId)
          .toList();

      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError(e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Team Analytics
  Future<void> _updateTeamAnalytics(String petId) async {
    final members = _careTeamMembers[petId] ?? [];
    final invites = _pendingInvites[petId] ?? [];

    _teamAnalytics[petId] = {
      'totalMembers': members.length,
      'activeMembers': members.where((m) => m.isActive).length,
      'roleDistribution': _calculateRoleDistribution(members),
      'contactCompleteness': _calculateContactCompleteness(members),
      'pendingInvites': invites.length,
      'teamComposition': _analyzeTeamComposition(members),
      'accessLevelDistribution': _calculateAccessLevelDistribution(members),
      'availabilityAnalysis': _analyzeAvailability(members),
      'certificationsSummary': _analyzeCertifications(members),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  Map<String, int> _calculateRoleDistribution(List<CareTeamMember> members) {
    final distribution = <String, int>{};
    for (var member in members) {
      distribution[member.role] = (distribution[member.role] ?? 0) + 1;
    }
    return distribution;
  }

  double _calculateContactCompleteness(List<CareTeamMember> members) {
    if (members.isEmpty) return 0.0;
    
    int completeContacts = 0;
    for (var member in members) {
      if (member.email != null && member.phone != null) {
        completeContacts++;
      }
    }
    return (completeContacts / members.length) * 100;
  }

  Map<String, dynamic> _analyzeTeamComposition(List<CareTeamMember> members) {
    return {
      'hasVeterinarian': members.any((m) => 
          m.role.toLowerCase().contains('vet')),
      'hasPrimaryCaregiver': members.any((m) => 
          m.role.toLowerCase() == 'primary caregiver'),
      'specializations': members
          .where((m) => m.specialization != null)
          .map((m) => m.specialization!)
          .toSet()
          .toList(),
      'organizations': members
          .where((m) => m.organization != null)
          .map((m) => m.organization!)
          .toSet()
          .toList(),
    };
  }

  // Generate comprehensive team report
  Map<String, dynamic> generateTeamReport(String petId) {
    final analytics = _teamAnalytics[petId];
    if (analytics == null) return {};

    return {
      'summary': {
        'totalMembers': analytics['totalMembers'],
        'activeMembers': analytics['activeMembers'],
        'pendingInvites': analytics['pendingInvites'],
        'contactCompleteness': analytics['contactCompleteness'],
      },
      'composition': analytics['teamComposition'],
      'distribution': {
        'roles': analytics['roleDistribution'],
        'accessLevels': analytics['accessLevelDistribution'],
      },
      'availability': analytics['availabilityAnalysis'],
      'certifications': analytics['certificationsSummary'],
      'recommendations': generateTeamRecommendations(petId),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  List<String> generateTeamRecommendations(String petId) {
    final analytics = _teamAnalytics[petId];
    if (analytics == null) return [];

    final recommendations = <String>[];
    final composition = analytics['teamComposition'] as Map<String, dynamic>;

    if (!composition['hasVeterinarian']) {
      recommendations.add('Add a veterinarian to the care team');
    }
    if (!composition['hasPrimaryCaregiver']) {
      recommendations.add('Designate a primary caregiver');
    }
    if (analytics['contactCompleteness'] < 80) {
      recommendations.add('Update contact information for team members');
    }

    return recommendations;
  }

  String _handleError(dynamic error, StackTrace stackTrace) {
    debugPrint('CareTeam Error: $error');
    debugPrint('StackTrace: $stackTrace');
    return 'Failed to process care team operation: ${error.toString()}';
  }
}

class CareTeamException implements Exception {
  final String message;
  CareTeamException(this.message);

  @override
  String toString() => message;
}
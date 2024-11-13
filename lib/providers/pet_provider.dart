// lib/providers/pet_provider.dart

import 'package:flutter/foundation.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';
import 'dart:async';

class PetProvider with ChangeNotifier {
  final PetService _petService = PetService();
  List<Pet> _pets = [];
  Pet? _selectedPet;
  bool _isLoading = false;
  String? _error;
  Map<String, DateTime> _lastUpdated = {};
  Map<String, Map<String, dynamic>> _petAnalytics = {};
  Timer? _autoRefreshTimer;
  Duration _cacheExpiration = const Duration(minutes: 30);
  bool _isInitialized = false;

  // Enhanced Getters
  List<Pet> get pets => _pets;
  Pet? get selectedPet => _selectedPet;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  Map<String, DateTime> get lastUpdated => _lastUpdated;

  PetProvider() {
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _refreshAllPets(silent: true),
    );
  }

  // Enhanced initialization
  Future<void> initialize(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (_isInitialized && !forceRefresh) return;

    try {
      _isLoading = true;
      notifyListeners();

      final petsList = await _petService.getUserPets(userId);
      _pets = petsList.map((data) => Pet.fromJson(data)).toList();

      if (_pets.isNotEmpty && _selectedPet == null) {
        _selectedPet = _pets.first;
      }

      // Initialize analytics for each pet
      for (var pet in _pets) {
        if (pet.id != null) {
          await _updatePetAnalytics(pet.id!);
          _lastUpdated[pet.id!] = DateTime.now();
        }
      }

      _isInitialized = true;
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Initialization failed', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if data needs refresh
  bool _needsRefresh(String petId) {
    final lastUpdate = _lastUpdated[petId];
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) > _cacheExpiration;
  }

  // Enhanced pet retrieval
  Future<Pet?> getPetById(
    String id, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh || _needsRefresh(id)) {
      await _refreshPetData(id);
    }
    return _pets.firstWhereOrNull((pet) => pet.id == id);
  }

  // Enhanced pet addition
  Future<void> addPet(
    Pet pet, {
    bool setAsSelected = true,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validate pet data
      _validatePetData(pet);

      final petId = await _petService.createPet(
        userId: pet.userId!,
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        dateOfBirth: pet.birthDate,
        gender: pet.gender,
        weight: pet.weight,
        microchipNumber: pet.microchipNumber,
        profileImage: pet.profileImage,
        allergies: pet.allergies,
        medications: pet.medications,
        veterinarianId: pet.veterinarianId,
        emergencyContact: pet.emergencyContact?.toJson(),
        metadata: {
          'createdAt': DateTime.now().toIso8601String(),
          'platform': 'mobile',
          'appVersion': await _getAppVersion(),
        },
      );

      final newPet = pet.copyWith(
        id: petId,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      _pets.add(newPet);
      _lastUpdated[petId] = DateTime.now();
      
      if (setAsSelected || _pets.length == 1) {
        _selectedPet = newPet;
      }

      await _updatePetAnalytics(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Failed to add pet', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Validate pet data
  void _validatePetData(Pet pet) {
    if (pet.name.isEmpty) {
      throw PetException('Pet name is required');
    }
    if (pet.species.isEmpty) {
      throw PetException('Species is required');
    }
    if (pet.birthDate != null && pet.birthDate!.isAfter(DateTime.now())) {
      throw PetException('Birth date cannot be in the future');
    }
    if (pet.weight != null && pet.weight! <= 0) {
      throw PetException('Weight must be greater than 0');
    }
  }

  // ... (continued in next part)
  // Continuing lib/providers/pet_provider.dart

  // Enhanced pet update
  Future<void> updatePet(Pet updatedPet) async {
    try {
      _isLoading = true;
      notifyListeners();

      _validatePetData(updatedPet);
      
      // Track changes for analytics
      final originalPet = getPetById(updatedPet.id!);
      final changes = _detectPetChanges(originalPet, updatedPet);

      await _petService.updatePet(
        petId: updatedPet.id!,
        name: updatedPet.name,
        species: updatedPet.species,
        breed: updatedPet.breed,
        dateOfBirth: updatedPet.birthDate,
        gender: updatedPet.gender,
        weight: updatedPet.weight,
        microchipNumber: updatedPet.microchipNumber,
        profileImage: updatedPet.profileImage,
        allergies: updatedPet.allergies,
        medications: updatedPet.medications,
        veterinarianId: updatedPet.veterinarianId,
        emergencyContact: updatedPet.emergencyContact?.toJson(),
        lastCheckup: updatedPet.lastCheckup,
        nextCheckupDue: updatedPet.nextVaccinationDate,
        metadata: {
          'lastModified': DateTime.now().toIso8601String(),
          'modifiedFields': changes.keys.toList(),
          'platform': 'mobile',
          'appVersion': await _getAppVersion(),
        },
      );

      final index = _pets.indexWhere((pet) => pet.id == updatedPet.id);
      if (index != -1) {
        _pets[index] = updatedPet.copyWith(lastUpdated: DateTime.now());
        if (_selectedPet?.id == updatedPet.id) {
          _selectedPet = _pets[index];
        }
      }

      _lastUpdated[updatedPet.id!] = DateTime.now();
      await _updatePetAnalytics(updatedPet.id!);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Failed to update pet', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _detectPetChanges(Pet? original, Pet updated) {
    if (original == null) return {'all': true};
    
    final changes = <String, dynamic>{};
    
    if (original.name != updated.name) changes['name'] = updated.name;
    if (original.weight != updated.weight) changes['weight'] = updated.weight;
    if (original.medications != updated.medications) {
      changes['medications'] = {
        'added': updated.medications?.where((m) => !original.medications!.contains(m)),
        'removed': original.medications?.where((m) => !updated.medications!.contains(m)),
      };
    }
    // Add more field comparisons as needed
    
    return changes;
  }

  // Enhanced refresh methods
  Future<void> _refreshAllPets({bool silent = false}) async {
    try {
      if (!silent) {
        _isLoading = true;
        notifyListeners();
      }

      for (var pet in _pets) {
        if (pet.id != null) {
          await _refreshPetData(pet.id!, silent: true);
        }
      }

      if (!silent) {
        _error = null;
      }
    } catch (e, stackTrace) {
      _error = _handleError('Failed to refresh pets', e, stackTrace);
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _refreshPetData(String petId, {bool silent = false}) async {
    try {
      if (!silent) {
        _isLoading = true;
        notifyListeners();
      }

      final petData = await _petService.getPet(petId);
      final updatedPet = Pet.fromJson(petData);
      
      final index = _pets.indexWhere((pet) => pet.id == petId);
      if (index != -1) {
        _pets[index] = updatedPet;
        if (_selectedPet?.id == petId) {
          _selectedPet = updatedPet;
        }
      }
      
      _lastUpdated[petId] = DateTime.now();
      await _updatePetAnalytics(petId);

      if (!silent) {
        _error = null;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      _error = _handleError('Failed to refresh pet data', e, stackTrace);
      if (!silent) rethrow;
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Enhanced analytics methods
  Future<void> _updatePetAnalytics(String petId) async {
    try {
      final pet = _pets.firstWhere((p) => p.id == petId);
      
      _petAnalytics[petId] = {
        'overview': {
          'age': _calculateAge(pet.birthDate),
          'lastCheckup': pet.lastCheckup,
          'nextVaccination': pet.nextVaccinationDate,
          'healthScore': await _calculateHealthScore(pet),
        },
        'healthMetrics': await _analyzeHealthMetrics(pet),
        'behaviorAnalysis': await _analyzeBehaviorPatterns(pet),
        'careCompliance': _analyzeCareCompliance(pet),
        'medicationTracking': _analyzeMedicationAdherence(pet),
        'vetVisits': _analyzeVetVisitHistory(pet),
        'recommendations': await _generatePetRecommendations(pet),
      };
    } catch (e, stackTrace) {
      _error = _handleError('Failed to update analytics', e, stackTrace);
    }
  }

  Map<String, dynamic> generatePetReport(String petId) {
    final analytics = _petAnalytics[petId];
    if (analytics == null) return {};

    return {
      'summary': analytics['overview'],
      'health': {
        'metrics': analytics['healthMetrics'],
        'behavior': analytics['behaviorAnalysis'],
        'medications': analytics['medicationTracking'],
      },
      'care': {
        'compliance': analytics['careCompliance'],
        'vetVisits': analytics['vetVisits'],
      },
      'recommendations': analytics['recommendations'],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  String _handleError(String operation, dynamic error, StackTrace stackTrace) {
    debugPrint('PetProvider Error: $operation');
    debugPrint('Error: $error');
    debugPrint('StackTrace: $stackTrace');
    return 'Failed to $operation: ${error.toString()}';
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}

class PetException implements Exception {
  final String message;
  PetException(this.message);

  @override
  String toString() => message;
}
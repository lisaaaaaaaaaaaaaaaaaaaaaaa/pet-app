import 'package:flutter/foundation.dart';
import '../models/medication.dart';
import '../models/symptom_log.dart';
import '../models/medical_record.dart';
import '../models/pet.dart';

class PetProvider with ChangeNotifier {
  Pet? _selectedPet;
  final Map<String, List<Medication>> _medications = {};
  final Map<String, List<SymptomLog>> _symptoms = {};
  final Map<String, List<MedicalRecord>> _medicalRecords = {};

  Pet? get selectedPet => _selectedPet;

  void selectPet(Pet pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  // Medications
  List<Medication> getMedications(String petId) {
    return _medications[petId] ?? [];
  }

  Future<void> loadMedications(String petId) async {
    try {
      // TODO: Implement API call to fetch medications
      // For now, using mock data
      _medications[petId] = [
        Medication(
          id: '1',
          petId: petId,
          name: 'Heartworm Prevention',
          dosage: '1 tablet',
          instructions: 'Give once monthly with food',
          nextDose: DateTime.now().add(const Duration(days: 2)),
        ),
        Medication(
          id: '2',
          petId: petId,
          name: 'Flea and Tick Prevention',
          dosage: '1 application',
          instructions: 'Apply to back of neck monthly',
          nextDose: DateTime.now().add(const Duration(days: 15)),
        ),
      ];
      notifyListeners();
    } catch (e) {
      print('Error loading medications: $e');
      rethrow;
    }
  }

  Future<void> addMedication({
    required String petId,
    required Medication medication,
  }) async {
    try {
      // TODO: Implement API call to add medication
      if (!_medications.containsKey(petId)) {
        _medications[petId] = [];
      }
      _medications[petId]!.add(medication);
      notifyListeners();
    } catch (e) {
      print('Error adding medication: $e');
      rethrow;
    }
  }

  Future<void> updateMedication({
    required String petId,
    required Medication medication,
  }) async {
    try {
      // TODO: Implement API call to update medication
      if (_medications.containsKey(petId)) {
        final index = _medications[petId]!.indexWhere((m) => m.id == medication.id);
        if (index != -1) {
          _medications[petId]![index] = medication;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating medication: $e');
      rethrow;
    }
  }

  Future<void> deleteMedication({
    required String petId,
    required String medicationId,
  }) async {
    try {
      // TODO: Implement API call to delete medication
      if (_medications.containsKey(petId)) {
        _medications[petId]!.removeWhere((m) => m.id == medicationId);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting medication: $e');
      rethrow;
    }
  }

  // Symptoms
  List<SymptomLog> getSymptoms(String petId) {
    return _symptoms[petId] ?? [];
  }

  Future<void> loadSymptoms(String petId) async {
    try {
      // TODO: Implement API call to fetch symptoms
      // For now, using mock data
      _symptoms[petId] = [
        SymptomLog(
          id: '1',
          petId: petId,
          type: 'Lethargy',
          severity: 2,
          observedAt: DateTime.now().subtract(const Duration(days: 1)),
          notes: 'Less active than usual',
        ),
        SymptomLog(
          id: '2',
          petId: petId,
          type: 'Loss of Appetite',
          severity: 1,
          observedAt: DateTime.now().subtract(const Duration(days: 2)),
          notes: 'Skipped breakfast',
        ),
      ];
      notifyListeners();
    } catch (e) {
      print('Error loading symptoms: $e');
      rethrow;
    }
  }

  Future<void> addSymptom({
    required String petId,
    required SymptomLog symptom,
  }) async {
    try {
      // TODO: Implement API call to add symptom
      if (!_symptoms.containsKey(petId)) {
        _symptoms[petId] = [];
      }
      _symptoms[petId]!.add(symptom);
      notifyListeners();
    } catch (e) {
      print('Error adding symptom: $e');
      rethrow;
    }
  }

  Future<void> updateSymptom({
    required String petId,
    required SymptomLog symptom,
  }) async {
    try {
      // TODO: Implement API call to update symptom
      if (_symptoms.containsKey(petId)) {
        final index = _symptoms[petId]!.indexWhere((s) => s.id == symptom.id);
        if (index != -1) {
          _symptoms[petId]![index] = symptom;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating symptom: $e');
      rethrow;
    }
  }

  Future<void> deleteSymptom({
    required String petId,
    required String symptomId,
  }) async {
    try {
      // TODO: Implement API call to delete symptom
      if (_symptoms.containsKey(petId)) {
        _symptoms[petId]!.removeWhere((s) => s.id == symptomId);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting symptom: $e');
      rethrow;
    }
  }

  // Medical Records
  List<MedicalRecord> getMedicalRecords(String petId) {
    return _medicalRecords[petId] ?? [];
  }

  Future<void> loadMedicalRecords(String petId) async {
    try {
      // TODO: Implement API call to fetch medical records
      // For now, using mock data
      _medicalRecords[petId] = [
        MedicalRecord(
          id: '1',
          petId: petId,
          title: 'Annual Checkup',
          type: 'Checkup',
          date: DateTime.now().subtract(const Duration(days: 30)),
          provider: 'Dr. Smith',
          notes: 'All vitals normal, weight stable',
        ),
        MedicalRecord(
          id: '2',
          petId: petId,
          title: 'Rabies Vaccination',
          type: 'Vaccination',
          date: DateTime.now().subtract(const Duration(days: 60)),
          provider: 'Dr. Johnson',
          notes: 'Three-year vaccination administered',
        ),
      ];
      notifyListeners();
    } catch (e) {
      print('Error loading medical records: $e');
      rethrow;
    }
  }

  Future<void> addMedicalRecord({
    required String petId,
    required MedicalRecord record,
  }) async {
    try {
      // TODO: Implement API call to add medical record
      if (!_medicalRecords.containsKey(petId)) {
        _medicalRecords[petId] = [];
      }
      _medicalRecords[petId]!.add(record);
      notifyListeners();
    } catch (e) {
      print('Error adding medical record: $e');
      rethrow;
    }
  }

  Future<void> updateMedicalRecord({
    required String petId,
    required MedicalRecord record,
  }) async {
    try {
      // TODO: Implement API call to update medical record
      if (_medicalRecords.containsKey(petId)) {
        final index = _medicalRecords[petId]!.indexWhere((r) => r.id == record.id);
        if (index != -1) {
          _medicalRecords[petId]![index] = record;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating medical record: $e');
      rethrow;
    }
  }

  Future<void> deleteMedicalRecord({
    required String petId,
    required String recordId,
  }) async {
    try {
      // TODO: Implement API call to delete medical record
      if (_medicalRecords.containsKey(petId)) {
        _medicalRecords[petId]!.removeWhere((r) => r.id == recordId);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting medical record: $e');
      rethrow;
    }
  }
}

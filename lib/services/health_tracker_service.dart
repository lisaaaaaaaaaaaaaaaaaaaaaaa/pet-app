// lib/services/health_tracker_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_record.dart';
import '../models/weight_record.dart';
import '../models/medication.dart';
import '../models/symptom_record.dart';

class HealthTrackerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern
  static final HealthTrackerService _instance = HealthTrackerService._internal();
  factory HealthTrackerService() => _instance;
  HealthTrackerService._internal();

  // Collection references
  CollectionReference get _usersRef => _firestore.collection('users');

  // Get pet's health collection reference
  CollectionReference _petHealthRef(String userId, String petId) =>
      _usersRef.doc(userId).collection('pets').doc(petId).collection('health');

  // HEALTH RECORDS

  Stream<List<HealthRecord>> getPetHealthRecords(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    try {
      var query = _petHealthRef(userId, petId)
          .doc('records')
          .collection('general')
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      return query.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => HealthRecord.fromJson(doc.data()))
          .toList());
    } catch (e) {
      throw HealthTrackerException('Error getting health records: $e');
    }
  }

  Future<void> addHealthRecord(
    String userId,
    String petId,
    HealthRecord record,
  ) async {
    try {
      await _petHealthRef(userId, petId)
          .doc('records')
          .collection('general')
          .doc(record.id)
          .set(record.toJson());

      // Update latest metrics
      await _updateLatestMetrics(userId, petId, record);
    } catch (e) {
      throw HealthTrackerException('Error adding health record: $e');
    }
  }

  Future<void> updateHealthRecord(
    String userId,
    String petId,
    HealthRecord record,
  ) async {
    try {
      await _petHealthRef(userId, petId)
          .doc('records')
          .collection('general')
          .doc(record.id)
          .update(record.toJson());

      // Update latest metrics
      await _updateLatestMetrics(userId, petId, record);
    } catch (e) {
      throw HealthTrackerException('Error updating health record: $e');
    }
  }

  Future<void> deleteHealthRecord(
    String userId,
    String petId,
    String recordId,
  ) async {
    try {
      await _petHealthRef(userId, petId)
          .doc('records')
          .collection('general')
          .doc(recordId)
          .delete();
    } catch (e) {
      throw HealthTrackerException('Error deleting health record: $e');
    }
  }

  // WEIGHT TRACKING

  Stream<List<WeightRecord>> getPetWeightRecords(
    String userId,
    String petId, {
    int? limit,
  }) {
    try {
      var query = _petHealthRef(userId, petId)
          .doc('records')
          .collection('weight')
          .orderBy('date', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => WeightRecord.fromJson(doc.data()))
          .toList());
    } catch (e) {
      throw HealthTrackerException('Error getting weight records: $e');
    }
  }

  Future<void> addWeightRecord(
    String userId,
    String petId,
    WeightRecord record,
  ) async {
    try {
      await _petHealthRef(userId, petId)
          .doc('records')
          .collection('weight')
          .doc(record.id)
          .set(record.toJson());

      // Update latest weight in pet profile
      await _updateLatestWeight(userId, petId, record);
    } catch (e) {
      throw HealthTrackerException('Error adding weight record: $e');
    }
  }

  // MEDICATIONS

  Stream<List<Medication>> getPetMedications(
    String userId,
    String petId, {
    bool activeOnly = true,
  }) {
    try {
      var query = _petHealthRef(userId, petId)
          .doc('medications')
          .collection('list')
          .orderBy('startDate', descending: true);

      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      return query.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => Medication.fromJson(doc.data()))
          .toList());
    } catch (e) {
      throw HealthTrackerException('Error getting medications: $e');
    }
  }

  Future<void> addMedication(
    String userId,
    String petId,
    Medication medication,
  ) async {
    try {
      await _petHealthRef(userId, petId)
          .doc('medications')
          .collection('list')
          .doc(medication.id)
          .set(medication.toJson());
    } catch (e) {
      throw HealthTrackerException('Error adding medication: $e');
    }
  }

  Future<void> updateMedication(
    String userId,
    String petId,
    Medication medication,
  ) async {
    try {
      await _petHealthRef(userId, petId)
          .doc('medications')
          .collection('list')
          .doc(medication.id)
          .update(medication.toJson());
    } catch (e) {
      throw HealthTrackerException('Error updating medication: $e');
    }
  }

  Future<void> deleteMedication(
    String userId,
    String petId,
    String medicationId,
  ) async {
    try {
      await _petHealthRef(userId, petId)
          .doc('medications')
          .collection('list')
          .doc(medicationId)
          .delete();
    } catch (e) {
      throw HealthTrackerException('Error deleting medication: $e');
    }
  }

  // SYMPTOMS TRACKING

  Stream<List<SymptomRecord>> getPetSymptoms(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    try {
      var query = _petHealthRef(userId, petId)
          .doc('symptoms')
          .collection('records')
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      return query.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => SymptomRecord.fromJson(doc.data()))
          .toList());
    } catch (e) {
      throw HealthTrackerException('Error getting symptoms: $e');
    }
  }

  Future<void> addSymptomRecord(
    String userId,
    String petId,
    SymptomRecord record,
  ) async {
    try {
      await _petHealthRef(userId, petId)
          .doc('symptoms')
          .collection('records')
          .doc(record.id)
          .set(record.toJson());
    } catch (e) {
      throw HealthTrackerException('Error adding symptom record: $e');
    }
  }

  // HEALTH METRICS AND ANALYTICS

  Future<Map<String, dynamic>> getHealthMetrics(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final healthRecords = await getPetHealthRecords(
        userId,
        petId,
        startDate: startDate,
        endDate: endDate,
      ).first;

      final weightRecords = await getPetWeightRecords(userId, petId).first;
      final medications = await getPetMedications(userId, petId).first;
      final symptoms = await getPetSymptoms(
        userId,
        petId,
        startDate: startDate,
        endDate: endDate,
      ).first;

      // Calculate metrics
      return {
        'totalRecords': healthRecords.length,
        'weightTrend': _calculateWeightTrend(weightRecords),
        'activeMedications': medications.length,
        'commonSymptoms': _getCommonSymptoms(symptoms),
        'lastCheckup': healthRecords.isNotEmpty ? healthRecords.first.date : null,
        'healthScore': _calculateHealthScore(
          healthRecords,
          symptoms,
          medications,
        ),
      };
    } catch (e) {
      throw HealthTrackerException('Error calculating health metrics: $e');
    }
  }

  // Helper Methods

  Future<void> _updateLatestMetrics(
    String userId,
    String petId,
    HealthRecord record,
  ) async {
    try {
      await _petHealthRef(userId, petId).doc('metrics').set({
        'lastCheckup': record.date,
        'lastVetVisit': record.vetVisit,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw HealthTrackerException('Error updating latest metrics: $e');
    }
  }

  Future<void> _updateLatestWeight(
    String userId,
    String petId,
    WeightRecord record,
  ) async {
    try {
      await _usersRef
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .update({'currentWeight': record.weight});
    } catch (e) {
      throw HealthTrackerException('Error updating latest weight: $e');
    }
  }

  Map<String, double> _calculateWeightTrend(List<WeightRecord> records) {
    if (records.length < 2) return {};

    final sorted = List<WeightRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    double totalChange = 0;
    double monthlyChange = 0;

    if (sorted.length >= 2) {
      totalChange =
          sorted.last.weight - sorted.first.weight;
      
      final lastMonth = sorted.where((record) =>
          record.date.isAfter(DateTime.now().subtract(const Duration(days: 30))));
      
      if (lastMonth.length >= 2) {
        monthlyChange = lastMonth.last.weight - lastMonth.first.weight;
      }
    }

    return {
      'totalChange': totalChange,
      'monthlyChange': monthlyChange,
    };
  }

  List<Map<String, dynamic>> _getCommonSymptoms(List<SymptomRecord> symptoms) {
    final Map<String, int> symptomCount = {};

    for (var record in symptoms) {
      for (var symptom in record.symptoms) {
        symptomCount[symptom] = (symptomCount[symptom] ?? 0) + 1;
      }
    }

    final sortedSymptoms = symptomCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedSymptoms
        .take(5)
        .map((e) => {
              'symptom': e.key,
              'count': e.value,
            })
        .toList();
  }

  double _calculateHealthScore(
    List<HealthRecord> healthRecords,
    List<SymptomRecord> symptoms,
    List<Medication> medications,
  ) {
    double score = 100;

    // Deduct points for recent symptoms
    final recentSymptoms = symptoms
        .where((s) => s.date
            .isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .length;
    score -= recentSymptoms * 2;

    // Deduct points for active medications
    final activeMeds = medications.where((m) => m.isActive).length;
    score -= activeMeds * 5;

    // Add points for regular checkups
    if (healthRecords.isNotEmpty) {
      final lastCheckup = healthRecords.first.date;
      final daysSinceCheckup =
          DateTime.now().difference(lastCheckup).inDays;
      if (daysSinceCheckup <= 180) {
        score += 10;
      }
    }

    return score.clamp(0, 100);
  }
}

class HealthTrackerException implements Exception {
  final String message;
  HealthTrackerException(this.message);

  @override
  String toString() => message;
}
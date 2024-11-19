import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/base_service.dart';
import '../models/health_record.dart';
import '../models/weight_record.dart';
import '../models/medication.dart';
import '../models/symptom_record.dart';
import '../models/vital_signs.dart';
import '../utils/exceptions.dart';

class HealthTrackerService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static final HealthTrackerService _instance = HealthTrackerService._internal();
  factory HealthTrackerService() => _instance;
  HealthTrackerService._internal();

  // Collection References
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference _petHealthRef(String userId, String petId) =>
      _usersRef.doc(userId).collection('pets').doc(petId).collection('health');

  // Health Records
  Future<void> addHealthRecord(String userId, String petId, HealthRecord record) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petHealthRef(userId, petId)
            .doc('records')
            .collection('general')
            .doc(record.id)
            .set(record.toJson());
            
        await _updateLatestMetrics(userId, petId, record);
        logger.i('Added health record: ${record.id}');
        analytics.logEvent('health_record_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding health record', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw HealthTrackerException('Error adding health record: $e');
    }
  }

  Stream<List<HealthRecord>> streamHealthRecords(
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
    } catch (e, stackTrace) {
      logger.e('Error streaming health records', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw HealthTrackerException('Error streaming health records: $e');
    }
  }

  // Weight Tracking
  Future<void> addWeightRecord(String userId, String petId, WeightRecord record) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petHealthRef(userId, petId)
            .doc('weight')
            .collection('records')
            .doc(record.id)
            .set(record.toJson());
            
        await _updateWeightMetrics(userId, petId, record);
        logger.i('Added weight record: ${record.id}');
        analytics.logEvent('weight_record_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding weight record', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw HealthTrackerException('Error adding weight record: $e');
    }
  }

  Future<List<WeightRecord>> getWeightHistory(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'weight_history_${userId}_$petId',
        duration: const Duration(hours: 1),
        fetchData: () async {
          var query = _petHealthRef(userId, petId)
              .doc('weight')
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

          if (limit != null) {
            query = query.limit(limit);
          }

          final snapshot = await query.get();
          return snapshot.docs
              .map((doc) => WeightRecord.fromJson(doc.data()))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting weight history', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw HealthTrackerException('Error getting weight history: $e');
    }
  }

  // Medication Tracking
  Future<void> addMedication(String userId, String petId, Medication medication) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petHealthRef(userId, petId)
            .doc('medications')
            .collection('active')
            .doc(medication.id)
            .set(medication.toJson());
            
        logger.i('Added medication: ${medication.id}');
        analytics.logEvent('medication_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding medication', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw HealthTrackerException('Error adding medication: $e');
    }
  }

  Future<List<Medication>> getActiveMedications(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'active_medications_${userId}_$petId',
        duration: const Duration(minutes: 30),
        fetchData: () async {
          final snapshot = await _petHealthRef(userId, petId)
              .doc('medications')
              .collection('active')
              .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
              .get();
              
          return snapshot.docs
              .map((doc) => Medication.fromJson(doc.data()))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting active medications', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw HealthTrackerException('Error getting active medications: $e');
    }
  }

  // Symptom Tracking
  Future<void> recordSymptom(String userId, String petId, SymptomRecord symptom) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petHealthRef(userId, petId)
            .doc('symptoms')
            .collection('records')
            .doc(symptom.id)
            .set(symptom.toJson());
            
        logger.i('Recorded symptom: ${symptom.id}');
        analytics.logEvent('symptom_recorded');
      });
    } catch (e, stackTrace) {
      logger.e('Error recording symptom', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw HealthTrackerException('Error recording symptom: $e');
    }
  }

  Stream<List<SymptomRecord>> streamRecentSymptoms(String userId, String petId) {
    try {
      return _petHealthRef(userId, petId)
          .doc('symptoms')
          .collection('records')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => SymptomRecord.fromJson(doc.data()))
              .toList());
    } catch (e, stackTrace) {
      logger.e('Error streaming symptoms', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw HealthTrackerException('Error streaming symptoms: $e');
    }
  }

  // Vital Signs
  Future<void> recordVitalSigns(String userId, String petId, VitalSigns vitals) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petHealthRef(userId, petId)
            .doc('vitals')
            .collection('records')
            .doc(vitals.id)
            .set(vitals.toJson());
            
        await _updateVitalMetrics(userId, petId, vitals);
        logger.i('Recorded vital signs: ${vitals.id}');
        analytics.logEvent('vitals_recorded');
      });
    } catch (e, stackTrace) {
      logger.e('Error recording vital signs', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw HealthTrackerException('Error recording vital signs: $e');
    }
  }

  // Health Analytics
  Future<Map<String, dynamic>> getHealthAnalytics(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await checkConnectivity();
      
      final weightRecords = await getWeightHistory(userId, petId, 
          startDate: startDate, endDate: endDate);
      final medications = await getActiveMedications(userId, petId);
      
      // Calculate analytics
      final analytics = {
        'weightTrend': _calculateWeightTrend(weightRecords),
        'activeMedications': medications.length,
        'lastCheckup': await _getLastCheckupDate(userId, petId),
        'healthScore': await _calculateHealthScore(userId, petId),
      };
      
      return analytics;
    } catch (e, stackTrace) {
      logger.e('Error getting health analytics', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw HealthTrackerException('Error getting health analytics: $e');
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
        'lastCondition': record.condition,
        'lastNotes': record.notes,
      }, SetOptions(merge: true));
    } catch (e) {
      logger.e('Error updating latest metrics', e);
    }
  }

  Future<void> _updateWeightMetrics(
    String userId,
    String petId,
    WeightRecord record,
  ) async {
    try {
      await _petHealthRef(userId, petId).doc('metrics').set({
        'lastWeight': record.weight,
        'lastWeightDate': record.date,
        'weightUnit': record.unit,
      }, SetOptions(merge: true));
    } catch (e) {
      logger.e('Error updating weight metrics', e);
    }
  }

  Future<void> _updateVitalMetrics(
    String userId,
    String petId,
    VitalSigns vitals,
  ) async {
    try {
      await _petHealthRef(userId, petId).doc('metrics').set({
        'lastVitals': vitals.toJson(),
        'lastVitalsDate': vitals.timestamp,
      }, SetOptions(merge: true));
    } catch (e) {
      logger.e('Error updating vital metrics', e);
    }
  }

  Map<String, dynamic> _calculateWeightTrend(List<WeightRecord> records) {
    if (records.isEmpty) return {'trend': 'stable', 'change': 0.0};
    
    final latest = records.first.weight;
    final oldest = records.last.weight;
    final change = latest - oldest;
    
    String trend;
    if (change > 0.5) {
      trend = 'increasing';
    } else if (change < -0.5) {
      trend = 'decreasing';
    } else {
      trend = 'stable';
    }
    
    return {
      'trend': trend,
      'change': change,
    };
  }

  Future<DateTime?> _getLastCheckupDate(String userId, String petId) async {
    final snapshot = await _petHealthRef(userId, petId)
        .doc('records')
        .collection('general')
        .orderBy('date', descending: true)
        .limit(1)
        .get();
        
    if (snapshot.docs.isEmpty) return null;
    return (snapshot.docs.first.data()['date'] as Timestamp).toDate();
  }

  Future<int> _calculateHealthScore(String userId, String petId) async {
    // Implement health score calculation logic
    // This could be based on various factors like:
    // - Recent vital signs
    // - Weight trends
    // - Medication adherence
    // - Symptom frequency
    // - Exercise records
    // Returns a score from 0-100
    return 85; // Placeholder implementation
  }
}

class HealthTrackerException implements Exception {
  final String message;
  HealthTrackerException(this.message);

  @override
  String toString() => message;
}

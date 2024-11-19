import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/base_service.dart';
import '../models/medical_record.dart';
import '../models/vaccination.dart';
import '../models/prescription.dart';
import '../models/medical_condition.dart';
import '../models/allergy.dart';
import '../utils/exceptions.dart';

class MedicalRecordService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static final MedicalRecordService _instance = MedicalRecordService._internal();
  factory MedicalRecordService() => _instance;
  MedicalRecordService._internal();

  // Collection References
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference _petMedicalRef(String userId, String petId) =>
      _usersRef.doc(userId).collection('pets').doc(petId).collection('medical');

  // Medical Records
  Future<void> addMedicalRecord(String userId, String petId, MedicalRecord record) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petMedicalRef(userId, petId)
            .doc('records')
            .collection('visits')
            .doc(record.id)
            .set(record.toJson());
            
        await _updateLatestVisit(userId, petId, record);
        logger.i('Added medical record: ${record.id}');
        analytics.logEvent('medical_record_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding medical record', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicalRecordException('Error adding medical record: $e');
    }
  }

  Future<List<MedicalRecord>> getMedicalHistory(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    int? limit,
  }) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'medical_history_${userId}_$petId',
        duration: const Duration(hours: 1),
        fetchData: () async {
          var query = _petMedicalRef(userId, petId)
              .doc('records')
              .collection('visits')
              .orderBy('date', descending: true);

          if (startDate != null) {
            query = query.where('date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
          }

          if (endDate != null) {
            query = query.where('date',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate));
          }

          if (type != null) {
            query = query.where('type', isEqualTo: type);
          }

          if (limit != null) {
            query = query.limit(limit);
          }

          final snapshot = await query.get();
          return snapshot.docs
              .map((doc) => MedicalRecord.fromJson(doc.data()))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting medical history', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicalRecordException('Error getting medical history: $e');
    }
  }

  // Vaccinations
  Future<void> addVaccination(String userId, String petId, Vaccination vaccination) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petMedicalRef(userId, petId)
            .doc('vaccinations')
            .collection('records')
            .doc(vaccination.id)
            .set(vaccination.toJson());
            
        await _updateVaccinationStatus(userId, petId);
        logger.i('Added vaccination: ${vaccination.id}');
        analytics.logEvent('vaccination_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding vaccination', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicalRecordException('Error adding vaccination: $e');
    }
  }

  Stream<List<Vaccination>> streamVaccinations(String userId, String petId) {
    try {
      return _petMedicalRef(userId, petId)
          .doc('vaccinations')
          .collection('records')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Vaccination.fromJson(doc.data()))
              .toList());
    } catch (e, stackTrace) {
      logger.e('Error streaming vaccinations', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicalRecordException('Error streaming vaccinations: $e');
    }
  }

  // Prescriptions
  Future<void> addPrescription(String userId, String petId, Prescription prescription) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petMedicalRef(userId, petId)
            .doc('prescriptions')
            .collection('active')
            .doc(prescription.id)
            .set(prescription.toJson());
            
        logger.i('Added prescription: ${prescription.id}');
        analytics.logEvent('prescription_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding prescription', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicalRecordException('Error adding prescription: $e');
    }
  }

  Future<List<Prescription>> getActivePrescriptions(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'active_prescriptions_${userId}_$petId',
        duration: const Duration(minutes: 30),
        fetchData: () async {
          final snapshot = await _petMedicalRef(userId, petId)
              .doc('prescriptions')
              .collection('active')
              .where('endDate', isGreaterThan: Timestamp.fromDate(DateTime.now()))
              .get();
              
          return snapshot.docs
              .map((doc) => Prescription.fromJson(doc.data()))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting active prescriptions', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicalRecordException('Error getting active prescriptions: $e');
    }
  }

  // Medical Conditions
  Future<void> addMedicalCondition(
    String userId,
    String petId,
    MedicalCondition condition,
  ) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petMedicalRef(userId, petId)
            .doc('conditions')
            .collection('active')
            .doc(condition.id)
            .set(condition.toJson());
            
        logger.i('Added medical condition: ${condition.id}');
        analytics.logEvent('medical_condition_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding medical condition', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicalRecordException('Error adding medical condition: $e');
    }
  }

  Stream<List<MedicalCondition>> streamMedicalConditions(String userId, String petId) {
    try {
      return _petMedicalRef(userId, petId)
          .doc('conditions')
          .collection('active')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MedicalCondition.fromJson(doc.data()))
              .toList());
    } catch (e, stackTrace) {
      logger.e('Error streaming medical conditions', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicalRecordException('Error streaming medical conditions: $e');
    }
  }

  // Allergies
  Future<void> addAllergy(String userId, String petId, Allergy allergy) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petMedicalRef(userId, petId)
            .doc('allergies')
            .collection('list')
            .doc(allergy.id)
            .set(allergy.toJson());
            
        logger.i('Added allergy: ${allergy.id}');
        analytics.logEvent('allergy_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding allergy', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicalRecordException('Error adding allergy: $e');
    }
  }

  Future<List<Allergy>> getAllergies(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'allergies_${userId}_$petId',
        duration: const Duration(hours: 2),
        fetchData: () async {
          final snapshot = await _petMedicalRef(userId, petId)
              .doc('allergies')
              .collection('list')
              .get();
              
          return snapshot.docs
              .map((doc) => Allergy.fromJson(doc.data()))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting allergies', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicalRecordException('Error getting allergies: $e');
    }
  }

  // Helper Methods
  Future<void> _updateLatestVisit(
    String userId,
    String petId,
    MedicalRecord record,
  ) async {
    try {
      await _petMedicalRef(userId, petId).doc('summary').set({
        'lastVisit': record.date,
        'lastVisitType': record.type,
        'lastClinic': record.clinicName,
        'lastVeterinarian': record.veterinarianName,
      }, SetOptions(merge: true));
    } catch (e) {
      logger.e('Error updating latest visit', e);
    }
  }

  Future<void> _updateVaccinationStatus(String userId, String petId) async {
    try {
      final vaccinations = await _petMedicalRef(userId, petId)
          .doc('vaccinations')
          .collection('records')
          .orderBy('date', descending: true)
          .get();

      final Map<String, DateTime> latestVaccinations = {};
      for (var doc in vaccinations.docs) {
        final vaccination = Vaccination.fromJson(doc.data());
        if (!latestVaccinations.containsKey(vaccination.type)) {
          latestVaccinations[vaccination.type] = vaccination.date;
        }
      }

      await _petMedicalRef(userId, petId).doc('summary').set({
        'vaccinationStatus': latestVaccinations,
        'lastVaccinationUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      logger.e('Error updating vaccination status', e);
    }
  }

  Future<Map<String, dynamic>> getMedicalSummary(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      final summary = await _petMedicalRef(userId, petId).doc('summary').get();
      return summary.data() as Map<String, dynamic>;
    } catch (e, stackTrace) {
      logger.e('Error getting medical summary', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicalRecordException('Error getting medical summary: $e');
    }
  }
}

class MedicalRecordException implements Exception {
  final String message;
  MedicalRecordException(this.message);

  @override
  String toString() => message;
}

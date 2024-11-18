import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/base_service.dart';
import '../models/medication.dart';
import '../models/medication_schedule.dart';
import '../models/medication_log.dart';
import '../utils/exceptions.dart';
import '../utils/notification_helper.dart';

class MedicationService extends BaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationHelper _notificationHelper = NotificationHelper();
  
  static final MedicationService _instance = MedicationService._internal();
  factory MedicationService() => _instance;
  MedicationService._internal();

  // Collection References
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference _petMedicationRef(String userId, String petId) =>
      _usersRef.doc(userId).collection('pets').doc(petId).collection('medications');

  // Medication Management
  Future<void> addMedication(
    String userId,
    String petId,
    Medication medication,
    MedicationSchedule schedule,
  ) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        // Add medication details
        await _petMedicationRef(userId, petId)
            .doc(medication.id)
            .set(medication.toJson());

        // Add schedule
        await _petMedicationRef(userId, petId)
            .doc(medication.id)
            .collection('schedules')
            .doc('current')
            .set(schedule.toJson());

        // Schedule notifications
        await _scheduleNotifications(userId, petId, medication, schedule);
        
        logger.i('Added medication: ${medication.id}');
        analytics.logEvent('medication_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding medication', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicationException('Error adding medication: $e');
    }
  }

  Future<List<Medication>> getActiveMedications(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'active_medications_${userId}_$petId',
        duration: const Duration(minutes: 30),
        fetchData: () async {
          final snapshot = await _petMedicationRef(userId, petId)
              .where('status', isEqualTo: 'active')
              .get();
              
          return snapshot.docs
              .map((doc) => Medication.fromJson(doc.data()))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting active medications', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicationException('Error getting active medications: $e');
    }
  }

  Stream<List<Medication>> streamMedications(String userId, String petId) {
    try {
      return _petMedicationRef(userId, petId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Medication.fromJson(doc.data()))
              .toList());
    } catch (e, stackTrace) {
      logger.e('Error streaming medications', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicationException('Error streaming medications: $e');
    }
  }

  // Medication Schedule Management
  Future<void> updateMedicationSchedule(
    String userId,
    String petId,
    String medicationId,
    MedicationSchedule newSchedule,
  ) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        // Update schedule
        await _petMedicationRef(userId, petId)
            .doc(medicationId)
            .collection('schedules')
            .doc('current')
            .set(newSchedule.toJson());

        // Get medication details
        final medicationDoc = await _petMedicationRef(userId, petId)
            .doc(medicationId)
            .get();
        final medication = Medication.fromJson(medicationDoc.data()!);

        // Reschedule notifications
        await _cancelExistingNotifications(medicationId);
        await _scheduleNotifications(userId, petId, medication, newSchedule);
        
        logger.i('Updated medication schedule: $medicationId');
        analytics.logEvent('medication_schedule_updated');
      });
    } catch (e, stackTrace) {
      logger.e('Error updating medication schedule', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicationException('Error updating medication schedule: $e');
    }
  }

  // Medication Logging
  Future<void> logMedicationDose(
    String userId,
    String petId,
    String medicationId,
    MedicationLog log,
  ) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petMedicationRef(userId, petId)
            .doc(medicationId)
            .collection('logs')
            .doc(log.id)
            .set(log.toJson());
            
        await _updateAdherenceMetrics(userId, petId, medicationId);
        logger.i('Logged medication dose: ${log.id}');
        analytics.logEvent('medication_dose_logged');
      });
    } catch (e, stackTrace) {
      logger.e('Error logging medication dose', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicationException('Error logging medication dose: $e');
    }
  }

  Future<List<MedicationLog>> getMedicationLogs(
    String userId,
    String petId,
    String medicationId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await checkConnectivity();
      
      var query = _petMedicationRef(userId, petId)
          .doc(medicationId)
          .collection('logs')
          .orderBy('timestamp', descending: true);

      if (startDate != null) {
        query = query.where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => MedicationLog.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      logger.e('Error getting medication logs', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicationException('Error getting medication logs: $e');
    }
  }

  // Medication Reminders
  Future<void> _scheduleNotifications(
    String userId,
    String petId,
    Medication medication,
    MedicationSchedule schedule,
  ) async {
    try {
      final List<PendingNotificationRequest> notifications = [];

      for (var time in schedule.times) {
        final id = DateTime.now().millisecondsSinceEpoch + notifications.length;
        
        notifications.add(
          PendingNotificationRequest(
            id,
            'Medication Reminder',
            '${medication.name} for ${medication.petName}',
            time,
            payload: {
              'type': 'medication',
              'medicationId': medication.id,
              'petId': petId,
              'userId': userId,
            },
          ),
        );
      }

      await _notificationHelper.scheduleNotifications(notifications);
    } catch (e) {
      logger.e('Error scheduling notifications', e);
    }
  }

  Future<void> _cancelExistingNotifications(String medicationId) async {
    try {
      await _notificationHelper.cancelNotificationsByTag(medicationId);
    } catch (e) {
      logger.e('Error canceling notifications', e);
    }
  }

  // Metrics and Analytics
  Future<void> _updateAdherenceMetrics(
    String userId,
    String petId,
    String medicationId,
  ) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));
      
      final logs = await getMedicationLogs(
        userId,
        petId,
        medicationId,
        startDate: startDate,
        endDate: now,
      );

      final schedule = await _petMedicationRef(userId, petId)
          .doc(medicationId)
          .collection('schedules')
          .doc('current')
          .get();

      final medicationSchedule = MedicationSchedule.fromJson(schedule.data()!);
      final adherenceRate = _calculateAdherenceRate(logs, medicationSchedule, startDate, now);

      await _petMedicationRef(userId, petId)
          .doc(medicationId)
          .update({
        'adherenceRate': adherenceRate,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      logger.e('Error updating adherence metrics', e);
    }
  }

  double _calculateAdherenceRate(
    List<MedicationLog> logs,
    MedicationSchedule schedule,
    DateTime startDate,
    DateTime endDate,
  ) {
    final expectedDoses = schedule.calculateExpectedDoses(startDate, endDate);
    final actualDoses = logs.length;
    
    return expectedDoses > 0 ? (actualDoses / expectedDoses) * 100 : 0;
  }

  // Reporting
  Future<Map<String, dynamic>> getMedicationReport(
    String userId,
    String petId,
    String medicationId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await checkConnectivity();
      
      final logs = await getMedicationLogs(
        userId,
        petId,
        medicationId,
        startDate: startDate,
        endDate: endDate,
      );

      final medicationDoc = await _petMedicationRef(userId, petId)
          .doc(medicationId)
          .get();
      final medication = Medication.fromJson(medicationDoc.data()!);

      final schedule = await _petMedicationRef(userId, petId)
          .doc(medicationId)
          .collection('schedules')
          .doc('current')
          .get();
      final medicationSchedule = MedicationSchedule.fromJson(schedule.data()!);

      return {
        'medication': medication.toJson(),
        'schedule': medicationSchedule.toJson(),
        'logs': logs.map((log) => log.toJson()).toList(),
        'adherenceRate': medication.adherenceRate,
        'missedDoses': _calculateMissedDoses(logs, medicationSchedule, startDate, endDate),
        'lastTaken': logs.isNotEmpty ? logs.first.timestamp : null,
      };
    } catch (e, stackTrace) {
      logger.e('Error generating medication report', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw MedicationException('Error generating medication report: $e');
    }
  }

  int _calculateMissedDoses(
    List<MedicationLog> logs,
    MedicationSchedule schedule,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    final expectedDoses = schedule.calculateExpectedDoses(start, end);
    return expectedDoses - logs.length;
  }
}

class MedicationException implements Exception {
  final String message;
  MedicationException(this.message);

  @override
  String toString() => message;
}

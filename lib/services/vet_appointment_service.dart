import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/base_service.dart';
import '../models/vet_appointment.dart';
import '../models/veterinarian.dart';
import '../models/clinic.dart';
import '../utils/exceptions.dart';
import '../utils/date_utils.dart';

class VetAppointmentService extends BaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static final VetAppointmentService _instance = VetAppointmentService._internal();
  factory VetAppointmentService() => _instance;
  VetAppointmentService._internal();

  // Collection References
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference get _clinicsRef => _firestore.collection('clinics');
  CollectionReference get _veterinariansRef => _firestore.collection('veterinarians');
  CollectionReference _petAppointmentsRef(String userId, String petId) =>
      _usersRef.doc(userId).collection('pets').doc(petId).collection('appointments');

  // Appointment Management
  Future<String> scheduleAppointment(
    String userId,
    String petId,
    VetAppointment appointment,
  ) async {
    try {
      await checkConnectivity();
      
      return await withRetry(() async {
        // Validate appointment time availability
        await _validateAppointmentTime(
          appointment.clinicId,
          appointment.veterinarianId,
          appointment.dateTime,
        );

        // Add appointment to Firestore
        final docRef = await _petAppointmentsRef(userId, petId)
            .add(appointment.toJson());
            
        // Update appointment with generated ID
        await _petAppointmentsRef(userId, petId)
            .doc(docRef.id)
            .update({'id': docRef.id});

        // Update clinic's appointment slots
        await _updateClinicSlots(
          appointment.clinicId,
          appointment.veterinarianId,
          appointment.dateTime,
          true,
        );

        // Schedule reminders
        await _scheduleAppointmentReminders(userId, petId, appointment);

        logger.i('Scheduled appointment: ${docRef.id}');
        analytics.logEvent('appointment_scheduled');
        
        return docRef.id;
      });
    } catch (e, stackTrace) {
      logger.e('Error scheduling appointment', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw VetAppointmentException('Error scheduling appointment: $e');
    }
  }

  Future<void> updateAppointment(
    String userId,
    String petId,
    VetAppointment appointment,
  ) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        // Get existing appointment
        final oldAppointment = await getAppointment(userId, petId, appointment.id);

        // If date/time changed, validate new time
        if (oldAppointment.dateTime != appointment.dateTime) {
          await _validateAppointmentTime(
            appointment.clinicId,
            appointment.veterinarianId,
            appointment.dateTime,
          );

          // Update clinic slots
          await _updateClinicSlots(
            oldAppointment.clinicId,
            oldAppointment.veterinarianId,
            oldAppointment.dateTime,
            false,
          );
          await _updateClinicSlots(
            appointment.clinicId,
            appointment.veterinarianId,
            appointment.dateTime,
            true,
          );
        }

        // Update appointment
        await _petAppointmentsRef(userId, petId)
            .doc(appointment.id)
            .update(appointment.toJson());

        // Update reminders
        await _updateAppointmentReminders(userId, petId, appointment);

        logger.i('Updated appointment: ${appointment.id}');
        analytics.logEvent('appointment_updated');
      });
    } catch (e, stackTrace) {
      logger.e('Error updating appointment', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw VetAppointmentException('Error updating appointment: $e');
    }
  }

  Future<void> cancelAppointment(
    String userId,
    String petId,
    String appointmentId,
  ) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        // Get appointment details
        final appointment = await getAppointment(userId, petId, appointmentId);

        // Update clinic slots
        await _updateClinicSlots(
          appointment.clinicId,
          appointment.veterinarianId,
          appointment.dateTime,
          false,
        );

        // Cancel reminders
        await _cancelAppointmentReminders(userId, petId, appointmentId);

        // Update appointment status
        await _petAppointmentsRef(userId, petId)
            .doc(appointmentId)
            .update({
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });

        logger.i('Cancelled appointment: $appointmentId');
        analytics.logEvent('appointment_cancelled');
      });
    } catch (e, stackTrace) {
      logger.e('Error cancelling appointment', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw VetAppointmentException('Error cancelling appointment: $e');
    }
  }

  // Appointment Retrieval
  Future<VetAppointment> getAppointment(
    String userId,
    String petId,
    String appointmentId,
  ) async {
    try {
      await checkConnectivity();
      
      final doc = await _petAppointmentsRef(userId, petId)
          .doc(appointmentId)
          .get();
          
      if (!doc.exists) {
        throw VetAppointmentException('Appointment not found');
      }
      
      return VetAppointment.fromJson(doc.data()!);
    } catch (e, stackTrace) {
      logger.e('Error getting appointment', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw VetAppointmentException('Error getting appointment: $e');
    }
  }

  Stream<List<VetAppointment>> streamUpcomingAppointments(
    String userId,
    String petId,
  ) {
    try {
      final now = DateTime.now();
      return _petAppointmentsRef(userId, petId)
          .where('dateTime', isGreaterThanOrEqualTo: now)
          .where('status', isEqualTo: 'scheduled')
          .orderBy('dateTime')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => VetAppointment.fromJson(doc.data()))
              .toList());
    } catch (e, stackTrace) {
      logger.e('Error streaming upcoming appointments', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw VetAppointmentException('Error streaming upcoming appointments: $e');
    }
  }

  Future<List<VetAppointment>> getPastAppointments(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      await checkConnectivity();
      
      var query = _petAppointmentsRef(userId, petId)
          .where('dateTime', isLessThan: DateTime.now())
          .orderBy('dateTime', descending: true);

      if (startDate != null) {
        query = query.where('dateTime',
            isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('dateTime',
            isLessThanOrEqualTo: endDate);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => VetAppointment.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      logger.e('Error getting past appointments', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw VetAppointmentException('Error getting past appointments: $e');
    }
  }

  // Clinic and Veterinarian Management
  Future<List<Clinic>> searchClinics(
    String query, {
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'clinics_${query}_${latitude}_${longitude}_$radius',
        duration: const Duration(hours: 1),
        fetchData: () async {
          var queryRef = _clinicsRef;

          if (query.isNotEmpty) {
            queryRef = queryRef
                .where('searchTerms', arrayContains: query.toLowerCase());
          }

          final snapshot = await queryRef.get();
          final clinics = snapshot.docs
              .map((doc) => Clinic.fromJson(doc.data()))
              .toList();

          // Filter by distance if location provided
          if (latitude != null && longitude != null && radius != null) {
            return _filterClinicsByDistance(
              clinics,
              latitude,
              longitude,
              radius,
            );
          }

          return clinics;
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error searching clinics', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw VetAppointmentException('Error searching clinics: $e');
    }
  }

  Future<List<Veterinarian>> getClinicVeterinarians(String clinicId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'veterinarians_$clinicId',
        duration: const Duration(hours: 1),
        fetchData: () async {
          final snapshot = await _veterinariansRef
              .where('clinicId', isEqualTo: clinicId)
              .get();
              
          return snapshot.docs
              .map((doc) => Veterinarian.fromJson(doc.data()))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting clinic veterinarians', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw VetAppointmentException('Error getting clinic veterinarians: $e');
    }
  }

  Future<List<DateTime>> getAvailableSlots(
    String clinicId,
    String veterinarianId,
    DateTime date,
  ) async {
    try {
      await checkConnectivity();
      
      final doc = await _clinicsRef
          .doc(clinicId)
          .collection('schedules')
          .doc(DateUtils.formatDate(date))
          .get();

      if (!doc.exists) {
        return _generateDefaultSlots(date);
      }

      final schedule = doc.data()!;
      final bookedSlots = List<DateTime>.from(
        (schedule['bookedSlots'] ?? []).map((ts) => ts.toDate()),
      );

      return _generateAvailableSlots(date, bookedSlots);
    } catch (e, stackTrace) {
      logger.e('Error getting available slots', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw VetAppointmentException('Error getting available slots: $e');
    }
  }

  // Helper Methods
  Future<void> _validateAppointmentTime(
    String clinicId,
    String veterinarianId,
    DateTime dateTime,
  ) async {
    final slots = await getAvailableSlots(
      clinicId,
      veterinarianId,
      dateTime,
    );

    if (!slots.contains(dateTime)) {
      throw VetAppointmentException('Selected time slot is not available');
    }
  }

  Future<void> _updateClinicSlots(
    String clinicId,
    String veterinarianId,
    DateTime dateTime,
    bool isBooked,
  ) async {
    try {
      final docRef = _clinicsRef
          .doc(clinicId)
          .collection('schedules')
          .doc(DateUtils.formatDate(dateTime));

      if (isBooked) {
        await docRef.set({
          'bookedSlots': FieldValue.arrayUnion([Timestamp.fromDate(dateTime)]),
        }, SetOptions(merge: true));
      } else {
        await docRef.set({
          'bookedSlots': FieldValue.arrayRemove([Timestamp.fromDate(dateTime)]),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      logger.e('Error updating clinic slots', e);
    }
  }

  List<DateTime> _generateDefaultSlots(DateTime date) {
    final slots = <DateTime>[];
    final startTime = DateTime(date.year, date.month, date.day, 9, 0); // 9 AM
    final endTime = DateTime(date.year, date.month, date.day, 17, 0); // 5 PM

    var currentSlot = startTime;
    while (currentSlot.isBefore(endTime)) {
      slots.add(currentSlot);
      currentSlot = currentSlot.add(const Duration(minutes: 30));
    }

    return slots;
  }

  List<DateTime> _generateAvailableSlots(
    DateTime date,
    List<DateTime> bookedSlots,
  ) {
    final allSlots = _generateDefaultSlots(date);
    return allSlots.where((slot) => !bookedSlots.contains(slot)).toList();
  }

  List<Clinic> _filterClinicsByDistance(
    List<Clinic> clinics,
    double latitude,
    double longitude,
    double radius,
  ) {
    return clinics.where((clinic) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        clinic.latitude,
        clinic.longitude,
      );
      return distance <= radius;
    }).toList();
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Implement Haversine formula for distance calculation
    // This is a simplified version
    const earthRadius = 6371.0; // kilometers

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Future<void> _scheduleAppointmentReminders(
    String userId,
    String petId,
    VetAppointment appointment,
  ) async {
    try {
      // Schedule reminders at different intervals
      final reminders = [
        appointment.dateTime.subtract(const Duration(days: 1)),
        appointment.dateTime.subtract(const Duration(hours: 2)),
      ];

      for (var reminderTime in reminders) {
        await notificationService.scheduleNotification(
          id: appointment.hashCode + reminderTime.hashCode,
          title: 'Upcoming Vet Appointment',
          body: 'Reminder: ${appointment.petName} has an appointment tomorrow',
          scheduledDate: reminderTime,
          payload: json.encode({
            'type': 'appointment',
            'appointmentId': appointment.id,
            'petId': petId,
          }),
        );
      }
    } catch (e) {
      logger.e('Error scheduling appointment reminders', e);
    }
  }

  Future<void> _updateAppointmentReminders(
    String userId,
    String petId,
    VetAppointment appointment,
  ) async {
    try {
      // Cancel existing reminders
      await _cancelAppointmentReminders(userId, petId, appointment.id);
      // Schedule new reminders
      await _scheduleAppointmentReminders(userId, petId, appointment);
    } catch (e) {
      logger.e('Error updating appointment reminders', e);
    }
  }

  Future<void> _cancelAppointmentReminders(
    String userId,
    String petId,
    String appointmentId,
  ) async {
    try {
      // Cancel all notifications related to this appointment
      await notificationService.cancelNotification(appointmentId.hashCode);
    } catch (e) {
      logger.e('Error cancelling appointment reminders', e);
    }
  }
}

class VetAppointmentException implements Exception {
  final String message;
  VetAppointmentException(this.message);

  @override
  String toString() => message;
}

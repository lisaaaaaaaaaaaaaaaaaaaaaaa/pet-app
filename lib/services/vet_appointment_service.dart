import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class VetAppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  // Singleton pattern
  static final VetAppointmentService _instance = VetAppointmentService._internal();
  factory VetAppointmentService() => _instance;
  VetAppointmentService._internal();

  // Create a new appointment
  Future<String> createAppointment({
    required String petId,
    required String userId,
    required String veterinarianId,
    required String clinicId,
    required DateTime appointmentDate,
    required String appointmentType,
    required int duration, // in minutes
    String? reason,
    String? notes,
    List<String>? attachments,
    Map<String, dynamic>? symptoms,
    bool isEmergency = false,
    String status = 'scheduled',
  }) async {
    try {
      final String appointmentId = uuid.v4();
      final documentRef = _firestore
          .collection('vetAppointments')
          .doc(appointmentId);

      final appointmentData = {
        'id': appointmentId,
        'petId': petId,
        'userId': userId,
        'veterinarianId': veterinarianId,
        'clinicId': clinicId,
        'appointmentDate': Timestamp.fromDate(appointmentDate),
        'appointmentType': appointmentType,
        'duration': duration,
        'reason': reason,
        'notes': notes,
        'attachments': attachments ?? [],
        'symptoms': symptoms ?? {},
        'isEmergency': isEmergency,
        'status': status,
        'followUpNeeded': false,
        'followUpDate': null,
        'cancellationReason': null,
        'diagnosis': null,
        'treatment': null,
        'prescriptions': [],
        'cost': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await documentRef.set(appointmentData);

      // Add to clinic's schedule
      await _firestore
          .collection('clinics')
          .doc(clinicId)
          .collection('schedule')
          .doc(appointmentId)
          .set({
        'appointmentId': appointmentId,
        'startTime': Timestamp.fromDate(appointmentDate),
        'endTime': Timestamp.fromDate(
          appointmentDate.add(Duration(minutes: duration)),
        ),
        'veterinarianId': veterinarianId,
        'status': status,
      });

      return appointmentId;
    } catch (e) {
      throw VetAppointmentException('Error creating appointment: $e');
    }
  }

  // Update an existing appointment
  Future<void> updateAppointment({
    required String appointmentId,
    DateTime? appointmentDate,
    String? appointmentType,
    int? duration,
    String? reason,
    String? notes,
    List<String>? attachments,
    Map<String, dynamic>? symptoms,
    bool? isEmergency,
    String? status,
    bool? followUpNeeded,
    DateTime? followUpDate,
    String? cancellationReason,
    String? diagnosis,
    String? treatment,
    List<Map<String, dynamic>>? prescriptions,
    double? cost,
  }) async {
    try {
      final documentRef = _firestore
          .collection('vetAppointments')
          .doc(appointmentId);

      final appointmentSnapshot = await documentRef.get();
      if (!appointmentSnapshot.exists) {
        throw VetAppointmentException('Appointment not found');
      }

      final appointmentData = appointmentSnapshot.data() as Map<String, dynamic>;
      final Map<String, dynamic> updateData = {};

      if (appointmentDate != null) {
        updateData['appointmentDate'] = Timestamp.fromDate(appointmentDate);
        
        // Update clinic schedule
        await _firestore
            .collection('clinics')
            .doc(appointmentData['clinicId'])
            .collection('schedule')
            .doc(appointmentId)
            .update({
          'startTime': Timestamp.fromDate(appointmentDate),
          'endTime': Timestamp.fromDate(
            appointmentDate.add(Duration(minutes: duration ?? appointmentData['duration'])),
          ),
        });
      }

      if (appointmentType != null) updateData['appointmentType'] = appointmentType;
      if (duration != null) updateData['duration'] = duration;
      if (reason != null) updateData['reason'] = reason;
      if (notes != null) updateData['notes'] = notes;
      if (attachments != null) updateData['attachments'] = attachments;
      if (symptoms != null) updateData['symptoms'] = symptoms;
      if (isEmergency != null) updateData['isEmergency'] = isEmergency;
      if (status != null) {
        updateData['status'] = status;
        
        // Update clinic schedule status
        await _firestore
            .collection('clinics')
            .doc(appointmentData['clinicId'])
            .collection('schedule')
            .doc(appointmentId)
            .update({'status': status});
      }
      if (followUpNeeded != null) updateData['followUpNeeded'] = followUpNeeded;
      if (followUpDate != null) updateData['followUpDate'] = Timestamp.fromDate(followUpDate);
      if (cancellationReason != null) updateData['cancellationReason'] = cancellationReason;
      if (diagnosis != null) updateData['diagnosis'] = diagnosis;
      if (treatment != null) updateData['treatment'] = treatment;
      if (prescriptions != null) updateData['prescriptions'] = prescriptions;
      if (cost != null) updateData['cost'] = cost;

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await documentRef.update(updateData);
    } catch (e) {
      throw VetAppointmentException('Error updating appointment: $e');
    }
  }

  // Get a single appointment
  Future<Map<String, dynamic>> getAppointment(String appointmentId) async {
    try {
      final documentRef = _firestore
          .collection('vetAppointments')
          .doc(appointmentId);

      final snapshot = await documentRef.get();
      if (!snapshot.exists) {
        throw VetAppointmentException('Appointment not found');
      }

      return snapshot.data() as Map<String, dynamic>;
    } catch (e) {
      throw VetAppointmentException('Error fetching appointment: $e');
    }
  }

  // Get appointments for a pet
  Future<List<Map<String, dynamic>>> getPetAppointments({
    required String petId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    bool includeCompleted = false,
  }) async {
    try {
      Query query = _firestore
          .collection('vetAppointments')
          .where('petId', isEqualTo: petId)
          .orderBy('appointmentDate', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      } else if (!includeCompleted) {
        query = query.where('status', whereIn: ['scheduled', 'confirmed', 'pending']);
      }

      if (startDate != null) {
        query = query.where('appointmentDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('appointmentDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw VetAppointmentException('Error fetching pet appointments: $e');
    }
  }

  // Cancel an appointment
  Future<void> cancelAppointment({
    required String appointmentId,
    required String cancellationReason,
  }) async {
    try {
      final appointment = await getAppointment(appointmentId);
      
      await updateAppointment(
        appointmentId: appointmentId,
        status: 'cancelled',
        cancellationReason: cancellationReason,
      );

      // Update clinic schedule
      await _firestore
          .collection('clinics')
          .doc(appointment['clinicId'])
          .collection('schedule')
          .doc(appointmentId)
          .update({
        'status': 'cancelled',
      });
    } catch (e) {
      throw VetAppointmentException('Error cancelling appointment: $e');
    }
  }

  // Check veterinarian availability
  Future<bool> checkVeterinarianAvailability({
    required String veterinarianId,
    required String clinicId,
    required DateTime proposedDate,
    required int duration,
  }) async {
    try {
      final startTime = Timestamp.fromDate(proposedDate);
      final endTime = Timestamp.fromDate(
        proposedDate.add(Duration(minutes: duration)),
      );

      final querySnapshot = await _firestore
          .collection('clinics')
          .doc(clinicId)
          .collection('schedule')
          .where('veterinarianId', isEqualTo: veterinarianId)
          .where('status', whereIn: ['scheduled', 'confirmed'])
          .where('startTime', isLessThan: endTime)
          .where('endTime', isGreaterThan: startTime)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw VetAppointmentException('Error checking veterinarian availability: $e');
    }
  }

  // Get available time slots
  Future<List<DateTime>> getAvailableTimeSlots({
    required String veterinarianId,
    required String clinicId,
    required DateTime date,
    required int duration,
    required Map<String, dynamic> clinicHours,
  }) async {
    try {
      final List<DateTime> availableSlots = [];
      final DateTime startOfDay = DateTime(date.year, date.month, date.day);
      
      // Get clinic hours for the day
      final String dayOfWeek = _getDayOfWeek(date);
      final Map<String, dynamic> dayHours = clinicHours[dayOfWeek];
      
      if (dayHours['isClosed']) return [];

      final DateTime clinicOpen = _parseTimeString(dayHours['open'], startOfDay);
      final DateTime clinicClose = _parseTimeString(dayHours['close'], startOfDay);

      // Get all appointments for the day
      final querySnapshot = await _firestore
          .collection('clinics')
          .doc(clinicId)
          .collection('schedule')
          .where('veterinarianId', isEqualTo: veterinarianId)
          .where('status', whereIn: ['scheduled', 'confirmed'])
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(clinicOpen))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(clinicClose))
          .get();

      final List<Map<String, DateTime>> bookedSlots = querySnapshot.docs
          .map((doc) => {
                'start': (doc.data()['startTime'] as Timestamp).toDate(),
                'end': (doc.data()['endTime'] as Timestamp).toDate(),
              })
          .toList();

      // Generate available time slots
      DateTime currentSlot = clinicOpen;
      while (currentSlot.add(Duration(minutes: duration)).isBefore(clinicClose)) {
        bool isAvailable = true;
        
        for (var bookedSlot in bookedSlots) {
          if (currentSlot.isBefore(bookedSlot['end']!) &&
              currentSlot.add(Duration(minutes: duration)).isAfter(bookedSlot['start']!)) {
            isAvailable = false;
            break;
          }
        }

        if (isAvailable) {
          availableSlots.add(currentSlot);
        }
        
        currentSlot = currentSlot.add(const Duration(minutes: 30)); // 30-minute intervals
      }

      return availableSlots;
    } catch (e) {
      throw VetAppointmentException('Error getting available time slots: $e');
    }
  }

  // Helper method to get day of week
  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  // Helper method to parse time string
  DateTime _parseTimeString(String timeString, DateTime date) {
    final List<String> parts = timeString.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}

class VetAppointmentException implements Exception {
  final String message;
  VetAppointmentException(this.message);

  @override
  String toString() => message;
}
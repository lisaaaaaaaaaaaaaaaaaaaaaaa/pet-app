import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  // Singleton pattern
  static final MedicationService _instance = MedicationService._internal();
  factory MedicationService() => _instance;
  MedicationService._internal();

  // Create a new medication
  Future<String> createMedication({
    required String petId,
    required String userId,
    required String name,
    required String dosage,
    required String frequency,
    required DateTime startDate,
    DateTime? endDate,
    String? prescribedBy,
    String? instructions,
    String? purpose,
    List<String>? sideEffects,
    bool isActive = true,
    List<String>? attachments,
    Map<String, dynamic>? reminders,
  }) async {
    try {
      final String medicationId = uuid.v4();
      final documentRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('medications')
          .doc(medicationId);

      final medicationData = {
        'id': medicationId,
        'petId': petId,
        'userId': userId,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
        'prescribedBy': prescribedBy,
        'instructions': instructions,
        'purpose': purpose,
        'sideEffects': sideEffects ?? [],
        'isActive': isActive,
        'attachments': attachments ?? [],
        'reminders': reminders ?? {},
        'lastAdministered': null,
        'nextDue': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await documentRef.set(medicationData);
      return medicationId;
    } catch (e) {
      throw MedicationException('Error creating medication: $e');
    }
  }

  // Update an existing medication
  Future<void> updateMedication({
    required String medicationId,
    required String petId,
    String? name,
    String? dosage,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? prescribedBy,
    String? instructions,
    String? purpose,
    List<String>? sideEffects,
    bool? isActive,
    List<String>? attachments,
    Map<String, dynamic>? reminders,
  }) async {
    try {
      final documentRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('medications')
          .doc(medicationId);

      final Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (dosage != null) updateData['dosage'] = dosage;
      if (frequency != null) updateData['frequency'] = frequency;
      if (startDate != null) updateData['startDate'] = Timestamp.fromDate(startDate);
      if (endDate != null) updateData['endDate'] = Timestamp.fromDate(endDate);
      if (prescribedBy != null) updateData['prescribedBy'] = prescribedBy;
      if (instructions != null) updateData['instructions'] = instructions;
      if (purpose != null) updateData['purpose'] = purpose;
      if (sideEffects != null) updateData['sideEffects'] = sideEffects;
      if (isActive != null) updateData['isActive'] = isActive;
      if (attachments != null) updateData['attachments'] = attachments;
      if (reminders != null) updateData['reminders'] = reminders;

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await documentRef.update(updateData);
    } catch (e) {
      throw MedicationException('Error updating medication: $e');
    }
  }

  // Record medication administration
  Future<void> recordMedicationAdministration({
    required String medicationId,
    required String petId,
    required DateTime administeredAt,
    String? notes,
    String? administeredBy,
  }) async {
    try {
      final medicationRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('medications')
          .doc(medicationId);

      final historyRef = medicationRef.collection('administrationHistory').doc();

      // Create administration record
      final administrationData = {
        'administeredAt': Timestamp.fromDate(administeredAt),
        'notes': notes,
        'administeredBy': administeredBy,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Update medication document
      await _firestore.runTransaction((transaction) async {
        final medicationDoc = await transaction.get(medicationRef);
        if (!medicationDoc.exists) {
          throw MedicationException('Medication not found');
        }

        // Calculate next due date based on frequency
        final medicationData = medicationDoc.data() as Map<String, dynamic>;
        final frequency = medicationData['frequency'] as String;
        final nextDue = calculateNextDueDate(administeredAt, frequency);

        transaction.update(medicationRef, {
          'lastAdministered': Timestamp.fromDate(administeredAt),
          'nextDue': Timestamp.fromDate(nextDue),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.set(historyRef, administrationData);
      });
    } catch (e) {
      throw MedicationException('Error recording medication administration: $e');
    }
  }

  // Get medication administration history
  Future<List<Map<String, dynamic>>> getMedicationHistory({
    required String medicationId,
    required String petId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('medications')
          .doc(medicationId)
          .collection('administrationHistory')
          .orderBy('administeredAt', descending: true);

      if (startDate != null) {
        query = query.where('administeredAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('administeredAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw MedicationException('Error fetching medication history: $e');
    }
  }

  // Get all active medications for a pet
  Future<List<Map<String, dynamic>>> getActiveMedications({
    required String petId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('pets')
          .doc(petId)
          .collection('medications')
          .where('isActive', isEqualTo: true)
          .orderBy('nextDue')
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw MedicationException('Error fetching active medications: $e');
    }
  }

  // Get all medications for a pet
  Future<List<Map<String, dynamic>>> getAllMedications({
    required String petId,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('medications')
          .orderBy('startDate', descending: true);

      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      if (startDate != null) {
        query = query.where('startDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('startDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw MedicationException('Error fetching medications: $e');
    }
  }

  // Delete a medication
  Future<void> deleteMedication({
    required String medicationId,
    required String petId,
  }) async {
    try {
      // Delete the medication document and its administration history
      final medicationRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('medications')
          .doc(medicationId);

      final historySnapshot = await medicationRef
          .collection('administrationHistory')
          .get();

      final batch = _firestore.batch();

      // Delete all administration history documents
      for (var doc in historySnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the medication document
      batch.delete(medicationRef);

      await batch.commit();
    } catch (e) {
      throw MedicationException('Error deleting medication: $e');
    }
  }

  // Helper method to calculate next due date
  DateTime calculateNextDueDate(DateTime lastAdministered, String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return lastAdministered.add(const Duration(days: 1));
      case 'twice daily':
        return lastAdministered.add(const Duration(hours: 12));
      case 'weekly':
        return lastAdministered.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(lastAdministered.year,
            lastAdministered.month + 1, lastAdministered.day);
      case 'every 8 hours':
        return lastAdministered.add(const Duration(hours: 8));
      case 'every 6 hours':
        return lastAdministered.add(const Duration(hours: 6));
      case 'every 4 hours':
        return lastAdministered.add(const Duration(hours: 4));
      default:
        return lastAdministered.add(const Duration(days: 1));
    }
  }

  // Get upcoming medication schedule
  Future<List<Map<String, dynamic>>> getUpcomingMedications({
    required String petId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('pets')
          .doc(petId)
          .collection('medications')
          .where('isActive', isEqualTo: true)
          .where('nextDue',
              isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate))
          .where('nextDue', isLessThanOrEqualTo: Timestamp.fromDate(toDate))
          .orderBy('nextDue')
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw MedicationException('Error fetching upcoming medications: $e');
    }
  }
}

class MedicationException implements Exception {
  final String message;
  MedicationException(this.message);

  @override
  String toString() => message;
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MedicalRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  // Singleton pattern
  static final MedicalRecordService _instance = MedicalRecordService._internal();
  factory MedicalRecordService() => _instance;
  MedicalRecordService._internal();

  // Create a new medical record
  Future<String> createMedicalRecord({
    required String petId,
    required String userId,
    required String recordType,
    required DateTime date,
    required String veterinarianName,
    required String clinicName,
    String? diagnosis,
    String? treatment,
    String? prescription,
    String? notes,
    List<String>? attachments,
    double? cost,
  }) async {
    try {
      final String recordId = uuid.v4();
      final documentRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('medicalRecords')
          .doc(recordId);

      final recordData = {
        'id': recordId,
        'petId': petId,
        'userId': userId,
        'recordType': recordType,
        'date': Timestamp.fromDate(date),
        'veterinarianName': veterinarianName,
        'clinicName': clinicName,
        'diagnosis': diagnosis,
        'treatment': treatment,
        'prescription': prescription,
        'notes': notes,
        'attachments': attachments ?? [],
        'cost': cost,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await documentRef.set(recordData);
      return recordId;
    } catch (e) {
      throw MedicalRecordException('Error creating medical record: $e');
    }
  }

  // Update an existing medical record
  Future<void> updateMedicalRecord({
    required String recordId,
    required String petId,
    String? recordType,
    DateTime? date,
    String? veterinarianName,
    String? clinicName,
    String? diagnosis,
    String? treatment,
    String? prescription,
    String? notes,
    List<String>? attachments,
    double? cost,
  }) async {
    try {
      final documentRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('medicalRecords')
          .doc(recordId);

      final Map<String, dynamic> updateData = {};

      if (recordType != null) updateData['recordType'] = recordType;
      if (date != null) updateData['date'] = Timestamp.fromDate(date);
      if (veterinarianName != null) updateData['veterinarianName'] = veterinarianName;
      if (clinicName != null) updateData['clinicName'] = clinicName;
      if (diagnosis != null) updateData['diagnosis'] = diagnosis;
      if (treatment != null) updateData['treatment'] = treatment;
      if (prescription != null) updateData['prescription'] = prescription;
      if (notes != null) updateData['notes'] = notes;
      if (attachments != null) updateData['attachments'] = attachments;
      if (cost != null) updateData['cost'] = cost;

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await documentRef.update(updateData);
    } catch (e) {
      throw MedicalRecordException('Error updating medical record: $e');
    }
  }

  // Get a single medical record
  Future<Map<String, dynamic>> getMedicalRecord({
    required String petId,
    required String recordId,
  }) async {
    try {
      final documentRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('medicalRecords')
          .doc(recordId);

      final snapshot = await documentRef.get();

      if (!snapshot.exists) {
        throw MedicalRecordException('Medical record not found');
      }

      return snapshot.data() as Map<String, dynamic>;
    } catch (e) {
      throw MedicalRecordException('Error fetching medical record: $e');
    }
  }

  // Get all medical records for a pet
  Future<List<Map<String, dynamic>>> getAllMedicalRecords({
    required String petId,
    String? recordType,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    String? lastRecordId,
  }) async {
    try {
      Query query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('medicalRecords')
          .orderBy('date', descending: true);

      if (recordType != null) {
        query = query.where('recordType', isEqualTo: recordType);
      }

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (lastRecordId != null) {
        final lastDoc = await _firestore
            .collection('pets')
            .doc(petId)
            .collection('medicalRecords')
            .doc(lastRecordId)
            .get();
        query = query.startAfterDocument(lastDoc);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw MedicalRecordException('Error fetching medical records: $e');
    }
  }

  // Delete a medical record
  Future<void> deleteMedicalRecord({
    required String petId,
    required String recordId,
  }) async {
    try {
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('medicalRecords')
          .doc(recordId)
          .delete();
    } catch (e) {
      throw MedicalRecordException('Error deleting medical record: $e');
    }
  }

  // Get medical record statistics
  Future<Map<String, dynamic>> getMedicalRecordStats({
    required String petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('medicalRecords');

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();
      final records = querySnapshot.docs;

      double totalCost = 0;
      Map<String, int> recordTypeCount = {};
      Map<String, int> clinicVisits = {};

      for (var record in records) {
        final data = record.data() as Map<String, dynamic>;
        
        // Calculate total cost
        if (data['cost'] != null) {
          totalCost += (data['cost'] as num).toDouble();
        }

        // Count record types
        final recordType = data['recordType'] as String;
        recordTypeCount[recordType] = (recordTypeCount[recordType] ?? 0) + 1;

        // Count clinic visits
        final clinicName = data['clinicName'] as String;
        clinicVisits[clinicName] = (clinicVisits[clinicName] ?? 0) + 1;
      }

      return {
        'totalRecords': records.length,
        'totalCost': totalCost,
        'recordTypeCount': recordTypeCount,
        'clinicVisits': clinicVisits,
        'startDate': startDate,
        'endDate': endDate,
      };
    } catch (e) {
      throw MedicalRecordException('Error getting medical record statistics: $e');
    }
  }

  // Search medical records
  Future<List<Map<String, dynamic>>> searchMedicalRecords({
    required String petId,
    String? searchTerm,
    List<String>? recordTypes,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('medicalRecords')
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (recordTypes != null && recordTypes.isNotEmpty) {
        query = query.where('recordType', whereIn: recordTypes);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      final records = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      if (searchTerm != null && searchTerm.isNotEmpty) {
        final searchLower = searchTerm.toLowerCase();
        return records.where((record) {
          return record['veterinarianName'].toString().toLowerCase().contains(searchLower) ||
              record['clinicName'].toString().toLowerCase().contains(searchLower) ||
              (record['diagnosis'] ?? '').toString().toLowerCase().contains(searchLower) ||
              (record['treatment'] ?? '').toString().toLowerCase().contains(searchLower) ||
              (record['notes'] ?? '').toString().toLowerCase().contains(searchLower);
        }).toList();
      }

      return records;
    } catch (e) {
      throw MedicalRecordException('Error searching medical records: $e');
    }
  }
}

class MedicalRecordException implements Exception {
  final String message;
  MedicalRecordException(this.message);

  @override
  String toString() => message;
}
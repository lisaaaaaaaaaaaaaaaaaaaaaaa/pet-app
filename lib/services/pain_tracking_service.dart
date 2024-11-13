import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PainTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  // Singleton pattern
  static final PainTrackingService _instance = PainTrackingService._internal();
  factory PainTrackingService() => _instance;
  PainTrackingService._internal();

  // Create a new pain record
  Future<String> createPainRecord({
    required String petId,
    required String userId,
    required int painLevel,
    required DateTime recordDate,
    required List<String> symptoms,
    required String bodyLocation,
    String? notes,
    List<String>? medications,
    Map<String, bool>? activities,
    List<String>? images,
    Map<String, dynamic>? behavioralChanges,
  }) async {
    try {
      final String recordId = uuid.v4();
      final documentRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('painRecords')
          .doc(recordId);

      final recordData = {
        'id': recordId,
        'petId': petId,
        'userId': userId,
        'painLevel': painLevel,
        'recordDate': Timestamp.fromDate(recordDate),
        'symptoms': symptoms,
        'bodyLocation': bodyLocation,
        'notes': notes,
        'medications': medications ?? [],
        'activities': activities ?? {},
        'images': images ?? [],
        'behavioralChanges': behavioralChanges ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await documentRef.set(recordData);
      return recordId;
    } catch (e) {
      throw PainTrackingException('Error creating pain record: $e');
    }
  }

  // Update an existing pain record
  Future<void> updatePainRecord({
    required String recordId,
    required String petId,
    int? painLevel,
    List<String>? symptoms,
    String? bodyLocation,
    String? notes,
    List<String>? medications,
    Map<String, bool>? activities,
    List<String>? images,
    Map<String, dynamic>? behavioralChanges,
  }) async {
    try {
      final documentRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('painRecords')
          .doc(recordId);

      final Map<String, dynamic> updateData = {};

      if (painLevel != null) updateData['painLevel'] = painLevel;
      if (symptoms != null) updateData['symptoms'] = symptoms;
      if (bodyLocation != null) updateData['bodyLocation'] = bodyLocation;
      if (notes != null) updateData['notes'] = notes;
      if (medications != null) updateData['medications'] = medications;
      if (activities != null) updateData['activities'] = activities;
      if (images != null) updateData['images'] = images;
      if (behavioralChanges != null) updateData['behavioralChanges'] = behavioralChanges;

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await documentRef.update(updateData);
    } catch (e) {
      throw PainTrackingException('Error updating pain record: $e');
    }
  }

  // Get a single pain record
  Future<Map<String, dynamic>> getPainRecord({
    required String petId,
    required String recordId,
  }) async {
    try {
      final documentRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('painRecords')
          .doc(recordId);

      final snapshot = await documentRef.get();

      if (!snapshot.exists) {
        throw PainTrackingException('Pain record not found');
      }

      return snapshot.data() as Map<String, dynamic>;
    } catch (e) {
      throw PainTrackingException('Error fetching pain record: $e');
    }
  }

  // Get all pain records for a pet
  Future<List<Map<String, dynamic>>> getPainRecords({
    required String petId,
    DateTime? startDate,
    DateTime? endDate,
    int? minPainLevel,
    int? maxPainLevel,
    List<String>? specificSymptoms,
    String? bodyLocation,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('painRecords')
          .orderBy('recordDate', descending: true);

      if (startDate != null) {
        query = query.where('recordDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('recordDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (minPainLevel != null) {
        query = query.where('painLevel', isGreaterThanOrEqualTo: minPainLevel);
      }

      if (maxPainLevel != null) {
        query = query.where('painLevel', isLessThanOrEqualTo: maxPainLevel);
      }

      if (bodyLocation != null) {
        query = query.where('bodyLocation', isEqualTo: bodyLocation);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      final records = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      if (specificSymptoms != null && specificSymptoms.isNotEmpty) {
        return records.where((record) {
          final recordSymptoms = List<String>.from(record['symptoms']);
          return specificSymptoms.any((symptom) => recordSymptoms.contains(symptom));
        }).toList();
      }

      return records;
    } catch (e) {
      throw PainTrackingException('Error fetching pain records: $e');
    }
  }

  // Delete a pain record
  Future<void> deletePainRecord({
    required String petId,
    required String recordId,
  }) async {
    try {
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('painRecords')
          .doc(recordId)
          .delete();
    } catch (e) {
      throw PainTrackingException('Error deleting pain record: $e');
    }
  }

  // Get pain statistics
  Future<Map<String, dynamic>> getPainStatistics({
    required String petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('painRecords')
          .orderBy('recordDate');

      if (startDate != null) {
        query = query.where('recordDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('recordDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();
      final records = querySnapshot.docs;

      if (records.isEmpty) {
        return {
          'averagePainLevel': 0,
          'highestPainLevel': 0,
          'lowestPainLevel': 0,
          'commonSymptoms': <String, int>{},
          'commonLocations': <String, int>{},
          'totalRecords': 0,
          'painLevelTrend': [],
          'startDate': startDate,
          'endDate': endDate,
        };
      }

      double totalPainLevel = 0;
      int highestPainLevel = 0;
      int lowestPainLevel = 10;
      Map<String, int> symptomCount = {};
      Map<String, int> locationCount = {};
      List<Map<String, dynamic>> painLevelTrend = [];

      for (var record in records) {
        final data = record.data() as Map<String, dynamic>;
        final painLevel = data['painLevel'] as int;
        
        // Calculate pain levels
        totalPainLevel += painLevel;
        highestPainLevel = painLevel > highestPainLevel ? painLevel : highestPainLevel;
        lowestPainLevel = painLevel < lowestPainLevel ? painLevel : lowestPainLevel;

        // Count symptoms
        final symptoms = List<String>.from(data['symptoms']);
        for (var symptom in symptoms) {
          symptomCount[symptom] = (symptomCount[symptom] ?? 0) + 1;
        }

        // Count locations
        final location = data['bodyLocation'] as String;
        locationCount[location] = (locationCount[location] ?? 0) + 1;

        // Add to trend data
        painLevelTrend.add({
          'date': (data['recordDate'] as Timestamp).toDate(),
          'painLevel': painLevel,
        });
      }

      return {
        'averagePainLevel': totalPainLevel / records.length,
        'highestPainLevel': highestPainLevel,
        'lowestPainLevel': lowestPainLevel,
        'commonSymptoms': symptomCount,
        'commonLocations': locationCount,
        'totalRecords': records.length,
        'painLevelTrend': painLevelTrend,
        'startDate': startDate,
        'endDate': endDate,
      };
    } catch (e) {
      throw PainTrackingException('Error getting pain statistics: $e');
    }
  }

  // Get recent pain trends
  Future<List<Map<String, dynamic>>> getPainTrends({
    required String petId,
    required int days,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final records = await getPainRecords(
        petId: petId,
        startDate: startDate,
        endDate: endDate,
      );

      // Group records by date
      final Map<DateTime, List<Map<String, dynamic>>> groupedRecords = {};
      for (var record in records) {
        final date = (record['recordDate'] as Timestamp).toDate();
        final dateOnly = DateTime(date.year, date.month, date.day);
        groupedRecords[dateOnly] ??= [];
        groupedRecords[dateOnly]!.add(record);
      }

      // Calculate daily averages
      final List<Map<String, dynamic>> trends = [];
      for (var entry in groupedRecords.entries) {
        double dailyPainAverage = entry.value.fold(0.0,
            (sum, record) => sum + (record['painLevel'] as int)) / entry.value.length;

        trends.add({
          'date': entry.key,
          'averagePainLevel': dailyPainAverage,
          'recordCount': entry.value.length,
        });
      }

      return trends..sort((a, b) => (a['date'] as DateTime).compareTo(b['date']));
    } catch (e) {
      throw PainTrackingException('Error getting pain trends: $e');
    }
  }
}

class PainTrackingException implements Exception {
  final String message;
  PainTrackingException(this.message);

  @override
  String toString() => message;
}
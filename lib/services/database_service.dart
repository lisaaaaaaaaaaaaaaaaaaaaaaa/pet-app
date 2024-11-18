import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/base_service.dart';
import '../models/pet.dart';
import '../models/user_profile.dart';
import '../utils/exceptions.dart';

class DatabaseService extends BaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Collection References
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference _userPetsRef(String userId) => _usersRef.doc(userId).collection('pets');
  CollectionReference _userProfilesRef(String userId) => _usersRef.doc(userId).collection('profiles');

  // User Operations
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _usersRef.doc(profile.userId).set(profile.toJson());
        logger.i('Created user profile: ${profile.userId}');
        analytics.logEvent('user_profile_created');
      });
    } catch (e, stackTrace) {
      logger.e('Error creating user profile', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DatabaseException('Error creating user profile: $e');
    }
  }

  Future<UserProfile> getUserProfile(String userId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'user_profile_$userId',
        duration: const Duration(minutes: 30),
        fetchData: () async {
          final doc = await _usersRef.doc(userId).get();
          if (!doc.exists) {
            throw DatabaseException('User profile not found');
          }
          return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error fetching user profile', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DatabaseException('Error fetching user profile: $e');
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _usersRef.doc(userId).update(updates);
        await clearCache('user_profile_$userId');
        logger.i('Updated user profile: $userId');
        analytics.logEvent('user_profile_updated');
      });
    } catch (e, stackTrace) {
      logger.e('Error updating user profile', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DatabaseException('Error updating user profile: $e');
    }
  }

  // Pet Operations
  Future<String> createPet(String userId, Pet pet) async {
    try {
      await checkConnectivity();
      
      return await withRetry(() async {
        final docRef = await _userPetsRef(userId).add(pet.toJson());
        logger.i('Created pet with ID: ${docRef.id}');
        analytics.logEvent('pet_created');
        return docRef.id;
      });
    } catch (e, stackTrace) {
      logger.e('Error creating pet', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DatabaseException('Error creating pet: $e');
    }
  }

  Future<Pet> getPet(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'pet_${userId}_$petId',
        duration: const Duration(minutes: 15),
        fetchData: () async {
          final doc = await _userPetsRef(userId).doc(petId).get();
          if (!doc.exists) {
            throw DatabaseException('Pet not found');
          }
          return Pet.fromJson(doc.data() as Map<String, dynamic>);
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error fetching pet', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DatabaseException('Error fetching pet: $e');
    }
  }

  Stream<List<Pet>> streamUserPets(String userId) {
    try {
      return _userPetsRef(userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Pet.fromJson(doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e, stackTrace) {
      logger.e('Error streaming pets', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DatabaseException('Error streaming pets: $e');
    }
  }

  Future<void> updatePet(String userId, String petId, Map<String, dynamic> updates) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _userPetsRef(userId).doc(petId).update(updates);
        await clearCache('pet_${userId}_$petId');
        logger.i('Updated pet: $petId');
        analytics.logEvent('pet_updated');
      });
    } catch (e, stackTrace) {
      logger.e('Error updating pet', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DatabaseException('Error updating pet: $e');
    }
  }

  Future<void> deletePet(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _userPetsRef(userId).doc(petId).delete();
        await clearCache('pet_${userId}_$petId');
        logger.i('Deleted pet: $petId');
        analytics.logEvent('pet_deleted');
      });
    } catch (e, stackTrace) {
      logger.e('Error deleting pet', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DatabaseException('Error deleting pet: $e');
    }
  }

  // Batch Operations
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      await checkConnectivity();
      
      final batch = _firestore.batch();
      
      for (final op in operations) {
        final ref = op['ref'] as DocumentReference;
        final data = op['data'] as Map<String, dynamic>;
        final type = op['type'] as String;

        switch (type) {
          case 'set':
            batch.set(ref, data);
            break;
          case 'update':
            batch.update(ref, data);
            break;
          case 'delete':
            batch.delete(ref);
            break;
        }
      }

      await batch.commit();
      logger.i('Batch operation completed');
    } catch (e, stackTrace) {
      logger.e('Error in batch operation', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DatabaseException('Error in batch operation: $e');
    }
  }

  // Transaction Operations
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) operation
  ) async {
    try {
      await checkConnectivity();
      
      return await _firestore.runTransaction((transaction) async {
        return await operation(transaction);
      });
    } catch (e, stackTrace) {
      logger.e('Error in transaction', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DatabaseException('Error in transaction: $e');
    }
  }

  // Query Operations
  Future<List<T>> queryCollection<T>({
    required CollectionReference collection,
    required T Function(Map<String, dynamic>) fromJson,
    List<List<dynamic>>? where,
    String? orderBy,
    bool? descending,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      await checkConnectivity();
      
      Query query = collection;

      if (where != null) {
        for (final condition in where) {
          query = query.where(
            condition[0] as String,
            isEqualTo: condition[1],
            isGreaterThan: condition.length > 2 ? condition[2] : null,
            isLessThan: condition.length > 3 ? condition[3] : null,
          );
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending ?? false);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      logger.e('Error querying collection', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DatabaseException('Error querying collection: $e');
    }
  }
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => message;
}

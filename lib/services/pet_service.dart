import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'core/base_service.dart';
import '../models/pet.dart';
import '../models/breed.dart';
import '../models/pet_stats.dart';
import '../models/pet_milestone.dart';
import '../utils/exceptions.dart';
import '../utils/image_utils.dart';

class PetService extends BaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
  
  static final PetService _instance = PetService._internal();
  factory PetService() => _instance;
  PetService._internal();

  // Collection References
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference get _breedsRef => _firestore.collection('breeds');
  CollectionReference _userPetsRef(String userId) => 
      _usersRef.doc(userId).collection('pets');

  // Pet Management
  Future<String> addPet(String userId, Pet pet, {File? profileImage}) async {
    try {
      await checkConnectivity();
      
      return await withRetry(() async {
        // Upload profile image if provided
        String? imageUrl;
        if (profileImage != null) {
          imageUrl = await _uploadPetImage(userId, profileImage);
          pet = pet.copyWith(profileImage: imageUrl);
        }

        // Add pet to Firestore
        final docRef = await _userPetsRef(userId).add(pet.toJson());
        
        // Update pet with generated ID
        await _userPetsRef(userId)
            .doc(docRef.id)
            .update({'id': docRef.id});

        logger.i('Added pet: ${docRef.id}');
        analytics.logEvent('pet_added');
        
        return docRef.id;
      });
    } catch (e, stackTrace) {
      logger.e('Error adding pet', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PetServiceException('Error adding pet: $e');
    }
  }

  Future<void> updatePet(String userId, Pet pet) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _userPetsRef(userId)
            .doc(pet.id)
            .update(pet.toJson());
            
        await clearCache('pet_${userId}_${pet.id}');
        logger.i('Updated pet: ${pet.id}');
        analytics.logEvent('pet_updated');
      });
    } catch (e, stackTrace) {
      logger.e('Error updating pet', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PetServiceException('Error updating pet: $e');
    }
  }

  Future<void> deletePet(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        // Delete pet profile image
        final pet = await getPet(userId, petId);
        if (pet.profileImage != null) {
          await _deleteImage(pet.profileImage!);
        }

        // Delete pet document and all subcollections
        await _userPetsRef(userId).doc(petId).delete();
        
        await clearCache('pet_${userId}_$petId');
        logger.i('Deleted pet: $petId');
        analytics.logEvent('pet_deleted');
      });
    } catch (e, stackTrace) {
      logger.e('Error deleting pet', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PetServiceException('Error deleting pet: $e');
    }
  }

  // Pet Retrieval
  Future<Pet> getPet(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'pet_${userId}_$petId',
        duration: const Duration(minutes: 30),
        fetchData: () async {
          final doc = await _userPetsRef(userId).doc(petId).get();
          if (!doc.exists) {
            throw PetServiceException('Pet not found');
          }
          return Pet.fromJson(doc.data()!);
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting pet', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PetServiceException('Error getting pet: $e');
    }
  }

  Stream<List<Pet>> streamUserPets(String userId) {
    try {
      return _userPetsRef(userId)
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Pet.fromJson(doc.data()))
              .toList());
    } catch (e, stackTrace) {
      logger.e('Error streaming pets', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PetServiceException('Error streaming pets: $e');
    }
  }

  // Breed Information
  Future<List<Breed>> getBreeds({String? species, String? query}) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'breeds_${species ?? 'all'}_${query ?? 'all'}',
        duration: const Duration(hours: 24),
        fetchData: () async {
          var queryRef = _breedsRef;
          
          if (species != null) {
            queryRef = queryRef.where('species', isEqualTo: species);
          }

          if (query != null) {
            queryRef = queryRef.where('name', isGreaterThanOrEqualTo: query)
                .where('name', isLessThanOrEqualTo: query + '\uf8ff');
          }

          final snapshot = await queryRef.get();
          return snapshot.docs
              .map((doc) => Breed.fromJson(doc.data()))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting breeds', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PetServiceException('Error getting breeds: $e');
    }
  }

  // Pet Statistics
  Future<PetStats> getPetStats(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'pet_stats_${userId}_$petId',
        duration: const Duration(minutes: 15),
        fetchData: () async {
          final pet = await getPet(userId, petId);
          final stats = await _calculatePetStats(userId, petId, pet);
          return stats;
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting pet stats', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PetServiceException('Error getting pet stats: $e');
    }
  }

  // Milestones
  Future<void> addMilestone(
    String userId,
    String petId,
    PetMilestone milestone,
  ) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _userPetsRef(userId)
            .doc(petId)
            .collection('milestones')
            .doc(milestone.id)
            .set(milestone.toJson());
            
        logger.i('Added milestone: ${milestone.id}');
        analytics.logEvent('milestone_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding milestone', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PetServiceException('Error adding milestone: $e');
    }
  }

  Future<List<PetMilestone>> getMilestones(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'milestones_${userId}_$petId',
        duration: const Duration(hours: 1),
        fetchData: () async {
          final snapshot = await _userPetsRef(userId)
              .doc(petId)
              .collection('milestones')
              .orderBy('date', descending: true)
              .get();
              
          return snapshot.docs
              .map((doc) => PetMilestone.fromJson(doc.data()))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting milestones', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw PetServiceException('Error getting milestones: $e');
    }
  }

  // Helper Methods
  Future<String> _uploadPetImage(String userId, File image) async {
    try {
      // Compress and resize image
      final processedImage = await ImageUtils.processImage(
        image,
        maxWidth: 800,
        maxHeight: 800,
        quality: 85,
      );

      final fileName = 'pet_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage
          .ref()
          .child('users/$userId/pets/profile_images/$fileName');

      await ref.putFile(processedImage);
      return await ref.getDownloadURL();
    } catch (e) {
      logger.e('Error uploading pet image', e);
      throw PetServiceException('Error uploading pet image: $e');
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      logger.e('Error deleting image', e);
    }
  }

  Future<PetStats> _calculatePetStats(
    String userId,
    String petId,
    Pet pet,
  ) async {
    try {
      // Get various statistics from different collections
      final milestones = await getMilestones(userId, petId);
      
      // Calculate age
      final age = DateTime.now().difference(pet.dateOfBirth);
      final ageInYears = age.inDays / 365;

      // Get health metrics from other services
      // This would typically involve calling other services
      // For now, we'll use placeholder values
      
      return PetStats(
        ageInYears: ageInYears,
        weightHistory: [], // Get from health tracker
        healthScore: 85, // Calculate based on various factors
        milestoneCount: milestones.length,
        lastCheckup: DateTime.now().subtract(const Duration(days: 30)),
        vaccinesUpToDate: true,
        activeConditions: 0,
        medicationCount: 2,
      );
    } catch (e) {
      logger.e('Error calculating pet stats', e);
      throw PetServiceException('Error calculating pet stats: $e');
    }
  }
}

class PetServiceException implements Exception {
  final String message;
  PetServiceException(this.message);

  @override
  String toString() => message;
}

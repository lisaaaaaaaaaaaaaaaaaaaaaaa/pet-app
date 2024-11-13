 // lib/services/database_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/pet.dart';
import '../models/vaccination.dart';
import '../models/appointment.dart';
import '../models/medical_record.dart';
import '../models/weight_record.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Collection references
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference get _petsRef => _firestore.collection('pets');
  
  // Get user's pets reference
  CollectionReference _userPetsRef(String userId) => 
      _usersRef.doc(userId).collection('pets');

  // PETS CRUD OPERATIONS
  
  // Create new pet
  Future<String> createPet(String userId, Pet pet) async {
    try {
      final docRef = await _userPetsRef(userId).add(pet.toJson());
      return docRef.id;
    } catch (e) {
      throw DatabaseException('Error creating pet: $e');
    }
  }

  // Get single pet
  Future<Pet> getPet(String userId, String petId) async {
    try {
      final doc = await _userPetsRef(userId).doc(petId).get();
      if (!doc.exists) {
        throw DatabaseException('Pet not found');
      }
      return Pet.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw DatabaseException('Error getting pet: $e');
    }
  }

  // Get all pets for user
  Stream<List<Pet>> getUserPets(String userId) {
    try {
      return _userPetsRef(userId)
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Pet.fromJson(doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      throw DatabaseException('Error getting user pets: $e');
    }
  }

  // Update pet
  Future<void> updatePet(String userId, String petId, Pet pet) async {
    try {
      await _userPetsRef(userId).doc(petId).update(pet.toJson());
    } catch (e) {
      throw DatabaseException('Error updating pet: $e');
    }
  }

  // Delete pet
  Future<void> deletePet(String userId, String petId) async {
    try {
      // Delete pet's image from storage if exists
      final pet = await getPet(userId, petId);
      if (pet.imageUrl != null) {
        await deleteImage(pet.imageUrl!);
      }
      
      // Delete pet document and all related collections
      final batch = _firestore.batch();
      final petRef = _userPetsRef(userId).doc(petId);
      
      // Delete vaccinations
      final vaccinationsSnapshot = await petRef.collection('vaccinations').get();
      for (var doc in vaccinationsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete appointments
      final appointmentsSnapshot = await petRef.collection('appointments').get();
      for (var doc in appointmentsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete medical records
      final recordsSnapshot = await petRef.collection('medical_records').get();
      for (var doc in recordsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete weight records
      final weightSnapshot = await petRef.collection('weight_records').get();
      for (var doc in weightSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete pet document
      batch.delete(petRef);
      
      await batch.commit();
    } catch (e) {
      throw DatabaseException('Error deleting pet: $e');
    }
  }

  // VACCINATIONS

  // Get pet's vaccinations
  Stream<List<Vaccination>> getPetVaccinations(String userId, String petId) {
    try {
      return _userPetsRef(userId)
          .doc(petId)
          .collection('vaccinations')
          .orderBy('dueDate')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Vaccination.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw DatabaseException('Error getting vaccinations: $e');
    }
  }

  Future<void> addVaccination(
    String userId,
    String petId,
    Vaccination vaccination,
  ) async {
    try {
      await _userPetsRef(userId)
          .doc(petId)
          .collection('vaccinations')
          .doc(vaccination.id)
          .set(vaccination.toJson());
    } catch (e) {
      throw DatabaseException('Error adding vaccination: $e');
    }
  }

  Future<void> updateVaccination(
    String userId,
    String petId,
    Vaccination vaccination,
  ) async {
    try {
      await _userPetsRef(userId)
          .doc(petId)
          .collection('vaccinations')
          .doc(vaccination.id)
          .update(vaccination.toJson());
    } catch (e) {
      throw DatabaseException('Error updating vaccination: $e');
    }
  }

  Future<void> deleteVaccination(
    String userId,
    String petId,
    String vaccinationId,
  ) async {
    try {
      await _userPetsRef(userId)
          .doc(petId)
          .collection('vaccinations')
          .doc(vaccinationId)
          .delete();
    } catch (e) {
      throw DatabaseException('Error deleting vaccination: $e');
    }
  }

  // APPOINTMENTS

  Stream<List<Appointment>> getPetAppointments(String userId, String petId) {
    try {
      return _userPetsRef(userId)
          .doc(petId)
          .collection('appointments')
          .orderBy('dateTime')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Appointment.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw DatabaseException('Error getting appointments: $e');
    }
  }

  Future<void> addAppointment(
    String userId,
    String petId,
    Appointment appointment,
  ) async {
    try {
      await _userPetsRef(userId)
          .doc(petId)
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toJson());
    } catch (e) {
      throw DatabaseException('Error adding appointment: $e');
    }
  }

  Future<void> updateAppointment(
    String userId,
    String petId,
    Appointment appointment,
  ) async {
    try {
      await _userPetsRef(userId)
          .doc(petId)
          .collection('appointments')
          .doc(appointment.id)
          .update(appointment.toJson());
    } catch (e) {
      throw DatabaseException('Error updating appointment: $e');
    }
  }

  Future<void> deleteAppointment(
    String userId,
    String petId,
    String appointmentId,
  ) async {
    try {
      await _userPetsRef(userId)
          .doc(petId)
          .collection('appointments')
          .doc(appointmentId)
          .delete();
    } catch (e) {
      throw DatabaseException('Error deleting appointment: $e');
    }
  }

  // MEDICAL RECORDS

  Stream<List<MedicalRecord>> getPetMedicalRecords(String userId, String petId) {
    try {
      return _userPetsRef(userId)
          .doc(petId)
          .collection('medical_records')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MedicalRecord.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw DatabaseException('Error getting medical records: $e');
    }
  }

  Future<void> addMedicalRecord(
    String userId,
    String petId,
    MedicalRecord record,
  ) async {
    try {
      await _userPetsRef(userId)
          .doc(petId)
          .collection('medical_records')
          .doc(record.id)
          .set(record.toJson());
    } catch (e) {
      throw DatabaseException('Error adding medical record: $e');
    }
  }

  Future<void> updateMedicalRecord(
    String userId,
    String petId,
    MedicalRecord record,
  ) async {
    try {
      await _userPetsRef(userId)
          .doc(petId)
          .collection('medical_records')
          .doc(record.id)
          .update(record.toJson());
    } catch (e) {
      throw DatabaseException('Error updating medical record: $e');
    }
  }

  Future<void> deleteMedicalRecord(
    String userId,
    String petId,
    String recordId,
  ) async {
    try {
      await _userPetsRef(userId)
          .doc(petId)
          .collection('medical_records')
          .doc(recordId)
          .delete();
    } catch (e) {
      throw DatabaseException('Error deleting medical record: $e');
    }
  }

  // WEIGHT RECORDS

  Stream<List<WeightRecord>> getPetWeightRecords(String userId, String petId) {
    try {
      return _userPetsRef(userId)
          .doc(petId)
          .collection('weight_records')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => WeightRecord.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw DatabaseException('Error getting weight records: $e');
    }
  }

  Future<void> addWeightRecord(
    String userId,
    String petId,
    WeightRecord record,
  ) async {
    try {
      await _userPetsRef(userId)
          .doc(petId)
          .collection('weight_records')
          .doc(record.id)
          .set(record.toJson());
    } catch (e) {
      throw DatabaseException('Error adding weight record: $e');
    }
  }

  // IMAGE HANDLING

  Future<String> uploadImage(String userId, String petId, File imageFile) async {
    try {
      final ref = _storage
          .ref()
          .child('users/$userId/pets/$petId/${DateTime.now().millisecondsSinceEpoch}');
      
      final uploadTask = await ref.putFile(imageFile);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      throw DatabaseException('Error uploading image: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw DatabaseException('Error deleting image: $e');
    }
  }

  // BATCH OPERATIONS

  Future<void> batchUpdate(List<Future Function()> operations) async {
    try {
      await Future.wait(operations);
    } catch (e) {
      throw DatabaseException('Error performing batch update: $e');
    }
  }
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => message;
}
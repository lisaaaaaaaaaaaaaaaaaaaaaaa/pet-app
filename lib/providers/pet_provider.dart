import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet.dart';

class PetProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Pet> _pets = [];
  Map<String, dynamic> _petStats = {};

  List<Pet> get pets => _pets;
  Map<String, dynamic> get petStats => _petStats;

  Future<void> loadPets() async {
    try {
      final snapshot = await _firestore.collection('pets').get();
      _pets = snapshot.docs.map((doc) => Pet.fromMap(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pets: $e');
    }
  }

  Future<void> loadPetStats() async {
    try {
      final snapshot = await _firestore.collection('petStats').get();
      if (snapshot.docs.isNotEmpty) {
        _petStats = snapshot.docs.first.data();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading pet stats: $e');
    }
  }

  Future<void> addPet(Pet pet) async {
    try {
      await _firestore.collection('pets').add(pet.toMap());
      await loadPets(); // Reload pets after adding
    } catch (e) {
      debugPrint('Error adding pet: $e');
    }
  }

  Future<void> updatePet(String id, Pet pet) async {
    try {
      await _firestore.collection('pets').doc(id).update(pet.toMap());
      await loadPets(); // Reload pets after updating
    } catch (e) {
      debugPrint('Error updating pet: $e');
    }
  }

  Future<void> deletePet(String id) async {
    try {
      await _firestore.collection('pets').doc(id).delete();
      await loadPets(); // Reload pets after deleting
    } catch (e) {
      debugPrint('Error deleting pet: $e');
    }
  }
}

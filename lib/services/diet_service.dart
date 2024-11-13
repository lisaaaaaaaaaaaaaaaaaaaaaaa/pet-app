// lib/services/diet_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diet_record.dart';
import '../models/food_item.dart';
import '../models/meal_schedule.dart';

class DietService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern
  static final DietService _instance = DietService._internal();
  factory DietService() => _instance;
  DietService._internal();

  // Collection references
  CollectionReference get _usersRef => _firestore.collection('users');

  // Get pet's diet collection reference
  CollectionReference _petDietRef(String userId, String petId) =>
      _usersRef.doc(userId).collection('pets').doc(petId).collection('diet');

  // MEAL SCHEDULES

  Stream<List<MealSchedule>> getPetMealSchedules(String userId, String petId) {
    try {
      return _petDietRef(userId, petId)
          .doc('schedule')
          .collection('meals')
          .orderBy('time')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MealSchedule.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw DietServiceException('Error getting meal schedules: $e');
    }
  }

  Future<void> addMealSchedule(
    String userId,
    String petId,
    MealSchedule schedule,
  ) async {
    try {
      await _petDietRef(userId, petId)
          .doc('schedule')
          .collection('meals')
          .doc(schedule.id)
          .set(schedule.toJson());
    } catch (e) {
      throw DietServiceException('Error adding meal schedule: $e');
    }
  }

  Future<void> updateMealSchedule(
    String userId,
    String petId,
    MealSchedule schedule,
  ) async {
    try {
      await _petDietRef(userId, petId)
          .doc('schedule')
          .collection('meals')
          .doc(schedule.id)
          .update(schedule.toJson());
    } catch (e) {
      throw DietServiceException('Error updating meal schedule: $e');
    }
  }

  Future<void> deleteMealSchedule(
    String userId,
    String petId,
    String scheduleId,
  ) async {
    try {
      await _petDietRef(userId, petId)
          .doc('schedule')
          .collection('meals')
          .doc(scheduleId)
          .delete();
    } catch (e) {
      throw DietServiceException('Error deleting meal schedule: $e');
    }
  }

  // FOOD ITEMS

  Stream<List<FoodItem>> getPetFoodItems(String userId, String petId) {
    try {
      return _petDietRef(userId, petId)
          .doc('food')
          .collection('items')
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => FoodItem.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw DietServiceException('Error getting food items: $e');
    }
  }

  Future<void> addFoodItem(
    String userId,
    String petId,
    FoodItem foodItem,
  ) async {
    try {
      await _petDietRef(userId, petId)
          .doc('food')
          .collection('items')
          .doc(foodItem.id)
          .set(foodItem.toJson());
    } catch (e) {
      throw DietServiceException('Error adding food item: $e');
    }
  }

  Future<void> updateFoodItem(
    String userId,
    String petId,
    FoodItem foodItem,
  ) async {
    try {
      await _petDietRef(userId, petId)
          .doc('food')
          .collection('items')
          .doc(foodItem.id)
          .update(foodItem.toJson());
    } catch (e) {
      throw DietServiceException('Error updating food item: $e');
    }
  }

  Future<void> deleteFoodItem(
    String userId,
    String petId,
    String foodItemId,
  ) async {
    try {
      await _petDietRef(userId, petId)
          .doc('food')
          .collection('items')
          .doc(foodItemId)
          .delete();
    } catch (e) {
      throw DietServiceException('Error deleting food item: $e');
    }
  }

  // DIET RECORDS

  Stream<List<DietRecord>> getPetDietRecords(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    try {
      var query = _petDietRef(userId, petId)
          .doc('records')
          .collection('daily')
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      return query.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => DietRecord.fromJson(doc.data()))
          .toList());
    } catch (e) {
      throw DietServiceException('Error getting diet records: $e');
    }
  }

  Future<void> addDietRecord(
    String userId,
    String petId,
    DietRecord record,
  ) async {
    try {
      await _petDietRef(userId, petId)
          .doc('records')
          .collection('daily')
          .doc(record.id)
          .set(record.toJson());

      // Update latest metrics
      await _updateLatestMetrics(userId, petId, record);
    } catch (e) {
      throw DietServiceException('Error adding diet record: $e');
    }
  }

  Future<void> updateDietRecord(
    String userId,
    String petId,
    DietRecord record,
  ) async {
    try {
      await _petDietRef(userId, petId)
          .doc('records')
          .collection('daily')
          .doc(record.id)
          .update(record.toJson());

      // Update latest metrics
      await _updateLatestMetrics(userId, petId, record);
    } catch (e) {
      throw DietServiceException('Error updating diet record: $e');
    }
  }

  Future<void> deleteDietRecord(
    String userId,
    String petId,
    String recordId,
  ) async {
    try {
      await _petDietRef(userId, petId)
          .doc('records')
          .collection('daily')
          .doc(recordId)
          .delete();
    } catch (e) {
      throw DietServiceException('Error deleting diet record: $e');
    }
  }

  // METRICS AND ANALYTICS

  Future<Map<String, dynamic>> getDietMetrics(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final records = await getPetDietRecords(
        userId,
        petId,
        startDate: startDate,
        endDate: endDate,
      ).first;

      if (records.isEmpty) {
        return {
          'totalMeals': 0,
          'averagePortionSize': 0.0,
          'mostCommonFood': null,
          'caloriesPerDay': 0.0,
        };
      }

      // Calculate metrics
      int totalMeals = 0;
      double totalPortionSize = 0.0;
      Map<String, int> foodFrequency = {};
      double totalCalories = 0.0;

      for (var record in records) {
        totalMeals += record.meals.length;
        
        for (var meal in record.meals) {
          totalPortionSize += meal.portionSize;
          totalCalories += meal.calories ?? 0;
          
          if (meal.foodName != null) {
            foodFrequency[meal.foodName!] = 
                (foodFrequency[meal.foodName!] ?? 0) + 1;
          }
        }
      }

      String? mostCommonFood;
      int maxFrequency = 0;
      foodFrequency.forEach((food, frequency) {
        if (frequency > maxFrequency) {
          mostCommonFood = food;
          maxFrequency = frequency;
        }
      });

      return {
        'totalMeals': totalMeals,
        'averagePortionSize': totalMeals > 0 
            ? totalPortionSize / totalMeals 
            : 0.0,
        'mostCommonFood': mostCommonFood,
        'caloriesPerDay': records.length > 0 
            ? totalCalories / records.length 
            : 0.0,
      };
    } catch (e) {
      throw DietServiceException('Error calculating diet metrics: $e');
    }
  }

  // Helper Methods

  Future<void> _updateLatestMetrics(
    String userId,
    String petId,
    DietRecord record,
  ) async {
    try {
      await _petDietRef(userId, petId).doc('metrics').set({
        'lastMealDate': record.date,
        'lastMealTime': record.meals.isNotEmpty 
            ? record.meals.last.time 
            : null,
        'totalMealsToday': record.meals.length,
        'totalCaloriesToday': record.meals.fold<double>(
          0.0,
          (sum, meal) => sum + (meal.calories ?? 0),
        ),
      }, SetOptions(merge: true));
    } catch (e) {
      throw DietServiceException('Error updating latest metrics: $e');
    }
  }
}

class DietServiceException implements Exception {
  final String message;
  DietServiceException(this.message);

  @override
  String toString() => message;
}
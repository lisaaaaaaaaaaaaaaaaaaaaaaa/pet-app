import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/base_service.dart';
import '../models/diet_record.dart';
import '../models/food_item.dart';
import '../models/meal_schedule.dart';
import '../utils/exceptions.dart';

class DietService extends BaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static final DietService _instance = DietService._internal();
  factory DietService() => _instance;
  DietService._internal();

  // Collection References
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference _petDietRef(String userId, String petId) =>
      _usersRef.doc(userId).collection('pets').doc(petId).collection('diet');

  // Meal Schedules
  Future<List<MealSchedule>> getMealSchedules(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'meal_schedules_${userId}_$petId',
        duration: const Duration(hours: 1),
        fetchData: () async {
          final snapshot = await _petDietRef(userId, petId)
              .doc('schedule')
              .collection('meals')
              .orderBy('time')
              .get();
              
          return snapshot.docs
              .map((doc) => MealSchedule.fromJson(doc.data()))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting meal schedules', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DietServiceException('Error getting meal schedules: $e');
    }
  }

  Future<void> addMealSchedule(String userId, String petId, MealSchedule schedule) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petDietRef(userId, petId)
            .doc('schedule')
            .collection('meals')
            .doc(schedule.id)
            .set(schedule.toJson());
            
        await clearCache('meal_schedules_${userId}_$petId');
        logger.i('Added meal schedule: ${schedule.id}');
        analytics.logEvent('meal_schedule_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding meal schedule', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DietServiceException('Error adding meal schedule: $e');
    }
  }

  Future<void> updateMealSchedule(String userId, String petId, MealSchedule schedule) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petDietRef(userId, petId)
            .doc('schedule')
            .collection('meals')
            .doc(schedule.id)
            .update(schedule.toJson());
            
        await clearCache('meal_schedules_${userId}_$petId');
        logger.i('Updated meal schedule: ${schedule.id}');
        analytics.logEvent('meal_schedule_updated');
      });
    } catch (e, stackTrace) {
      logger.e('Error updating meal schedule', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DietServiceException('Error updating meal schedule: $e');
    }
  }

  Future<void> deleteMealSchedule(String userId, String petId, String scheduleId) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petDietRef(userId, petId)
            .doc('schedule')
            .collection('meals')
            .doc(scheduleId)
            .delete();
            
        await clearCache('meal_schedules_${userId}_$petId');
        logger.i('Deleted meal schedule: $scheduleId');
        analytics.logEvent('meal_schedule_deleted');
      });
    } catch (e, stackTrace) {
      logger.e('Error deleting meal schedule', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DietServiceException('Error deleting meal schedule: $e');
    }
  }

  // Food Items
  Future<List<FoodItem>> getFoodItems(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'food_items_${userId}_$petId',
        duration: const Duration(hours: 2),
        fetchData: () async {
          final snapshot = await _petDietRef(userId, petId)
              .doc('food')
              .collection('items')
              .orderBy('name')
              .get();
              
          return snapshot.docs
              .map((doc) => FoodItem.fromJson(doc.data()))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting food items', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DietServiceException('Error getting food items: $e');
    }
  }

  Future<void> addFoodItem(String userId, String petId, FoodItem foodItem) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petDietRef(userId, petId)
            .doc('food')
            .collection('items')
            .doc(foodItem.id)
            .set(foodItem.toJson());
            
        await clearCache('food_items_${userId}_$petId');
        logger.i('Added food item: ${foodItem.id}');
        analytics.logEvent('food_item_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding food item', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DietServiceException('Error adding food item: $e');
    }
  }

  // Diet Records
  Stream<List<DietRecord>> streamDietRecords(
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
    } catch (e, stackTrace) {
      logger.e('Error streaming diet records', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DietServiceException('Error streaming diet records: $e');
    }
  }

  Future<void> addDietRecord(String userId, String petId, DietRecord record) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petDietRef(userId, petId)
            .doc('records')
            .collection('daily')
            .doc(record.id)
            .set(record.toJson());
            
        await _updateLatestMetrics(userId, petId, record);
        logger.i('Added diet record: ${record.id}');
        analytics.logEvent('diet_record_added');
      });
    } catch (e, stackTrace) {
      logger.e('Error adding diet record', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DietServiceException('Error adding diet record: $e');
    }
  }

  // Metrics and Analytics
  Future<Map<String, dynamic>> getDietMetrics(
    String userId,
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await checkConnectivity();
      
      final records = await _getDietRecords(userId, petId, startDate, endDate);
      
      if (records.isEmpty) {
        return _getEmptyMetrics();
      }

      return _calculateMetrics(records);
    } catch (e, stackTrace) {
      logger.e('Error calculating diet metrics', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw DietServiceException('Error calculating diet metrics: $e');
    }
  }

  // Helper Methods
  Future<List<DietRecord>> _getDietRecords(
    String userId,
    String petId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
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

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => DietRecord.fromJson(doc.data()))
        .toList();
  }

  Map<String, dynamic> _getEmptyMetrics() {
    return {
      'totalMeals': 0,
      'averagePortionSize': 0.0,
      'mostCommonFood': null,
      'caloriesPerDay': 0.0,
    };
  }

  Map<String, dynamic> _calculateMetrics(List<DietRecord> records) {
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
  }

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
      logger.e('Error updating latest metrics', e);
    }
  }
}

class DietServiceException implements Exception {
  final String message;
  DietServiceException(this.message);

  @override
  String toString() => message;
}

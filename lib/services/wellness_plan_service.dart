import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class WellnessPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  // Singleton pattern
  static final WellnessPlanService _instance = WellnessPlanService._internal();
  factory WellnessPlanService() => _instance;
  WellnessPlanService._internal();

  // Create a new wellness plan
  Future<String> createWellnessPlan({
    required String petId,
    required String userId,
    required String planName,
    required DateTime startDate,
    required DateTime endDate,
    required List<Map<String, dynamic>> goals,
    required List<Map<String, dynamic>> activities,
    String? veterinarianId,
    Map<String, dynamic>? dietaryPlan,
    Map<String, dynamic>? exercisePlan,
    List<Map<String, dynamic>>? medications,
    List<Map<String, dynamic>>? supplements,
    Map<String, dynamic>? progressMetrics,
    String? notes,
  }) async {
    try {
      final String planId = uuid.v4();
      final documentRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('wellnessPlans')
          .doc(planId);

      final planData = {
        'id': planId,
        'petId': petId,
        'userId': userId,
        'planName': planName,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'goals': goals,
        'activities': activities,
        'veterinarianId': veterinarianId,
        'dietaryPlan': dietaryPlan ?? {},
        'exercisePlan': exercisePlan ?? {},
        'medications': medications ?? [],
        'supplements': supplements ?? [],
        'progressMetrics': progressMetrics ?? {},
        'notes': notes,
        'status': 'active',
        'completedActivities': [],
        'achievedGoals': [],
        'lastUpdated': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await documentRef.set(planData);
      return planId;
    } catch (e) {
      throw WellnessPlanException('Error creating wellness plan: $e');
    }
  }

  // Update an existing wellness plan
  Future<void> updateWellnessPlan({
    required String petId,
    required String planId,
    String? planName,
    DateTime? startDate,
    DateTime? endDate,
    List<Map<String, dynamic>>? goals,
    List<Map<String, dynamic>>? activities,
    String? veterinarianId,
    Map<String, dynamic>? dietaryPlan,
    Map<String, dynamic>? exercisePlan,
    List<Map<String, dynamic>>? medications,
    List<Map<String, dynamic>>? supplements,
    Map<String, dynamic>? progressMetrics,
    String? notes,
    String? status,
  }) async {
    try {
      final documentRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('wellnessPlans')
          .doc(planId);

      final Map<String, dynamic> updateData = {};

      if (planName != null) updateData['planName'] = planName;
      if (startDate != null) updateData['startDate'] = Timestamp.fromDate(startDate);
      if (endDate != null) updateData['endDate'] = Timestamp.fromDate(endDate);
      if (goals != null) updateData['goals'] = goals;
      if (activities != null) updateData['activities'] = activities;
      if (veterinarianId != null) updateData['veterinarianId'] = veterinarianId;
      if (dietaryPlan != null) updateData['dietaryPlan'] = dietaryPlan;
      if (exercisePlan != null) updateData['exercisePlan'] = exercisePlan;
      if (medications != null) updateData['medications'] = medications;
      if (supplements != null) updateData['supplements'] = supplements;
      if (progressMetrics != null) updateData['progressMetrics'] = progressMetrics;
      if (notes != null) updateData['notes'] = notes;
      if (status != null) updateData['status'] = status;

      updateData['lastUpdated'] = FieldValue.serverTimestamp();

      await documentRef.update(updateData);
    } catch (e) {
      throw WellnessPlanException('Error updating wellness plan: $e');
    }
  }

  // Get a specific wellness plan
  Future<Map<String, dynamic>> getWellnessPlan({
    required String petId,
    required String planId,
  }) async {
    try {
      final documentSnapshot = await _firestore
          .collection('pets')
          .doc(petId)
          .collection('wellnessPlans')
          .doc(planId)
          .get();

      if (!documentSnapshot.exists) {
        throw WellnessPlanException('Wellness plan not found');
      }

      return documentSnapshot.data() as Map<String, dynamic>;
    } catch (e) {
      throw WellnessPlanException('Error fetching wellness plan: $e');
    }
  }

  // Get all wellness plans for a pet
  Future<List<Map<String, dynamic>>> getPetWellnessPlans({
    required String petId,
    String? status,
  }) async {
    try {
      Query query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('wellnessPlans')
          .orderBy('startDate', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw WellnessPlanException('Error fetching wellness plans: $e');
    }
  }

  // Record activity completion
  Future<void> recordActivityCompletion({
    required String petId,
    required String planId,
    required String activityId,
    required DateTime completionDate,
    Map<String, dynamic>? metrics,
    String? notes,
  }) async {
    try {
      final documentRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('wellnessPlans')
          .doc(planId);

      await _firestore.runTransaction((transaction) async {
        final planSnapshot = await transaction.get(documentRef);
        
        if (!planSnapshot.exists) {
          throw WellnessPlanException('Wellness plan not found');
        }

        final List<dynamic> completedActivities = 
            List.from(planSnapshot.data()?['completedActivities'] ?? []);

        completedActivities.add({
          'activityId': activityId,
          'completionDate': Timestamp.fromDate(completionDate),
          'metrics': metrics ?? {},
          'notes': notes,
        });

        transaction.update(documentRef, {
          'completedActivities': completedActivities,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw WellnessPlanException('Error recording activity completion: $e');
    }
  }

  // Update goal progress
  Future<void> updateGoalProgress({
    required String petId,
    required String planId,
    required String goalId,
    required double progress,
    bool? achieved,
    String? notes,
  }) async {
    try {
      final documentRef = _firestore
          .collection('pets')
          .doc(petId)
          .collection('wellnessPlans')
          .doc(planId);

      await _firestore.runTransaction((transaction) async {
        final planSnapshot = await transaction.get(documentRef);
        
        if (!planSnapshot.exists) {
          throw WellnessPlanException('Wellness plan not found');
        }

        final List<dynamic> goals = List.from(planSnapshot.data()?['goals'] ?? []);
        final int goalIndex = goals.indexWhere((g) => g['id'] == goalId);

        if (goalIndex == -1) {
          throw WellnessPlanException('Goal not found');
        }

        goals[goalIndex]['progress'] = progress;
        if (achieved != null) goals[goalIndex]['achieved'] = achieved;
        if (notes != null) goals[goalIndex]['notes'] = notes;

        transaction.update(documentRef, {
          'goals': goals,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw WellnessPlanException('Error updating goal progress: $e');
    }
  }

  // Get wellness plan progress
  Future<Map<String, dynamic>> getWellnessPlanProgress({
    required String petId,
    required String planId,
  }) async {
    try {
      final planSnapshot = await _firestore
          .collection('pets')
          .doc(petId)
          .collection('wellnessPlans')
          .doc(planId)
          .get();

      if (!planSnapshot.exists) {
        throw WellnessPlanException('Wellness plan not found');
      }

      final planData = planSnapshot.data()!;
      final List<dynamic> goals = planData['goals'] ?? [];
      final List<dynamic> activities = planData['activities'] ?? [];
      final List<dynamic> completedActivities = planData['completedActivities'] ?? [];

      final totalGoals = goals.length;
      final achievedGoals = goals.where((g) => g['achieved'] == true).length;
      final totalActivities = activities.length;
      final completedActivitiesCount = completedActivities.length;

      return {
        'totalGoals': totalGoals,
        'achievedGoals': achievedGoals,
        'goalProgress': totalGoals > 0 ? (achievedGoals / totalGoals) : 0.0,
        'totalActivities': totalActivities,
        'completedActivities': completedActivitiesCount,
        'activityProgress': totalActivities > 0 
            ? (completedActivitiesCount / totalActivities) 
            : 0.0,
        'lastUpdated': planData['lastUpdated'],
      };
    } catch (e) {
      throw WellnessPlanException('Error getting wellness plan progress: $e');
    }
  }

  // Archive wellness plan
  Future<void> archiveWellnessPlan({
    required String petId,
    required String planId,
    String? archiveReason,
  }) async {
    try {
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('wellnessPlans')
          .doc(planId)
          .update({
        'status': 'archived',
        'archiveReason': archiveReason,
        'archivedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw WellnessPlanException('Error archiving wellness plan: $e');
    }
  }
}

class WellnessPlanException implements Exception {
  final String message;
  WellnessPlanException(this.message);

  @override
  String toString() => message;
}
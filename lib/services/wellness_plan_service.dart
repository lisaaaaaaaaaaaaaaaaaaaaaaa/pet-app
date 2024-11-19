import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/base_service.dart';
import '../models/wellness_plan.dart';
import '../models/wellness_task.dart';
import '../models/wellness_progress.dart';
import '../models/wellness_recommendation.dart';
import '../utils/exceptions.dart';

class WellnessPlanService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static final WellnessPlanService _instance = WellnessPlanService._internal();
  factory WellnessPlanService() => _instance;
  WellnessPlanService._internal();

  // Collection References
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference _petWellnessRef(String userId, String petId) =>
      _usersRef.doc(userId).collection('pets').doc(petId).collection('wellness');

  // Wellness Plan Management
  Future<void> createWellnessPlan(
    String userId,
    String petId,
    WellnessPlan plan,
  ) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petWellnessRef(userId, petId)
            .doc('plan')
            .set(plan.toJson());
            
        // Create initial progress tracking
        await _initializeProgress(userId, petId, plan);
        
        // Schedule reminders for tasks
        await _scheduleTaskReminders(userId, petId, plan);
        
        logger.i('Created wellness plan for pet: $petId');
        analytics.logEvent('wellness_plan_created');
      });
    } catch (e, stackTrace) {
      logger.e('Error creating wellness plan', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw WellnessPlanException('Error creating wellness plan: $e');
    }
  }

  Future<void> updateWellnessPlan(
    String userId,
    String petId,
    WellnessPlan plan,
  ) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petWellnessRef(userId, petId)
            .doc('plan')
            .update(plan.toJson());
            
        // Update progress tracking
        await _updateProgress(userId, petId, plan);
        
        // Update task reminders
        await _updateTaskReminders(userId, petId, plan);
        
        logger.i('Updated wellness plan for pet: $petId');
        analytics.logEvent('wellness_plan_updated');
      });
    } catch (e, stackTrace) {
      logger.e('Error updating wellness plan', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw WellnessPlanException('Error updating wellness plan: $e');
    }
  }

  // Task Management
  Future<void> completeTask(
    String userId,
    String petId,
    String taskId,
    Map<String, dynamic> completionData,
  ) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        // Update task completion status
        await _petWellnessRef(userId, petId)
            .doc('progress')
            .collection('tasks')
            .doc(taskId)
            .update({
          'completed': true,
          'completedAt': FieldValue.serverTimestamp(),
          'completionData': completionData,
        });

        // Update overall progress
        await _updateOverallProgress(userId, petId);
        
        logger.i('Completed wellness task: $taskId');
        analytics.logEvent('wellness_task_completed');
      });
    } catch (e, stackTrace) {
      logger.e('Error completing task', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw WellnessPlanException('Error completing task: $e');
    }
  }

  Future<void> skipTask(
    String userId,
    String petId,
    String taskId,
    String reason,
  ) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        await _petWellnessRef(userId, petId)
            .doc('progress')
            .collection('tasks')
            .doc(taskId)
            .update({
          'skipped': true,
          'skippedAt': FieldValue.serverTimestamp(),
          'skipReason': reason,
        });
        
        logger.i('Skipped wellness task: $taskId');
        analytics.logEvent('wellness_task_skipped');
      });
    } catch (e, stackTrace) {
      logger.e('Error skipping task', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw WellnessPlanException('Error skipping task: $e');
    }
  }

  // Progress Tracking
  Stream<WellnessProgress> streamProgress(String userId, String petId) {
    try {
      return _petWellnessRef(userId, petId)
          .doc('progress')
          .snapshots()
          .map((doc) => WellnessProgress.fromJson(doc.data()!));
    } catch (e, stackTrace) {
      logger.e('Error streaming progress', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw WellnessPlanException('Error streaming progress: $e');
    }
  }

  Future<List<WellnessTask>> getDueTasks(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'due_tasks_${userId}_$petId',
        duration: const Duration(minutes: 15),
        fetchData: () async {
          final now = DateTime.now();
          final snapshot = await _petWellnessRef(userId, petId)
              .doc('progress')
              .collection('tasks')
              .where('dueDate', isLessThanOrEqualTo: now)
              .where('completed', isEqualTo: false)
              .where('skipped', isEqualTo: false)
              .orderBy('dueDate')
              .get();
              
          return snapshot.docs
              .map((doc) => WellnessTask.fromJson(doc.data()))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting due tasks', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw WellnessPlanException('Error getting due tasks: $e');
    }
  }

  // Recommendations
  Future<List<WellnessRecommendation>> getRecommendations(
    String userId,
    String petId,
  ) async {
    try {
      await checkConnectivity();
      
      final plan = await _getCurrentPlan(userId, petId);
      final progress = await _getCurrentProgress(userId, petId);
      
      return _generateRecommendations(plan, progress);
    } catch (e, stackTrace) {
      logger.e('Error getting recommendations', e, stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
      throw WellnessPlanException('Error getting recommendations: $e');
    }
  }

  // Helper Methods
  Future<void> _initializeProgress(
    String userId,
    String petId,
    WellnessPlan plan,
  ) async {
    try {
      final progress = WellnessProgress(
        planId: plan.id,
        startDate: DateTime.now(),
        overallProgress: 0,
        categoryProgress: {},
        lastUpdated: DateTime.now(),
      );

      await _petWellnessRef(userId, petId)
          .doc('progress')
          .set(progress.toJson());

      // Initialize task tracking
      for (var task in plan.tasks) {
        await _petWellnessRef(userId, petId)
            .doc('progress')
            .collection('tasks')
            .doc(task.id)
            .set({
          ...task.toJson(),
          'completed': false,
          'skipped': false,
          'dueDate': _calculateNextDueDate(task),
        });
      }
    } catch (e) {
      logger.e('Error initializing progress', e);
      throw WellnessPlanException('Error initializing progress: $e');
    }
  }

  Future<void> _updateProgress(
    String userId,
    String petId,
    WellnessPlan plan,
  ) async {
    try {
      // Update existing tasks
      final existingTasks = await _petWellnessRef(userId, petId)
          .doc('progress')
          .collection('tasks')
          .get();

      final batch = _firestore.batch();

      // Remove tasks that are no longer in the plan
      for (var doc in existingTasks.docs) {
        if (!plan.tasks.any((task) => task.id == doc.id)) {
          batch.delete(doc.reference);
        }
      }

      // Add or update tasks
      for (var task in plan.tasks) {
        final taskRef = _petWellnessRef(userId, petId)
            .doc('progress')
            .collection('tasks')
            .doc(task.id);

        final existingTask = existingTasks.docs
            .firstWhere((doc) => doc.id == task.id, orElse: () => null as DocumentSnapshot<Object?>);

        // Update existing task
        batch.update(taskRef, task.toJson());
            }

      await batch.commit();
    } catch (e) {
      logger.e('Error updating progress', e);
      throw WellnessPlanException('Error updating progress: $e');
    }
  }

  Future<void> _updateOverallProgress(String userId, String petId) async {
    try {
      final tasks = await _petWellnessRef(userId, petId)
          .doc('progress')
          .collection('tasks')
          .get();

      final totalTasks = tasks.docs.length;
      final completedTasks = tasks.docs
          .where((doc) => doc.data()['completed'] == true)
          .length;

      final progress = (completedTasks / totalTasks) * 100;

      await _petWellnessRef(userId, petId)
          .doc('progress')
          .update({
        'overallProgress': progress,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      logger.e('Error updating overall progress', e);
    }
  }

  DateTime _calculateNextDueDate(WellnessTask task) {
    final now = DateTime.now();
    
    switch (task.frequency) {
      case 'daily':
        return DateTime(now.year, now.month, now.day)
            .add(const Duration(days: 1));
      case 'weekly':
        return DateTime(now.year, now.month, now.day)
            .add(const Duration(days: 7));
      case 'monthly':
        return DateTime(now.year, now.month + 1, now.day);
      case 'yearly':
        return DateTime(now.year + 1, now.month, now.day);
      default:
        return now;
    }
  }

  Future<WellnessPlan> _getCurrentPlan(String userId, String petId) async {
    final doc = await _petWellnessRef(userId, petId).doc('plan').get();
    return WellnessPlan.fromJson(doc.data()!);
  }

  Future<WellnessProgress> _getCurrentProgress(String userId, String petId) async {
    final doc = await _petWellnessRef(userId, petId).doc('progress').get();
    return WellnessProgress.fromJson(doc.data()!);
  }

  List<WellnessRecommendation> _generateRecommendations(
    WellnessPlan plan,
    WellnessProgress progress,
  ) {
    final recommendations = <WellnessRecommendation>[];

    // Add recommendations based on progress
    if (progress.overallProgress < 50) {
      recommendations.add(
        WellnessRecommendation(
          id: 'improve_completion',
          title: 'Improve Task Completion',
          description: 'Try to complete more wellness tasks to improve your pet\'s health.',
          priority: 'high',
        ),
      );
    }

    // Add category-specific recommendations
    for (var entry in progress.categoryProgress.entries) {
      if (entry.value < 70) {
        recommendations.add(
          WellnessRecommendation(
            id: 'improve_${entry.key}',
            title: 'Focus on ${entry.key}',
            description: 'This category needs more attention.',
            priority: 'medium',
          ),
        );
      }
    }

    return recommendations;
  }

  Future<void> _scheduleTaskReminders(
    String userId,
    String petId,
    WellnessPlan plan,
  ) async {
    try {
      for (var task in plan.tasks) {
        if (task.reminderEnabled) {
          final dueDate = _calculateNextDueDate(task);
          final reminderTime = dueDate.subtract(const Duration(hours: 1));

          await notificationService.scheduleNotification(
            id: task.hashCode,
            title: 'Wellness Task Due Soon',
            body: 'Don\'t forget: ${task.name}',
            scheduledDate: reminderTime,
            payload: json.encode({
              'type': 'wellness_task',
              'taskId': task.id,
              'petId': petId,
            }),
          );
        }
      }
    } catch (e) {
      logger.e('Error scheduling task reminders', e);
    }
  }

  Future<void> _updateTaskReminders(
    String userId,
    String petId,
    WellnessPlan plan,
  ) async {
    try {
      // Cancel existing reminders
      for (var task in plan.tasks) {
        await notificationService.cancelNotification(task.hashCode);
      }

      // Schedule new reminders
      await _scheduleTaskReminders(userId, petId, plan);
    } catch (e) {
      logger.e('Error updating task reminders', e);
    }
  }
}

class WellnessPlanException implements Exception {
  final String message;
  WellnessPlanException(this.message);

  @override
  String toString() => message;
}

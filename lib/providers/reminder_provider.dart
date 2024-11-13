// lib/providers/reminder_provider.dart

import 'package:flutter/foundation.dart';
import '../services/pet_service.dart';
import '../models/pet.dart';
import 'dart:async';

class ReminderProvider with ChangeNotifier {
  final PetService _petService = PetService();
  Map<String, List<PetReminder>> _reminders = {};
  Map<String, DateTime> _lastUpdated = {};
  Map<String, Map<String, dynamic>> _reminderAnalytics = {};
  bool _isLoading = false;
  String? _error;
  Timer? _autoRefreshTimer;
  Duration _cacheExpiration = const Duration(minutes: 30);
  bool _isInitialized = false;

  // Enhanced Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  Map<String, DateTime> get lastUpdated => _lastUpdated;

  ReminderProvider() {
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _refreshAllReminders(silent: true),
    );
  }

  // Check if data needs refresh
  bool _needsRefresh(String petId) {
    final lastUpdate = _lastUpdated[petId];
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) > _cacheExpiration;
  }

  // Enhanced reminder retrieval
  Future<List<PetReminder>> getRemindersForPet(
    String petId, {
    bool forceRefresh = false,
    String? type,
    bool? isCompleted,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? assignedTo,
  }) async {
    if (forceRefresh || _needsRefresh(petId)) {
      await loadReminders(petId);
    }

    var reminders = _reminders[petId] ?? [];

    // Apply filters
    if (type != null) {
      reminders = reminders.where(
        (r) => r.type.toLowerCase() == type.toLowerCase()
      ).toList();
    }

    if (isCompleted != null) {
      reminders = reminders.where(
        (r) => r.isCompleted == isCompleted
      ).toList();
    }

    if (startDate != null) {
      reminders = reminders.where(
        (r) => r.dueDate.isAfter(startDate)
      ).toList();
    }

    if (endDate != null) {
      reminders = reminders.where(
        (r) => r.dueDate.isBefore(endDate)
      ).toList();
    }

    if (assignedTo != null && assignedTo.isNotEmpty) {
      reminders = reminders.where(
        (r) => assignedTo.any((userId) => r.assignedTo.contains(userId))
      ).toList();
    }

    return reminders;
  }

  // Enhanced reminder loading
  Future<void> loadReminders(
    String petId, {
    bool silent = false,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (!silent) {
        _isLoading = true;
        notifyListeners();
      }

      final reminders = await _petService.getReminders(
        petId,
        startDate: startDate,
        endDate: endDate,
      );

      _reminders[petId] = reminders
          .map((data) => PetReminder.fromJson(data))
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

      _lastUpdated[petId] = DateTime.now();
      await _updateReminderAnalytics(petId);
      
      if (!silent) _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Failed to load reminders', e, stackTrace);
      if (!silent) rethrow;
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Enhanced reminder addition with validation
  Future<void> addReminder({
    required String petId,
    required String title,
    required String type,
    required DateTime dueDate,
    required ReminderFrequency frequency,
    String? notes,
    bool isRecurring = false,
    Map<String, dynamic>? recurringDetails,
    List<String>? assignedTo,
    Map<String, dynamic>? metadata,
    NotificationPreference? notificationPreference,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validate reminder data
      _validateReminderData(
        title: title,
        dueDate: dueDate,
        frequency: frequency,
        recurringDetails: recurringDetails,
      );

      // ... (continued in next part)
      // Continuing lib/providers/reminder_provider.dart

      final reminder = await _petService.addReminder(
        petId: petId,
        title: title,
        type: type,
        dueDate: dueDate,
        frequency: frequency,
        notes: notes,
        isRecurring: isRecurring,
        recurringDetails: recurringDetails,
        assignedTo: assignedTo,
        metadata: {
          ...?metadata,
          'createdAt': DateTime.now().toIso8601String(),
          'platform': 'mobile',
          'appVersion': await _getAppVersion(),
        },
        notificationPreference: notificationPreference?.toJson(),
      );

      // Update local cache
      final reminders = _reminders[petId] ?? [];
      reminders.add(PetReminder.fromJson(reminder));
      _reminders[petId] = reminders..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      
      _lastUpdated[petId] = DateTime.now();
      await _updateReminderAnalytics(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Failed to add reminder', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _validateReminderData({
    required String title,
    required DateTime dueDate,
    required ReminderFrequency frequency,
    Map<String, dynamic>? recurringDetails,
  }) {
    if (title.isEmpty) {
      throw ReminderException('Reminder title is required');
    }
    
    if (dueDate.isBefore(DateTime.now())) {
      throw ReminderException('Due date cannot be in the past');
    }

    if (frequency != ReminderFrequency.once && recurringDetails == null) {
      throw ReminderException('Recurring details required for recurring reminders');
    }
  }

  // Enhanced reminder completion with smart rescheduling
  Future<void> completeReminder({
    required String petId,
    required String reminderId,
    String? completionNotes,
    DateTime? completedAt,
    Map<String, dynamic>? completionMetadata,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final reminder = _reminders[petId]?.firstWhere(
        (r) => r.id == reminderId,
        orElse: () => throw ReminderException('Reminder not found'),
      );

      await _petService.updateReminder(
        petId: petId,
        reminderId: reminderId,
        isCompleted: true,
        completedAt: completedAt ?? DateTime.now(),
        notes: completionNotes,
        metadata: {
          ...?completionMetadata,
          'completedAt': DateTime.now().toIso8601String(),
          'completionStatus': 'manual',
        },
      );

      if (reminder?.isRecurring ?? false) {
        await _scheduleNextRecurrence(reminder!, completedAt);
      }

      await _checkComplianceAndNotify(petId, reminder!);
      await loadReminders(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Failed to complete reminder', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _scheduleNextRecurrence(
    PetReminder reminder,
    DateTime? completedAt,
  ) async {
    final nextDate = _calculateNextOccurrence(
      reminder.dueDate,
      reminder.frequency,
      reminder.recurringDetails,
      completedAt,
    );

    if (nextDate != null) {
      await addReminder(
        petId: reminder.petId,
        title: reminder.title,
        type: reminder.type,
        dueDate: nextDate,
        frequency: reminder.frequency,
        notes: reminder.notes,
        isRecurring: true,
        recurringDetails: reminder.recurringDetails,
        assignedTo: reminder.assignedTo,
        notificationPreference: reminder.notificationPreference,
      );
    }
  }

  DateTime? _calculateNextOccurrence(
    DateTime currentDate,
    ReminderFrequency frequency,
    Map<String, dynamic>? recurringDetails,
    DateTime? completedAt,
  ) {
    final baseDate = completedAt ?? currentDate;
    
    switch (frequency) {
      case ReminderFrequency.daily:
        return _calculateNextDaily(baseDate, recurringDetails);
      case ReminderFrequency.weekly:
        return _calculateNextWeekly(baseDate, recurringDetails);
      case ReminderFrequency.monthly:
        return _calculateNextMonthly(baseDate, recurringDetails);
      case ReminderFrequency.yearly:
        return _calculateNextYearly(baseDate, recurringDetails);
      default:
        return null;
    }
  }

  // Enhanced analytics methods
  Future<void> _updateReminderAnalytics(String petId) async {
    try {
      final reminders = _reminders[petId] ?? [];
      
      _reminderAnalytics[petId] = {
        'overview': {
          'total': reminders.length,
          'completed': reminders.where((r) => r.isCompleted).length,
          'overdue': getOverdueReminders(petId).length,
          'upcoming': getUpcomingReminders(petId).length,
        },
        'compliance': _calculateComplianceMetrics(reminders),
        'categories': _analyzeReminderCategories(reminders),
        'timing': _analyzeReminderTiming(reminders),
        'assignments': _analyzeAssignments(reminders),
        'trends': await _analyzeComplianceTrends(petId),
      };
    } catch (e, stackTrace) {
      _error = _handleError('Failed to update analytics', e, stackTrace);
    }
  }

  Map<String, dynamic> generateReminderReport(String petId) {
    final analytics = _reminderAnalytics[petId];
    if (analytics == null) return {};

    return {
      'summary': analytics['overview'],
      'compliance': analytics['compliance'],
      'analysis': {
        'categories': analytics['categories'],
        'timing': analytics['timing'],
        'assignments': analytics['assignments'],
      },
      'trends': analytics['trends'],
      'recommendations': _generateRecommendations(analytics),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  String _handleError(String operation, dynamic error, StackTrace stackTrace) {
    debugPrint('ReminderProvider Error: $operation');
    debugPrint('Error: $error');
    debugPrint('StackTrace: $stackTrace');
    return 'Failed to $operation: ${error.toString()}';
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}

class ReminderException implements Exception {
  final String message;
  ReminderException(this.message);

  @override
  String toString() => message;
}

class NotificationPreference {
  final bool enabled;
  final List<Duration> remindBefore;
  final String? sound;
  final Map<String, dynamic>? customSettings;

  NotificationPreference({
    this.enabled = true,
    this.remindBefore = const [Duration(hours: 24)],
    this.sound,
    this.customSettings,
  });

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'remindBefore': remindBefore.map((d) => d.inMinutes).toList(),
    'sound': sound,
    'customSettings': customSettings,
  };
}
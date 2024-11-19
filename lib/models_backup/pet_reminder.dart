// lib/models/pet_reminder.dart

import 'package:flutter/foundation.dart';

class PetReminder {
  final String id;
  final String petId;
  final String title;
  final String type;
  final DateTime dueDate;
  final ReminderFrequency frequency;
  final String? notes;
  final bool isRecurring;
  final Map<String, dynamic>? recurringDetails;
  final List<String> assignedTo;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String createdBy;
  final String? completedBy;
  final ReminderPriority priority;
  final bool hasNotification;
  final List<DateTime>? notificationTimes;
  final Map<String, dynamic>? customData;
  // New premium features
  final String category;
  final Map<String, dynamic> schedule;
  final List<String> attachments;
  final Map<String, dynamic> linkedRecords;
  final List<String> tags;
  final Map<String, dynamic> completionRequirements;
  final List<String> dependencies;
  final Map<String, dynamic> progressTracking;
  final bool requiresVerification;
  final Map<String, dynamic>? verificationDetails;
  final List<String> skipDates;
  final Map<String, dynamic> customNotifications;
  final Map<String, dynamic> reminderHistory;
  final bool isTemplate;
  final String? templateId;
  final Map<String, dynamic> locationDetails;
  final Map<String, dynamic> weatherDependency;
  final Map<String, dynamic> costs;
  final List<String> relatedReminders;
  final Map<String, dynamic> compliance;
  final Map<String, dynamic> escalation;
  final bool requiresPhoto;
  final bool requiresNote;
  final List<String> alternativeSchedules;
  final Map<String, dynamic> metrics;

  PetReminder({
    required this.id,
    required this.petId,
    required this.title,
    required this.type,
    required this.dueDate,
    required this.frequency,
    this.notes,
    this.isRecurring = false,
    this.recurringDetails,
    this.assignedTo = const [],
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    required this.createdBy,
    this.completedBy,
    this.priority = ReminderPriority.medium,
    this.hasNotification = true,
    this.notificationTimes,
    this.customData,
    // New premium features
    this.category = 'general',
    this.schedule = const {},
    this.attachments = const [],
    this.linkedRecords = const {},
    this.tags = const [],
    this.completionRequirements = const {},
    this.dependencies = const [],
    this.progressTracking = const {},
    this.requiresVerification = false,
    this.verificationDetails,
    this.skipDates = const [],
    this.customNotifications = const {},
    this.reminderHistory = const {},
    this.isTemplate = false,
    this.templateId,
    this.locationDetails = const {},
    this.weatherDependency = const {},
    this.costs = const {},
    this.relatedReminders = const [],
    this.compliance = const {},
    this.escalation = const {},
    this.requiresPhoto = false,
    this.requiresNote = false,
    this.alternativeSchedules = const [],
    this.metrics = const {},
  });

  // Existing methods remain the same...

  Map<String, dynamic> toJson() {
    return {
      // Existing fields...
      'category': category,
      'schedule': schedule,
      'attachments': attachments,
      'linkedRecords': linkedRecords,
      'tags': tags,
      'completionRequirements': completionRequirements,
      'dependencies': dependencies,
      'progressTracking': progressTracking,
      'requiresVerification': requiresVerification,
      'verificationDetails': verificationDetails,
      'skipDates': skipDates,
      'customNotifications': customNotifications,
      'reminderHistory': reminderHistory,
      'isTemplate': isTemplate,
      'templateId': templateId,
      'locationDetails': locationDetails,
      'weatherDependency': weatherDependency,
      'costs': costs,
      'relatedReminders': relatedReminders,
      'compliance': compliance,
      'escalation': escalation,
      'requiresPhoto': requiresPhoto,
      'requiresNote': requiresNote,
      'alternativeSchedules': alternativeSchedules,
      'metrics': metrics,
    };
  }

  factory PetReminder.fromJson(Map<String, dynamic> json) {
    return PetReminder(
      // Existing fields...
      category: json['category'] ?? 'general',
      schedule: Map<String, dynamic>.from(json['schedule'] ?? {}),
      attachments: List<String>.from(json['attachments'] ?? []),
      linkedRecords: Map<String, dynamic>.from(json['linkedRecords'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
      completionRequirements: 
          Map<String, dynamic>.from(json['completionRequirements'] ?? {}),
      dependencies: List<String>.from(json['dependencies'] ?? []),
      progressTracking: Map<String, dynamic>.from(json['progressTracking'] ?? {}),
      requiresVerification: json['requiresVerification'] ?? false,
      verificationDetails: json['verificationDetails'],
      skipDates: List<String>.from(json['skipDates'] ?? []),
      customNotifications: 
          Map<String, dynamic>.from(json['customNotifications'] ?? {}),
      reminderHistory: Map<String, dynamic>.from(json['reminderHistory'] ?? {}),
      isTemplate: json['isTemplate'] ?? false,
      templateId: json['templateId'],
      locationDetails: Map<String, dynamic>.from(json['locationDetails'] ?? {}),
      weatherDependency: Map<String, dynamic>.from(json['weatherDependency'] ?? {}),
      costs: Map<String, dynamic>.from(json['costs'] ?? {}),
      relatedReminders: List<String>.from(json['relatedReminders'] ?? []),
      compliance: Map<String, dynamic>.from(json['compliance'] ?? {}),
      escalation: Map<String, dynamic>.from(json['escalation'] ?? {}),
      requiresPhoto: json['requiresPhoto'] ?? false,
      requiresNote: json['requiresNote'] ?? false,
      alternativeSchedules: List<String>.from(json['alternativeSchedules'] ?? []),
      metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
    );
  }

  // Additional helper methods
  bool canComplete() {
    if (completionRequirements.isEmpty) return true;
    return completionRequirements.entries
        .every((requirement) => requirement.value['met'] == true);
  }

  bool isBlocked() {
    return dependencies.isNotEmpty && 
           dependencies.any((depId) => 
               !reminderHistory[depId]?['completed'] ?? true);
  }

  bool shouldSkip() {
    return skipDates.contains(dueDate.toIso8601String()) ||
           (weatherDependency.isNotEmpty && 
            !_isWeatherSuitable(weatherDependency));
  }

  bool needsEscalation() {
    if (escalation.isEmpty) return false;
    final threshold = Duration(
        hours: escalation['thresholdHours'] ?? 24);
    return isOverdue() && 
           DateTime.now().difference(dueDate) > threshold;
  }

  bool isCompliant() {
    if (compliance.isEmpty) return true;
    final completionRate = compliance['completionRate'] ?? 0.0;
    final threshold = compliance['threshold'] ?? 0.8;
    return completionRate >= threshold;
  }

  List<DateTime> getAlternativeSchedule() {
    if (alternativeSchedules.isEmpty) return [];
    return alternativeSchedules
        .map((dateStr) => DateTime.parse(dateStr))
        .where((date) => date.isAfter(DateTime.now()))
        .toList();
  }

  Map<String, dynamic> getMetrics() {
    return {
      'completionRate': _calculateCompletionRate(),
      'averageDelay': _calculateAverageDelay(),
      'complianceScore': _calculateComplianceScore(),
    };
  }

  bool _isWeatherSuitable(Map<String, dynamic> conditions) {
    // Implementation depends on weather service integration
    return true;
  }

  double _calculateCompletionRate() {
    if (reminderHistory.isEmpty) return 1.0;
    final completed = reminderHistory.values
        .where((history) => history['completed'] == true)
        .length;
    return completed / reminderHistory.length;
  }

  Duration _calculateAverageDelay() {
    if (reminderHistory.isEmpty) return Duration.zero;
    final delays = reminderHistory.values
        .map((history) => DateTime.parse(history['completedAt'])
            .difference(DateTime.parse(history['dueDate'])))
        .toList();
    final totalDelay = delays.fold(
        Duration.zero, (prev, delay) => prev + delay);
    return Duration(
        microseconds: totalDelay.inMicroseconds ~/ delays.length);
  }

  double _calculateComplianceScore() {
    final completionRate = _calculateCompletionRate();
    final averageDelay = _calculateAverageDelay();
    final maxDelay = const Duration(days: 7);
    final delayFactor = 1 - (averageDelay.inHours / maxDelay.inHours);
    return (completionRate + delayFactor) / 2;
  }
}

// Existing enums remain the same...

enum ReminderCategory {
  health,
  care,
  training,
  social,
  administrative,
  other
}

enum CompletionStatus {
  pending,
  completed,
  verified,
  skipped,
  failed,
  blocked
}

enum WeatherCondition {
  any,
  sunny,
  cloudy,
  rainy,
  snowy,
  windy,
  extreme
}
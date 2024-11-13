// lib/models/reminder.dart

import 'package:flutter/foundation.dart';

class Reminder {
  final String id;
  final String petId;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime? completedDate;
  final ReminderType type;
  final ReminderPriority priority;
  final bool isRecurring;
  final RecurrencePattern recurrencePattern;
  final bool isCompleted;
  final String notes;
  final List<String> attachments;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final String? createdBy;
  final List<ReminderHistory> history;
  final Map<String, dynamic> metadata;
  final NotificationSettings notificationSettings;
  final CompletionRequirements completionRequirements;
  final List<String> tags;
  final String? linkedEntityId;
  final String? linkedEntityType;

  const Reminder({
    required this.id,
    required this.petId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.completedDate,
    required this.type,
    this.priority = ReminderPriority.medium,
    this.isRecurring = false,
    this.recurrencePattern = const RecurrencePattern(),
    this.isCompleted = false,
    this.notes = '',
    this.attachments = const [],
    this.assignedTo,
    DateTime? createdAt,
    this.modifiedAt,
    this.createdBy,
    this.history = const [],
    this.metadata = const {},
    this.notificationSettings = const NotificationSettings(),
    this.completionRequirements = const CompletionRequirements(),
    this.tags = const [],
    this.linkedEntityId,
    this.linkedEntityType,
  }) : createdAt = createdAt ?? DateTime.now();

  // CopyWith method for immutability
  Reminder copyWith({
    String? id,
    String? petId,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? completedDate,
    ReminderType? type,
    ReminderPriority? priority,
    bool? isRecurring,
    RecurrencePattern? recurrencePattern,
    bool? isCompleted,
    String? notes,
    List<String>? attachments,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? createdBy,
    List<ReminderHistory>? history,
    Map<String, dynamic>? metadata,
    NotificationSettings? notificationSettings,
    CompletionRequirements? completionRequirements,
    List<String>? tags,
    String? linkedEntityId,
    String? linkedEntityType,
  }) {
    return Reminder(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      createdBy: createdBy ?? this.createdBy,
      history: history ?? this.history,
      metadata: metadata ?? this.metadata,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      completionRequirements: completionRequirements ?? this.completionRequirements,
      tags: tags ?? this.tags,
      linkedEntityId: linkedEntityId ?? this.linkedEntityId,
      linkedEntityType: linkedEntityType ?? this.linkedEntityType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'type': type.toString(),
      'priority': priority.toString(),
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern.toJson(),
      'isCompleted': isCompleted,
      'notes': notes,
      'attachments': attachments,
      'assignedTo': assignedTo,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
      'createdBy': createdBy,
      'history': history.map((h) => h.toJson()).toList(),
      'metadata': metadata,
      'notificationSettings': notificationSettings.toJson(),
      'completionRequirements': completionRequirements.toJson(),
      'tags': tags,
      'linkedEntityId': linkedEntityId,
      'linkedEntityType': linkedEntityType,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      petId: json['petId'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate']) 
          : null,
      type: ReminderType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ReminderType.other,
      ),
      priority: ReminderPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => ReminderPriority.medium,
      ),
      isRecurring: json['isRecurring'] ?? false,
      recurrencePattern: json['recurrencePattern'] != null
          ? RecurrencePattern.fromJson(json['recurrencePattern'])
          : const RecurrencePattern(),
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      assignedTo: json['assignedTo'],
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: json['modifiedAt'] != null 
          ? DateTime.parse(json['modifiedAt'])
          : null,
      createdBy: json['createdBy'],
      history: (json['history'] as List?)
          ?.map((h) => ReminderHistory.fromJson(h))
          .toList() ?? [],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      notificationSettings: json['notificationSettings'] != null
          ? NotificationSettings.fromJson(json['notificationSettings'])
          : const NotificationSettings(),
      completionRequirements: json['completionRequirements'] != null
          ? CompletionRequirements.fromJson(json['completionRequirements'])
          : const CompletionRequirements(),
      tags: List<String>.from(json['tags'] ?? []),
      linkedEntityId: json['linkedEntityId'],
      linkedEntityType: json['linkedEntityType'],
    );
  }

  // Helper methods
  bool get isOverdue => 
      !isCompleted && DateTime.now().isAfter(dueDate);

  bool get needsAction =>
      !isCompleted && dueDate.difference(DateTime.now()).inDays <= 7;

  DateTime? getNextOccurrence() {
    if (!isRecurring) return null;
    return recurrencePattern.calculateNextOccurrence(dueDate);
  }

  List<DateTime> getNextOccurrences({int count = 5}) {
    if (!isRecurring) return [];
    return recurrencePattern.calculateNextOccurrences(dueDate, count);
  }

  bool canComplete(String userId) {
    if (isCompleted) return false;
    if (assignedTo != null && assignedTo != userId) return false;
    return completionRequirements.checkRequirements(this);
  }
}
// Continuing lib/models/reminder.dart

enum ReminderType {
  medication,
  appointment,
  vaccination,
  grooming,
  exercise,
  feeding,
  training,
  socialization,
  measurement,
  other
}

enum ReminderPriority {
  low,
  medium,
  high,
  urgent
}

enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
  custom
}

class RecurrencePattern {
  final RecurrenceFrequency frequency;
  final int interval;
  final List<int> daysOfWeek;
  final int? dayOfMonth;
  final DateTime? endDate;
  final int? occurrences;
  final Map<String, dynamic> customPattern;

  const RecurrencePattern({
    this.frequency = RecurrenceFrequency.daily,
    this.interval = 1,
    this.daysOfWeek = const [],
    this.dayOfMonth,
    this.endDate,
    this.occurrences,
    this.customPattern = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency.toString(),
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'endDate': endDate?.toIso8601String(),
      'occurrences': occurrences,
      'customPattern': customPattern,
    };
  }

  factory RecurrencePattern.fromJson(Map<String, dynamic> json) {
    return RecurrencePattern(
      frequency: RecurrenceFrequency.values.firstWhere(
        (e) => e.toString() == json['frequency'],
        orElse: () => RecurrenceFrequency.daily,
      ),
      interval: json['interval'] ?? 1,
      daysOfWeek: List<int>.from(json['daysOfWeek'] ?? []),
      dayOfMonth: json['dayOfMonth'],
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'])
          : null,
      occurrences: json['occurrences'],
      customPattern: Map<String, dynamic>.from(json['customPattern'] ?? {}),
    );
  }

  DateTime calculateNextOccurrence(DateTime from) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return from.add(Duration(days: interval));
      case RecurrenceFrequency.weekly:
        return from.add(Duration(days: 7 * interval));
      case RecurrenceFrequency.monthly:
        return DateTime(
          from.year,
          from.month + interval,
          dayOfMonth ?? from.day,
        );
      case RecurrenceFrequency.yearly:
        return DateTime(
          from.year + interval,
          from.month,
          from.day,
        );
      case RecurrenceFrequency.custom:
        // Implement custom recurrence logic
        return from;
    }
  }

  List<DateTime> calculateNextOccurrences(DateTime from, int count) {
    final occurrences = <DateTime>[];
    var current = from;
    
    for (var i = 0; i < count; i++) {
      current = calculateNextOccurrence(current);
      if (endDate != null && current.isAfter(endDate!)) break;
      occurrences.add(current);
    }
    
    return occurrences;
  }
}

class NotificationSettings {
  final bool enabled;
  final List<Duration> reminders;
  final bool emailEnabled;
  final bool pushEnabled;
  final bool smsEnabled;
  final Map<String, dynamic> customSettings;

  const NotificationSettings({
    this.enabled = true,
    this.reminders = const [
      Duration(days: 1),
      Duration(hours: 1),
    ],
    this.emailEnabled = false,
    this.pushEnabled = true,
    this.smsEnabled = false,
    this.customSettings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'reminders': reminders.map((d) => d.inMinutes).toList(),
      'emailEnabled': emailEnabled,
      'pushEnabled': pushEnabled,
      'smsEnabled': smsEnabled,
      'customSettings': customSettings,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] ?? true,
      reminders: (json['reminders'] as List?)
          ?.map((m) => Duration(minutes: m))
          .toList() ?? const [
        Duration(days: 1),
        Duration(hours: 1),
      ],
      emailEnabled: json['emailEnabled'] ?? false,
      pushEnabled: json['pushEnabled'] ?? true,
      smsEnabled: json['smsEnabled'] ?? false,
      customSettings: Map<String, dynamic>.from(json['customSettings'] ?? {}),
    );
  }

  List<DateTime> getNotificationTimes(DateTime dueDate) {
    return reminders
        .map((duration) => dueDate.subtract(duration))
        .where((date) => date.isAfter(DateTime.now()))
        .toList()
      ..sort();
  }
}

class CompletionRequirements {
  final bool requiresPhoto;
  final bool requiresNote;
  final bool requiresSignature;
  final bool requiresGeoLocation;
  final List<String> requiredFields;
  final Map<String, dynamic> customRequirements;

  const CompletionRequirements({
    this.requiresPhoto = false,
    this.requiresNote = false,
    this.requiresSignature = false,
    this.requiresGeoLocation = false,
    this.requiredFields = const [],
    this.customRequirements = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'requiresPhoto': requiresPhoto,
      'requiresNote': requiresNote,
      'requiresSignature': requiresSignature,
      'requiresGeoLocation': requiresGeoLocation,
      'requiredFields': requiredFields,
      'customRequirements': customRequirements,
    };
  }

  factory CompletionRequirements.fromJson(Map<String, dynamic> json) {
    return CompletionRequirements(
      requiresPhoto: json['requiresPhoto'] ?? false,
      requiresNote: json['requiresNote'] ?? false,
      requiresSignature: json['requiresSignature'] ?? false,
      requiresGeoLocation: json['requiresGeoLocation'] ?? false,
      requiredFields: List<String>.from(json['requiredFields'] ?? []),
      customRequirements: Map<String, dynamic>.from(json['customRequirements'] ?? {}),
    );
  }

  bool checkRequirements(Reminder reminder) {
    // Implement requirement checking logic
    return true;
  }
}

class ReminderHistory {
  final DateTime timestamp;
  final String action;
  final String? userId;
  final Map<String, dynamic> changes;
  final String? notes;

  const ReminderHistory({
    required this.timestamp,
    required this.action,
    this.userId,
    this.changes = const {},
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'userId': userId,
      'changes': changes,
      'notes': notes,
    };
  }

  factory ReminderHistory.fromJson(Map<String, dynamic> json) {
    return ReminderHistory(
      timestamp: DateTime.parse(json['timestamp']),
      action: json['action'],
      userId: json['userId'],
      changes: Map<String, dynamic>.from(json['changes'] ?? {}),
      notes: json['notes'],
    );
  }
}

// Utility class for reminder management
class ReminderUtils {
  static List<Reminder> filterByStatus(List<Reminder> reminders, {
    bool? isCompleted,
    bool? isOverdue,
    bool? needsAction,
  }) {
    return reminders.where((reminder) {
      if (isCompleted != null && reminder.isCompleted != isCompleted) {
        return false;
      }
      if (isOverdue != null && reminder.isOverdue != isOverdue) {
        return false;
      }
      if (needsAction != null && reminder.needsAction != needsAction) {
        return false;
      }
      return true;
    }).toList();
  }

  static List<Reminder> sortByPriority(List<Reminder> reminders) {
    return [...reminders]..sort((a, b) {
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;
      return a.dueDate.compareTo(b.dueDate);
    });
  }

  static Map<DateTime, List<Reminder>> groupByDate(List<Reminder> reminders) {
    final grouped = <DateTime, List<Reminder>>{};
    for (final reminder in reminders) {
      final date = DateTime(
        reminder.dueDate.year,
        reminder.dueDate.month,
        reminder.dueDate.day,
      );
      grouped.putIfAbsent(date, () => []).add(reminder);
    }
    return grouped;
  }
}
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetReminder {
  final String id;
  final String petId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String type;
  final bool isRecurring;
  final String? frequency;
  final bool isCompleted;
  final String? notes;
  final int priority;
  final List<String> tags;
  // Enhanced fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final Map<String, dynamic>? metadata;
  final DateTime? lastCompleted;
  final Map<String, dynamic>? recurringDetails;
  final List<String>? attachments;
  final Map<String, dynamic>? notificationSettings;
  final List<String>? assignedTo;
  final ReminderStatus status;
  final Map<String, dynamic>? completionHistory;
  final String? category;
  final Map<String, dynamic>? customFields;
  final bool requiresVerification;

  PetReminder({
    required this.id,
    required this.petId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.type,
    this.isRecurring = false,
    this.frequency,
    this.isCompleted = false,
    this.notes,
    this.priority = 1,
    this.tags = const [],
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.metadata,
    this.lastCompleted,
    this.recurringDetails,
    this.attachments,
    this.notificationSettings,
    this.assignedTo,
    this.status = ReminderStatus.pending,
    this.completionHistory,
    this.category,
    this.customFields,
    this.requiresVerification = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'type': type,
      'isRecurring': isRecurring,
      'frequency': frequency,
      'isCompleted': isCompleted,
      'notes': notes,
      'priority': priority,
      'tags': tags,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'metadata': metadata,
      'lastCompleted': lastCompleted?.toIso8601String(),
      'recurringDetails': recurringDetails,
      'attachments': attachments,
      'notificationSettings': notificationSettings,
      'assignedTo': assignedTo,
      'status': status.toString(),
      'completionHistory': completionHistory,
      'category': category,
      'customFields': customFields,
      'requiresVerification': requiresVerification,
    };
  }

  factory PetReminder.fromJson(Map<String, dynamic> json) {
    return PetReminder(
      id: json['id'],
      petId: json['petId'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      type: json['type'],
      isRecurring: json['isRecurring'] ?? false,
      frequency: json['frequency'],
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'],
      priority: json['priority'] ?? 1,
      tags: List<String>.from(json['tags'] ?? []),
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      metadata: json['metadata'],
      lastCompleted: json['lastCompleted'] != null 
          ? DateTime.parse(json['lastCompleted'])
          : null,
      recurringDetails: json['recurringDetails'],
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : null,
      notificationSettings: json['notificationSettings'],
      assignedTo: json['assignedTo'] != null 
          ? List<String>.from(json['assignedTo'])
          : null,
      status: ReminderStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ReminderStatus.pending,
      ),
      completionHistory: json['completionHistory'],
      category: json['category'],
      customFields: json['customFields'],
      requiresVerification: json['requiresVerification'] ?? false,
    );
  }

  bool isOverdue() => 
      !isCompleted && dueDate.isBefore(DateTime.now());

  bool isDueSoon() {
    final now = DateTime.now();
    return !isCompleted && 
           dueDate.isAfter(now) && 
           dueDate.isBefore(now.add(const Duration(days: 1)));
  }

  DateTime? getNextDueDate() {
    if (!isRecurring || frequency == null) return null;
    
    final lastDate = lastCompleted ?? dueDate;
    switch (frequency) {
      case 'daily':
        return lastDate.add(const Duration(days: 1));
      case 'weekly':
        return lastDate.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(lastDate.year, lastDate.month + 1, lastDate.day);
      case 'yearly':
        return DateTime(lastDate.year + 1, lastDate.month, lastDate.day);
      default:
        return null;
    }
  }

  bool hasTag(String tag) => tags.contains(tag.toLowerCase());

  bool isAssignedTo(String userId) => 
      assignedTo?.contains(userId) ?? false;

  bool canEdit(String userId) => createdBy == userId || !isPremium;

  String getPriorityLabel() {
    if (priority >= 4) return 'High';
    if (priority >= 2) return 'Medium';
    return 'Low';
  }

  Map<String, dynamic> getNotificationConfig() {
    if (notificationSettings == null) return {};
    
    return {
      'enabled': notificationSettings!['enabled'] ?? true,
      'advance': notificationSettings!['advance'] ?? 30,
      'repeat': notificationSettings!['repeat'] ?? false,
      'channels': notificationSettings!['channels'] ?? ['app'],
    };
  }

  List<Map<String, dynamic>> getCompletionHistoryList() {
    if (completionHistory == null) return [];
    
    return completionHistory!.entries.map((entry) {
      final completion = entry.value as Map<String, dynamic>;
      return {
        'date': DateTime.parse(entry.key),
        'completedBy': completion['completedBy'],
        'notes': completion['notes'],
        'verified': completion['verified'] ?? false,
      };
    }).toList()
      ..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
  }

  bool requiresAttention() =>
      isOverdue() || 
      (priority >= 3 && !isCompleted) || 
      (requiresVerification && status == ReminderStatus.completed && !isCompleted);

  double getCompletionRate() {
    if (!isRecurring || completionHistory == null) return isCompleted ? 1.0 : 0.0;
    
    final totalDue = recurringDetails?['totalOccurrences'] ?? 0;
    if (totalDue == 0) return 0.0;
    
    return completionHistory!.length / totalDue;
  }
}

enum ReminderStatus {
  pending,
  inProgress,
  completed,
  skipped,
  cancelled,
  needsVerification
}

extension ReminderStatusExtension on ReminderStatus {
  String get displayName {
    switch (this) {
      case ReminderStatus.pending: return 'Pending';
      case ReminderStatus.inProgress: return 'In Progress';
      case ReminderStatus.completed: return 'Completed';
      case ReminderStatus.skipped: return 'Skipped';
      case ReminderStatus.cancelled: return 'Cancelled';
      case ReminderStatus.needsVerification: return 'Needs Verification';
    }
  }

  bool get isActive => 
      this == ReminderStatus.pending || 
      this == ReminderStatus.inProgress || 
      this == ReminderStatus.needsVerification;
}

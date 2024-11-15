// lib/models/appointment.dart

import 'package:flutter/foundation.dart';

class Appointment {
  final String id;
  final String petId;
  final DateTime date;
  final String type;
  final String vetName;
  final String clinicName;
  final String purpose;
  final bool isRoutineCheckup;
  final String notes;
  final bool completed;
  final List<String> medications;
  final List<String> vaccinations;
  // New premium features
  final String? vetId;  // Links to CareTeamMember
  final List<String> sharedWith;  // Care team members who can view this
  final Map<String, dynamic>? diagnosis;
  final List<String>? attachments;  // Document IDs
  final double? cost;
  final String? insuranceClaim;
  final AppointmentStatus status;
  final DateTime? reminderTime;
  final List<String>? followUpActions;
  final Map<String, dynamic>? vitals;
  final String? cancelReason;
  final DateTime? completedAt;
  final String? completedBy;

  Appointment({
    required this.id,
    required this.petId,
    required this.date,
    required this.type,
    required this.vetName,
    required this.clinicName,
    required this.purpose,
    this.isRoutineCheckup = true,
    this.notes = '',
    this.completed = false,
    this.medications = const [],
    this.vaccinations = const [],
    // New premium features
    this.vetId,
    this.sharedWith = const [],
    this.diagnosis,
    this.attachments,
    this.cost,
    this.insuranceClaim,
    this.status = AppointmentStatus.scheduled,
    this.reminderTime,
    this.followUpActions,
    this.vitals,
    this.cancelReason,
    this.completedAt,
    this.completedBy,
  });

  Appointment copyWith({
    String? id,
    String? petId,
    DateTime? date,
    String? type,
    String? vetName,
    String? clinicName,
    String? purpose,
    bool? isRoutineCheckup,
    String? notes,
    bool? completed,
    List<String>? medications,
    List<String>? vaccinations,
    // New premium features
    String? vetId,
    List<String>? sharedWith,
    Map<String, dynamic>? diagnosis,
    List<String>? attachments,
    double? cost,
    String? insuranceClaim,
    AppointmentStatus? status,
    DateTime? reminderTime,
    List<String>? followUpActions,
    Map<String, dynamic>? vitals,
    String? cancelReason,
    DateTime? completedAt,
    String? completedBy,
  }) {
    return Appointment(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      date: date ?? this.date,
      type: type ?? this.type,
      vetName: vetName ?? this.vetName,
      clinicName: clinicName ?? this.clinicName,
      purpose: purpose ?? this.purpose,
      isRoutineCheckup: isRoutineCheckup ?? this.isRoutineCheckup,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
      medications: medications ?? this.medications,
      vaccinations: vaccinations ?? this.vaccinations,
      // New premium features
      vetId: vetId ?? this.vetId,
      sharedWith: sharedWith ?? this.sharedWith,
      diagnosis: diagnosis ?? this.diagnosis,
      attachments: attachments ?? this.attachments,
      cost: cost ?? this.cost,
      insuranceClaim: insuranceClaim ?? this.insuranceClaim,
      status: status ?? this.status,
      reminderTime: reminderTime ?? this.reminderTime,
      followUpActions: followUpActions ?? this.followUpActions,
      vitals: vitals ?? this.vitals,
      cancelReason: cancelReason ?? this.cancelReason,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'date': date.toIso8601String(),
      'type': type,
      'vetName': vetName,
      'clinicName': clinicName,
      'purpose': purpose,
      'isRoutineCheckup': isRoutineCheckup,
      'notes': notes,
      'completed': completed,
      'medications': medications,
      'vaccinations': vaccinations,
      // New premium features
      'vetId': vetId,
      'sharedWith': sharedWith,
      'diagnosis': diagnosis,
      'attachments': attachments,
      'cost': cost,
      'insuranceClaim': insuranceClaim,
      'status': status.toString(),
      'reminderTime': reminderTime?.toIso8601String(),
      'followUpActions': followUpActions,
      'vitals': vitals,
      'cancelReason': cancelReason,
      'completedAt': completedAt?.toIso8601String(),
      'completedBy': completedBy,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      petId: json['petId'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      vetName: json['vetName'],
      clinicName: json['clinicName'],
      purpose: json['purpose'],
      isRoutineCheckup: json['isRoutineCheckup'],
      notes: json['notes'],
      completed: json['completed'],
      medications: List<String>.from(json['medications'] ?? []),
      vaccinations: List<String>.from(json['vaccinations'] ?? []),
      // New premium features
      vetId: json['vetId'],
      sharedWith: List<String>.from(json['sharedWith'] ?? []),
      diagnosis: json['diagnosis'],
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments']) 
          : null,
      cost: json['cost']?.toDouble(),
      insuranceClaim: json['insuranceClaim'],
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      reminderTime: json['reminderTime'] != null 
          ? DateTime.parse(json['reminderTime']) 
          : null,
      followUpActions: json['followUpActions'] != null 
          ? List<String>.from(json['followUpActions']) 
          : null,
      vitals: json['vitals'],
      cancelReason: json['cancelReason'],
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      completedBy: json['completedBy'],
    );
  }

  // Helper methods
  bool isUpcoming() {
    return date.isAfter(DateTime.now());
  }

  bool isOverdue() {
    return !completed && date.isBefore(DateTime.now());
  }

  String getFormattedCost() {
    if (cost == null) return 'N/A';
    return '\$${cost!.toStringAsFixed(2)}';
  }

  bool canEdit(String userId) {
    return sharedWith.contains(userId) || completedBy == userId;
  }
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow,
  rescheduled
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get displayName {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
    }
  }

  String get color {
    switch (this) {
      case AppointmentStatus.scheduled:
        return '#FFA500'; // Orange
      case AppointmentStatus.confirmed:
        return '#4CAF50'; // Green
      case AppointmentStatus.inProgress:
        return '#2196F3'; // Blue
      case AppointmentStatus.completed:
        return '#4CAF50'; // Green
      case AppointmentStatus.cancelled:
        return '#F44336'; // Red
      case AppointmentStatus.noShow:
        return '#F44336'; // Red
      case AppointmentStatus.rescheduled:
        return '#FF9800'; // Orange
    }
  }
}
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VetAppointment {
  final String id;
  final String petId;
  final DateTime dateTime;
  final String type;
  final String veterinarianId;
  final String clinicId;
  final String reason;
  final String? notes;
  final bool isConfirmed;
  final List<String> services;
  final double? estimatedCost;
  // Enhanced fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final Map<String, dynamic>? metadata;
  final List<String>? attachments;
  final Map<String, dynamic>? diagnosis;
  final List<String>? prescriptions;
  final Map<String, dynamic>? vitals;
  final Map<String, dynamic>? followUp;
  final List<String>? vaccinations;
  final Map<String, dynamic>? procedures;
  final Map<String, dynamic>? billing;
  final AppointmentStatus status;
  final Map<String, dynamic>? reminders;
  final Map<String, dynamic>? history;

  VetAppointment({
    required this.id,
    required this.petId,
    required this.dateTime,
    required this.type,
    required this.veterinarianId,
    required this.clinicId,
    required this.reason,
    this.notes,
    this.isConfirmed = false,
    this.services = const [],
    this.estimatedCost,
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.metadata,
    this.attachments,
    this.diagnosis,
    this.prescriptions,
    this.vitals,
    this.followUp,
    this.vaccinations,
    this.procedures,
    this.billing,
    this.status = AppointmentStatus.scheduled,
    this.reminders,
    this.history,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'dateTime': dateTime.toIso8601String(),
      'type': type,
      'veterinarianId': veterinarianId,
      'clinicId': clinicId,
      'reason': reason,
      'notes': notes,
      'isConfirmed': isConfirmed,
      'services': services,
      'estimatedCost': estimatedCost,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'metadata': metadata,
      'attachments': attachments,
      'diagnosis': diagnosis,
      'prescriptions': prescriptions,
      'vitals': vitals,
      'followUp': followUp,
      'vaccinations': vaccinations,
      'procedures': procedures,
      'billing': billing,
      'status': status.toString(),
      'reminders': reminders,
      'history': history,
    };
  }

  factory VetAppointment.fromJson(Map<String, dynamic> json) {
    return VetAppointment(
      id: json['id'],
      petId: json['petId'],
      dateTime: DateTime.parse(json['dateTime']),
      type: json['type'],
      veterinarianId: json['veterinarianId'],
      clinicId: json['clinicId'],
      reason: json['reason'],
      notes: json['notes'],
      isConfirmed: json['isConfirmed'] ?? false,
      services: List<String>.from(json['services'] ?? []),
      estimatedCost: json['estimatedCost']?.toDouble(),
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      metadata: json['metadata'],
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : null,
      diagnosis: json['diagnosis'],
      prescriptions: json['prescriptions'] != null 
          ? List<String>.from(json['prescriptions'])
          : null,
      vitals: json['vitals'],
      followUp: json['followUp'],
      vaccinations: json['vaccinations'] != null 
          ? List<String>.from(json['vaccinations'])
          : null,
      procedures: json['procedures'],
      billing: json['billing'],
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      reminders: json['reminders'],
      history: json['history'],
    );
  }

  bool isUpcoming() => 
      dateTime.isAfter(DateTime.now());

  bool isDueSoon() {
    final now = DateTime.now();
    return dateTime.isAfter(now) && 
           dateTime.isBefore(now.add(const Duration(hours: 24)));
  }

  bool hasService(String service) => 
      services.contains(service);

  bool hasPrescription(String prescription) => 
      prescriptions?.contains(prescription) ?? false;

  bool hasVaccination(String vaccination) => 
      vaccinations?.contains(vaccination) ?? false;

  bool canEdit(String userId) => 
      createdBy == userId || !isPremium;

  bool get isCompleted => 
      status == AppointmentStatus.completed;

  Map<String, dynamic> getDiagnosisDetails() {
    if (diagnosis == null) return {};
    
    return {
      'condition': diagnosis!['condition'],
      'notes': diagnosis!['notes'],
      'severity': diagnosis!['severity'],
      'treatment': diagnosis!['treatment'],
      'prognosis': diagnosis!['prognosis'],
    };
  }

  Map<String, dynamic> getVitalsRecord() {
    if (vitals == null) return {};
    
    return {
      'temperature': vitals!['temperature'],
      'heartRate': vitals!['heartRate'],
      'weight': vitals!['weight'],
      'bloodPressure': vitals!['bloodPressure'],
      'respiratory': vitals!['respiratory'],
    };
  }

  Map<String, dynamic> getFollowUpDetails() {
    if (followUp == null) return {};
    
    return {
      'recommended': followUp!['recommended'] ?? false,
      'date': followUp!['date'],
      'reason': followUp!['reason'],
      'instructions': followUp!['instructions'],
      'priority': followUp!['priority'] ?? 'normal',
    };
  }

  Map<String, dynamic> getProcedureDetails() {
    if (procedures == null) return {};
    
    return {
      'performed': procedures!['performed'] ?? [],
      'results': procedures!['results'] ?? {},
      'complications': procedures!['complications'],
      'aftercare': procedures!['aftercare'],
    };
  }

  Map<String, dynamic> getBillingDetails() {
    if (billing == null) return {};
    
    return {
      'total': billing!['total'] ?? estimatedCost,
      'paid': billing!['paid'] ?? false,
      'insurance': billing!['insurance'],
      'breakdown': billing!['breakdown'] ?? {},
      'paymentMethod': billing!['paymentMethod'],
    };
  }

  List<Map<String, dynamic>> getRemindersList() {
    if (reminders == null) return [];
    
    return reminders!.entries.map((entry) {
      return {
        'type': entry.key,
        'time': entry.value['time'],
        'message': entry.value['message'],
        'sent': entry.value['sent'] ?? false,
      };
    }).toList();
  }

  List<Map<String, dynamic>> getAppointmentHistory() {
    if (history == null) return [];
    
    final entries = history!.entries.map((entry) {
      return {
        'date': DateTime.parse(entry.key),
        'action': entry.value['action'],
        'by': entry.value['by'],
        'notes': entry.value['notes'],
      };
    }).toList();
    
    entries.sort((a, b) => 
        (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return entries;
  }

  bool requiresAttention() =>
      !isConfirmed && 
      dateTime.difference(DateTime.now()).inDays <= 2;

  String getFormattedDateTime() {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
           '${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  double getTotalCost() {
    final billingDetails = getBillingDetails();
    return billingDetails['total'] ?? estimatedCost ?? 0.0;
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
      case AppointmentStatus.scheduled: return 'Scheduled';
      case AppointmentStatus.confirmed: return 'Confirmed';
      case AppointmentStatus.inProgress: return 'In Progress';
      case AppointmentStatus.completed: return 'Completed';
      case AppointmentStatus.cancelled: return 'Cancelled';
      case AppointmentStatus.noShow: return 'No Show';
      case AppointmentStatus.rescheduled: return 'Rescheduled';
    }
  }

  bool get isActive =>
      this == AppointmentStatus.scheduled || 
      this == AppointmentStatus.confirmed || 
      this == AppointmentStatus.inProgress;
}

enum AppointmentType {
  checkup,
  vaccination,
  surgery,
  dental,
  emergency,
  followUp,
  grooming,
  other
}

extension AppointmentTypeExtension on AppointmentType {
  String get displayName {
    switch (this) {
      case AppointmentType.checkup: return 'Check-up';
      case AppointmentType.vaccination: return 'Vaccination';
      case AppointmentType.surgery: return 'Surgery';
      case AppointmentType.dental: return 'Dental';
      case AppointmentType.emergency: return 'Emergency';
      case AppointmentType.followUp: return 'Follow-up';
      case AppointmentType.grooming: return 'Grooming';
      case AppointmentType.other: return 'Other';
    }
  }

  bool get isUrgent =>
      this == AppointmentType.emergency;
}

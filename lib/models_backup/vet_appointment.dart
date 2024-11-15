// lib/models/vet_appointment.dart

import 'package:flutter/foundation.dart';

class VetAppointment {
  final String id;
  final String petId;
  final String vetId;
  final DateTime appointmentDate;
  final String purpose;
  final AppointmentType type;
  final AppointmentStatus status;
  final String clinicName;
  final String clinicAddress;
  final String vetName;
  final double cost;
  final List<String> procedures;
  final List<String> prescriptions;
  final String notes;
  final bool requiresFollowUp;
  final DateTime? followUpDate;
  final List<String> attachments;
  // New fields
  final Duration duration;
  final bool isVirtual;
  final Map<String, dynamic> virtualMeetingDetails;
  final List<VitalSign> vitalSigns;
  final List<Diagnosis> diagnoses;
  final List<Treatment> treatments;
  final PaymentStatus paymentStatus;
  final InsuranceClaim? insuranceClaim;
  final List<AppointmentReminder> reminders;
  final Map<String, dynamic> metadata;
  final String? cancellationReason;
  final DateTime? checkinTime;
  final DateTime? checkoutTime;
  final List<AppointmentNote> appointmentNotes;

  VetAppointment({
    required this.id,
    required this.petId,
    required this.vetId,
    required this.appointmentDate,
    required this.purpose,
    required this.type,
    this.status = AppointmentStatus.scheduled,
    required this.clinicName,
    required this.clinicAddress,
    required this.vetName,
    this.cost = 0.0,
    this.procedures = const [],
    this.prescriptions = const [],
    this.notes = '',
    this.requiresFollowUp = false,
    this.followUpDate,
    this.attachments = const [],
    this.duration = const Duration(minutes: 30),
    this.isVirtual = false,
    this.virtualMeetingDetails = const {},
    this.vitalSigns = const [],
    this.diagnoses = const [],
    this.treatments = const [],
    this.paymentStatus = PaymentStatus.pending,
    this.insuranceClaim,
    this.reminders = const [],
    this.metadata = const {},
    this.cancellationReason,
    this.checkinTime,
    this.checkoutTime,
    this.appointmentNotes = const [],
  });

  bool get isUpcoming => 
      appointmentDate.isAfter(DateTime.now()) && 
      status != AppointmentStatus.cancelled;

  bool get isPastDue =>
      appointmentDate.isBefore(DateTime.now()) && 
      status == AppointmentStatus.scheduled;

  bool get needsFollowUpScheduling =>
      requiresFollowUp && followUpDate == null;

  Duration get appointmentDuration =>
      checkoutTime != null && checkinTime != null
          ? checkoutTime!.difference(checkinTime!)
          : duration;

  double get totalCost {
    double total = cost;
    for (var treatment in treatments) {
      total += treatment.cost;
    }
    return total;
  }

  Map<String, dynamic> toJson() {
    return {
      // Existing fields
      'id': id,
      'petId': petId,
      'vetId': vetId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'purpose': purpose,
      'type': type.toString(),
      'status': status.toString(),
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'vetName': vetName,
      'cost': cost,
      'procedures': procedures,
      'prescriptions': prescriptions,
      'notes': notes,
      'requiresFollowUp': requiresFollowUp,
      'followUpDate': followUpDate?.toIso8601String(),
      'attachments': attachments,
      // New fields
      'duration': duration.inMinutes,
      'isVirtual': isVirtual,
      'virtualMeetingDetails': virtualMeetingDetails,
      'vitalSigns': vitalSigns.map((v) => v.toJson()).toList(),
      'diagnoses': diagnoses.map((d) => d.toJson()).toList(),
      'treatments': treatments.map((t) => t.toJson()).toList(),
      'paymentStatus': paymentStatus.toString(),
      'insuranceClaim': insuranceClaim?.toJson(),
      'reminders': reminders.map((r) => r.toJson()).toList(),
      'metadata': metadata,
      'cancellationReason': cancellationReason,
      'checkinTime': checkinTime?.toIso8601String(),
      'checkoutTime': checkoutTime?.toIso8601String(),
      'appointmentNotes': appointmentNotes.map((n) => n.toJson()).toList(),
    };
  }

  factory VetAppointment.fromJson(Map<String, dynamic> json) {
    return VetAppointment(
      // Existing fields
      id: json['id'],
      petId: json['petId'],
      vetId: json['vetId'],
      appointmentDate: DateTime.parse(json['appointmentDate']),
      purpose: json['purpose'],
      type: AppointmentType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      clinicName: json['clinicName'],
      clinicAddress: json['clinicAddress'],
      vetName: json['vetName'],
      cost: json['cost'].toDouble(),
      procedures: List<String>.from(json['procedures'] ?? []),
      prescriptions: List<String>.from(json['prescriptions'] ?? []),
      notes: json['notes'] ?? '',
      requiresFollowUp: json['requiresFollowUp'] ?? false,
      followUpDate: json['followUpDate'] != null 
          ? DateTime.parse(json['followUpDate']) 
          : null,
      attachments: List<String>.from(json['attachments'] ?? []),
      // New fields
      duration: Duration(minutes: json['duration'] ?? 30),
      isVirtual: json['isVirtual'] ?? false,
      virtualMeetingDetails: 
          Map<String, dynamic>.from(json['virtualMeetingDetails'] ?? {}),
      vitalSigns: (json['vitalSigns'] as List?)
          ?.map((v) => VitalSign.fromJson(v))
          .toList() ?? [],
      diagnoses: (json['diagnoses'] as List?)
          ?.map((d) => Diagnosis.fromJson(d))
          .toList() ?? [],
      treatments: (json['treatments'] as List?)
          ?.map((t) => Treatment.fromJson(t))
          .toList() ?? [],
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      insuranceClaim: json['insuranceClaim'] != null
          ? InsuranceClaim.fromJson(json['insuranceClaim'])
          : null,
      reminders: (json['reminders'] as List?)
          ?.map((r) => AppointmentReminder.fromJson(r))
          .toList() ?? [],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      cancellationReason: json['cancellationReason'],
      checkinTime: json['checkinTime'] != null
          ? DateTime.parse(json['checkinTime'])
          : null,
      checkoutTime: json['checkoutTime'] != null
          ? DateTime.parse(json['checkoutTime'])
          : null,
      appointmentNotes: (json['appointmentNotes'] as List?)
          ?.map((n) => AppointmentNote.fromJson(n))
          .toList() ?? [],
    );
  }
}
// Continuing lib/models/vet_appointment.dart

enum AppointmentType {
  checkup,
  vaccination,
  surgery,
  dental,
  emergency,
  followUp,
  consultation,
  grooming,
  imaging,
  laboratory,
  therapy,
  other
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow,
  rescheduled,
  waitlisted
}

enum PaymentStatus {
  pending,
  paid,
  partiallyPaid,
  refunded,
  failed,
  insurancePending
}

class VitalSign {
  final String type;
  final double value;
  final String unit;
  final DateTime timestamp;
  final String? notes;
  final Map<String, dynamic> metadata;

  const VitalSign({
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.notes,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory VitalSign.fromJson(Map<String, dynamic> json) {
    return VitalSign(
      type: json['type'],
      value: json['value'].toDouble(),
      unit: json['unit'],
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class Diagnosis {
  final String code;
  final String name;
  final String description;
  final String type;
  final DateTime diagnosedDate;
  final String? prognosis;
  final List<String> differentials;
  final Map<String, dynamic> metadata;

  const Diagnosis({
    required this.code,
    required this.name,
    required this.description,
    required this.type,
    required this.diagnosedDate,
    this.prognosis,
    this.differentials = const [],
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'type': type,
      'diagnosedDate': diagnosedDate.toIso8601String(),
      'prognosis': prognosis,
      'differentials': differentials,
      'metadata': metadata,
    };
  }

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      code: json['code'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      diagnosedDate: DateTime.parse(json['diagnosedDate']),
      prognosis: json['prognosis'],
      differentials: List<String>.from(json['differentials'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class Treatment {
  final String name;
  final String description;
  final String type;
  final double cost;
  final DateTime administeredDate;
  final String? administrator;
  final List<String> medications;
  final Duration? duration;
  final Map<String, dynamic> metadata;

  const Treatment({
    required this.name,
    required this.description,
    required this.type,
    required this.cost,
    required this.administeredDate,
    this.administrator,
    this.medications = const [],
    this.duration,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'cost': cost,
      'administeredDate': administeredDate.toIso8601String(),
      'administrator': administrator,
      'medications': medications,
      'duration': duration?.inMinutes,
      'metadata': metadata,
    };
  }

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      name: json['name'],
      description: json['description'],
      type: json['type'],
      cost: json['cost'].toDouble(),
      administeredDate: DateTime.parse(json['administeredDate']),
      administrator: json['administrator'],
      medications: List<String>.from(json['medications'] ?? []),
      duration: json['duration'] != null 
          ? Duration(minutes: json['duration'])
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class InsuranceClaim {
  final String claimId;
  final String provider;
  final String policyNumber;
  final double claimAmount;
  final double? approvedAmount;
  final String status;
  final DateTime submissionDate;
  final DateTime? processedDate;
  final List<String> documents;
  final Map<String, dynamic> metadata;

  const InsuranceClaim({
    required this.claimId,
    required this.provider,
    required this.policyNumber,
    required this.claimAmount,
    this.approvedAmount,
    required this.status,
    required this.submissionDate,
    this.processedDate,
    this.documents = const [],
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'claimId': claimId,
      'provider': provider,
      'policyNumber': policyNumber,
      'claimAmount': claimAmount,
      'approvedAmount': approvedAmount,
      'status': status,
      'submissionDate': submissionDate.toIso8601String(),
      'processedDate': processedDate?.toIso8601String(),
      'documents': documents,
      'metadata': metadata,
    };
  }

  factory InsuranceClaim.fromJson(Map<String, dynamic> json) {
    return InsuranceClaim(
      claimId: json['claimId'],
      provider: json['provider'],
      policyNumber: json['policyNumber'],
      claimAmount: json['claimAmount'].toDouble(),
      approvedAmount: json['approvedAmount']?.toDouble(),
      status: json['status'],
      submissionDate: DateTime.parse(json['submissionDate']),
      processedDate: json['processedDate'] != null 
          ? DateTime.parse(json['processedDate'])
          : null,
      documents: List<String>.from(json['documents'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class AppointmentReminder {
  final String id;
  final DateTime reminderTime;
  final String type;
  final String message;
  final bool sent;
  final DateTime? sentTime;
  final String? recipientType;
  final Map<String, dynamic> metadata;

  const AppointmentReminder({
    required this.id,
    required this.reminderTime,
    required this.type,
    required this.message,
    this.sent = false,
    this.sentTime,
    this.recipientType,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reminderTime': reminderTime.toIso8601String(),
      'type': type,
      'message': message,
      'sent': sent,
      'sentTime': sentTime?.toIso8601String(),
      'recipientType': recipientType,
      'metadata': metadata,
    };
  }

  factory AppointmentReminder.fromJson(Map<String, dynamic> json) {
    return AppointmentReminder(
      id: json['id'],
      reminderTime: DateTime.parse(json['reminderTime']),
      type: json['type'],
      message: json['message'],
      sent: json['sent'] ?? false,
      sentTime: json['sentTime'] != null 
          ? DateTime.parse(json['sentTime'])
          : null,
      recipientType: json['recipientType'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class AppointmentNote {
  final String id;
  final String content;
  final String author;
  final DateTime timestamp;
  final bool isPrivate;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  const AppointmentNote({
    required this.id,
    required this.content,
    required this.author,
    required this.timestamp,
    this.isPrivate = false,
    this.tags = const [],
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author,
      'timestamp': timestamp.toIso8601String(),
      'isPrivate': isPrivate,
      'tags': tags,
      'metadata': metadata,
    };
  }

  factory AppointmentNote.fromJson(Map<String, dynamic> json) {
    return AppointmentNote(
      id: json['id'],
      content: json['content'],
      author: json['author'],
      timestamp: DateTime.parse(json['timestamp']),
      isPrivate: json['isPrivate'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}
// Continuing lib/models/vet_appointment.dart

class AppointmentUtils {
  // Appointment scheduling utilities
  static bool canSchedule(DateTime proposedTime, List<VetAppointment> existingAppointments) {
    final proposedEnd = proposedTime.add(const Duration(minutes: 30));
    
    return !existingAppointments.any((appointment) {
      final appointmentEnd = appointment.appointmentDate.add(appointment.duration);
      return (proposedTime.isBefore(appointmentEnd) && 
              proposedEnd.isAfter(appointment.appointmentDate));
    });
  }

  static List<DateTime> getAvailableSlots({
    required DateTime date,
    required List<VetAppointment> existingAppointments,
    Duration slotDuration = const Duration(minutes: 30),
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0),
    TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0),
  }) {
    final slots = <DateTime>[];
    var currentSlot = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    
    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    while (currentSlot.isBefore(endDateTime)) {
      if (canSchedule(currentSlot, existingAppointments)) {
        slots.add(currentSlot);
      }
      currentSlot = currentSlot.add(slotDuration);
    }

    return slots;
  }

  // Appointment analysis utilities
  static Map<String, dynamic> analyzeAppointments(List<VetAppointment> appointments) {
    final analysis = {
      'totalAppointments': appointments.length,
      'byStatus': _getStatusDistribution(appointments),
      'byType': _getTypeDistribution(appointments),
      'averageDuration': _calculateAverageDuration(appointments),
      'averageCost': _calculateAverageCost(appointments),
      'noShowRate': _calculateNoShowRate(appointments),
      'commonProcedures': _getCommonProcedures(appointments),
      'monthlyTrends': _getMonthlyTrends(appointments),
    };

    return analysis;
  }

  static Map<AppointmentStatus, int> _getStatusDistribution(
    List<VetAppointment> appointments
  ) {
    final distribution = <AppointmentStatus, int>{};
    for (var appointment in appointments) {
      distribution[appointment.status] = 
          (distribution[appointment.status] ?? 0) + 1;
    }
    return distribution;
  }

  static Map<AppointmentType, int> _getTypeDistribution(
    List<VetAppointment> appointments
  ) {
    final distribution = <AppointmentType, int>{};
    for (var appointment in appointments) {
      distribution[appointment.type] = 
          (distribution[appointment.type] ?? 0) + 1;
    }
    return distribution;
  }

  static Duration _calculateAverageDuration(List<VetAppointment> appointments) {
    if (appointments.isEmpty) return Duration.zero;
    
    final totalMinutes = appointments.fold<int>(
      0,
      (sum, appointment) => sum + appointment.duration.inMinutes,
    );
    return Duration(minutes: totalMinutes ~/ appointments.length);
  }

  static double _calculateAverageCost(List<VetAppointment> appointments) {
    if (appointments.isEmpty) return 0.0;
    
    final totalCost = appointments.fold<double>(
      0.0,
      (sum, appointment) => sum + appointment.totalCost,
    );
    return totalCost / appointments.length;
  }

  static double _calculateNoShowRate(List<VetAppointment> appointments) {
    if (appointments.isEmpty) return 0.0;
    
    final noShows = appointments
        .where((a) => a.status == AppointmentStatus.noShow)
        .length;
    return noShows / appointments.length;
  }

  static Map<String, int> _getCommonProcedures(List<VetAppointment> appointments) {
    final procedureCounts = <String, int>{};
    for (var appointment in appointments) {
      for (var procedure in appointment.procedures) {
        procedureCounts[procedure] = (procedureCounts[procedure] ?? 0) + 1;
      }
    }
    return procedureCounts;
  }

  static Map<String, List<VetAppointment>> _getMonthlyTrends(
    List<VetAppointment> appointments
  ) {
    final trends = <String, List<VetAppointment>>{};
    for (var appointment in appointments) {
      final monthKey = '${appointment.appointmentDate.year}-${appointment.appointmentDate.month.toString().padLeft(2, '0')}';
      if (!trends.containsKey(monthKey)) {
        trends[monthKey] = [];
      }
      trends[monthKey]!.add(appointment);
    }
    return trends;
  }
}

class AppointmentReminders {
  static List<AppointmentReminder> generateReminders(VetAppointment appointment) {
    final reminders = <AppointmentReminder>[];
    final now = DateTime.now();

    // 24 hours before
    reminders.add(AppointmentReminder(
      id: '${appointment.id}_24h',
      reminderTime: appointment.appointmentDate.subtract(const Duration(hours: 24)),
      type: 'email',
      message: _generateReminderMessage(appointment, '24 hours'),
    ));

    // 2 hours before
    reminders.add(AppointmentReminder(
      id: '${appointment.id}_2h',
      reminderTime: appointment.appointmentDate.subtract(const Duration(hours: 2)),
      type: 'sms',
      message: _generateReminderMessage(appointment, '2 hours'),
    ));

    // Filter out past reminders
    return reminders.where((reminder) => reminder.reminderTime.isAfter(now)).toList();
  }

  static String _generateReminderMessage(VetAppointment appointment, String timeframe) {
    return '''
    Reminder: Vet appointment in $timeframe
    Pet: ${appointment.petId}
    Clinic: ${appointment.clinicName}
    Date: ${_formatDateTime(appointment.appointmentDate)}
    Purpose: ${appointment.purpose}
    ''';
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class AppointmentReportGenerator {
  static Map<String, dynamic> generateSummaryReport(VetAppointment appointment) {
    return {
      'appointmentDetails': {
        'id': appointment.id,
        'date': appointment.appointmentDate.toIso8601String(),
        'type': appointment.type.toString(),
        'status': appointment.status.toString(),
        'duration': appointment.duration.inMinutes,
        'isVirtual': appointment.isVirtual,
      },
      'clinicDetails': {
        'name': appointment.clinicName,
        'address': appointment.clinicAddress,
        'veterinarian': appointment.vetName,
      },
      'medicalDetails': {
        'purpose': appointment.purpose,
        'procedures': appointment.procedures,
        'prescriptions': appointment.prescriptions,
        'diagnoses': appointment.diagnoses.map((d) => d.toJson()).toList(),
        'treatments': appointment.treatments.map((t) => t.toJson()).toList(),
        'vitalSigns': appointment.vitalSigns.map((v) => v.toJson()).toList(),
      },
      'financialDetails': {
        'cost': appointment.totalCost,
        'paymentStatus': appointment.paymentStatus.toString(),
        'insuranceClaim': appointment.insuranceClaim?.toJson(),
      },
      'followUp': {
        'required': appointment.requiresFollowUp,
        'date': appointment.followUpDate?.toIso8601String(),
      },
      'attachments': appointment.attachments,
      'notes': appointment.appointmentNotes.map((n) => n.toJson()).toList(),
    };
  }
}
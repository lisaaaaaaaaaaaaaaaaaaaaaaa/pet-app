
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
  final String? vetId;
  final List<String> sharedWith;
  final Map<String, dynamic>? diagnosis;
  final List<String>? attachments;
  final double? cost;
  final String? insuranceClaim;
  final AppointmentStatus status;
  final DateTime? reminderTime;
  final List<String>? followUpActions;
  final Map<String, dynamic>? vitals;
  final String? cancelReason;
  final DateTime? completedAt;
  final String? completedBy;
  final bool isPremium;

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
    this.isPremium = false,
  });

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
      'isPremium': isPremium,
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
      isRoutineCheckup: json['isRoutineCheckup'] ?? true,
      notes: json['notes'] ?? '',
      completed: json['completed'] ?? false,
      medications: List<String>.from(json['medications'] ?? []),
      vaccinations: List<String>.from(json['vaccinations'] ?? []),
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
      isPremium: json['isPremium'] ?? false,
    );
  }

  bool isUpcoming() => date.isAfter(DateTime.now());
  bool isOverdue() => !completed && date.isBefore(DateTime.now());
  String getFormattedCost() => cost == null ? 'N/A' : '\$${cost!.toStringAsFixed(2)}';
  bool canEdit(String userId) => sharedWith.contains(userId) || completedBy == userId;
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

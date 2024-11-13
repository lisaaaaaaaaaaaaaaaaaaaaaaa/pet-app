import 'package:flutter/foundation.dart';

class Activity {
  final String id;
  final String petId;
  final String type;
  final DateTime date;
  final int durationMinutes;
  final String description;
  final ActivityIntensity intensity;
  final bool completed;
  final String notes;

  Activity({
    required this.id,
    required this.petId,
    required this.type,
    required this.date,
    required this.durationMinutes,
    required this.description,
    this.intensity = ActivityIntensity.moderate,
    this.completed = false,
    this.notes = '',
  });

  // Create a copy of the activity with some fields updated
  Activity copyWith({
    String? id,
    String? petId,
    String? type,
    DateTime? date,
    int? durationMinutes,
    String? description,
    ActivityIntensity? intensity,
    bool? completed,
    String? notes,
  }) {
    return Activity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
      intensity: intensity ?? this.intensity,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
  }

  // Convert activity to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'type': type,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'description': description,
      'intensity': intensity.toString(),
      'completed': completed,
      'notes': notes,
    };
  }

  // Create activity from JSON format
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      petId: json['petId'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      durationMinutes: json['durationMinutes'],
      description: json['description'],
      intensity: ActivityIntensity.values.firstWhere(
        (e) => e.toString() == json['intensity'],
        orElse: () => ActivityIntensity.moderate,
      ),
      completed: json['completed'],
      notes: json['notes'],
    );
  }
}

enum ActivityIntensity {
  light,
  moderate,
  vigorous
}
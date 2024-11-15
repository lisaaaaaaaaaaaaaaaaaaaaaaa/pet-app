import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String? createdBy;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  final List<String>? attachments;
  final ActivityStats? stats;
  final bool isPremium;

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
    this.createdBy,
    DateTime? createdAt,
    this.metadata,
    this.attachments,
    this.stats,
    this.isPremium = false,
  }) : this.createdAt = createdAt ?? DateTime.now();

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
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
      'attachments': attachments,
      'stats': stats?.toJson(),
      'isPremium': isPremium,
    };
  }

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
      completed: json['completed'] ?? false,
      notes: json['notes'] ?? '',
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      metadata: json['metadata'],
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments'])
          : null,
      stats: json['stats'] != null 
          ? ActivityStats.fromJson(json['stats'])
          : null,
      isPremium: json['isPremium'] ?? false,
    );
  }

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
    String? createdBy,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    List<String>? attachments,
    ActivityStats? stats,
    bool? isPremium,
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
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      attachments: attachments ?? this.attachments,
      stats: stats ?? this.stats,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  bool canEdit(String userId) => createdBy == userId || !isPremium;
  Duration get duration => Duration(minutes: durationMinutes);
  bool get isRecent => date.isAfter(DateTime.now().subtract(const Duration(days: 7)));
}

class ActivityStats {
  final double? distance;
  final int? steps;
  final int? calories;

  ActivityStats({this.distance, this.steps, this.calories});

  Map<String, dynamic> toJson() => {
    'distance': distance,
    'steps': steps,
    'calories': calories,
  };

  factory ActivityStats.fromJson(Map<String, dynamic> json) => ActivityStats(
    distance: json['distance']?.toDouble(),
    steps: json['steps'],
    calories: json['calories'],
  );
}

enum ActivityIntensity { light, moderate, vigorous }

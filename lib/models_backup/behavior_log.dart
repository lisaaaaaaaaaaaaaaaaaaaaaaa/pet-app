// lib/models/behavior_log.dart


class BehaviorLog {
  final String id;
  final String petId;
  final String behavior;
  final String context;
  final DateTime date;
  final String? trigger;
  final String? resolution;
  final List<String> interventions;
  final bool wasSuccessful;
  final Duration? duration;
  final BehaviorIntensity intensity;
  final List<String> symptoms;
  final String? notes;
  final String? location;

  BehaviorLog({
    required this.id,
    required this.petId,
    required this.behavior,
    required this.context,
    required this.date,
    this.trigger,
    this.resolution,
    this.interventions = const [],
    this.wasSuccessful = false,
    this.duration,
    this.intensity = BehaviorIntensity.moderate,
    this.symptoms = const [],
    this.notes,
    this.location,
  });

  BehaviorLog copyWith({
    String? id,
    String? petId,
    String? behavior,
    String? context,
    DateTime? date,
    String? trigger,
    String? resolution,
    List<String>? interventions,
    bool? wasSuccessful,
    Duration? duration,
    BehaviorIntensity? intensity,
    List<String>? symptoms,
    String? notes,
    String? location,
  }) {
    return BehaviorLog(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      behavior: behavior ?? this.behavior,
      context: context ?? this.context,
      date: date ?? this.date,
      trigger: trigger ?? this.trigger,
      resolution: resolution ?? this.resolution,
      interventions: interventions ?? this.interventions,
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
      duration: duration ?? this.duration,
      intensity: intensity ?? this.intensity,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'behavior': behavior,
      'context': context,
      'date': date.toIso8601String(),
      'trigger': trigger,
      'resolution': resolution,
      'interventions': interventions,
      'wasSuccessful': wasSuccessful,
      'duration': duration?.inMinutes,
      'intensity': intensity.toString(),
      'symptoms': symptoms,
      'notes': notes,
      'location': location,
    };
  }

  factory BehaviorLog.fromJson(Map<String, dynamic> json) {
    return BehaviorLog(
      id: json['id'],
      petId: json['petId'],
      behavior: json['behavior'],
      context: json['context'],
      date: DateTime.parse(json['date']),
      trigger: json['trigger'],
      resolution: json['resolution'],
      interventions: List<String>.from(json['interventions'] ?? []),
      wasSuccessful: json['wasSuccessful'] ?? false,
      duration: json['duration'] != null 
          ? Duration(minutes: json['duration']) 
          : null,
      intensity: BehaviorIntensity.values.firstWhere(
        (e) => e.toString() == json['intensity'],
        orElse: () => BehaviorIntensity.moderate,
      ),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      notes: json['notes'],
      location: json['location'],
    );
  }

  // Helper method to get duration in readable format
  String? getFormattedDuration() {
    if (duration == null) return null;
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    }
    return '$minutes min';
  }

  // Helper method to categorize behavior
  BehaviorCategory getBehaviorCategory() {
    final lowerBehavior = behavior.toLowerCase();
    if (lowerBehavior.contains('anxiety') || 
        lowerBehavior.contains('stress') ||
        lowerBehavior.contains('fear')) {
      return BehaviorCategory.anxiety;
    } else if (lowerBehavior.contains('aggression') || 
               lowerBehavior.contains('hostile')) {
      return BehaviorCategory.aggression;
    } else if (lowerBehavior.contains('eating') || 
               lowerBehavior.contains('food')) {
      return BehaviorCategory.eating;
    } else if (lowerBehavior.contains('elimination') || 
               lowerBehavior.contains('potty')) {
      return BehaviorCategory.elimination;
    }
    return BehaviorCategory.other;
  }
}

enum BehaviorIntensity {
  mild,
  moderate,
  severe
}

enum BehaviorCategory {
  anxiety,
  aggression,
  eating,
  elimination,
  social,
  grooming,
  vocalization,
  destructive,
  other
}

// Extension for behavior categories
extension BehaviorCategoryExtension on BehaviorCategory {
  String get displayName {
    switch (this) {
      case BehaviorCategory.anxiety:
        return 'Anxiety/Stress';
      case BehaviorCategory.aggression:
        return 'Aggression';
      case BehaviorCategory.eating:
        return 'Eating/Drinking';
      case BehaviorCategory.elimination:
        return 'Elimination';
      case BehaviorCategory.social:
        return 'Social Behavior';
      case BehaviorCategory.grooming:
        return 'Grooming';
      case BehaviorCategory.vocalization:
        return 'Vocalization';
      case BehaviorCategory.destructive:
        return 'Destructive Behavior';
      case BehaviorCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case BehaviorCategory.anxiety:
        return '😰';
      case BehaviorCategory.aggression:
        return '😠';
      case BehaviorCategory.eating:
        return '🍽';
      case BehaviorCategory.elimination:
        return '🚽';
      case BehaviorCategory.social:
        return '🤝';
      case BehaviorCategory.grooming:
        return '🛁';
      case BehaviorCategory.vocalization:
        return '🗣';
      case BehaviorCategory.destructive:
        return '💥';
      case BehaviorCategory.other:
        return '❓';
    }
  }
}
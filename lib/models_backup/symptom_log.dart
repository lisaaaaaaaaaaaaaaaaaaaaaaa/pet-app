// lib/models/symptom_log.dart

import 'package:flutter/foundation.dart';

class SymptomLog {
  final String id;
  final String petId;
  final DateTime dateTime;
  final String symptom;
  final int severity; // 1-10 scale
  final String description;
  final List<String> associatedSymptoms;
  final Duration duration;
  final List<String> triggers;
  final bool wasEating;
  final bool wasActive;
  final String location;
  final List<String> medications;
  final String notes;
  final bool reportedToVet;
  final List<String> images;
  // New fields
  final String? vetFeedback;
  final DateTime? vetReviewDate;
  final Map<String, dynamic> vitalSigns;
  final List<String> treatments;
  final bool resolved;
  final DateTime? resolvedDate;
  final String? resolution;
  final List<SymptomLogUpdate> updates;
  final Map<String, dynamic> metadata;

  SymptomLog({
    required this.id,
    required this.petId,
    required this.dateTime,
    required this.symptom,
    required this.severity,
    required this.description,
    this.associatedSymptoms = const [],
    required this.duration,
    this.triggers = const [],
    this.wasEating = true,
    this.wasActive = true,
    required this.location,
    this.medications = const [],
    this.notes = '',
    this.reportedToVet = false,
    this.images = const [],
    // New parameters
    this.vetFeedback,
    this.vetReviewDate,
    this.vitalSigns = const {},
    this.treatments = const [],
    this.resolved = false,
    this.resolvedDate,
    this.resolution,
    this.updates = const [],
    this.metadata = const {},
  });

  // CopyWith method for immutability
  SymptomLog copyWith({
    String? id,
    String? petId,
    DateTime? dateTime,
    String? symptom,
    int? severity,
    String? description,
    List<String>? associatedSymptoms,
    Duration? duration,
    List<String>? triggers,
    bool? wasEating,
    bool? wasActive,
    String? location,
    List<String>? medications,
    String? notes,
    bool? reportedToVet,
    List<String>? images,
    String? vetFeedback,
    DateTime? vetReviewDate,
    Map<String, dynamic>? vitalSigns,
    List<String>? treatments,
    bool? resolved,
    DateTime? resolvedDate,
    String? resolution,
    List<SymptomLogUpdate>? updates,
    Map<String, dynamic>? metadata,
  }) {
    return SymptomLog(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      dateTime: dateTime ?? this.dateTime,
      symptom: symptom ?? this.symptom,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      associatedSymptoms: associatedSymptoms ?? this.associatedSymptoms,
      duration: duration ?? this.duration,
      triggers: triggers ?? this.triggers,
      wasEating: wasEating ?? this.wasEating,
      wasActive: wasActive ?? this.wasActive,
      location: location ?? this.location,
      medications: medications ?? this.medications,
      notes: notes ?? this.notes,
      reportedToVet: reportedToVet ?? this.reportedToVet,
      images: images ?? this.images,
      vetFeedback: vetFeedback ?? this.vetFeedback,
      vetReviewDate: vetReviewDate ?? this.vetReviewDate,
      vitalSigns: vitalSigns ?? this.vitalSigns,
      treatments: treatments ?? this.treatments,
      resolved: resolved ?? this.resolved,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      resolution: resolution ?? this.resolution,
      updates: updates ?? this.updates,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'dateTime': dateTime.toIso8601String(),
      'symptom': symptom,
      'severity': severity,
      'description': description,
      'associatedSymptoms': associatedSymptoms,
      'duration': duration.inMinutes,
      'triggers': triggers,
      'wasEating': wasEating,
      'wasActive': wasActive,
      'location': location,
      'medications': medications,
      'notes': notes,
      'reportedToVet': reportedToVet,
      'images': images,
      'vetFeedback': vetFeedback,
      'vetReviewDate': vetReviewDate?.toIso8601String(),
      'vitalSigns': vitalSigns,
      'treatments': treatments,
      'resolved': resolved,
      'resolvedDate': resolvedDate?.toIso8601String(),
      'resolution': resolution,
      'updates': updates.map((u) => u.toJson()).toList(),
      'metadata': metadata,
    };
  }

  factory SymptomLog.fromJson(Map<String, dynamic> json) {
    return SymptomLog(
      id: json['id'],
      petId: json['petId'],
      dateTime: DateTime.parse(json['dateTime']),
      symptom: json['symptom'],
      severity: json['severity'],
      description: json['description'],
      associatedSymptoms: List<String>.from(json['associatedSymptoms'] ?? []),
      duration: Duration(minutes: json['duration']),
      triggers: List<String>.from(json['triggers'] ?? []),
      wasEating: json['wasEating'] ?? true,
      wasActive: json['wasActive'] ?? true,
      location: json['location'],
      medications: List<String>.from(json['medications'] ?? []),
      notes: json['notes'] ?? '',
      reportedToVet: json['reportedToVet'] ?? false,
      images: List<String>.from(json['images'] ?? []),
      vetFeedback: json['vetFeedback'],
      vetReviewDate: json['vetReviewDate'] != null 
          ? DateTime.parse(json['vetReviewDate'])
          : null,
      vitalSigns: Map<String, dynamic>.from(json['vitalSigns'] ?? {}),
      treatments: List<String>.from(json['treatments'] ?? []),
      resolved: json['resolved'] ?? false,
      resolvedDate: json['resolvedDate'] != null 
          ? DateTime.parse(json['resolvedDate'])
          : null,
      resolution: json['resolution'],
      updates: (json['updates'] as List?)
          ?.map((u) => SymptomLogUpdate.fromJson(u))
          .toList() ?? [],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  // Helper methods
  bool isRecent({int hours = 24}) {
    return DateTime.now().difference(dateTime).inHours < hours;
  }

  bool isSevere() {
    return severity >= 8;
  }

  bool needsVetAttention() {
    return isSevere() || duration.inHours >= 24 || 
           (associatedSymptoms.length >= 3);
  }

  String getSeverityLevel() {
    if (severity <= 3) return 'Mild';
    if (severity <= 6) return 'Moderate';
    if (severity <= 8) return 'Severe';
    return 'Critical';
  }

  Duration getTimeSinceOccurrence() {
    return DateTime.now().difference(dateTime);
  }
}
// Continuing lib/models/symptom_log.dart

class SymptomLogUpdate {
  final String id;
  final DateTime timestamp;
  final String type; // 'status_change', 'severity_change', 'vet_review', etc.
  final Map<String, dynamic> changes;
  final String? updatedBy;
  final String? notes;

  const SymptomLogUpdate({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.changes,
    this.updatedBy,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'changes': changes,
      'updatedBy': updatedBy,
      'notes': notes,
    };
  }

  factory SymptomLogUpdate.fromJson(Map<String, dynamic> json) {
    return SymptomLogUpdate(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      changes: Map<String, dynamic>.from(json['changes']),
      updatedBy: json['updatedBy'],
      notes: json['notes'],
    );
  }
}

class SymptomAnalytics {
  static Map<String, dynamic> analyzeSymptomTrends(List<SymptomLog> logs) {
    final trends = <String, dynamic>{};
    
    // Frequency analysis
    final symptomFrequency = <String, int>{};
    final locationFrequency = <String, int>{};
    final triggerFrequency = <String, int>{};
    
    for (var log in logs) {
      symptomFrequency[log.symptom] = 
          (symptomFrequency[log.symptom] ?? 0) + 1;
      locationFrequency[log.location] = 
          (locationFrequency[log.location] ?? 0) + 1;
      
      for (var trigger in log.triggers) {
        triggerFrequency[trigger] = 
            (triggerFrequency[trigger] ?? 0) + 1;
      }
    }

    // Severity trends
    final severityTrend = logs.map((log) => {
      'date': log.dateTime.toIso8601String(),
      'severity': log.severity,
      'symptom': log.symptom,
    }).toList();

    // Duration analysis
    final durationBySymptom = <String, Duration>{};
    for (var log in logs) {
      if (durationBySymptom.containsKey(log.symptom)) {
        durationBySymptom[log.symptom] = 
            durationBySymptom[log.symptom]! + log.duration;
      } else {
        durationBySymptom[log.symptom] = log.duration;
      }
    }

    return {
      'symptomFrequency': symptomFrequency,
      'locationFrequency': locationFrequency,
      'triggerFrequency': triggerFrequency,
      'severityTrend': severityTrend,
      'durationBySymptom': durationBySymptom.map(
        (k, v) => MapEntry(k, v.inMinutes)
      ),
    };
  }
}

class SymptomReportGenerator {
  static Map<String, dynamic> generateVetReport(SymptomLog log) {
    return {
      'symptomDetails': {
        'mainSymptom': log.symptom,
        'severity': log.severity,
        'severityLevel': log.getSeverityLevel(),
        'duration': '${log.duration.inHours}h ${log.duration.inMinutes % 60}m',
        'location': log.location,
        'associatedSymptoms': log.associatedSymptoms,
      },
      'behavioralChanges': {
        'eating': log.wasEating ? 'Normal' : 'Affected',
        'activity': log.wasActive ? 'Normal' : 'Affected',
      },
      'medications': log.medications,
      'triggers': log.triggers,
      'vitalSigns': log.vitalSigns,
      'treatments': log.treatments,
      'images': log.images,
      'notes': log.notes,
      'timeline': {
        'onset': log.dateTime.toIso8601String(),
        'reported': DateTime.now().toIso8601String(),
        'duration': log.getTimeSinceOccurrence().inHours,
      },
    };
  }
}

// Utility class for common symptom-related operations
class SymptomUtils {
  static const commonSymptoms = {
    'digestive': [
      'vomiting',
      'diarrhea',
      'constipation',
      'loss_of_appetite',
    ],
    'respiratory': [
      'coughing',
      'sneezing',
      'difficulty_breathing',
      'nasal_discharge',
    ],
    'musculoskeletal': [
      'limping',
      'stiffness',
      'reluctance_to_move',
      'joint_swelling',
    ],
    'dermatological': [
      'itching',
      'rash',
      'hair_loss',
      'hot_spots',
    ],
    'behavioral': [
      'lethargy',
      'aggression',
      'anxiety',
      'excessive_vocalization',
    ],
  };

  static const severityGuidelines = {
    'mild': {
      'range': [1, 3],
      'description': 'Minimal impact on daily activities',
      'recommendation': 'Monitor and document changes',
    },
    'moderate': {
      'range': [4, 6],
      'description': 'Noticeable impact on daily activities',
      'recommendation': 'Consider veterinary consultation',
    },
    'severe': {
      'range': [7, 8],
      'description': 'Significant impact on daily activities',
      'recommendation': 'Veterinary attention recommended',
    },
    'critical': {
      'range': [9, 10],
      'description': 'Extreme impact on daily activities',
      'recommendation': 'Immediate veterinary attention required',
    },
  };

  static List<String> getRelatedSymptoms(String mainSymptom) {
    for (var category in commonSymptoms.entries) {
      if (category.value.contains(mainSymptom)) {
        return category.value.where((s) => s != mainSymptom).toList();
      }
    }
    return [];
  }

  static Map<String, dynamic> getSeverityGuidelines(int severityLevel) {
    for (var severity in severityGuidelines.entries) {
      final range = severity.value['range'] as List<int>;
      if (severityLevel >= range[0] && severityLevel <= range[1]) {
        return severity.value;
      }
    }
    return severityGuidelines['moderate']!;
  }

  static bool isEmergency(SymptomLog log) {
    return log.severity >= 9 ||
           log.symptom == 'difficulty_breathing' ||
           (log.associatedSymptoms.contains('collapse')) ||
           log.duration.inHours >= 48;
  }

  static String generateSummary(SymptomLog log) {
    final severity = log.getSeverityLevel();
    final duration = log.duration.inHours;
    final timeAgo = log.getTimeSinceOccurrence().inHours;

    return '''
    $severity ${log.symptom} reported $timeAgo hours ago
    Duration: $duration hours
    Location: ${log.location}
    ${log.associatedSymptoms.isNotEmpty ? 'Associated symptoms: ${log.associatedSymptoms.join(', ')}' : ''}
    ${log.medications.isNotEmpty ? 'Medications: ${log.medications.join(', ')}' : ''}
    ''';
  }
}
// lib/models/weight_log.dart

import 'package:intl/intl.dart';

class WeightLog {
  final String id;
  final String petId;
  final double weight;
  final DateTime date;
  final String? notes;
  // New fields
  final String unit; // 'kg' or 'lbs'
  final String? measuredBy;
  final WeightSource source;
  final double? previousWeight;
  final double? weightChange;
  final String? weightTrend; // 'gain', 'loss', 'stable'
  final Map<String, dynamic> metadata;

  WeightLog({
    required this.id,
    required this.petId,
    required this.weight,
    required this.date,
    this.notes,
    this.unit = 'kg',
    this.measuredBy,
    this.source = WeightSource.manual,
    this.previousWeight,
    this.weightChange,
    this.weightTrend,
    this.metadata = const {},
  });

  // Getters
  bool get isRecentMeasurement => 
      date.isAfter(DateTime.now().subtract(const Duration(days: 7)));

  double get weightInKg => 
      unit == 'lbs' ? weight * 0.453592 : weight;

  double get weightInLbs => 
      unit == 'kg' ? weight * 2.20462 : weight;

  double? get changePercentage => weightChange != null && previousWeight != null
      ? (weightChange! / previousWeight! * 100)
      : null;

  // Convert WeightLog instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'weight': weight,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'notes': notes,
      'unit': unit,
      'measuredBy': measuredBy,
      'source': source.toString(),
      'previousWeight': previousWeight,
      'weightChange': weightChange,
      'weightTrend': weightTrend,
      'metadata': metadata,
    };
  }

  // Create WeightLog instance from a Map
  factory WeightLog.fromMap(Map<String, dynamic> map) {
    return WeightLog(
      id: map['id'],
      petId: map['petId'],
      weight: map['weight'].toDouble(),
      date: DateFormat('yyyy-MM-dd').parse(map['date']),
      notes: map['notes'],
      unit: map['unit'] ?? 'kg',
      measuredBy: map['measuredBy'],
      source: WeightSource.values.firstWhere(
        (e) => e.toString() == map['source'],
        orElse: () => WeightSource.manual,
      ),
      previousWeight: map['previousWeight']?.toDouble(),
      weightChange: map['weightChange']?.toDouble(),
      weightTrend: map['weightTrend'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  // Create a copy of WeightLog with some fields changed
  WeightLog copyWith({
    String? id,
    String? petId,
    double? weight,
    DateTime? date,
    String? notes,
    String? unit,
    String? measuredBy,
    WeightSource? source,
    double? previousWeight,
    double? weightChange,
    String? weightTrend,
    Map<String, dynamic>? metadata,
  }) {
    return WeightLog(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      unit: unit ?? this.unit,
      measuredBy: measuredBy ?? this.measuredBy,
      source: source ?? this.source,
      previousWeight: previousWeight ?? this.previousWeight,
      weightChange: weightChange ?? this.weightChange,
      weightTrend: weightTrend ?? this.weightTrend,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'WeightLog('
           'id: $id, '
           'petId: $petId, '
           'weight: $weight$unit, '
           'date: ${DateFormat('yyyy-MM-dd').format(date)}, '
           'trend: $weightTrend, '
           'notes: $notes'
           ')';
  }

  // Convert weight between units
  WeightLog convertTo(String targetUnit) {
    if (targetUnit == unit) return this;
    
    final convertedWeight = targetUnit == 'kg' 
        ? weightInKg 
        : weightInLbs;
    
    return copyWith(
      weight: convertedWeight,
      unit: targetUnit,
      previousWeight: previousWeight != null 
          ? (targetUnit == 'kg' 
              ? previousWeight! * 0.453592 
              : previousWeight! * 2.20462)
          : null,
      weightChange: weightChange != null 
          ? (targetUnit == 'kg' 
              ? weightChange! * 0.453592 
              : weightChange! * 2.20462)
          : null,
    );
  }
}

enum WeightSource {
  manual,
  vetScale,
  smartScale,
  estimated
}

// Utility class for weight analysis
class WeightAnalytics {
  static Map<String, dynamic> analyzeWeightTrend(List<WeightLog> logs) {
    if (logs.isEmpty) return {};
    
    final sortedLogs = List<WeightLog>.from(logs)
      ..sort((a, b) => b.date.compareTo(a.date));

    final firstLog = sortedLogs.last;
    final lastLog = sortedLogs.first;
    final totalChange = lastLog.weight - firstLog.weight;
    final daysDifference = lastLog.date.difference(firstLog.date).inDays;

    return {
      'startWeight': firstLog.weight,
      'currentWeight': lastLog.weight,
      'totalChange': totalChange,
      'changePercentage': (totalChange / firstLog.weight * 100),
      'averageChangePerDay': daysDifference > 0 
          ? totalChange / daysDifference 
          : 0.0,
      'minWeight': sortedLogs.map((l) => l.weight).reduce(min),
      'maxWeight': sortedLogs.map((l) => l.weight).reduce(max),
      'measurementCount': logs.length,
      'daysCovered': daysDifference,
    };
  }

  static List<Map<String, dynamic>> calculateMonthlyAverages(
    List<WeightLog> logs
  ) {
    final monthlyData = <String, List<WeightLog>>{};
    
    for (var log in logs) {
      final monthKey = DateFormat('yyyy-MM').format(log.date);
      monthlyData.putIfAbsent(monthKey, () => []).add(log);
    }

    return monthlyData.entries.map((entry) {
      final weights = entry.value.map((l) => l.weight);
      return {
        'month': entry.key,
        'averageWeight': weights.reduce((a, b) => a + b) / weights.length,
        'measurementCount': entry.value.length,
      };
    }).toList();
  }

  static String determineWeightTrend(double? previousWeight, double currentWeight) {
    if (previousWeight == null) return 'initial';
    final difference = currentWeight - previousWeight;
    if (difference.abs() < 0.1) return 'stable';
    return difference > 0 ? 'gain' : 'loss';
  }
}
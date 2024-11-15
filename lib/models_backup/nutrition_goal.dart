import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionGoal {
  final String id;
  final String petId;
  final double calories;
  final double protein;
  final double fat;
  final double fiber;
  final List<String> mealSchedule;
  final DateTime lastUpdated;

  NutritionGoal({
    required this.id,
    required this.petId,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.fiber,
    required this.mealSchedule,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'fiber': fiber,
      'mealSchedule': mealSchedule,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory NutritionGoal.fromJson(Map<String, dynamic> json) {
    return NutritionGoal(
      id: json['id'],
      petId: json['petId'],
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      fat: json['fat'].toDouble(),
      fiber: json['fiber'].toDouble(),
      mealSchedule: List<String>.from(json['mealSchedule']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  factory NutritionGoal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NutritionGoal.fromJson({
      ...data,
      'id': doc.id,
      'mealSchedule': (data['mealSchedule'] as List<dynamic>).map((e) => e.toString()).toList(),
      'lastUpdated': (data['lastUpdated'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'fiber': fiber,
      'mealSchedule': mealSchedule,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  NutritionGoal copyWith({
    String? id,
    String? petId,
    double? calories,
    double? protein,
    double? fat,
    double? fiber,
    List<String>? mealSchedule,
    DateTime? lastUpdated,
  }) {
    return NutritionGoal(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      mealSchedule: mealSchedule ?? this.mealSchedule,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
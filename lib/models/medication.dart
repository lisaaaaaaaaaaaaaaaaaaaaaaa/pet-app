class Medication {
  final String? id;
  final String petId;
  final String name;
  final String dosage;
  final String instructions;
  final DateTime nextDose;
  final bool isCompleted;
  final DateTime? completedAt;

  Medication({
    this.id,
    required this.petId,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.nextDose,
    this.isCompleted = false,
    this.completedAt,
  });

  Medication copyWith({
    String? id,
    String? petId,
    String? name,
    String? dosage,
    String? instructions,
    DateTime? nextDose,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      nextDose: nextDose ?? this.nextDose,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class SymptomLog {
  final String? id;
  final String petId;
  final String type;
  final int severity;
  final DateTime observedAt;
  final String? notes;

  SymptomLog({
    this.id,
    required this.petId,
    required this.type,
    required this.severity,
    required this.observedAt,
    this.notes,
  });

  SymptomLog copyWith({
    String? id,
    String? petId,
    String? type,
    int? severity,
    DateTime? observedAt,
    String? notes,
  }) {
    return SymptomLog(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      observedAt: observedAt ?? this.observedAt,
      notes: notes ?? this.notes,
    );
  }
}

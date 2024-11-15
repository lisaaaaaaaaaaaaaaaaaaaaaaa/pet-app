class MedicalRecord {
  final String? id;
  final String petId;
  final String title;
  final String type;
  final DateTime date;
  final String? provider;
  final String? notes;
  final List<String>? attachments;

  MedicalRecord({
    this.id,
    required this.petId,
    required this.title,
    required this.type,
    required this.date,
    this.provider,
    this.notes,
    this.attachments,
  });

  MedicalRecord copyWith({
    String? id,
    String? petId,
    String? title,
    String? type,
    DateTime? date,
    String? provider,
    String? notes,
    List<String>? attachments,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      type: type ?? this.type,
      date: date ?? this.date,
      provider: provider ?? this.provider,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
    );
  }
}

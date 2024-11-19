class Pet {
  final String id;
  final String name;
  final String breed;
  final int age;
  final double weight;
  final String? imageUrl;
  final DateTime lastCheckup;
  final List<String> medications;
  final List<String> vaccinations;

  const Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.weight,
    this.imageUrl,
    required this.lastCheckup,
    this.medications = const [],
    this.vaccinations = const [],
  });

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] as String,
      name: map['name'] as String,
      breed: map['breed'] as String,
      age: map['age'] as int,
      weight: (map['weight'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String?,
      lastCheckup: DateTime.parse(map['lastCheckup'] as String),
      medications: List<String>.from(map['medications'] ?? []),
      vaccinations: List<String>.from(map['vaccinations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'age': age,
      'weight': weight,
      'imageUrl': imageUrl,
      'lastCheckup': lastCheckup.toIso8601String(),
      'medications': medications,
      'vaccinations': vaccinations,
    };
  }

  Pet copyWith({
    String? id,
    String? name,
    String? breed,
    int? age,
    double? weight,
    String? imageUrl,
    DateTime? lastCheckup,
    List<String>? medications,
    List<String>? vaccinations,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      imageUrl: imageUrl ?? this.imageUrl,
      lastCheckup: lastCheckup ?? this.lastCheckup,
      medications: medications ?? this.medications,
      vaccinations: vaccinations ?? this.vaccinations,
    );
  }
}

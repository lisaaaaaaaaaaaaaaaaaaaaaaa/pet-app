class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final double age;
  final double weight;
  final String gender;
  final String status;
  final String imageUrl;
  final String? microchipId;
  final List<dynamic>? medications;
  final List<dynamic>? appointments;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.weight,
    required this.gender,
    required this.status,
    required this.imageUrl,
    this.microchipId,
    this.medications,
    this.appointments,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String,
      age: (json['age'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      gender: json['gender'] as String,
      status: json['status'] as String,
      imageUrl: json['imageUrl'] as String,
      microchipId: json['microchipId'] as String?,
      medications: json['medications'] as List<dynamic>?,
      appointments: json['appointments'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'weight': weight,
      'gender': gender,
      'status': status,
      'imageUrl': imageUrl,
      'microchipId': microchipId,
      'medications': medications,
      'appointments': appointments,
    };
  }

  Pet copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    double? age,
    double? weight,
    String? gender,
    String? status,
    String? imageUrl,
    String? microchipId,
    List<dynamic>? medications,
    List<dynamic>? appointments,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      microchipId: microchipId ?? this.microchipId,
      medications: medications ?? this.medications,
      appointments: appointments ?? this.appointments,
    );
  }
}
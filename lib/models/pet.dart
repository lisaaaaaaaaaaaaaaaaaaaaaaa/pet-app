class Pet {
  final String? id;
  final String name;
  final String species;
  final String breed;
  final DateTime dateOfBirth;
  final String? photoUrl;
  final double? weight;
  final String? microchipNumber;

  Pet({
    this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.dateOfBirth,
    this.photoUrl,
    this.weight,
    this.microchipNumber,
  });

  Pet copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    DateTime? dateOfBirth,
    String? photoUrl,
    double? weight,
    String? microchipNumber,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      photoUrl: photoUrl ?? this.photoUrl,
      weight: weight ?? this.weight,
      microchipNumber: microchipNumber ?? this.microchipNumber,
    );
  }
}

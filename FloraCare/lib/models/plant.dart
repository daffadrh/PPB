class Plant {
  final int? id;
  final String name;
  final String species;
  final int waterFrequencyDays;
  final String imagePath;

  Plant({
    this.id,
    required this.name,
    required this.species,
    required this.waterFrequencyDays,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'waterFrequencyDays': waterFrequencyDays,
      'imagePath': imagePath,
    };
  }

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'],
      name: map['name'],
      species: map['species'],
      waterFrequencyDays: map['waterFrequencyDays'],
      imagePath: map['imagePath'],
    );
  }
}
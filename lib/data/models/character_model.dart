class Character {
  final String name;
  final String role;
  final String significance;
  final String lifespan;
  final String? imageUrl; // new field

  Character({
    required this.name,
    required this.role,
    required this.significance,
    required this.lifespan,
    this.imageUrl,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      significance: json['significance'] ?? '',
      lifespan: json['lifespan'] ?? '',
      imageUrl: json['image_url'], // map new field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'significance': significance,
      'lifespan': lifespan,
      'image_url': imageUrl, // include in JSON
    };
  }
}

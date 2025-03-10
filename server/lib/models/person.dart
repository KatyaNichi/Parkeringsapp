class Person {
  final int id;
  final String name;
  final int personnummer;

  Person({
    required this.id,
    required this.name,
    required this.personnummer,
  });

  // Convert Person object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'personnummer': personnummer,
    };
  }

  // Create a Person from a JSON map
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      personnummer: json['personnummer'],
    );
  }
}
import 'person.dart';

class Vehicle {
  final int id;
  final String type;
  final Person owner;
  final int registrationNumber;

  Vehicle({
    required this.id,
    required this.type,
    required this.registrationNumber,
    required this.owner,
  });

  // Convert Vehicle object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'registrationNumber': registrationNumber,
      'ownerId': owner.id,  // Store just the owner ID in JSON
    };
  }

  // Create a Vehicle from a JSON map and owner object
  factory Vehicle.fromJson(Map<String, dynamic> json, Person owner) {
    return Vehicle(
      id: json['id'],
      type: json['type'],
      registrationNumber: json['registrationNumber'],
      owner: owner,
    );
  }
}
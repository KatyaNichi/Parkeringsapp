class ParkingSpace {
  final int id;
  final String adress;
  final int pricePerHour;

  ParkingSpace({
    required this.id,
    required this.adress,
    required this.pricePerHour,
  });

  // Convert ParkingSpace object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adress': adress,
      'pricePerHour': pricePerHour,
    };
  }

  // Create a ParkingSpace from a JSON map
  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'],
      adress: json['adress'],
      pricePerHour: json['pricePerHour'],
    );
  }
}
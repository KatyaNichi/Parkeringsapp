class Parking {
  final int id;
  final String fordon;
  final String parkingPlace;
  final String startTime;
  final String? endTime;

  Parking({
    required this.id,
    required this.fordon,
    required this.parkingPlace,
    required this.startTime,
    this.endTime,
  });

  // Convert Parking object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fordon': fordon,
      'parkingPlace': parkingPlace,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  // Create a Parking from a JSON map
  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'],
      fordon: json['fordon'],
      parkingPlace: json['parkingPlace'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}
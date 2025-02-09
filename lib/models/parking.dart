import 'dart:math';


class Parking {
  final int id;
  final String fordon;
  final String parkingPlace;
  final String startTime;
  final String? endTime;

  Parking({required this.fordon,required this.parkingPlace, required this.startTime, required this.endTime}) : id = _generateId();

  static int _generateId() {
    return Random().nextInt(1000000);
  }
}
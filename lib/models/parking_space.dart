import 'dart:math';


class ParkingSpace {
  final int id;
  final String adress;
  final int pricePerHour;

  ParkingSpace({required this.adress, required this.pricePerHour}) : id = _generateId();

  static int _generateId() {
    return Random().nextInt(1000000);
  }
}
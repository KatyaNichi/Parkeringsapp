import 'dart:math';


class ParkingSpace {
  final int id;
  final String adress;
  final int pricePerHpour;

  ParkingSpace({required this.adress, required this.pricePerHpour}) : id = _generateId();

  static int _generateId() {
    return Random().nextInt(1000000);
  }
}
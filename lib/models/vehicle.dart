import 'dart:math';
import 'person.dart';


class Vehicle {
  final int id;
  final String type;
  final Person owner;
  final int registrationNumber;

  Vehicle({required this.type, required this.registrationNumber, required this.owner}) : id = _generateId();

  static int _generateId() {
    return Random().nextInt(1000000);
  }
}
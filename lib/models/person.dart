import 'dart:math';


class Person {
  final int id;
  final String name;
  final int personnummer;

  Person({required this.name, required this.personnummer}) : id = _generateId();

  static int _generateId() {
    return Random().nextInt(1000000);
  }
}
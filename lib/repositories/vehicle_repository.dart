import 'dart:io';
import '../models/vehicle.dart';
import '../models/person.dart';

class VehicleRepository {
  final List<Vehicle> _vehicles = [];

  void add(List<Person> persons) {
    stdout.write('Ange typ av fordon: ');
    String? type = stdin.readLineSync();

    stdout.write('Ange registreringsnummer: ');
    String? regNumInput = stdin.readLineSync();
    int? registrationNumber = int.tryParse(regNumInput ?? '');

    stdout.writeln('Lista över alla personer:');
    for (var person in persons) {
      stdout.writeln('ID: ${person.id}, Namn: ${person.name}, Personnummer: ${person.personnummer}');
    }
    stdout.write('Ange ID för fordonsägaren: ');
    String? ownerIdInput = stdin.readLineSync();
    int? ownerId = int.tryParse(ownerIdInput ?? '');

   Person? owner = persons.where((p) => p.id == ownerId).isNotEmpty
    ? persons.firstWhere((p) => p.id == ownerId)
    : null;


    if (type == null || registrationNumber == null || owner == null) {
      stdout.writeln('Felaktig inmatning. Fordonet skapades inte.');
      return;
    }

    _vehicles.add(Vehicle(type: type, registrationNumber: registrationNumber, owner: owner));
    stdout.writeln('Fordonet $type har lagts till.');
  }

  void showAll() {
    if (_vehicles.isEmpty) {
      stdout.writeln('Inga fordon hittades.');
    } else {
      stdout.writeln('Lista över alla fordon:');
      for (var vehicle in _vehicles) {
        stdout.writeln('ID: ${vehicle.id}, Typ: ${vehicle.type}, Registreringsnummer: ${vehicle.registrationNumber}, Ägare: ${vehicle.owner.name}');
      }
    }
  }

  bool update(int id) {
    final vehicleIndex = _vehicles.indexWhere((v) => v.id == id);
    if (vehicleIndex == -1) {
      stdout.writeln('Fordon med id $id hittades inte.');
      return false;
    }

    final currentVehicle = _vehicles[vehicleIndex];

    stdout.write('Ange ny typ (tryck enter för att behålla den gamla): ');
    String? newType = stdin.readLineSync();
    stdout.write('Ange nytt registreringsnummer (tryck enter för att behålla det gamla): ');
    String? newRegNumInput = stdin.readLineSync();
    int? newRegNum = int.tryParse(newRegNumInput ?? '');

    _vehicles[vehicleIndex] = Vehicle(
      type: newType?.isNotEmpty == true ? newType! : currentVehicle.type,
      registrationNumber: newRegNum ?? currentVehicle.registrationNumber,
      owner: currentVehicle.owner,
    );

    stdout.writeln('Fordonet har uppdaterats.');
    return true;
  }

bool remove(int id) {
  final vehicle = _vehicles.firstWhere(
    (v) => v.id == id,
    orElse: () => Vehicle(type: 'Unknown', registrationNumber: -1, owner: Person(name: 'Unknown', personnummer: 0)),
  );

  if (vehicle.registrationNumber != -1) {
    _vehicles.remove(vehicle);
    stdout.writeln('Fordonet har tagits bort.');
    return true;
  }

  stdout.writeln('Fordon med id $id hittades inte.');
  return false;
}

}

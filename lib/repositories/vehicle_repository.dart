import '../models/vehicle.dart';
import '../models/person.dart';

class VehicleRepository {
  final List<Vehicle> _vehicles = [];

  // Add a new vehicle
  void add(String type, int registrationNumber, Person owner) {
    _vehicles.add(Vehicle(type: type, registrationNumber: registrationNumber, owner: owner));
  }

  // Get all vehicles
  List<Vehicle> getAll() {
    return _vehicles;
  }

  // Get a vehicle by ID
  Vehicle? getVehicleById(int id) {
    return _vehicles.isNotEmpty && _vehicles.any((v) => v.id == id)
        ? _vehicles.firstWhere((v) => v.id == id)
        : null;
  }

  // Update a vehicle by ID
  bool update(int id, {String? newType, int? newRegNum}) {
    final vehicleIndex = _vehicles.indexWhere((v) => v.id == id);
    if (vehicleIndex == -1) return false;

    final currentVehicle = _vehicles[vehicleIndex];
    _vehicles[vehicleIndex] = Vehicle(
      type: newType?.isNotEmpty == true ? newType! : currentVehicle.type,
      registrationNumber: newRegNum ?? currentVehicle.registrationNumber,
      owner: currentVehicle.owner,
    );

    return true;
  }

  // Remove a vehicle by ID
  bool remove(int id) {
    final vehicleIndex = _vehicles.indexWhere((v) => v.id == id);
    if (vehicleIndex == -1) return false;

    _vehicles.removeAt(vehicleIndex);
    return true;
  }
}

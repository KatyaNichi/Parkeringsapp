import '../models/parking_space.dart';


class ParkingSpaceRepository {
  final List<ParkingSpace> _parkingSpaces = [];

  // Add a new parking space
  void add(String adress, int pricePerHour) {
    _parkingSpaces.add(ParkingSpace(adress: adress, pricePerHour: pricePerHour));
  }

  // Get all parking spaces
  List<ParkingSpace> getAll() {
    return _parkingSpaces;
  }

  // Get a specific parking space by ID
  ParkingSpace? getParkingSpaceById(int id) {
  return _parkingSpaces.isNotEmpty && _parkingSpaces.any((p) => p.id == id)
      ? _parkingSpaces.firstWhere((p) => p.id == id)
      : null;
}


  // Update a parking space by ID
  bool update(int id, {String? newAdress, int? newPrice}) {
    final spaceIndex = _parkingSpaces.indexWhere((p) => p.id == id);
    if (spaceIndex == -1) return false;

    final currentSpace = _parkingSpaces[spaceIndex];
    _parkingSpaces[spaceIndex] = ParkingSpace(
      adress: newAdress?.isNotEmpty == true ? newAdress! : currentSpace.adress,
      pricePerHour: newPrice ?? currentSpace.pricePerHour,
    );
    return true;
  }

  // Remove a parking space by ID
  bool remove(int id) {
    final spaceIndex = _parkingSpaces.indexWhere((p) => p.id == id);
    if (spaceIndex == -1) return false;

    _parkingSpaces.removeAt(spaceIndex);
    return true;
  }
}

import '../models/parking.dart';

class ParkingRepository {
  final List<Parking> _parkings = [];

  // Add a new parking record
  void add(String fordon, String parkingPlace, String startTime, String? endTime) {
    _parkings.add(Parking(fordon: fordon, parkingPlace: parkingPlace, startTime: startTime, endTime: endTime));
  }

  // Get all parking records
  List<Parking> getAll() {
    return _parkings;
  }

  // Get a parking entry by ID
 Parking? getParkingById(int id) {
  return _parkings.isNotEmpty && _parkings.any((p) => p.id == id)
      ? _parkings.firstWhere((p) => p.id == id)
      : null;
}


  // Update a parking entry by ID
  bool update(int id, {String? newFordon, String? newParkingPlace, String? newStartTime, String? newEndTime}) {
    final parkingIndex = _parkings.indexWhere((p) => p.id == id);
    if (parkingIndex == -1) return false;

    final currentParking = _parkings[parkingIndex];
    _parkings[parkingIndex] = Parking(
      fordon: newFordon?.isNotEmpty == true ? newFordon! : currentParking.fordon,
      parkingPlace: newParkingPlace?.isNotEmpty == true ? newParkingPlace! : currentParking.parkingPlace,
      startTime: newStartTime?.isNotEmpty == true ? newStartTime! : currentParking.startTime,
      endTime: newEndTime?.isNotEmpty == true ? newEndTime! : currentParking.endTime,
    );

    return true;
  }

  // Remove a parking entry by ID
  bool remove(int id) {
    final parkingIndex = _parkings.indexWhere((p) => p.id == id);
    if (parkingIndex == -1) return false;

    _parkings.removeAt(parkingIndex);
    return true;
  }
}


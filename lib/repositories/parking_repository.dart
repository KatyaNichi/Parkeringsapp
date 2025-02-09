import 'dart:io';
import '../models/parking.dart';

class ParkingRepository {
  final List<Parking> _parkings = [];

  void add() {
    stdout.write('Ange fordon: ');
    String? fordon = stdin.readLineSync();

    stdout.write('Ange parkeringsplats: ');
    String? parkingPlace = stdin.readLineSync();

    stdout.write('Ange starttid (t.ex. 2025-02-08 10:00): ');
    String? startTime = stdin.readLineSync();

    stdout.write('Ange sluttid (t.ex. 2025-02-08 12:00): ');
    String? endTime = stdin.readLineSync();

    if (fordon == null || parkingPlace == null || startTime == null || endTime == null) {
      stdout.writeln('Felaktig inmatning. Parkeringen skapades inte.');
      return;
    }

    _parkings.add(Parking(fordon: fordon, parkingPlace: parkingPlace, startTime: startTime, endTime: endTime));
    stdout.writeln('Parkering för $fordon har lagts till.');
  }

  void showAll() {
    if (_parkings.isEmpty) {
      stdout.writeln('Inga parkeringar hittades.');
    } else {
      stdout.writeln('Lista över alla parkeringar:');
      for (var parking in _parkings) {
        stdout.writeln('ID: ${parking.id}, Fordon: ${parking.fordon}, Plats: ${parking.parkingPlace}, Starttid: ${parking.startTime}, Sluttid: ${parking.endTime ?? "Pågår"}');
      }
    }
  }

 bool update(int id) {
  final parkingIndex = _parkings.indexWhere((p) => p.id == id);
  
  if (parkingIndex == -1) {
    stdout.writeln('Parkering med id $id hittades inte.');
    return false;
  }

  final currentParking = _parkings[parkingIndex];
  
  stdout.write('Ange nytt fordon (tryck enter för att behålla det gamla): ');
  String? newFordon = stdin.readLineSync();
  
  stdout.write('Ange ny parkeringsplats (tryck enter för att behålla det gamla): ');
  String? newParkingPlace = stdin.readLineSync();
  
  stdout.write('Ange ny starttid (tryck enter för att behålla det gamla): ');
  String? newStartTime = stdin.readLineSync();
  
  stdout.write('Ange ny sluttid (tryck enter för att behålla det gamla): ');
  String? newEndTime = stdin.readLineSync();

  _parkings[parkingIndex] = Parking(
    fordon: newFordon?.isNotEmpty == true ? newFordon! : currentParking.fordon,
    parkingPlace: newParkingPlace?.isNotEmpty == true ? newParkingPlace! : currentParking.parkingPlace,
    startTime: newStartTime?.isNotEmpty == true ? newStartTime! : currentParking.startTime,
    endTime: newEndTime?.isNotEmpty == true ? newEndTime! : currentParking.endTime,
  );

  stdout.writeln('Parkeringen har uppdaterats.');
  return true;
}

  bool remove(int id) {
  final parking = _parkings.firstWhere(
    (p) => p.id == id,
    orElse: () => Parking(fordon: '', parkingPlace: '', startTime: '', endTime: null),
  );

  if (parking.fordon.isNotEmpty) {
    _parkings.remove(parking);
    stdout.writeln('Parkeringen har tagits bort.');
    return true;
  }
  
  stdout.writeln('Parkering med id $id hittades inte.');
  return false;
}
}

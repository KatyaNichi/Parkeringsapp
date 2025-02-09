import 'dart:io';
import '../models/parking_space.dart';


class ParkingSpaceRepository {
  final List<ParkingSpace> _parkingSpaces = [];

  void add() {
    stdout.write('Ange adress för parkeringsplats: ');
    String? adress = stdin.readLineSync();

    stdout.write('Ange pris per timme: ');
    String? priceInput = stdin.readLineSync();
    int? pricePerHour = int.tryParse(priceInput ?? '');

    if (adress == null || pricePerHour == null) {
      stdout.writeln('Felaktig inmatning. Parkeringsplatsen skapades inte.');
      return;
    }

    _parkingSpaces.add(ParkingSpace(adress: adress, pricePerHpour: pricePerHour));
    stdout.writeln('Parkeringsplats $adress har lagts till.');
  }

  void showAll() {
    if (_parkingSpaces.isEmpty) {
      stdout.writeln('Inga parkeringsplatser hittades.');
    } else {
      stdout.writeln('Lista över alla parkeringsplatser:');
      for (var space in _parkingSpaces) {
        stdout.writeln('ID: ${space.id}, Adress: ${space.adress}, Pris per timme: ${space.pricePerHpour} kr');
      }
    }
  }

  bool update(int id) {
    final spaceIndex = _parkingSpaces.indexWhere((p) => p.id == id);
    if (spaceIndex == -1) {
      stdout.writeln('Parkeringsplats med id $id hittades inte.');
      return false;
    }

    stdout.write('Ange ny adress (tryck enter för att behålla den gamla): ');
    String? newAdress = stdin.readLineSync();
    stdout.write('Ange nytt pris per timme (tryck enter för att behålla det gamla): ');
    String? newPriceInput = stdin.readLineSync();
    int? newPrice = int.tryParse(newPriceInput ?? '');

    final currentSpace = _parkingSpaces[spaceIndex];
    _parkingSpaces[spaceIndex] = ParkingSpace(
      adress: newAdress?.isNotEmpty == true ? newAdress! : currentSpace.adress,
      pricePerHpour: newPrice ?? currentSpace.pricePerHpour,
    );

    stdout.writeln('Parkeringsplatsen har uppdaterats.');
    return true;
  }

bool remove(int id) {
  final space = _parkingSpaces.firstWhere((p) => p.id == id, orElse: () => ParkingSpace(adress: '', pricePerHpour: 0));
  if (space.adress.isNotEmpty) {
    _parkingSpaces.remove(space);
    stdout.writeln('Parkeringsplatsen ${space.adress} har tagits bort.');
    return true;
  }
  stdout.writeln('Parkeringsplats med id $id hittades inte.');
  return false;
}

}

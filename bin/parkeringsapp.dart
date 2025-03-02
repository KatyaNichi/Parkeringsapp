import 'dart:io';
import 'package:parkeringsapp/repositories/person_repository.dart';
import 'package:parkeringsapp/models/person.dart';
import 'package:parkeringsapp/models/parking_space.dart';
import 'package:parkeringsapp/models/parking.dart';
import 'package:parkeringsapp/models/vehicle.dart';
import 'package:parkeringsapp/repositories/parking_space_repository.dart';
import 'package:parkeringsapp/repositories/parking_repository.dart';
import 'package:parkeringsapp/repositories/vehicle_repository.dart';



void main() {

  final PersonRepository personRepository = PersonRepository();
  final parkingSpaceRepository = ParkingSpaceRepository();
  final parkingRepository = ParkingRepository();
  final vehicleRepository = VehicleRepository();

while (true) {
  const greeting = ('Välkommen till Parkeringsappen! \nVad vill du hantera?\n1. Personer\n2. Fordon\n3. Parkeringplatser\n4. Parkeringar\n5. Avsluta');
  const makeChoice =('Välj ett alternativ (1-5): ');
  stdout.writeln(greeting);
  stdout.writeln(makeChoice);
  final String? firstAnswer = stdin.readLineSync();
  int? objectChoice = int.tryParse(firstAnswer ?? '');

  if (objectChoice == null || objectChoice < 1 || objectChoice > 5) {
       stdout.writeln('Ogiltigt val. Vänligen ange ett nummer mellan 1 och 5.\n');
      continue;
    }
  

    switch (objectChoice) {
      case 1:
        managePersonMenu(personRepository);
        break;
      case 2:
     manageVehicleMenu(vehicleRepository, personRepository.getAllPersons());
      break;
      case 3:
        manageParkingSpaceMenu(parkingSpaceRepository);
        break;
      case 4:
         manageParkingMenu(parkingRepository);
        break;
      case 5:
       stdout.writeln('Avslutar... Hej då!');
        return;
    }
  }
}
void managePersonMenu(PersonRepository repository) {
  while (true) {
    stdout.writeln('\n--- Hantera Personer ---');
    stdout.writeln('1. Skapa ny person');
    stdout.writeln('2. Visa alla personer');
    stdout.writeln('3. Uppdatera person');
    stdout.writeln('4. Ta bort person');
    stdout.writeln('5. Gå tillbaka till huvudmenyn');
    stdout.write('Välj ett alternativ (1-5): ');

    String? input = stdin.readLineSync();
    int? choice = int.tryParse(input ?? '');

    if (choice == null || choice < 1 || choice > 5) {
      stdout.writeln('Ogiltigt val. Försök igen.');
      continue;
    }

    switch (choice) {
      case 1:
        stdout.write('Ange namn: ');
        String? name = stdin.readLineSync();

        stdout.write('Ange personnummer: ');
        String? personnummerInput = stdin.readLineSync();
        int? personnummer = int.tryParse(personnummerInput ?? '');

        if (name != null && personnummer != null) {
          repository.addPerson(name, personnummer);
          stdout.writeln('Personen $name har lagts till.');
        } else {
          stdout.writeln('Felaktig inmatning.');
        }
        break;

      case 2:
        List<Person> persons = repository.getAllPersons();
        if (persons.isEmpty) {
          stdout.writeln('Inga personer hittades.');
        } else {
          stdout.writeln('\nLista över alla personer:');
          for (var person in persons) {
            stdout.writeln('ID: ${person.id}, Namn: ${person.name}, Personnummer: ${person.personnummer}');
          }
        }
        break;

      case 3:
        stdout.write('Ange ID för personen du vill uppdatera: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');
        if (id == null || repository.getPersonById(id) == null) {
          stdout.writeln('Felaktigt ID.');
          break;
        }

        stdout.write('Ange nytt namn (lämna tomt för att behålla det gamla): ');
        String? newName = stdin.readLineSync();
        stdout.write('Ange nytt personnummer (lämna tomt för att behålla det gamla): ');
        String? newPersonnummerInput = stdin.readLineSync();
        int? newPersonnummer = int.tryParse(newPersonnummerInput ?? '');

        if (repository.updatePerson(id, newName: newName?.isNotEmpty == true ? newName : null, newPersonnummer: newPersonnummer)) {
          stdout.writeln('Personen har uppdaterats.');
        } else {
          stdout.writeln('Uppdatering misslyckades.');
        }
        break;

      case 4:
        stdout.write('Ange ID för personen du vill ta bort: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');
        if (id == null) {
          stdout.writeln('Felaktigt ID.');
        } else {
          bool removed = repository.removePerson(id);
          stdout.writeln(removed ? 'Personen har tagits bort.' : 'Personen hittades inte.');
        }
        break;

      case 5:
        stdout.writeln('Återvänder till huvudmenyn...\n');
        return;
    }
  }
}


void manageParkingSpaceMenu(ParkingSpaceRepository repository) {
  while (true) {
    stdout.writeln('\n--- Hantera Parkeringsplatser ---');
    stdout.writeln('1. Skapa ny parkeringsplats');
    stdout.writeln('2. Visa alla parkeringsplatser');
    stdout.writeln('3. Uppdatera parkeringsplats');
    stdout.writeln('4. Ta bort parkeringsplats');
    stdout.writeln('5. Gå tillbaka till huvudmenyn');
    stdout.write('Välj ett alternativ (1-5): ');

    final String? input = stdin.readLineSync();
    int? choice = int.tryParse(input ?? '');

    if (choice == null || choice < 1 || choice > 5) {
      stdout.writeln('Ogiltigt val. Försök igen.');
      continue;
    }

    switch (choice) {
      case 1:
        stdout.write('Ange adress för parkeringsplats: ');
        String? adress = stdin.readLineSync();

        stdout.write('Ange pris per timme: ');
        String? priceInput = stdin.readLineSync();
        int? pricePerHour = int.tryParse(priceInput ?? '');

        if (adress != null && pricePerHour != null) {
          repository.add(adress, pricePerHour);
          stdout.writeln('Parkeringsplats $adress har lagts till.');
        } else {
          stdout.writeln('Felaktig inmatning.');
        }
        break;

      case 2:
        List<ParkingSpace> spaces = repository.getAll();
        if (spaces.isEmpty) {
          stdout.writeln('Inga parkeringsplatser hittades.');
        } else {
          stdout.writeln('\nLista över alla parkeringsplatser:');
          for (var space in spaces) {
            stdout.writeln('ID: ${space.id}, Adress: ${space.adress}, Pris per timme: ${space.pricePerHour} kr');
          }
        }
        break;

      case 3:
        stdout.write('Ange ID för parkeringsplatsen du vill uppdatera: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');

        if (id == null || repository.getParkingSpaceById(id) == null) {
          stdout.writeln('Felaktigt ID.');
          break;
        }

        stdout.write('Ange ny adress (lämna tomt för att behålla det gamla): ');
        String? newAdress = stdin.readLineSync();

        stdout.write('Ange nytt pris per timme (lämna tomt för att behålla det gamla): ');
        String? newPriceInput = stdin.readLineSync();
        int? newPrice = int.tryParse(newPriceInput ?? '');

        if (repository.update(id, newAdress: newAdress?.isNotEmpty == true ? newAdress : null, newPrice: newPrice)) {
          stdout.writeln('Parkeringsplatsen har uppdaterats.');
        } else {
          stdout.writeln('Uppdatering misslyckades.');
        }
        break;

      case 4:
        stdout.write('Ange ID för parkeringsplatsen du vill ta bort: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');

        if (id == null) {
          stdout.writeln('Felaktigt ID.');
        } else {
          bool removed = repository.remove(id);
          stdout.writeln(removed ? 'Parkeringsplatsen har tagits bort.' : 'Parkeringsplatsen hittades inte.');
        }
        break;

      case 5:
        stdout.writeln('Återvänder till huvudmenyn...\n');
        return;
    }
  }
}


void manageParkingMenu(ParkingRepository repository) {
  while (true) {
    stdout.writeln('\n--- Hantera Parkeringar ---');
    stdout.writeln('1. Skapa ny parkering');
    stdout.writeln('2. Visa alla parkeringar');
    stdout.writeln('3. Uppdatera parkering');
    stdout.writeln('4. Ta bort parkering');
    stdout.writeln('5. Gå tillbaka till huvudmenyn');
    stdout.write('Välj ett alternativ (1-5): ');

    final String? input = stdin.readLineSync();
    int? choice = int.tryParse(input ?? '');

    if (choice == null || choice < 1 || choice > 5) {
      stdout.writeln('Ogiltigt val. Försök igen.');
      continue;
    }

    switch (choice) {
      case 1:
        stdout.write('Ange fordon: ');
        String? fordon = stdin.readLineSync();

        stdout.write('Ange parkeringsplats: ');
        String? parkingPlace = stdin.readLineSync();

        stdout.write('Ange starttid (t.ex. 2025-02-08 10:00): ');
        String? startTime = stdin.readLineSync();

        stdout.write('Ange sluttid (lämna tomt om parkeringen pågår): ');
        String? endTime = stdin.readLineSync();

        if (fordon != null && parkingPlace != null && startTime != null) {
          repository.add(fordon, parkingPlace, startTime, endTime?.isNotEmpty == true ? endTime : null);
          stdout.writeln('Parkering för $fordon har lagts till.');
        } else {
          stdout.writeln('Felaktig inmatning.');
        }
        break;

      case 2:
        List<Parking> parkings = repository.getAll();
        if (parkings.isEmpty) {
          stdout.writeln('Inga parkeringar hittades.');
        } else {
          stdout.writeln('\nLista över alla parkeringar:');
          for (var parking in parkings) {
            stdout.writeln('ID: ${parking.id}, Fordon: ${parking.fordon}, Plats: ${parking.parkingPlace}, Starttid: ${parking.startTime}, Sluttid: ${parking.endTime ?? "Pågår"}');
          }
        }
        break;

      case 3:
        stdout.write('Ange ID för parkeringen du vill uppdatera: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');

        if (id == null || repository.getParkingById(id) == null) {
          stdout.writeln('Felaktigt ID.');
          break;
        }

        stdout.write('Ange nytt fordon (lämna tomt för att behålla det gamla): ');
        String? newFordon = stdin.readLineSync();

        stdout.write('Ange ny parkeringsplats (lämna tomt för att behålla det gamla): ');
        String? newParkingPlace = stdin.readLineSync();

        stdout.write('Ange ny starttid (lämna tomt för att behålla det gamla): ');
        String? newStartTime = stdin.readLineSync();

        stdout.write('Ange ny sluttid (lämna tomt för att behålla det gamla): ');
        String? newEndTime = stdin.readLineSync();

        if (repository.update(id, newFordon: newFordon?.isNotEmpty == true ? newFordon : null, newParkingPlace: newParkingPlace?.isNotEmpty == true ? newParkingPlace : null, newStartTime: newStartTime?.isNotEmpty == true ? newStartTime : null, newEndTime: newEndTime?.isNotEmpty == true ? newEndTime : null)) {
          stdout.writeln('Parkeringen har uppdaterats.');
        } else {
          stdout.writeln('Uppdatering misslyckades.');
        }
        break;

      case 4:
        stdout.write('Ange ID för parkeringen du vill ta bort: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');

        if (id == null) {
          stdout.writeln('Felaktigt ID.');
        } else {
          bool removed = repository.remove(id);
          stdout.writeln(removed ? 'Parkeringen har tagits bort.' : 'Parkeringen hittades inte.');
        }
        break;

      case 5:
        stdout.writeln('Återvänder till huvudmenyn...\n');
        return;
    }
  }
}


void manageVehicleMenu(VehicleRepository repository, List<Person> persons) {
  while (true) {
    stdout.writeln('\n--- Hantera Fordon ---');
    stdout.writeln('1. Skapa nytt fordon');
    stdout.writeln('2. Visa alla fordon');
    stdout.writeln('3. Uppdatera fordon');
    stdout.writeln('4. Ta bort fordon');
    stdout.writeln('5. Gå tillbaka till huvudmenyn');
    stdout.write('Välj ett alternativ (1-5): ');

    final String? input = stdin.readLineSync();
    int? choice = int.tryParse(input ?? '');

    if (choice == null || choice < 1 || choice > 5) {
      stdout.writeln('Ogiltigt val. Försök igen.');
      continue;
    }

    switch (choice) {
      case 1:
        stdout.write('Ange typ av fordon: ');
        String? type = stdin.readLineSync();

        stdout.write('Ange registreringsnummer: ');
        String? regNumInput = stdin.readLineSync();
        int? registrationNumber = int.tryParse(regNumInput ?? '');

        if (persons.isEmpty) {
          stdout.writeln('Inga registrerade personer hittades.');
          break;
        }

        stdout.writeln('Lista över alla personer:');
        for (var person in persons) {
          stdout.writeln('ID: ${person.id}, Namn: ${person.name}, Personnummer: ${person.personnummer}');
        }

        stdout.write('Ange ID för fordonsägaren: ');
        String? ownerIdInput = stdin.readLineSync();
        int? ownerId = int.tryParse(ownerIdInput ?? '');
        Person? owner = persons.firstWhere((p) => p.id == ownerId, orElse: () => Person(name: '', personnummer: -1));

        if (type != null && registrationNumber != null && owner.name.isNotEmpty) {
          repository.add(type, registrationNumber, owner);
          stdout.writeln('Fordonet $type har lagts till.');
        } else {
          stdout.writeln('Felaktig inmatning.');
        }
        break;

      case 2:
        List<Vehicle> vehicles = repository.getAll();
        if (vehicles.isEmpty) {
          stdout.writeln('Inga fordon hittades.');
        } else {
          stdout.writeln('\nLista över alla fordon:');
          for (var vehicle in vehicles) {
            stdout.writeln('ID: ${vehicle.id}, Typ: ${vehicle.type}, Registreringsnummer: ${vehicle.registrationNumber}, Ägare: ${vehicle.owner.name}');
          }
        }
        break;

      case 3:
        stdout.write('Ange ID för fordonet du vill uppdatera: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');

        if (id == null || repository.getVehicleById(id) == null) {
          stdout.writeln('Felaktigt ID.');
          break;
        }

        stdout.write('Ange ny typ (lämna tomt för att behålla det gamla): ');
        String? newType = stdin.readLineSync();

        stdout.write('Ange nytt registreringsnummer (lämna tomt för att behålla det gamla): ');
        String? newRegNumInput = stdin.readLineSync();
        int? newRegNum = int.tryParse(newRegNumInput ?? '');

        if (repository.update(id, newType: newType?.isNotEmpty == true ? newType : null, newRegNum: newRegNum)) {
          stdout.writeln('Fordonet har uppdaterats.');
        } else {
          stdout.writeln('Uppdatering misslyckades.');
        }
        break;

      case 4:
        stdout.write('Ange ID för fordonet du vill ta bort: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');

        if (id == null) {
          stdout.writeln('Felaktigt ID.');
        } else {
          bool removed = repository.remove(id);
          stdout.writeln(removed ? 'Fordonet har tagits bort.' : 'Fordonet hittades inte.');
        }
        break;

      case 5:
        stdout.writeln('Återvänder till huvudmenyn...\n');
        return;
    }
  }
}


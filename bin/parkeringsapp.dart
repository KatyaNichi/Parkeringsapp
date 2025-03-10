import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:parkeringsapp/repositories/http_person_repository.dart';
import 'package:parkeringsapp/repositories/http_vehicle_repository.dart';
import 'package:parkeringsapp/repositories/http_parking_space_repository.dart';
import 'package:parkeringsapp/repositories/http_parking_repository.dart';
//import 'package:parkeringsapp/models/person.dart';

Future<void> main() async {
  // Configure server URL
  const serverUrl = 'http://localhost:8080'; // Change if server is on a different host/port

  // Create repositories using HTTP
  final personRepository = HttpPersonRepository(baseUrl: serverUrl);
 final vehicleRepository = HttpVehicleRepository(baseUrl: serverUrl);
   final parkingSpaceRepository = HttpParkingSpaceRepository(baseUrl: serverUrl);
  final parkingRepository = HttpParkingRepository(baseUrl: serverUrl);


  // Check if server is running
  try {
    final response = await http.get(Uri.parse('$serverUrl/ping'));
    if (response.statusCode != 200 || response.body != 'pong') {
      stdout.writeln('⚠️ Server kommunikationsproblem. Kontrollera att servern körs på $serverUrl');
      exit(1);
    }
  } catch (e) {
    stdout.writeln('⚠️ Kunde inte ansluta till servern på $serverUrl: $e');
    stdout.writeln('Se till att servern är igång innan du startar klienten.');
    exit(1);
  }

  stdout.writeln('✅ Ansluten till servern på $serverUrl');

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

    try {
      switch (objectChoice) {
        case 1:
          await managePersonMenu(personRepository);
          break;
        case 2:
          await manageVehicleMenu(vehicleRepository, personRepository);
          break;
          case 3:
          await manageParkingSpaceMenu(parkingSpaceRepository);
          break;
        case 4:
          await manageParkingMenu(parkingRepository, vehicleRepository, parkingSpaceRepository);
          break;
        case 5:
          stdout.writeln('Avslutar... Hej då!');
          return;
      }
    } catch (e) {
      stdout.writeln('Ett fel uppstod: $e');
    }
  }
}

Future<void> manageVehicleMenu(
  HttpVehicleRepository vehicleRepository,
  HttpPersonRepository personRepository
) async {
  while (true) {
    stdout.writeln('\n--- Hantera Fordon ---');
    stdout.writeln('1. Skapa nytt fordon');
    stdout.writeln('2. Visa alla fordon');
    stdout.writeln('3. Visa fordon efter ägare');
    stdout.writeln('4. Uppdatera fordon');
    stdout.writeln('5. Ta bort fordon');
    stdout.writeln('6. Gå tillbaka till huvudmenyn');
    stdout.write('Välj ett alternativ (1-6): ');

    final String? input = stdin.readLineSync();
    int? choice = int.tryParse(input ?? '');

    if (choice == null || choice < 1 || choice > 6) {
      stdout.writeln('Ogiltigt val. Försök igen.');
      continue;
    }

    try {
      switch (choice) {
        case 1:
          // Create new vehicle
          stdout.write('Ange typ av fordon: ');
          String? type = stdin.readLineSync();

          stdout.write('Ange registreringsnummer: ');
          String? regNumInput = stdin.readLineSync();
          int? registrationNumber = int.tryParse(regNumInput ?? '');

          // Get all persons to select owner
          stdout.writeln('Hämtar alla personer...');
          final persons = await personRepository.getAllPersons();
          if (persons.isEmpty) {
            stdout.writeln('Inga registrerade personer hittades. Skapa en person först.');
            break;
          }

          stdout.writeln('Lista över alla personer:');
          for (var person in persons) {
            stdout.writeln('ID: ${person.id}, Namn: ${person.name}, Personnummer: ${person.personnummer}');
          }

          stdout.write('Ange ID för fordonsägaren: ');
          String? ownerIdInput = stdin.readLineSync();
          int? ownerId = int.tryParse(ownerIdInput ?? '');

          if (type != null && registrationNumber != null && ownerId != null) {
            final vehicle = await vehicleRepository.addVehicle(type, registrationNumber, ownerId);
            stdout.writeln('Fordonet ${vehicle.type} har lagts till.');
          } else {
            stdout.writeln('Felaktig inmatning.');
          }
          break;

        case 2:
          // Show all vehicles
          stdout.writeln('Hämtar alla fordon...');
          final vehicles = await vehicleRepository.getAllVehicles();
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
          // Show vehicles by owner
          stdout.write('Ange ägar-ID för att visa fordon: ');
          String? ownerIdInput = stdin.readLineSync();
          int? ownerId = int.tryParse(ownerIdInput ?? '');

          if (ownerId == null) {
            stdout.writeln('Felaktigt ID.');
            break;
          }

          final vehicles = await vehicleRepository.getVehiclesByOwnerId(ownerId);
          if (vehicles.isEmpty) {
            stdout.writeln('Inga fordon hittades för denna ägare.');
          } else {
            stdout.writeln('\nLista över fordon för ägare med ID $ownerId:');
            for (var vehicle in vehicles) {
              stdout.writeln('ID: ${vehicle.id}, Typ: ${vehicle.type}, Registreringsnummer: ${vehicle.registrationNumber}, Ägare: ${vehicle.owner.name}');
            }
          }
          break;

        case 4:
          // Update vehicle
          stdout.write('Ange ID för fordonet du vill uppdatera: ');
          int? id = int.tryParse(stdin.readLineSync() ?? '');

          if (id == null) {
            stdout.writeln('Felaktigt ID.');
            break;
          }

          // Check if vehicle exists
          final vehicle = await vehicleRepository.getVehicleById(id);
          if (vehicle == null) {
            stdout.writeln('Fordonet hittades inte.');
            break;
          }

          stdout.write('Ange ny typ (lämna tomt för att behålla det gamla): ');
          String? newType = stdin.readLineSync();

          stdout.write('Ange nytt registreringsnummer (lämna tomt för att behålla det gamla): ');
          String? newRegNumInput = stdin.readLineSync();
          int? newRegNum = int.tryParse(newRegNumInput ?? '');

          bool updated = await vehicleRepository.updateVehicle(
            id, 
            newType: newType?.isNotEmpty == true ? newType : null, 
            newRegistrationNumber: newRegNum
          );
          
          stdout.writeln(updated ? 'Fordonet har uppdaterats.' : 'Uppdatering misslyckades.');
          break;

        case 5:
          // Delete vehicle
          stdout.write('Ange ID för fordonet du vill ta bort: ');
          int? id = int.tryParse(stdin.readLineSync() ?? '');

          if (id == null) {
            stdout.writeln('Felaktigt ID.');
            break;
          }

          bool removed = await vehicleRepository.removeVehicle(id);
          stdout.writeln(removed ? 'Fordonet har tagits bort.' : 'Fordonet hittades inte.');
          break;

        case 6:
          stdout.writeln('Återvänder till huvudmenyn...\n');
          return;
      }
    } catch (e) {
      stdout.writeln('Ett fel uppstod: $e');
    }
  }
}

Future<void> manageParkingSpaceMenu(HttpParkingSpaceRepository repository) async {
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

    try {
      switch (choice) {
        case 1:
          stdout.write('Ange adress för parkeringsplats: ');
          String? adress = stdin.readLineSync();

          stdout.write('Ange pris per timme: ');
          String? priceInput = stdin.readLineSync();
          int? pricePerHour = int.tryParse(priceInput ?? '');

          if (adress != null && pricePerHour != null) {
            final space = await repository.addParkingSpace(adress, pricePerHour);
            stdout.writeln('Parkeringsplats ${space.adress} har lagts till.');
          } else {
            stdout.writeln('Felaktig inmatning.');
          }
          break;

        case 2:
          stdout.writeln('Hämtar alla parkeringsplatser...');
          final spaces = await repository.getAllParkingSpaces();
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

          if (id == null) {
            stdout.writeln('Felaktigt ID.');
            break;
          }

          // Check if parking space exists
          final space = await repository.getParkingSpaceById(id);
          if (space == null) {
            stdout.writeln('Parkeringsplatsen hittades inte.');
            break;
          }

          stdout.write('Ange ny adress (lämna tomt för att behålla det gamla): ');
          String? newAdress = stdin.readLineSync();

          stdout.write('Ange nytt pris per timme (lämna tomt för att behålla det gamla): ');
          String? newPriceInput = stdin.readLineSync();
          int? newPrice = int.tryParse(newPriceInput ?? '');

          bool updated = await repository.updateParkingSpace(
            id, 
            newAdress: newAdress?.isNotEmpty == true ? newAdress : null, 
            newPricePerHour: newPrice
          );
          
          stdout.writeln(updated ? 'Parkeringsplatsen har uppdaterats.' : 'Uppdatering misslyckades.');
          break;

        case 4:
          stdout.write('Ange ID för parkeringsplatsen du vill ta bort: ');
          int? id = int.tryParse(stdin.readLineSync() ?? '');

          if (id == null) {
            stdout.writeln('Felaktigt ID.');
            break;
          }

          bool removed = await repository.removeParkingSpace(id);
          stdout.writeln(removed ? 'Parkeringsplatsen har tagits bort.' : 'Parkeringsplatsen hittades inte.');
          break;

        case 5:
          stdout.writeln('Återvänder till huvudmenyn...\n');
          return;
      }
    } catch (e) {
      stdout.writeln('Ett fel uppstod: $e');
    }
  }
}

Future<void> manageParkingMenu(
  HttpParkingRepository parkingRepository,
  HttpVehicleRepository vehicleRepository,
  HttpParkingSpaceRepository parkingSpaceRepository
) async {
  while (true) {
    stdout.writeln('\n--- Hantera Parkeringar ---');
    stdout.writeln('1. Skapa ny parkering');
    stdout.writeln('2. Visa alla parkeringar');
    stdout.writeln('3. Visa aktiva parkeringar');
    stdout.writeln('4. Avsluta parkering');
    stdout.writeln('5. Uppdatera parkering');
    stdout.writeln('6. Ta bort parkering');
    stdout.writeln('7. Gå tillbaka till huvudmenyn');
    stdout.write('Välj ett alternativ (1-7): ');

    final String? input = stdin.readLineSync();
    int? choice = int.tryParse(input ?? '');

    if (choice == null || choice < 1 || choice > 7) {
      stdout.writeln('Ogiltigt val. Försök igen.');
      continue;
    }

    try {
      switch (choice) {
        case 1:
          // Get all vehicles to select from
          stdout.writeln('Hämtar tillgängliga fordon...');
          final vehicles = await vehicleRepository.getAllVehicles();
          if (vehicles.isEmpty) {
            stdout.writeln('Inga fordon hittades. Skapa ett fordon först.');
            break;
          }

          stdout.writeln('\nTillgängliga fordon:');
          for (var vehicle in vehicles) {
            stdout.writeln('ID: ${vehicle.id}, Typ: ${vehicle.type}, Reg.nr: ${vehicle.registrationNumber}, Ägare: ${vehicle.owner.name}');
          }

          stdout.write('Ange fordonets ID: ');
          int? vehicleId = int.tryParse(stdin.readLineSync() ?? '');
          if (vehicleId == null) {
            stdout.writeln('Felaktigt ID.');
            break;
          }

          final selectedVehicle = vehicles.firstWhere(
            (v) => v.id == vehicleId, 
            orElse: () => throw Exception('Fordon ej hittat')
          );
          
          // Get all parking spaces to select from
          stdout.writeln('Hämtar tillgängliga parkeringsplatser...');
          final spaces = await parkingSpaceRepository.getAllParkingSpaces();
          if (spaces.isEmpty) {
            stdout.writeln('Inga parkeringsplatser hittades. Skapa en parkeringsplats först.');
            break;
          }

          stdout.writeln('\nTillgängliga parkeringsplatser:');
          for (var space in spaces) {
            stdout.writeln('ID: ${space.id}, Adress: ${space.adress}, Pris: ${space.pricePerHour} kr/h');
          }

          stdout.write('Ange parkeringsplatsens ID: ');
          int? spaceId = int.tryParse(stdin.readLineSync() ?? '');
          if (spaceId == null) {
            stdout.writeln('Felaktigt ID.');
            break;
          }

          final selectedSpace = spaces.firstWhere(
            (s) => s.id == spaceId, 
            orElse: () => throw Exception('Parkeringsplats ej hittad')
          );

          // Get start time (current time as default)
          final now = DateTime.now();
          final defaultStartTime = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
          
          stdout.write('Ange starttid (t.ex. $defaultStartTime) eller tryck Enter för nuvarande tid: ');
          String? startTime = stdin.readLineSync();
          if (startTime == null || startTime.isEmpty) {
            startTime = defaultStartTime;
          }

          // Create the parking
          final parking = await parkingRepository.addParking(
            selectedVehicle.id.toString(), 
            selectedSpace.id.toString(), 
            startTime, 
            null
          );
          
          stdout.writeln('Parkering har skapats för fordon ${selectedVehicle.type} (${selectedVehicle.registrationNumber}) på adress ${selectedSpace.adress}.');
          break;

        case 2:
          stdout.writeln('Hämtar alla parkeringar...');
          final parkings = await parkingRepository.getAllParkings();
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
          stdout.writeln('Hämtar aktiva parkeringar...');
          final activeParkings = await parkingRepository.getActiveParkings();
          if (activeParkings.isEmpty) {
            stdout.writeln('Inga aktiva parkeringar hittades.');
          } else {
            stdout.writeln('\nLista över aktiva parkeringar:');
            for (var parking in activeParkings) {
              stdout.writeln('ID: ${parking.id}, Fordon: ${parking.fordon}, Plats: ${parking.parkingPlace}, Starttid: ${parking.startTime}');
            }
          }
          break;

        case 4:
          stdout.writeln('Hämtar aktiva parkeringar...');
          final activeParkings = await parkingRepository.getActiveParkings();
          if (activeParkings.isEmpty) {
            stdout.writeln('Inga aktiva parkeringar hittades.');
            break;
          }

          stdout.writeln('\nLista över aktiva parkeringar:');
          for (var parking in activeParkings) {
            stdout.writeln('ID: ${parking.id}, Fordon: ${parking.fordon}, Plats: ${parking.parkingPlace}, Starttid: ${parking.startTime}');
          }

          stdout.write('Ange ID för parkeringen du vill avsluta: ');
          int? id = int.tryParse(stdin.readLineSync() ?? '');
          if (id == null) {
            stdout.writeln('Felaktigt ID.');
            break;
          }

          // Set end time to current time by default
          final now = DateTime.now();
          final defaultEndTime = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
          
          stdout.write('Ange sluttid (t.ex. $defaultEndTime) eller tryck Enter för nuvarande tid: ');
          String? endTime = stdin.readLineSync();
          if (endTime == null || endTime.isEmpty) {
            endTime = defaultEndTime;
          }

          bool ended = await parkingRepository.endParking(id, endTime);
          stdout.writeln(ended ? 'Parkeringen har avslutats.' : 'Det gick inte att avsluta parkeringen.');
          break;

        case 5:
          stdout.write('Ange ID för parkeringen du vill uppdatera: ');
          int? id = int.tryParse(stdin.readLineSync() ?? '');
          if (id == null) {
            stdout.writeln('Felaktigt ID.');
            break;
          }

          // Check if parking exists
          final parking = await parkingRepository.getParkingById(id);
          if (parking == null) {
            stdout.writeln('Parkeringen hittades inte.');
            break;
          }

          stdout.writeln('Uppdatera parkering (ID: ${parking.id}):');
          stdout.writeln('Nuvarande information:');
          stdout.writeln('Fordon: ${parking.fordon}');
          stdout.writeln('Plats: ${parking.parkingPlace}');
          stdout.writeln('Starttid: ${parking.startTime}');
          stdout.writeln('Sluttid: ${parking.endTime ?? "Pågår"}');

          stdout.write('Ange nytt fordon (lämna tomt för att behålla det gamla): ');
          String? newFordon = stdin.readLineSync();
          
          stdout.write('Ange ny parkeringsplats (lämna tomt för att behålla det gamla): ');
          String? newParkingPlace = stdin.readLineSync();
          
          stdout.write('Ange ny starttid (lämna tomt för att behålla det gamla): ');
          String? newStartTime = stdin.readLineSync();
          
          stdout.write('Ange ny sluttid (lämna tomt för att behålla det gamla): ');
          String? newEndTime = stdin.readLineSync();

          bool updated = await parkingRepository.updateParking(
            id,
            newFordon: newFordon?.isNotEmpty == true ? newFordon : null,
            newParkingPlace: newParkingPlace?.isNotEmpty == true ? newParkingPlace : null,
            newStartTime: newStartTime?.isNotEmpty == true ? newStartTime : null,
            newEndTime: newEndTime?.isNotEmpty == true ? newEndTime : null,
          );
          
          stdout.writeln(updated ? 'Parkeringen har uppdaterats.' : 'Uppdatering misslyckades.');
          break;

        case 6:
          stdout.write('Ange ID för parkeringen du vill ta bort: ');
          int? id = int.tryParse(stdin.readLineSync() ?? '');
          if (id == null) {
            stdout.writeln('Felaktigt ID.');
            break;
          }

          bool removed = await parkingRepository.removeParking(id);
          stdout.writeln(removed ? 'Parkeringen har tagits bort.' : 'Parkeringen hittades inte.');
          break;

        case 7:
          stdout.writeln('Återvänder till huvudmenyn...\n');
          return;
      }
    } catch (e) {
      stdout.writeln('Ett fel uppstod: $e');
    }
  }
}

Future<void> managePersonMenu(HttpPersonRepository repository) async {
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

    try {
      switch (choice) {
        case 1:
          stdout.write('Ange namn: ');
          String? name = stdin.readLineSync();

          stdout.write('Ange personnummer: ');
          String? personnummerInput = stdin.readLineSync();
          int? personnummer = int.tryParse(personnummerInput ?? '');

          if (name != null && personnummer != null) {
            await repository.addPerson(name, personnummer);
            stdout.writeln('Personen $name har lagts till.');
          } else {
            stdout.writeln('Felaktig inmatning.');
          }
          break;

        case 2:
          stdout.writeln('Hämtar alla personer...');
          final persons = await repository.getAllPersons();
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
          if (id == null) {
            stdout.writeln('Felaktigt ID.');
            break;
          }
          
          // Check if person exists
          final person = await repository.getPersonById(id);
          if (person == null) {
            stdout.writeln('Personen hittades inte.');
            break;
          }

          stdout.write('Ange nytt namn (lämna tomt för att behålla det gamla): ');
          String? newName = stdin.readLineSync();
          
          stdout.write('Ange nytt personnummer (lämna tomt för att behålla det gamla): ');
          String? newPersonnummerInput = stdin.readLineSync();
          int? newPersonnummer = int.tryParse(newPersonnummerInput ?? '');

          bool updated = await repository.updatePerson(
            id, 
            newName: newName?.isNotEmpty == true ? newName : null, 
            newPersonnummer: newPersonnummer
          );
          
          stdout.writeln(updated ? 'Personen har uppdaterats.' : 'Uppdatering misslyckades.');
          break;

        case 4:
          stdout.write('Ange ID för personen du vill ta bort: ');
          int? id = int.tryParse(stdin.readLineSync() ?? '');
          if (id == null) {
            stdout.writeln('Felaktigt ID.');
            break;
          }
          
          bool removed = await repository.removePerson(id);
          stdout.writeln(removed ? 'Personen har tagits bort.' : 'Personen hittades inte.');
          break;

        case 5:
          stdout.writeln('Återvänder till huvudmenyn...\n');
          return;
      }
    } catch (e) {
      stdout.writeln('Ett fel uppstod: $e');
    }
  }
}
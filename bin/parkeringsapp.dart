import 'dart:io';
import 'package:parkeringsapp/repositories/person_repository.dart';
import 'package:parkeringsapp/models/person.dart';
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
    stdout.writeln('Du har vält att hantera Personer. Vad vill du göra?');
    stdout.writeln('1. Skapa ny person');
    stdout.writeln('2. Visa alla personer');
    stdout.writeln('3. Uppdatera person');
    stdout.writeln('4. Ta bort person');
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
        repository.addPerson();
        break;
      case 2:
        repository.showAllPersons(); 
        break;
      case 3:
        stdout.write('Ange ID för personen du vill uppdatera: ');
        String? idInput = stdin.readLineSync();
        int? id = int.tryParse(idInput ?? '');
        if (id == null) {
          stdout.writeln('Ogiltigt ID.');
        } else {
          repository.updatePerson(id); 
        }
        break;
      case 4:
        stdout.write('Ange ID för personen du vill ta bort: ');
        String? idInput = stdin.readLineSync();
        int? id = int.tryParse(idInput ?? '');
        if (id == null) {
          stdout.writeln('Ogiltigt ID.');
        } else {
          repository.removePerson(id); 
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
    stdout.writeln('Du har vält att hantera Parkeringsplatser. Vad vill du göra?');
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
        repository.add();
        break;
      case 2:
        repository.showAll();
        break;
      case 3:
        stdout.write('Ange ID för parkeringsplatsen du vill uppdatera: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');
        if (id == null || !repository.update(id)) {
          stdout.writeln('Uppdatering misslyckades. Ogiltigt ID.');
        }
        break;
      case 4:
        stdout.write('Ange ID för parkeringsplatsen du vill ta bort: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');
        if (id == null || !repository.remove(id)) {
          stdout.writeln('Radering misslyckades. Ogiltigt ID.');
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
    stdout.writeln('Du har vält att hantera Parkeringar. Vad vill du göra? ');
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
        repository.add();
        break;
      case 2:
        repository.showAll();
        break;
      case 3:
        stdout.write('Ange ID för parkeringen du vill uppdatera: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');
        if (id == null || !repository.update(id)) {
          stdout.writeln('Uppdatering misslyckades. Ogiltigt ID.');
        }
        break;
      case 4:
        stdout.write('Ange ID för parkeringen du vill ta bort: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');
        if (id == null || !repository.remove(id)) {
          stdout.writeln('Radering misslyckades. Ogiltigt ID.');
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
    stdout.writeln('Du har vält att hantera Fordon. Vad vill du göra? ');
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
        repository.add(persons);
        break;
      case 2:
        repository.showAll();
        break;
      case 3:
        stdout.write('Ange ID för fordonet du vill uppdatera: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');
        if (id == null || !repository.update(id)) {
          stdout.writeln('Uppdatering misslyckades. Ogiltigt ID.');
        }
        break;
      case 4:
        stdout.write('Ange ID för fordonet du vill ta bort: ');
        int? id = int.tryParse(stdin.readLineSync() ?? '');
        if (id == null || !repository.remove(id)) {
          stdout.writeln('Radering misslyckades. Ogiltigt ID.');
        }
        break;
      case 5:
        stdout.writeln('Återvänder till huvudmenyn...\n');
        return;
    }
  }
}


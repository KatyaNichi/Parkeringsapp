import 'dart:io';
import '../models/person.dart';

class PersonRepository {
  final List<Person> _persons = [];

  // Add a new Person with user input
  void addPerson() {
    stdout.write('Ange namn: ');
    String? name = stdin.readLineSync();

    stdout.write('Ange personnummer: ');
    String? personnummerInput = stdin.readLineSync();
    int? personnummer = int.tryParse(personnummerInput ?? '');

    if (name == null || personnummer == null) {
      stdout.writeln('Felaktig inmatning. Personen skapades inte.');
      return;
    }

    _persons.add(Person(name: name, personnummer: personnummer));
    stdout.writeln('Personen $name har lagts till.');
  }

  // Remove a Person by id with confirmation
  bool removePerson(int id) {
    final person = _persons.firstWhere(
      (p) => p.id == id,
      orElse: () => Person(name: 'Unknown', personnummer: -1),
    );

    if (person.id != -1) {
      stdout.write('Är du säker på att du vill ta bort ${person.name}? (j/n): ');
      String? confirmation = stdin.readLineSync()?.toLowerCase();

      if (confirmation == 'j') {
        _persons.remove(person);
        stdout.writeln('Personen ${person.name} har tagits bort.');
        return true;
      } else {
        stdout.writeln('Personen togs inte bort.');
        return false;
      }
    }

    stdout.writeln('Person med id $id hittades inte.');
    return false;
  }

  // Update a Person by id with user input
  bool updatePerson(int id) {
    final personIndex = _persons.indexWhere((p) => p.id == id);
    if (personIndex == -1) {
      stdout.writeln('Person med id $id hittades inte.');
      return false;
    }

    stdout.write('Ange nytt namn (tryck enter för att behålla det gamla): ');
    String? newName = stdin.readLineSync();
    stdout.write('Ange nytt personnummer (tryck enter för att behålla det gamla): ');
    String? newPersonnummerInput = stdin.readLineSync();
    int? newPersonnummer = int.tryParse(newPersonnummerInput ?? '');

    final currentPerson = _persons[personIndex];
    _persons[personIndex] = Person(
      name: newName?.isNotEmpty == true ? newName! : currentPerson.name,
      personnummer: newPersonnummer ?? currentPerson.personnummer,
    );

    stdout.writeln('Personen har uppdaterats.');
    return true;
  }

  // Get all Persons
List<Person> getAllPersons() {
  return _persons;
}
 // Show all Persons for `managePersonMenu`
  void showAllPersons() {
    if (_persons.isEmpty) {
      stdout.writeln('Inga personer hittades.');
    } else {
      stdout.writeln('Lista över alla personer:');
      for (var person in _persons) {
        stdout.writeln('ID: ${person.id}, Namn: ${person.name}, Personnummer: ${person.personnummer}');
      }
    }
  }


  // Get a Person by id
  Person? getPersonById(int id) {
    final results = _persons.where((p) => p.id == id);
    return results.isNotEmpty ? results.first : null;
  }
}

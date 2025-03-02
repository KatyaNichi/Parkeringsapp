import '../models/person.dart';

class PersonRepository {
  final List<Person> _persons = [];

  // Add a new Person with user input
 // Add a new person
  void addPerson(String name, int personnummer) {
    _persons.add(Person(name: name, personnummer: personnummer));
  }

  
  // Remove a person by ID
  bool removePerson(int id) {
    final personIndex = _persons.indexWhere((p) => p.id == id);
    if (personIndex == -1) {
      return false; // Person not found
    }
    _persons.removeAt(personIndex);
    return true; // Successfully removed
  }

 // Update a person by ID
  bool updatePerson(int id, {String? newName, int? newPersonnummer}) {
    final personIndex = _persons.indexWhere((p) => p.id == id);
    if (personIndex == -1) {
      return false;
    }

    final currentPerson = _persons[personIndex];
    _persons[personIndex] = Person(
      name: newName ?? currentPerson.name,
      personnummer: newPersonnummer ?? currentPerson.personnummer,
    );

    return true;
  }
 // Get all persons
  List<Person> getAllPersons() {
    return _persons;
  }

 // Get a person by ID
 Person? getPersonById(int id) {
  return _persons.firstWhere(
    (p) => p.id == id,
    orElse: () => Person(name: '', personnummer: -1),
  );
}
}
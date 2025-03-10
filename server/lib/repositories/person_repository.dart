import 'dart:async';
import '../models/person.dart';
import '../utils/json_storage.dart';

class PersonRepository {
  final List<Person> _persons = [];
  bool _initialized = false;
  int _nextId = 1;
  static String FILENAME = 'persons.json';
  
  // Load data from storage
  Future<void> initialize() async {
    if (_initialized) return;
    
    final data = await JsonStorage.loadData(FILENAME);
    if (data != null) {
      final List<dynamic> personsJson = data['persons'];
      _persons.clear();
      
      for (var personJson in personsJson) {
        _persons.add(Person.fromJson(personJson));
      }
      
      _nextId = data['nextId'] ?? 1;
    }
    
    _initialized = true;
  }
  
  // Save data to storage
  Future<void> _saveData() async {
    await JsonStorage.saveData(FILENAME, {
      'persons': _persons.map((p) => p.toJson()).toList(),
      'nextId': _nextId,
    });
  }
  
  // Add a new person
  Future<Person> addPerson(String name, int personnummer) async {
    await initialize();
    
    final person = Person(
      id: _nextId++,
      name: name,
      personnummer: personnummer,
    );
    
    _persons.add(person);
    await _saveData();
    
    return person;
  }
  
  // Remove a person by ID
  Future<bool> removePerson(int id) async {
    await initialize();
    
    final personIndex = _persons.indexWhere((p) => p.id == id);
    if (personIndex == -1) {
      return false; // Person not found
    }
    
    _persons.removeAt(personIndex);
    await _saveData();
    
    return true; // Successfully removed
  }
  
  // Update a person by ID
  Future<bool> updatePerson(int id, {String? newName, int? newPersonnummer}) async {
    await initialize();
    
    final personIndex = _persons.indexWhere((p) => p.id == id);
    if (personIndex == -1) {
      return false;
    }
    
    final currentPerson = _persons[personIndex];
    _persons[personIndex] = Person(
      id: currentPerson.id,
      name: newName ?? currentPerson.name,
      personnummer: newPersonnummer ?? currentPerson.personnummer,
    );
    
    await _saveData();
    return true;
  }
  
  // Get all persons
  Future<List<Person>> getAllPersons() async {
    await initialize();
    return List.from(_persons);
  }
  
  // Get a person by ID
  Future<Person?> getPersonById(int id) async {
    await initialize();
    
    try {
      return _persons.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
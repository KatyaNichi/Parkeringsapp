
import 'dart:io';
import 'package:test/test.dart';
import 'package:server/repositories/person_repository.dart';
import 'package:server/utils/json_storage.dart';

void main() {
  late PersonRepository repository;
  final testDir = 'test/data';
  final testFile = '$testDir/persons_test.json';

  // Setup: Create a test directory and repository
  setUp(() async {
    // Create test directory if it doesn't exist
    final dir = Directory(testDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    // Delete test file if it exists
    final file = File(testFile);
    if (await file.exists()) {
      await file.delete();
    }
    
    // Override the FILENAME constant for testing
    PersonRepository.FILENAME = 'persons_test.json';
    JsonStorage.DATA_DIR = testDir;
    
    repository = PersonRepository();
    await repository.initialize();
  });

  // Cleanup: Remove test files
  tearDown(() async {
    final file = File(testFile);
    if (await file.exists()) {
      await file.delete();
    }
  });

  group('PersonRepository', () {
    test('should start with an empty list', () async {
      // When
      final persons = await repository.getAllPersons();
      
      // Then
      expect(persons, isEmpty);
    });

    test('should add a person', () async {
      // Given
      const name = 'Test Person';
      const personnummer = 1234567890;
      
      // When
      final person = await repository.addPerson(name, personnummer);
      
      // Then
      expect(person.name, equals(name));
      expect(person.personnummer, equals(personnummer));
      expect(person.id, equals(1)); // First person should have ID 1
      
      final persons = await repository.getAllPersons();
      expect(persons.length, equals(1));
    });

    test('should retrieve a person by ID', () async {
      // Given
      final person = await repository.addPerson('Test Person', 1234567890);
      
      // When
      final retrievedPerson = await repository.getPersonById(person.id);
      
      // Then
      expect(retrievedPerson, isNotNull);
      expect(retrievedPerson!.id, equals(person.id));
      expect(retrievedPerson.name, equals(person.name));
    });

    test('should update a person', () async {
      // Given
      final person = await repository.addPerson('Original Name', 1234567890);
      const newName = 'Updated Name';
      
      // When
      final updated = await repository.updatePerson(person.id, newName: newName);
      
      // Then
      expect(updated, isTrue);
      
      final retrievedPerson = await repository.getPersonById(person.id);
      expect(retrievedPerson!.name, equals(newName));
      expect(retrievedPerson.personnummer, equals(person.personnummer)); // Unchanged
    });

    test('should remove a person', () async {
      // Given
      final person = await repository.addPerson('Test Person', 1234567890);
      
      // When
      final removed = await repository.removePerson(person.id);
      
      // Then
      expect(removed, isTrue);
      
      final persons = await repository.getAllPersons();
      expect(persons, isEmpty);
    });

    test('should persist data across repository instances', () async {
      // Given
      await repository.addPerson('Test Person 1', 1111111111);
      await repository.addPerson('Test Person 2', 2222222222);
      
      // When: Create a new repository instance
      final newRepository = PersonRepository();
      await newRepository.initialize();
      final persons = await newRepository.getAllPersons();
      
      // Then: Data should still be there
      expect(persons.length, equals(2));
      expect(persons.map((p) => p.name), contains('Test Person 1'));
      expect(persons.map((p) => p.name), contains('Test Person 2'));
    });
  });
}
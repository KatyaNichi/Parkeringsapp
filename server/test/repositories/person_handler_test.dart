import 'dart:convert';
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:server/handlers/person_handler.dart';
import 'package:server/models/person.dart';
import 'package:server/repositories/person_repository.dart';

// Create a mock PersonRepository for testing
class MockPersonRepository extends PersonRepository {
  bool initialized = true;
  int nextId = 1;
  final Map<int, Person> persons = {};

  @override
  Future<void> initialize() async {
    // Already initialized for testing
  }

  @override
  Future<List<Person>> getAllPersons() async {
    return persons.values.toList();
  }

  @override
  Future<Person?> getPersonById(int id) async {
    return persons[id];
  }

  @override
  Future<Person> addPerson(String name, int personnummer) async {
    final person = Person(
      id: nextId++,
      name: name,
      personnummer: personnummer,
    );
    persons[person.id] = person;
    return person;
  }

  @override
  Future<bool> updatePerson(int id, {String? newName, int? newPersonnummer}) async {
    if (!persons.containsKey(id)) return false;
    
    final current = persons[id]!;
    persons[id] = Person(
      id: current.id,
      name: newName ?? current.name,
      personnummer: newPersonnummer ?? current.personnummer,
    );
    return true;
  }

  @override
  Future<bool> removePerson(int id) async {
    return persons.remove(id) != null;
  }
}

void main() {
  late MockPersonRepository repository;
  late PersonHandler handler;

  setUp(() {
    repository = MockPersonRepository();
    handler = PersonHandler(repository);
  });

  group('PersonHandler', () {
    test('getAllPersons returns empty list when no persons', () async {
      // Given - Use absolute URL
      final request = Request('GET', Uri.parse('http://localhost/'));
      
      // When
      final response = await handler.router.call(request);
      
      // Then
      expect(response.statusCode, equals(200));
      
      final body = await response.readAsString();
      final List<dynamic> personsJson = jsonDecode(body);
      expect(personsJson, isEmpty);
    });

    test('getAllPersons returns all persons', () async {
      // Given
      await repository.addPerson('Person 1', 1111111111);
      await repository.addPerson('Person 2', 2222222222);
      // Use absolute URL
      final request = Request('GET', Uri.parse('http://localhost/'));
      
      // When
      final response = await handler.router.call(request);
      
      // Then
      expect(response.statusCode, equals(200));
      
      final body = await response.readAsString();
      final List<dynamic> personsJson = jsonDecode(body);
      expect(personsJson.length, equals(2));
      expect(personsJson[0]['name'], equals('Person 1'));
      expect(personsJson[1]['name'], equals('Person 2'));
    });

    test('getPersonById returns person when exists', () async {
      // Given
      final person = await repository.addPerson('Test Person', 1234567890);
      // Use absolute URL
      final request = Request('GET', Uri.parse('http://localhost/${person.id}'));
      
      // When
      final response = await handler.router.call(request);
      
      // Then
      expect(response.statusCode, equals(200));
      
      final body = await response.readAsString();
      final Map<String, dynamic> personJson = jsonDecode(body);
      expect(personJson['id'], equals(person.id));
      expect(personJson['name'], equals(person.name));
    });

    test('getPersonById returns 404 when person not found', () async {
      // Given - Use absolute URL
      final request = Request('GET', Uri.parse('http://localhost/999')); // Non-existent ID
      
      // When
      final response = await handler.router.call(request);
      
      // Then
      expect(response.statusCode, equals(404));
    });

    test('createPerson adds a new person', () async {
      // Given - Use absolute URL
      final request = Request(
        'POST', 
        Uri.parse('http://localhost/'),
        body: jsonEncode({
          'name': 'New Person',
          'personnummer': 9876543210,
        }),
      );
      
      // When
      final response = await handler.router.call(request);
      
      // Then
      expect(response.statusCode, equals(201));
      
      final body = await response.readAsString();
      final responseData = jsonDecode(body);
      expect(responseData['message'], contains('created successfully'));
      expect(responseData['person']['name'], equals('New Person'));
      
      final persons = await repository.getAllPersons();
      expect(persons.length, equals(1));
    });
  });
}
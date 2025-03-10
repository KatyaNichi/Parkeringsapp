import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
//import '../models/person.dart';
import '../repositories/person_repository.dart';

class PersonHandler {
  final PersonRepository repository;
  
  PersonHandler(this.repository);
  
  // Create a router for person-related endpoints
  Router get router {
    final router = Router();
    
    // GET all persons
    router.get('/', _getAllPersons);
    
    // GET a specific person by ID
    router.get('/<id>', _getPersonById);
    
    // POST to create a new person
    router.post('/', _createPerson);
    
    // PUT to update an existing person
    router.put('/<id>', _updatePerson);
    
    // DELETE to remove a person
    router.delete('/<id>', _deletePerson);
    
    return router;
  }
  
  // Handler implementations
  Future<Response> _getAllPersons(Request request) async {
    final persons = await repository.getAllPersons();
    final personsJson = persons.map((person) => {
      'id': person.id,
      'name': person.name,
      'personnummer': person.personnummer,
    }).toList();
    
    return Response.ok(
      jsonEncode(personsJson),
      headers: {'content-type': 'application/json'},
    );
  }
  
  Future<Response> _getPersonById(Request request, String id) async {
    final personId = int.tryParse(id);
    if (personId == null) {
      return Response(400, body: 'Invalid ID format');
    }
    
    final person = await repository.getPersonById(personId);
    if (person == null) {
      return Response.notFound('Person not found');
    }
    
    return Response.ok(
      jsonEncode({
        'id': person.id,
        'name': person.name,
        'personnummer': person.personnummer,
      }),
      headers: {'content-type': 'application/json'},
    );
  }
  
  Future<Response> _createPerson(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      final name = data['name'] as String?;
      final personnummer = data['personnummer'] as int?;
      
      if (name == null || personnummer == null) {
        return Response(400, body: 'Missing required fields: name and personnummer');
      }
      
      final person = await repository.addPerson(name, personnummer);
      
      return Response(201, 
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'message': 'Person created successfully',
          'person': {
            'id': person.id,
            'name': person.name,
            'personnummer': person.personnummer,
          }
        })
      );
    } catch (e) {
      return Response(400, body: 'Invalid request: ${e.toString()}');
    }
  }
  
  Future<Response> _updatePerson(Request request, String id) async {
    try {
      final personId = int.tryParse(id);
      if (personId == null) {
        return Response(400, body: 'Invalid ID format');
      }
      
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      final newName = data['name'] as String?;
      final newPersonnummer = data['personnummer'] as int?;
      
      final success = await repository.updatePerson(
        personId,
        newName: newName,
        newPersonnummer: newPersonnummer,
      );
      
      if (!success) {
        return Response.notFound('Person not found');
      }
      
      return Response.ok(
        jsonEncode({'message': 'Person updated successfully'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response(400, body: 'Invalid request: ${e.toString()}');
    }
  }
  
  Future<Response> _deletePerson(Request request, String id) async {
    final personId = int.tryParse(id);
    if (personId == null) {
      return Response(400, body: 'Invalid ID format');
    }
    
    final success = await repository.removePerson(personId);
    if (!success) {
      return Response.notFound('Person not found');
    }
    
    return Response.ok(
      jsonEncode({'message': 'Person deleted successfully'}),
      headers: {'content-type': 'application/json'},
    );
  }
}
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../repositories/parking_space_repository.dart';

class ParkingSpaceHandler {
  final ParkingSpaceRepository repository;
  
  ParkingSpaceHandler(this.repository);
  
  // Create a router for parking space-related endpoints
  Router get router {
    final router = Router();
    
    // GET all parking spaces
    router.get('/', _getAllParkingSpaces);
    
    // GET a specific parking space by ID
    router.get('/<id>', _getParkingSpaceById);
    
    // POST to create a new parking space
    router.post('/', _createParkingSpace);
    
    // PUT to update an existing parking space
    router.put('/<id>', _updateParkingSpace);
    
    // DELETE to remove a parking space
    router.delete('/<id>', _deleteParkingSpace);
    
    return router;
  }
  
  // Handler implementations
  Future<Response> _getAllParkingSpaces(Request request) async {
    final spaces = await repository.getAll();
    final spacesJson = spaces.map((space) => {
      'id': space.id,
      'adress': space.adress,
      'pricePerHour': space.pricePerHour,
    }).toList();
    
    return Response.ok(
      jsonEncode(spacesJson),
      headers: {'content-type': 'application/json'},
    );
  }
  
  Future<Response> _getParkingSpaceById(Request request, String id) async {
    final spaceId = int.tryParse(id);
    if (spaceId == null) {
      return Response(400, body: 'Invalid ID format');
    }
    
    final space = await repository.getParkingSpaceById(spaceId);
    if (space == null) {
      return Response.notFound('Parking space not found');
    }
    
    return Response.ok(
      jsonEncode({
        'id': space.id,
        'adress': space.adress,
        'pricePerHour': space.pricePerHour,
      }),
      headers: {'content-type': 'application/json'},
    );
  }
  
  Future<Response> _createParkingSpace(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      final adress = data['adress'] as String?;
      final pricePerHour = data['pricePerHour'] as int?;
      
      if (adress == null || pricePerHour == null) {
        return Response(400, body: 'Missing required fields: adress and pricePerHour');
      }
      
      final space = await repository.add(adress, pricePerHour);
      
      return Response(201, 
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'message': 'Parking space created successfully',
          'parkingSpace': {
            'id': space.id,
            'adress': space.adress,
            'pricePerHour': space.pricePerHour,
          },
        })
      );
    } catch (e) {
      return Response(400, body: 'Invalid request: ${e.toString()}');
    }
  }
  
  Future<Response> _updateParkingSpace(Request request, String id) async {
    try {
      final spaceId = int.tryParse(id);
      if (spaceId == null) {
        return Response(400, body: 'Invalid ID format');
      }
      
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      final newAdress = data['adress'] as String?;
      final newPrice = data['pricePerHour'] as int?;
      
      final success = await repository.update(
        spaceId,
        newAdress: newAdress,
        newPrice: newPrice,
      );
      
      if (!success) {
        return Response.notFound('Parking space not found');
      }
      
      return Response.ok(
        jsonEncode({'message': 'Parking space updated successfully'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response(400, body: 'Invalid request: ${e.toString()}');
    }
  }
  
  Future<Response> _deleteParkingSpace(Request request, String id) async {
    final spaceId = int.tryParse(id);
    if (spaceId == null) {
      return Response(400, body: 'Invalid ID format');
    }
    
    final success = await repository.remove(spaceId);
    if (!success) {
      return Response.notFound('Parking space not found');
    }
    
    return Response.ok(
      jsonEncode({'message': 'Parking space deleted successfully'}),
      headers: {'content-type': 'application/json'},
    );
  }
}
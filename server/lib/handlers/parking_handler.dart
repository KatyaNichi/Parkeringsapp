import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../repositories/parking_repository.dart';

class ParkingHandler {
  final ParkingRepository repository;
  
  ParkingHandler(this.repository);
  
  // Create a router for parking-related endpoints
  Router get router {
    final router = Router();
    
    // GET all parkings
    router.get('/', _getAllParkings);
    
    // GET active parkings (no end time)
    router.get('/active', _getActiveParkings);
    
    // GET parkings by vehicle
    router.get('/vehicle/<fordon>', _getParkingsByVehicle);
    
    // GET parkings by parking place
    router.get('/place/<parkingPlace>', _getParkingsByPlace);
    
    // GET a specific parking by ID
    router.get('/<id>', _getParkingById);
    
    // POST to create a new parking
    router.post('/', _createParking);
    
    // PUT to update an existing parking
    router.put('/<id>', _updateParking);
    
    // PUT to end a parking (set end time)
    router.put('/<id>/end', _endParking);
    
    // DELETE to remove a parking
    router.delete('/<id>', _deleteParking);
    
    return router;
  }
  
  // Handler implementations
  Future<Response> _getAllParkings(Request request) async {
    final parkings = await repository.getAll();
    final parkingsJson = parkings.map(_parkingToJson).toList();
    
    return Response.ok(
      jsonEncode(parkingsJson),
      headers: {'content-type': 'application/json'},
    );
  }
  
  Future<Response> _getActiveParkings(Request request) async {
    final parkings = await repository.getActiveParkings();
    final parkingsJson = parkings.map(_parkingToJson).toList();
    
    return Response.ok(
      jsonEncode(parkingsJson),
      headers: {'content-type': 'application/json'},
    );
  }
  
  Future<Response> _getParkingsByVehicle(Request request, String fordon) async {
    final parkings = await repository.getParkingsByVehicle(fordon);
    final parkingsJson = parkings.map(_parkingToJson).toList();
    
    return Response.ok(
      jsonEncode(parkingsJson),
      headers: {'content-type': 'application/json'},
    );
  }
  
  Future<Response> _getParkingsByPlace(Request request, String parkingPlace) async {
    final parkings = await repository.getParkingsByPlace(parkingPlace);
    final parkingsJson = parkings.map(_parkingToJson).toList();
    
    return Response.ok(
      jsonEncode(parkingsJson),
      headers: {'content-type': 'application/json'},
    );
  }
  
  Future<Response> _getParkingById(Request request, String id) async {
    final parkingId = int.tryParse(id);
    if (parkingId == null) {
      return Response(400, body: 'Invalid ID format');
    }
    
    final parking = await repository.getParkingById(parkingId);
    if (parking == null) {
      return Response.notFound('Parking not found');
    }
    
    return Response.ok(
      jsonEncode(_parkingToJson(parking)),
      headers: {'content-type': 'application/json'},
    );
  }
  
  Future<Response> _createParking(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      final fordon = data['fordon'] as String?;
      final parkingPlace = data['parkingPlace'] as String?;
      final startTime = data['startTime'] as String?;
      final endTime = data['endTime'] as String?;
      
      if (fordon == null || parkingPlace == null || startTime == null) {
        return Response(400, body: 'Missing required fields: fordon, parkingPlace, and startTime');
      }
      
      final parking = await repository.add(fordon, parkingPlace, startTime, endTime);
      
      return Response(201, 
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'message': 'Parking created successfully',
          'parking': _parkingToJson(parking),
        })
      );
    } catch (e) {
      return Response(400, body: 'Invalid request: ${e.toString()}');
    }
  }
  
  Future<Response> _updateParking(Request request, String id) async {
    try {
      final parkingId = int.tryParse(id);
      if (parkingId == null) {
        return Response(400, body: 'Invalid ID format');
      }
      
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      final newFordon = data['fordon'] as String?;
      final newParkingPlace = data['parkingPlace'] as String?;
      final newStartTime = data['startTime'] as String?;
      final newEndTime = data['endTime'] as String?;
      
      final success = await repository.update(
        parkingId,
        newFordon: newFordon,
        newParkingPlace: newParkingPlace,
        newStartTime: newStartTime,
        newEndTime: newEndTime,
      );
      
      if (!success) {
        return Response.notFound('Parking not found');
      }
      
      return Response.ok(
        jsonEncode({'message': 'Parking updated successfully'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response(400, body: 'Invalid request: ${e.toString()}');
    }
  }
  
  Future<Response> _endParking(Request request, String id) async {
    try {
      final parkingId = int.tryParse(id);
      if (parkingId == null) {
        return Response(400, body: 'Invalid ID format');
      }
      
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      final endTime = data['endTime'] as String?;
      
      if (endTime == null) {
        return Response(400, body: 'Missing required field: endTime');
      }
      
      final success = await repository.endParking(parkingId, endTime);
      
      if (!success) {
        return Response.notFound('Parking not found');
      }
      
      return Response.ok(
        jsonEncode({'message': 'Parking ended successfully'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response(400, body: 'Invalid request: ${e.toString()}');
    }
  }
  
  Future<Response> _deleteParking(Request request, String id) async {
    final parkingId = int.tryParse(id);
    if (parkingId == null) {
      return Response(400, body: 'Invalid ID format');
    }
    
    final success = await repository.remove(parkingId);
    if (!success) {
      return Response.notFound('Parking not found');
    }
    
    return Response.ok(
      jsonEncode({'message': 'Parking deleted successfully'}),
      headers: {'content-type': 'application/json'},
    );
  }
  
  // Helper method to convert Parking to JSON
  Map<String, dynamic> _parkingToJson(parking) {
    return {
      'id': parking.id,
      'fordon': parking.fordon,
      'parkingPlace': parking.parkingPlace,
      'startTime': parking.startTime,
      'endTime': parking.endTime,
    };
  }
}
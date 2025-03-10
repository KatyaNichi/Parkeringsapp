import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../repositories/vehicle_repository.dart';

class VehicleHandler {
  final VehicleRepository repository;
  
  VehicleHandler(this.repository);
  
  // Create a router for vehicle-related endpoints
  Router get router {
    final router = Router();
    
    // GET all vehicles
    router.get('/', _getAllVehicles);
    
    // GET a specific vehicle by ID
    router.get('/<id>', _getVehicleById);
    
    // GET vehicles by owner ID
    router.get('/owner/<ownerId>', _getVehiclesByOwnerId);
    
    // POST to create a new vehicle
    router.post('/', _createVehicle);
    
    // PUT to update an existing vehicle
    router.put('/<id>', _updateVehicle);
    
    // DELETE to remove a vehicle
    router.delete('/<id>', _deleteVehicle);
    
    return router;
  }
  
  // Handler implementations
  Future<Response> _getAllVehicles(Request request) async {
    final vehicles = await repository.getAll();
    final vehiclesJson = vehicles.map((vehicle) => {
      'id': vehicle.id,
      'type': vehicle.type,
      'registrationNumber': vehicle.registrationNumber,
      'owner': {
        'id': vehicle.owner.id,
        'name': vehicle.owner.name,
        'personnummer': vehicle.owner.personnummer,
      },
    }).toList();
    
    return Response.ok(
      jsonEncode(vehiclesJson),
      headers: {'content-type': 'application/json'},
    );
  }
  
  Future<Response> _getVehicleById(Request request, String id) async {
    final vehicleId = int.tryParse(id);
    if (vehicleId == null) {
      return Response(400, body: 'Invalid ID format');
    }
    
    final vehicle = await repository.getVehicleById(vehicleId);
    if (vehicle == null) {
      return Response.notFound('Vehicle not found');
    }
    
    return Response.ok(
      jsonEncode({
        'id': vehicle.id,
        'type': vehicle.type,
        'registrationNumber': vehicle.registrationNumber,
        'owner': {
          'id': vehicle.owner.id,
          'name': vehicle.owner.name,
          'personnummer': vehicle.owner.personnummer,
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  }
  
  Future<Response> _getVehiclesByOwnerId(Request request, String ownerId) async {
    final id = int.tryParse(ownerId);
    if (id == null) {
      return Response(400, body: 'Invalid owner ID format');
    }
    
    final vehicles = await repository.getVehiclesByOwnerId(id);
    final vehiclesJson = vehicles.map((vehicle) => {
      'id': vehicle.id,
      'type': vehicle.type,
      'registrationNumber': vehicle.registrationNumber,
      'owner': {
        'id': vehicle.owner.id,
        'name': vehicle.owner.name,
        'personnummer': vehicle.owner.personnummer,
      },
    }).toList();
    
    return Response.ok(
      jsonEncode(vehiclesJson),
      headers: {'content-type': 'application/json'},
    );
  }
  
  Future<Response> _createVehicle(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      final type = data['type'] as String?;
      final registrationNumber = data['registrationNumber'] as int?;
      final ownerId = data['ownerId'] as int?;
      
      if (type == null || registrationNumber == null || ownerId == null) {
        return Response(400, body: 'Missing required fields: type, registrationNumber, and ownerId');
      }
      
      try {
        final vehicle = await repository.add(type, registrationNumber, ownerId);
        
        return Response(201, 
          headers: {'content-type': 'application/json'},
          body: jsonEncode({
            'message': 'Vehicle created successfully',
            'vehicle': {
              'id': vehicle.id,
              'type': vehicle.type,
              'registrationNumber': vehicle.registrationNumber,
              'owner': {
                'id': vehicle.owner.id,
                'name': vehicle.owner.name,
                'personnummer': vehicle.owner.personnummer,
              },
            },
          })
        );
      } catch (e) {
        return Response(400, body: 'Error creating vehicle: ${e.toString()}');
      }
    } catch (e) {
      return Response(400, body: 'Invalid request: ${e.toString()}');
    }
  }
  
  Future<Response> _updateVehicle(Request request, String id) async {
    try {
      final vehicleId = int.tryParse(id);
      if (vehicleId == null) {
        return Response(400, body: 'Invalid ID format');
      }
      
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      final newType = data['type'] as String?;
      final newRegistrationNumber = data['registrationNumber'] as int?;
      
      final success = await repository.update(
        vehicleId,
        newType: newType,
        newRegNum: newRegistrationNumber,
      );
      
      if (!success) {
        return Response.notFound('Vehicle not found');
      }
      
      return Response.ok(
        jsonEncode({'message': 'Vehicle updated successfully'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response(400, body: 'Invalid request: ${e.toString()}');
    }
  }
  
  Future<Response> _deleteVehicle(Request request, String id) async {
    final vehicleId = int.tryParse(id);
    if (vehicleId == null) {
      return Response(400, body: 'Invalid ID format');
    }
    
    final success = await repository.remove(vehicleId);
    if (!success) {
      return Response.notFound('Vehicle not found');
    }
    
    return Response.ok(
      jsonEncode({'message': 'Vehicle deleted successfully'}),
      headers: {'content-type': 'application/json'},
    );
  }
}
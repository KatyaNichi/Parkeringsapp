import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:server/handlers/person_handler.dart';
import 'package:server/handlers/vehicle_handler.dart';
import 'package:server/handlers/parking_space_handler.dart';
import 'package:server/handlers/parking_handler.dart';
import 'package:server/repositories/person_repository.dart';
import 'package:server/repositories/vehicle_repository.dart';
import 'package:server/repositories/parking_space_repository.dart';
import 'package:server/repositories/parking_repository.dart';

// Define route handlers
Response _rootHandler(Request request) {
  return Response.ok('Parkeringsapp Server is Running');
}

Response _pingHandler(Request request) {
  return Response.ok('pong');
}

void main() async {
  final ip = InternetAddress.anyIPv4;
  final port = 8080;

  // Create repositories
  final personRepository = PersonRepository();
  final vehicleRepository = VehicleRepository(personRepository);
  final parkingSpaceRepository = ParkingSpaceRepository();
  final parkingRepository = ParkingRepository();

  await personRepository.initialize();
  await vehicleRepository.initialize();
  await parkingSpaceRepository.initialize();
  await parkingRepository.initialize();

  // Create handlers with their repositories
  final personHandler = PersonHandler(personRepository);
  final vehicleHandler = VehicleHandler(vehicleRepository);
  final parkingSpaceHandler = ParkingSpaceHandler(parkingSpaceRepository);
  final parkingHandler = ParkingHandler(parkingRepository);

  // Set up router
  final router = Router()
    ..get('/', _rootHandler)
    ..get('/ping', _pingHandler)
    // Mount the person handler under /api/persons
    ..mount('/api/persons', personHandler.router)
    // Mount the vehicle handler under /api/vehicles
    ..mount('/api/vehicles', vehicleHandler.router)
    // Mount the parking space handler under /api/parkingSpaces
    ..mount('/api/parkingSpaces', parkingSpaceHandler.router)
    // Mount the parking handler under /api/parkings
    ..mount('/api/parkings', parkingHandler.router);

  // Create a pipeline with logging middleware
  final handler = Pipeline()
    .addMiddleware(logRequests())
    .addHandler(router);

  final server = await shelf_io.serve(handler, ip, port);
  print('Server running on http://${server.address.host}:${server.port}');
}
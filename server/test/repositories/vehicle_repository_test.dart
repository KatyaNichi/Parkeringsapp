import 'dart:io';
import 'package:test/test.dart';
import 'package:server/models/person.dart';
import 'package:server/repositories/person_repository.dart';
import 'package:server/repositories/vehicle_repository.dart';
import 'package:server/utils/json_storage.dart';

void main() {
  late PersonRepository personRepository;
  late VehicleRepository vehicleRepository;
  late Person testPerson;
  
  final testDir = 'test/data';
  final personTestFile = '$testDir/persons_test.json';
  final vehicleTestFile = '$testDir/vehicles_test.json';

  // Setup: Create test directories and repositories
  setUp(() async {
    // Create test directory if it doesn't exist
    final dir = Directory(testDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    // Delete test files if they exist
    final personFile = File(personTestFile);
    if (await personFile.exists()) {
      await personFile.delete();
    }
    
    final vehicleFile = File(vehicleTestFile);
    if (await vehicleFile.exists()) {
      await vehicleFile.delete();
    }
    
    // Override FILENAME constants for testing
    PersonRepository.FILENAME = 'persons_test.json';
    VehicleRepository.FILENAME = 'vehicles_test.json';
    JsonStorage.DATA_DIR = testDir;
    
    personRepository = PersonRepository();
    await personRepository.initialize();
    
    vehicleRepository = VehicleRepository(personRepository);
    await vehicleRepository.initialize();
    
    // Create a test person to use in vehicle tests
    testPerson = await personRepository.addPerson('Vehicle Owner', 1234567890);
  });

  // Cleanup: Remove test files
  tearDown(() async {
    final personFile = File(personTestFile);
    if (await personFile.exists()) {
      await personFile.delete();
    }
    
    final vehicleFile = File(vehicleTestFile);
    if (await vehicleFile.exists()) {
      await vehicleFile.delete();
    }
  });

  group('VehicleRepository', () {
    test('should start with an empty list', () async {
      // When
      final vehicles = await vehicleRepository.getAll();
      
      // Then
      expect(vehicles, isEmpty);
    });

    test('should add a vehicle', () async {
      // Given
      const type = 'Car';
      const registrationNumber = 12345;
      
      // When
      final vehicle = await vehicleRepository.add(type, registrationNumber, testPerson.id);
      
      // Then
      expect(vehicle.type, equals(type));
      expect(vehicle.registrationNumber, equals(registrationNumber));
      expect(vehicle.owner.id, equals(testPerson.id));
      expect(vehicle.id, equals(1)); // First vehicle should have ID 1
      
      final vehicles = await vehicleRepository.getAll();
      expect(vehicles.length, equals(1));
    });

    test('should throw exception when adding vehicle with non-existent owner', () async {
      // When/Then
      expect(
        () => vehicleRepository.add('Car', 12345, 999), // Non-existent owner ID
        throwsException,
      );
    });

    test('should retrieve a vehicle by ID', () async {
      // Given
      final vehicle = await vehicleRepository.add('Car', 12345, testPerson.id);
      
      // When
      final retrievedVehicle = await vehicleRepository.getVehicleById(vehicle.id);
      
      // Then
      expect(retrievedVehicle, isNotNull);
      expect(retrievedVehicle!.id, equals(vehicle.id));
      expect(retrievedVehicle.type, equals(vehicle.type));
    });

    test('should update a vehicle', () async {
      // Given
      final vehicle = await vehicleRepository.add('Car', 12345, testPerson.id);
      const newType = 'Truck';
      
      // When
      final updated = await vehicleRepository.update(vehicle.id, newType: newType);
      
      // Then
      expect(updated, isTrue);
      
      final retrievedVehicle = await vehicleRepository.getVehicleById(vehicle.id);
      expect(retrievedVehicle!.type, equals(newType));
      expect(retrievedVehicle.registrationNumber, equals(vehicle.registrationNumber)); // Unchanged
    });

    test('should remove a vehicle', () async {
      // Given
      final vehicle = await vehicleRepository.add('Car', 12345, testPerson.id);
      
      // When
      final removed = await vehicleRepository.remove(vehicle.id);
      
      // Then
      expect(removed, isTrue);
      
      final vehicles = await vehicleRepository.getAll();
      expect(vehicles, isEmpty);
    });

    test('should get vehicles by owner ID', () async {
      // Given
      final person1 = await personRepository.addPerson('Owner 1', 1111111111);
      final person2 = await personRepository.addPerson('Owner 2', 2222222222);
      
      await vehicleRepository.add('Car 1', 11111, person1.id);
      await vehicleRepository.add('Car 2', 22222, person1.id);
      await vehicleRepository.add('Car 3', 33333, person2.id);
      
      // When
      final person1Vehicles = await vehicleRepository.getVehiclesByOwnerId(person1.id);
      
      // Then
      expect(person1Vehicles.length, equals(2));
      expect(person1Vehicles.map((v) => v.type), contains('Car 1'));
      expect(person1Vehicles.map((v) => v.type), contains('Car 2'));
      expect(person1Vehicles.map((v) => v.type), isNot(contains('Car 3')));
    });
  });
}
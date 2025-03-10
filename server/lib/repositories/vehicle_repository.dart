import 'dart:async';
import '../models/vehicle.dart';
//import '../models/person.dart';
import '../utils/json_storage.dart';
import 'person_repository.dart';

class VehicleRepository {
  final List<Vehicle> _vehicles = [];
  final PersonRepository _personRepository;
  bool _initialized = false;
  int _nextId = 1;
  static String FILENAME = 'vehicles.json';
  
  VehicleRepository(this._personRepository);
  
  // Load data from storage
  Future<void> initialize() async {
    if (_initialized) return;
    
    final data = await JsonStorage.loadData(FILENAME);
    if (data != null) {
      final List<dynamic> vehiclesJson = data['vehicles'];
      _vehicles.clear();
      
      for (var vehicleJson in vehiclesJson) {
        final ownerId = vehicleJson['ownerId'];
        final owner = await _personRepository.getPersonById(ownerId);
        
        if (owner != null) {
          _vehicles.add(Vehicle.fromJson(vehicleJson, owner));
        }
      }
      
      _nextId = data['nextId'] ?? 1;
    }
    
    _initialized = true;
  }
  
  // Save data to storage
  Future<void> _saveData() async {
    await JsonStorage.saveData(FILENAME, {
      'vehicles': _vehicles.map((v) => v.toJson()).toList(),
      'nextId': _nextId,
    });
  }
  
  // Add a new vehicle
  Future<Vehicle> add(String type, int registrationNumber, int ownerId) async {
    await initialize();
    
    final owner = await _personRepository.getPersonById(ownerId);
    if (owner == null) {
      throw Exception('Owner not found');
    }
    
    final vehicle = Vehicle(
      id: _nextId++,
      type: type,
      registrationNumber: registrationNumber,
      owner: owner,
    );
    
    _vehicles.add(vehicle);
    await _saveData();
    
    return vehicle;
  }
  
  // Get all vehicles
  Future<List<Vehicle>> getAll() async {
    await initialize();
    return List.from(_vehicles);
  }
  
  // Get a vehicle by ID
  Future<Vehicle?> getVehicleById(int id) async {
    await initialize();
    
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Update a vehicle by ID
  Future<bool> update(int id, {String? newType, int? newRegNum}) async {
    await initialize();
    
    final vehicleIndex = _vehicles.indexWhere((v) => v.id == id);
    if (vehicleIndex == -1) return false;
    
    final currentVehicle = _vehicles[vehicleIndex];
    _vehicles[vehicleIndex] = Vehicle(
      id: currentVehicle.id,
      type: newType ?? currentVehicle.type,
      registrationNumber: newRegNum ?? currentVehicle.registrationNumber,
      owner: currentVehicle.owner,
    );
    
    await _saveData();
    return true;
  }
  
  // Remove a vehicle by ID
  Future<bool> remove(int id) async {
    await initialize();
    
    final vehicleIndex = _vehicles.indexWhere((v) => v.id == id);
    if (vehicleIndex == -1) return false;
    
    _vehicles.removeAt(vehicleIndex);
    await _saveData();
    
    return true;
  }
  
  // Get vehicles by owner ID
  Future<List<Vehicle>> getVehiclesByOwnerId(int ownerId) async {
    await initialize();
    return _vehicles.where((v) => v.owner.id == ownerId).toList();
  }
}
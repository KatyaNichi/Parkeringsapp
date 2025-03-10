import 'dart:async';
import '../models/parking_space.dart';
import '../utils/json_storage.dart';

class ParkingSpaceRepository {
  final List<ParkingSpace> _parkingSpaces = [];
  bool _initialized = false;
  int _nextId = 1;
  static String FILENAME = 'parking_spaces.json';
  
  // Load data from storage
  Future<void> initialize() async {
    if (_initialized) return;
    
    final data = await JsonStorage.loadData(FILENAME);
    if (data != null) {
      final List<dynamic> spacesJson = data['parkingSpaces'];
      _parkingSpaces.clear();
      
      for (var spaceJson in spacesJson) {
        _parkingSpaces.add(ParkingSpace.fromJson(spaceJson));
      }
      
      _nextId = data['nextId'] ?? 1;
    }
    
    _initialized = true;
  }
  
  // Save data to storage
  Future<void> _saveData() async {
    await JsonStorage.saveData(FILENAME, {
      'parkingSpaces': _parkingSpaces.map((s) => s.toJson()).toList(),
      'nextId': _nextId,
    });
  }
  
  // Add a new parking space
  Future<ParkingSpace> add(String adress, int pricePerHour) async {
    await initialize();
    
    final space = ParkingSpace(
      id: _nextId++,
      adress: adress,
      pricePerHour: pricePerHour,
    );
    
    _parkingSpaces.add(space);
    await _saveData();
    
    return space;
  }
  
  // Get all parking spaces
  Future<List<ParkingSpace>> getAll() async {
    await initialize();
    return List.from(_parkingSpaces);
  }
  
  // Get a specific parking space by ID
  Future<ParkingSpace?> getParkingSpaceById(int id) async {
    await initialize();
    
    try {
      return _parkingSpaces.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Update a parking space by ID
  Future<bool> update(int id, {String? newAdress, int? newPrice}) async {
    await initialize();
    
    final spaceIndex = _parkingSpaces.indexWhere((p) => p.id == id);
    if (spaceIndex == -1) return false;
    
    final currentSpace = _parkingSpaces[spaceIndex];
    _parkingSpaces[spaceIndex] = ParkingSpace(
      id: currentSpace.id,
      adress: newAdress ?? currentSpace.adress,
      pricePerHour: newPrice ?? currentSpace.pricePerHour,
    );
    
    await _saveData();
    return true;
  }
  
  // Remove a parking space by ID
  Future<bool> remove(int id) async {
    await initialize();
    
    final spaceIndex = _parkingSpaces.indexWhere((p) => p.id == id);
    if (spaceIndex == -1) return false;
    
    _parkingSpaces.removeAt(spaceIndex);
    await _saveData();
    
    return true;
  }
}
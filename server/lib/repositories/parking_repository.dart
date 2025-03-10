import 'dart:async';
import '../models/parking.dart';
import '../utils/json_storage.dart';

class ParkingRepository {
  final List<Parking> _parkings = [];
  bool _initialized = false;
  int _nextId = 1;
  static String FILENAME = 'parkings.json';
  
  // Load data from storage
  Future<void> initialize() async {
    if (_initialized) return;
    
    final data = await JsonStorage.loadData(FILENAME);
    if (data != null) {
      final List<dynamic> parkingsJson = data['parkings'];
      _parkings.clear();
      
      for (var parkingJson in parkingsJson) {
        _parkings.add(Parking.fromJson(parkingJson));
      }
      
      _nextId = data['nextId'] ?? 1;
    }
    
    _initialized = true;
  }
  
  // Save data to storage
  Future<void> _saveData() async {
    await JsonStorage.saveData(FILENAME, {
      'parkings': _parkings.map((p) => p.toJson()).toList(),
      'nextId': _nextId,
    });
  }
  
  // Add a new parking
  Future<Parking> add(String fordon, String parkingPlace, String startTime, String? endTime) async {
    await initialize();
    
    final parking = Parking(
      id: _nextId++,
      fordon: fordon,
      parkingPlace: parkingPlace,
      startTime: startTime,
      endTime: endTime,
    );
    
    _parkings.add(parking);
    await _saveData();
    
    return parking;
  }
  
  // Get all parkings
  Future<List<Parking>> getAll() async {
    await initialize();
    return List.from(_parkings);
  }
  
  // Get a specific parking by ID
  Future<Parking?> getParkingById(int id) async {
    await initialize();
    
    try {
      return _parkings.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get parkings by vehicle
  Future<List<Parking>> getParkingsByVehicle(String fordon) async {
    await initialize();
    return _parkings.where((p) => p.fordon == fordon).toList();
  }
  
  // Get parkings by parking place
  Future<List<Parking>> getParkingsByPlace(String parkingPlace) async {
    await initialize();
    return _parkings.where((p) => p.parkingPlace == parkingPlace).toList();
  }
  
  // Get active parkings (no end time)
  Future<List<Parking>> getActiveParkings() async {
    await initialize();
    return _parkings.where((p) => p.endTime == null).toList();
  }
  
  // Update a parking by ID
  Future<bool> update(int id, {String? newFordon, String? newParkingPlace, String? newStartTime, String? newEndTime}) async {
    await initialize();
    
    final parkingIndex = _parkings.indexWhere((p) => p.id == id);
    if (parkingIndex == -1) return false;
    
    final currentParking = _parkings[parkingIndex];
    _parkings[parkingIndex] = Parking(
      id: currentParking.id,
      fordon: newFordon ?? currentParking.fordon,
      parkingPlace: newParkingPlace ?? currentParking.parkingPlace,
      startTime: newStartTime ?? currentParking.startTime,
      endTime: newEndTime ?? currentParking.endTime,
    );
    
    await _saveData();
    return true;
  }
  
  // End a parking (set end time)
  Future<bool> endParking(int id, String endTime) async {
    await initialize();
    
    final parkingIndex = _parkings.indexWhere((p) => p.id == id);
    if (parkingIndex == -1) return false;
    
    final currentParking = _parkings[parkingIndex];
    _parkings[parkingIndex] = Parking(
      id: currentParking.id,
      fordon: currentParking.fordon,
      parkingPlace: currentParking.parkingPlace,
      startTime: currentParking.startTime,
      endTime: endTime,
    );
    
    await _saveData();
    return true;
  }
  
  // Remove a parking by ID
  Future<bool> remove(int id) async {
    await initialize();
    
    final parkingIndex = _parkings.indexWhere((p) => p.id == id);
    if (parkingIndex == -1) return false;
    
    _parkings.removeAt(parkingIndex);
    await _saveData();
    
    return true;
  }
}
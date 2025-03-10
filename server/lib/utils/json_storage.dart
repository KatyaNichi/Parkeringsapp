import 'dart:convert';
import 'dart:io';

class JsonStorage {
  static String DATA_DIR = 'data';
  
  // Ensure data directory exists
  static Future<void> ensureDataDirectoryExists() async {
    final directory = Directory(DATA_DIR);
    if (!await directory.exists()) {
      await directory.create();
    }
  }
  
  // Save data to a JSON file
  static Future<void> saveData(String filename, dynamic data) async {
    await ensureDataDirectoryExists();
    final file = File('$DATA_DIR/$filename');
    final jsonString = jsonEncode(data);
    await file.writeAsString(jsonString);
  }
  
  // Load data from a JSON file
  static Future<dynamic> loadData(String filename) async {
    await ensureDataDirectoryExists();
    final file = File('$DATA_DIR/$filename');
    
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      return jsonDecode(jsonString);
    }
    
    return null;
  }
}
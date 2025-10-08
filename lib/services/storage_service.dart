import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car.dart';
import '../models/service_item.dart';
import '../models/service_event.dart';
import '../models/reminder.dart';
import '../models/app_settings.dart';
import '../constants/default_items.dart';
import 'webdav_service.dart';

class StorageService {
  static const String _carsFile = 'cars.json';
  static const String _activeCarKey = 'active_car_id';
  
  WebdavService? _webdavService;
  
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }
  
  String _getCarFileName(String carId, String type) {
    return 'car_${carId}_$type.json';
  }
  
  /// Set WebDAV service for auto-sync
  void setWebdavService(WebdavService? service) {
    _webdavService = service;
  }
  
  // Cars Management
  Future<List<Car>> loadCars() async {
    try {
      final file = await _getFile(_carsFile);
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((item) => Car.fromJson(item)).toList();
    } catch (e) {
      print('Error loading cars: $e');
      return [];
    }
  }
  
  Future<void> saveCars(List<Car> cars) async {
    try {
      final file = await _getFile(_carsFile);
      final jsonData = cars.map((car) => car.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
      
      // Auto-sync to WebDAV
      await _webdavService?.autoSyncFile(_carsFile);
    } catch (e) {
      print('Error saving cars: $e');
    }
  }
  
  Future<String?> loadActiveCarId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_activeCarKey);
    } catch (e) {
      print('Error loading active car ID: $e');
      return null;
    }
  }
  
  Future<void> saveActiveCarId(String carId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeCarKey, carId);
    } catch (e) {
      print('Error saving active car ID: $e');
    }
  }

  // Service Items (per car)
  Future<List<ServiceItem>> loadServiceItems(String carId) async {
    try {
      final file = await _getFile(_getCarFileName(carId, 'service_items'));
      if (!await file.exists()) {
        // Initialize with default items
        await saveServiceItems(defaultServiceItems, carId);
        return defaultServiceItems;
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((item) => ServiceItem.fromJson(item)).toList();
    } catch (e) {
      print('Error loading service items: $e');
      return defaultServiceItems;
    }
  }

  Future<void> saveServiceItems(List<ServiceItem> items, String carId) async {
    try {
      final fileName = _getCarFileName(carId, 'service_items');
      final file = await _getFile(fileName);
      final jsonData = items.map((item) => item.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
      
      // Auto-sync to WebDAV
      await _webdavService?.autoSyncFile(fileName);
    } catch (e) {
      print('Error saving service items: $e');
    }
  }

  // Service Events (per car)
  Future<List<ServiceEvent>> loadServiceEvents(String carId) async {
    try {
      final file = await _getFile(_getCarFileName(carId, 'service_events'));
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((item) => ServiceEvent.fromJson(item)).toList();
    } catch (e) {
      print('Error loading service events: $e');
      return [];
    }
  }

  Future<void> saveServiceEvents(List<ServiceEvent> events, String carId) async {
    try {
      final fileName = _getCarFileName(carId, 'service_events');
      final file = await _getFile(fileName);
      final jsonData = events.map((event) => event.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
      
      // Auto-sync to WebDAV
      await _webdavService?.autoSyncFile(fileName);
    } catch (e) {
      print('Error saving service events: $e');
    }
  }

  // Reminders (per car)
  Future<List<Reminder>> loadReminders(String carId) async {
    try {
      final file = await _getFile(_getCarFileName(carId, 'reminders'));
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((item) => Reminder.fromJson(item)).toList();
    } catch (e) {
      print('Error loading reminders: $e');
      return [];
    }
  }

  Future<void> saveReminders(List<Reminder> reminders, String carId) async {
    try {
      final fileName = _getCarFileName(carId, 'reminders');
      final file = await _getFile(fileName);
      final jsonData = reminders.map((reminder) => reminder.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
      
      // Auto-sync to WebDAV
      await _webdavService?.autoSyncFile(fileName);
    } catch (e) {
      print('Error saving reminders: $e');
    }
  }

  // Settings (per car)
  Future<AppSettings> loadSettings(String carId) async {
    try {
      final file = await _getFile(_getCarFileName(carId, 'settings'));
      if (!await file.exists()) {
        final defaultSettings = AppSettings(currentMileage: 0);
        await saveSettings(defaultSettings, carId);
        return defaultSettings;
      }
      final contents = await file.readAsString();
      final Map<String, dynamic> jsonData = json.decode(contents);
      return AppSettings.fromJson(jsonData);
    } catch (e) {
      print('Error loading settings: $e');
      return AppSettings(currentMileage: 0);
    }
  }

  Future<void> saveSettings(AppSettings settings, String carId) async {
    try {
      final fileName = _getCarFileName(carId, 'settings');
      final file = await _getFile(fileName);
      await file.writeAsString(json.encode(settings.toJson()));
      
      // Auto-sync to WebDAV
      await _webdavService?.autoSyncFile(fileName);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }
}


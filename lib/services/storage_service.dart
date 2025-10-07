import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/service_item.dart';
import '../models/service_event.dart';
import '../models/reminder.dart';
import '../models/app_settings.dart';
import '../constants/default_items.dart';

class StorageService {
  static const String _serviceItemsFile = 'service_items.json';
  static const String _serviceEventsFile = 'service_events.json';
  static const String _remindersFile = 'reminders.json';
  static const String _settingsFile = 'settings.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  // Service Items
  Future<List<ServiceItem>> loadServiceItems() async {
    try {
      final file = await _getFile(_serviceItemsFile);
      if (!await file.exists()) {
        // Initialize with default items
        await saveServiceItems(defaultServiceItems);
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

  Future<void> saveServiceItems(List<ServiceItem> items) async {
    try {
      final file = await _getFile(_serviceItemsFile);
      final jsonData = items.map((item) => item.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      print('Error saving service items: $e');
    }
  }

  // Service Events
  Future<List<ServiceEvent>> loadServiceEvents() async {
    try {
      final file = await _getFile(_serviceEventsFile);
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

  Future<void> saveServiceEvents(List<ServiceEvent> events) async {
    try {
      final file = await _getFile(_serviceEventsFile);
      final jsonData = events.map((event) => event.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      print('Error saving service events: $e');
    }
  }

  // Reminders
  Future<List<Reminder>> loadReminders() async {
    try {
      final file = await _getFile(_remindersFile);
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

  Future<void> saveReminders(List<Reminder> reminders) async {
    try {
      final file = await _getFile(_remindersFile);
      final jsonData = reminders.map((reminder) => reminder.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      print('Error saving reminders: $e');
    }
  }

  // Settings
  Future<AppSettings> loadSettings() async {
    try {
      final file = await _getFile(_settingsFile);
      if (!await file.exists()) {
        final defaultSettings = AppSettings(currentMileage: 0);
        await saveSettings(defaultSettings);
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

  Future<void> saveSettings(AppSettings settings) async {
    try {
      final file = await _getFile(_settingsFile);
      await file.writeAsString(json.encode(settings.toJson()));
    } catch (e) {
      print('Error saving settings: $e');
    }
  }
}


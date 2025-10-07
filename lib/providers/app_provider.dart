import 'package:flutter/material.dart';
import '../models/car.dart';
import '../models/service_item.dart';
import '../models/service_event.dart';
import '../models/reminder.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class AppProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<Car> _cars = [];
  String? _activeCarId;
  
  List<ServiceItem> _serviceItems = [];
  List<ServiceEvent> _serviceEvents = [];
  List<Reminder> _reminders = [];
  AppSettings _settings = AppSettings(currentMileage: 0);

  bool _isLoading = true;

  List<Car> get cars => _cars;
  Car? get activeCar {
    if (_activeCarId != null) {
      try {
        return _cars.firstWhere((c) => c.id == _activeCarId);
      } catch (e) {
        return _cars.isNotEmpty ? _cars.first : null;
      }
    }
    return _cars.isNotEmpty ? _cars.first : null;
  }
  
  List<ServiceItem> get serviceItems => _serviceItems;
  List<ServiceEvent> get serviceEvents => _serviceEvents;
  List<Reminder> get reminders => _reminders;
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  AppProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    // Load cars and active car ID
    _cars = await _storageService.loadCars();
    _activeCarId = await _storageService.loadActiveCarId();
    
    // If no cars exist, create a default one
    if (_cars.isEmpty) {
      final defaultCar = Car.create(name: 'My Car', plateNumber: '');
      _cars.add(defaultCar);
      _activeCarId = defaultCar.id;
      await _storageService.saveCars(_cars);
      await _storageService.saveActiveCarId(_activeCarId!);
    }
    
    // Set active car if not set
    if (_activeCarId == null || !_cars.any((c) => c.id == _activeCarId)) {
      _activeCarId = _cars.first.id;
      await _storageService.saveActiveCarId(_activeCarId!);
    }

    // Load data for active car
    await _loadCarData(_activeCarId!);

    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> _loadCarData(String carId) async {
    _serviceItems = await _storageService.loadServiceItems(carId);
    _serviceEvents = await _storageService.loadServiceEvents(carId);
    _reminders = await _storageService.loadReminders(carId);
    _settings = await _storageService.loadSettings(carId);
  }

  // Car Management
  Future<void> addCar(Car car) async {
    _cars.add(car);
    await _storageService.saveCars(_cars);
    notifyListeners();
  }
  
  Future<void> updateCar(Car car) async {
    final index = _cars.indexWhere((c) => c.id == car.id);
    if (index != -1) {
      _cars[index] = car;
      await _storageService.saveCars(_cars);
      notifyListeners();
    }
  }
  
  Future<void> deleteCar(String carId) async {
    if (_cars.length <= 1) {
      // Don't allow deleting the last car
      return;
    }
    
    _cars.removeWhere((car) => car.id == carId);
    await _storageService.saveCars(_cars);
    
    // If we deleted the active car, switch to the first available car
    if (_activeCarId == carId) {
      _activeCarId = _cars.first.id;
      await _storageService.saveActiveCarId(_activeCarId!);
      await _loadCarData(_activeCarId!);
    }
    
    notifyListeners();
  }
  
  Future<void> switchCar(String carId) async {
    if (_activeCarId == carId) return;
    
    _activeCarId = carId;
    await _storageService.saveActiveCarId(carId);
    await _loadCarData(carId);
    notifyListeners();
  }

  // Service Items
  Future<void> addServiceItem(ServiceItem item) async {
    _serviceItems.add(item);
    await _storageService.saveServiceItems(_serviceItems, _activeCarId!);
    notifyListeners();
  }

  Future<void> updateServiceItem(ServiceItem item) async {
    final index = _serviceItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _serviceItems[index] = item;
      await _storageService.saveServiceItems(_serviceItems, _activeCarId!);
      notifyListeners();
    }
  }

  Future<void> deleteServiceItem(String itemId) async {
    _serviceItems.removeWhere((item) => item.id == itemId);
    await _storageService.saveServiceItems(_serviceItems, _activeCarId!);
    notifyListeners();
  }

  ServiceItem? getServiceItem(String itemId) {
    try {
      return _serviceItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // Service Events
  Future<void> addServiceEvent(ServiceEvent event) async {
    _serviceEvents.add(event);
    _serviceEvents.sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
    await _storageService.saveServiceEvents(_serviceEvents, _activeCarId!);
    
    // Auto-update current mileage if this event has higher mileage
    if (event.mileage > _settings.currentMileage) {
      _settings = _settings.copyWith(currentMileage: event.mileage);
      await _storageService.saveSettings(_settings, _activeCarId!);
    }
    
    notifyListeners();
  }

  Future<void> updateServiceEvent(ServiceEvent event) async {
    final index = _serviceEvents.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _serviceEvents[index] = event;
      _serviceEvents.sort((a, b) => b.date.compareTo(a.date));
      await _storageService.saveServiceEvents(_serviceEvents, _activeCarId!);
      
      // Auto-update current mileage to highest mileage in any event
      final maxMileage = _serviceEvents.map((e) => e.mileage).reduce((a, b) => a > b ? a : b);
      if (maxMileage > _settings.currentMileage) {
        _settings = _settings.copyWith(currentMileage: maxMileage);
        await _storageService.saveSettings(_settings, _activeCarId!);
      }
      
      notifyListeners();
    }
  }

  Future<void> deleteServiceEvent(String eventId) async {
    _serviceEvents.removeWhere((event) => event.id == eventId);
    await _storageService.saveServiceEvents(_serviceEvents, _activeCarId!);
    notifyListeners();
  }

  ServiceEvent? getLastServiceForItems(List<String> itemIds) {
    try {
      return _serviceEvents.firstWhere(
        (event) => event.items.any((item) => itemIds.contains(item.itemId)),
      );
    } catch (e) {
      return null;
    }
  }

  // Reminders
  Future<void> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    await _storageService.saveReminders(_reminders, _activeCarId!);
    notifyListeners();
  }

  Future<void> updateReminder(Reminder reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      await _storageService.saveReminders(_reminders, _activeCarId!);
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    _reminders.removeWhere((reminder) => reminder.id == reminderId);
    await _storageService.saveReminders(_reminders, _activeCarId!);
    notifyListeners();
  }

  // Settings
  Future<void> updateMileage(int mileage) async {
    _settings = _settings.copyWith(currentMileage: mileage);
    await _storageService.saveSettings(_settings, _activeCarId!);
    notifyListeners();
  }

  Future<void> updateLanguage(String languageCode) async {
    _settings = _settings.copyWith(languageCode: languageCode);
    await _storageService.saveSettings(_settings, _activeCarId!);
    notifyListeners();
  }

  Future<void> updateCurrency(String currency) async {
    _settings = _settings.copyWith(currency: currency);
    await _storageService.saveSettings(_settings, _activeCarId!);
    notifyListeners();
  }

  // Upcoming services calculation
  List<Map<String, dynamic>> getUpcomingServices() {
    final List<Map<String, dynamic>> upcoming = [];

    for (final reminder in _reminders) {
      final lastService = getLastServiceForItems(reminder.itemIds);
      
      if (lastService == null) {
        // No previous service, mark as due now
        upcoming.add({
          'reminder': reminder,
          'dueKm': reminder.hasKmInterval ? reminder.intervalKm : null,
          'dueDate': reminder.hasTimeInterval
              ? DateTime.now().add(Duration(days: reminder.intervalMonths! * 30))
              : null,
          'isOverdue': true,
        });
      } else {
        int? dueKm;
        DateTime? dueDate;
        bool isOverdue = false;

        if (reminder.hasKmInterval) {
          dueKm = lastService.mileage + reminder.intervalKm!;
          if (_settings.currentMileage >= dueKm) {
            isOverdue = true;
          }
        }

        if (reminder.hasTimeInterval) {
          dueDate = DateTime(
            lastService.date.year,
            lastService.date.month + reminder.intervalMonths!,
            lastService.date.day,
          );
          if (DateTime.now().isAfter(dueDate)) {
            isOverdue = true;
          }
        }

        upcoming.add({
          'reminder': reminder,
          'lastService': lastService,
          'dueKm': dueKm,
          'dueDate': dueDate,
          'isOverdue': isOverdue,
        });
      }
    }

    // Sort by urgency (overdue first, then by proximity)
    upcoming.sort((a, b) {
      if (a['isOverdue'] && !b['isOverdue']) return -1;
      if (!a['isOverdue'] && b['isOverdue']) return 1;
      
      // Both overdue or both not overdue, sort by proximity
      if (a['dueKm'] != null && b['dueKm'] != null) {
        final aDiff = (a['dueKm'] as int) - _settings.currentMileage;
        final bDiff = (b['dueKm'] as int) - _settings.currentMileage;
        return aDiff.compareTo(bDiff);
      }
      
      return 0;
    });

    return upcoming;
  }
}


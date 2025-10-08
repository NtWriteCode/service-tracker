import 'package:flutter/material.dart';
import '../models/car.dart';
import '../models/service_item.dart';
import '../models/service_event.dart';
import '../models/reminder.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../services/car_brand_service.dart';
import '../services/webdav_service.dart';

class AppProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final WebdavService _webdavService = WebdavService();

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
  WebdavService get webdavService => _webdavService;

  AppProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    // Preload car brands for logo display
    await CarBrandService.loadBrands();

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
    
    // Initialize WebDAV service with loaded settings
    _initializeWebdavService();
  }
  
  void _initializeWebdavService() {
    _webdavService.initialize(_settings);
    _storageService.setWebdavService(_webdavService);
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

  Future<void> skipReminderPeriod(String reminderId) async {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      final reminder = _reminders[index];
      // Max 1 skipped period
      if (reminder.skippedPeriods < 1) {
        _reminders[index] = reminder.copyWith(skippedPeriods: 1);
        await _storageService.saveReminders(_reminders, _activeCarId!);
        notifyListeners();
      }
    }
  }

  Future<void> undoSkipReminderPeriod(String reminderId) async {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      final reminder = _reminders[index];
      if (reminder.skippedPeriods > 0) {
        _reminders[index] = reminder.copyWith(skippedPeriods: 0);
        await _storageService.saveReminders(_reminders, _activeCarId!);
        notifyListeners();
      }
    }
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

  // WebDAV Sync
  Future<bool> updateWebdavCredentials({
    required String url,
    required String username,
    required String password,
  }) async {
    // Validate connection first
    final isValid = await _webdavService.validateConnection(url, username, password);
    if (!isValid) {
      return false;
    }

    _settings = _settings.copyWith(
      webdavUrl: url,
      webdavUsername: username,
      webdavPassword: password,
    );
    
    // Re-initialize WebDAV service BEFORE saving to enable auto-sync
    _initializeWebdavService();
    
    // Now save settings - this will trigger auto-sync if enabled
    await _storageService.saveSettings(_settings, _activeCarId!);
    
    notifyListeners();
    return true;
  }

  Future<void> clearWebdavCredentials() async {
    _settings = _settings.clearWebdavCredentials();
    await _storageService.saveSettings(_settings, _activeCarId!);
    
    _webdavService.clear();
    _storageService.setWebdavService(null);
    
    notifyListeners();
  }

  Future<void> updateAutoSync(bool enabled) async {
    _settings = _settings.copyWith(autoSync: enabled);
    
    // Re-initialize WebDAV service to pick up the new autoSync setting
    _initializeWebdavService();
    
    await _storageService.saveSettings(_settings, _activeCarId!);
    notifyListeners();
  }

  Future<Map<String, bool>> exportToWebdav() async {
    return await _webdavService.syncToServer();
  }

  Future<Map<String, bool>> importFromWebdav() async {
    final results = await _webdavService.syncFromServer();
    
    // Reload data after import
    if (results.isNotEmpty) {
      await _loadCarData(_activeCarId!);
      notifyListeners();
    }
    
    return results;
  }

  Future<Map<String, dynamic>> getWebdavSyncStatus() async {
    return await _webdavService.getSyncStatus();
  }

  // Upcoming services calculation
  List<Map<String, dynamic>> getUpcomingServices() {
    final List<Map<String, dynamic>> upcoming = [];

    for (final reminder in _reminders) {
      final lastService = getLastServiceForItems(reminder.itemIds);
      
      if (lastService == null) {
        // No previous service, instant overdue state
        upcoming.add({
          'reminder': reminder,
          'dueKm': reminder.hasKmInterval ? reminder.intervalKm : null,
          'dueDate': reminder.hasTimeInterval
              ? DateTime.now().add(Duration(days: reminder.intervalMonths! * 30))
              : null,
          'urgencyLevel': 'overdue',
          'kmPercentage': null,
          'datePercentage': null,
        });
      } else {
        int? dueKm;
        DateTime? dueDate;
        double? kmPercentage;
        double? datePercentage;

        // Calculate km-based urgency (accounting for skipped periods)
        if (reminder.hasKmInterval) {
          final periodsToSkip = reminder.skippedPeriods + 1; // +1 for the current period
          dueKm = lastService.mileage + (reminder.intervalKm! * periodsToSkip);
          final kmElapsed = _settings.currentMileage - lastService.mileage;
          final totalKmForPeriod = reminder.intervalKm! * periodsToSkip;
          kmPercentage = (kmElapsed / totalKmForPeriod) * 100;
        }

        // Calculate time-based urgency (accounting for skipped periods)
        if (reminder.hasTimeInterval) {
          final periodsToSkip = reminder.skippedPeriods + 1; // +1 for the current period
          dueDate = DateTime(
            lastService.date.year,
            lastService.date.month + (reminder.intervalMonths! * periodsToSkip),
            lastService.date.day,
          );
          final totalDays = dueDate.difference(lastService.date).inDays;
          final elapsedDays = DateTime.now().difference(lastService.date).inDays;
          datePercentage = (elapsedDays / totalDays) * 100;
        }

        // Determine urgency level based on the worst (highest) percentage
        final maxPercentage = [
          kmPercentage ?? 0,
          datePercentage ?? 0,
        ].reduce((a, b) => a > b ? a : b);

        String urgencyLevel;
        if (maxPercentage < 50) {
          // Below 50%, don't show unless it's a skipped reminder
          if (!reminder.isSkipped) {
            continue;
          }
          // If skipped, still show it as green
          urgencyLevel = 'good';
        } else if (maxPercentage < 75) {
          // 50-75%: Green
          urgencyLevel = 'good';
        } else if (maxPercentage < 95) {
          // 75-95%: Orange
          urgencyLevel = 'warning';
        } else if (maxPercentage < 100) {
          // 95-100%: Red
          urgencyLevel = 'urgent';
        } else {
          // 100%+: Dark red (overdue)
          urgencyLevel = 'overdue';
        }

        upcoming.add({
          'reminder': reminder,
          'lastService': lastService,
          'dueKm': dueKm,
          'dueDate': dueDate,
          'urgencyLevel': urgencyLevel,
          'kmPercentage': kmPercentage,
          'datePercentage': datePercentage,
        });
      }
    }

    // Sort by urgency level first, then by percentage
    upcoming.sort((a, b) {
      final urgencyOrder = {'overdue': 0, 'urgent': 1, 'warning': 2, 'good': 3};
      final aOrder = urgencyOrder[a['urgencyLevel']]!;
      final bOrder = urgencyOrder[b['urgencyLevel']]!;
      
      if (aOrder != bOrder) return aOrder.compareTo(bOrder);
      
      // Same urgency, sort by highest percentage
      final aMax = [a['kmPercentage'] ?? 0.0, a['datePercentage'] ?? 0.0]
          .reduce((a, b) => a > b ? a : b);
      final bMax = [b['kmPercentage'] ?? 0.0, b['datePercentage'] ?? 0.0]
          .reduce((a, b) => a > b ? a : b);
      
      return bMax.compareTo(aMax); // Higher percentage first
    });

    return upcoming;
  }
}


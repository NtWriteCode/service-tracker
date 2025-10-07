import 'package:flutter/material.dart';
import '../models/service_item.dart';
import '../models/service_event.dart';
import '../models/reminder.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class AppProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<ServiceItem> _serviceItems = [];
  List<ServiceEvent> _serviceEvents = [];
  List<Reminder> _reminders = [];
  AppSettings _settings = AppSettings(currentMileage: 0);

  bool _isLoading = true;

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

    _serviceItems = await _storageService.loadServiceItems();
    _serviceEvents = await _storageService.loadServiceEvents();
    _reminders = await _storageService.loadReminders();
    _settings = await _storageService.loadSettings();

    _isLoading = false;
    notifyListeners();
  }

  // Service Items
  Future<void> addServiceItem(ServiceItem item) async {
    _serviceItems.add(item);
    await _storageService.saveServiceItems(_serviceItems);
    notifyListeners();
  }

  Future<void> updateServiceItem(ServiceItem item) async {
    final index = _serviceItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _serviceItems[index] = item;
      await _storageService.saveServiceItems(_serviceItems);
      notifyListeners();
    }
  }

  Future<void> deleteServiceItem(String itemId) async {
    _serviceItems.removeWhere((item) => item.id == itemId);
    await _storageService.saveServiceItems(_serviceItems);
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
    await _storageService.saveServiceEvents(_serviceEvents);
    
    // Auto-update current mileage if this event has higher mileage
    if (event.mileage > _settings.currentMileage) {
      _settings = _settings.copyWith(currentMileage: event.mileage);
      await _storageService.saveSettings(_settings);
    }
    
    notifyListeners();
  }

  Future<void> updateServiceEvent(ServiceEvent event) async {
    final index = _serviceEvents.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _serviceEvents[index] = event;
      _serviceEvents.sort((a, b) => b.date.compareTo(a.date));
      await _storageService.saveServiceEvents(_serviceEvents);
      
      // Auto-update current mileage to highest mileage in any event
      final maxMileage = _serviceEvents.map((e) => e.mileage).reduce((a, b) => a > b ? a : b);
      if (maxMileage > _settings.currentMileage) {
        _settings = _settings.copyWith(currentMileage: maxMileage);
        await _storageService.saveSettings(_settings);
      }
      
      notifyListeners();
    }
  }

  Future<void> deleteServiceEvent(String eventId) async {
    _serviceEvents.removeWhere((event) => event.id == eventId);
    await _storageService.saveServiceEvents(_serviceEvents);
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
    await _storageService.saveReminders(_reminders);
    notifyListeners();
  }

  Future<void> updateReminder(Reminder reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      await _storageService.saveReminders(_reminders);
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    _reminders.removeWhere((reminder) => reminder.id == reminderId);
    await _storageService.saveReminders(_reminders);
    notifyListeners();
  }

  // Settings
  Future<void> updateMileage(int mileage) async {
    _settings = _settings.copyWith(currentMileage: mileage);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateLanguage(String languageCode) async {
    _settings = _settings.copyWith(languageCode: languageCode);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateCurrency(String currency) async {
    _settings = _settings.copyWith(currency: currency);
    await _storageService.saveSettings(_settings);
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


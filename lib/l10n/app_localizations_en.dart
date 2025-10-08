// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Service Tracker';

  @override
  String get home => 'Home';

  @override
  String get services => 'Services';

  @override
  String get reminders => 'Reminders';

  @override
  String get settings => 'Settings';

  @override
  String get currentMileage => 'Current Mileage';

  @override
  String get updateMileage => 'Update Mileage';

  @override
  String get registerMileage => 'Register Mileage';

  @override
  String get mileage => 'Mileage';

  @override
  String get km => 'km';

  @override
  String get date => 'Date';

  @override
  String get place => 'Place';

  @override
  String get items => 'Items';

  @override
  String get addService => 'Add Service';

  @override
  String get newService => 'New Service';

  @override
  String get editService => 'Edit Service';

  @override
  String get deleteService => 'Delete Service';

  @override
  String get serviceHistory => 'Service History';

  @override
  String get serviceDone => 'Service Done';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get newReminder => 'New Reminder';

  @override
  String get editReminder => 'Edit Reminder';

  @override
  String get deleteReminder => 'Delete Reminder';

  @override
  String get reminderName => 'Reminder Name';

  @override
  String get everyKm => 'Every (km)';

  @override
  String get everyMonths => 'Every (months)';

  @override
  String get selectItems => 'Select Items';

  @override
  String get serviceItems => 'Service Items';

  @override
  String get manageItems => 'Manage Items';

  @override
  String get addItem => 'Add Item';

  @override
  String get newItem => 'New Item';

  @override
  String get editItem => 'Edit Item';

  @override
  String get deleteItem => 'Delete Item';

  @override
  String get itemName => 'Item Name';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteServiceConfirm =>
      'Are you sure you want to delete this service?';

  @override
  String get deleteReminderConfirm =>
      'Are you sure you want to delete this reminder?';

  @override
  String get deleteItemConfirm => 'Are you sure you want to delete this item?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get upcomingServices => 'Upcoming Services';

  @override
  String get noUpcomingServices => 'No upcoming services';

  @override
  String get noServices => 'No services yet';

  @override
  String get noReminders => 'No reminders yet';

  @override
  String get dueIn => 'Due in';

  @override
  String get dueAt => 'Due at';

  @override
  String get overdue => 'Overdue';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hungarian => 'Hungarian';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get enterMileage => 'Enter mileage';

  @override
  String get enterPlace => 'Enter place (e.g., mechanic shop)';

  @override
  String get selectDate => 'Select Date';

  @override
  String get quantity => 'Quantity';

  @override
  String get price => 'Price';

  @override
  String get total => 'Total';

  @override
  String get currency => 'Currency';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get addItemToService => 'Add Item to Service';

  @override
  String get selectedItems => 'Selected Items';

  @override
  String get noItemsSelected => 'No items selected';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidNumber => 'Please enter a valid number';

  @override
  String get mileageMustBePositive => 'Mileage must be positive';

  @override
  String get atLeastOneCondition =>
      'At least one condition (km or months) is required';

  @override
  String get lastService => 'Last Service';

  @override
  String get nextDue => 'Next Due';

  @override
  String get or => 'or';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get locationServicesDisabled =>
      'Location services are disabled. Please enable them.';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationPermissionDeniedForever =>
      'Location permission permanently denied. Please enable it in settings.';

  @override
  String get locationNotFound => 'Could not determine location';

  @override
  String get error => 'Error';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get importDrivvo => 'Import from Drivvo';

  @override
  String get importDrivvoDesc =>
      'Import service history from Drivvo CSV export';

  @override
  String get importing => 'Importing...';

  @override
  String get importSuccess => 'Import successful';

  @override
  String get servicesImported => 'services imported';

  @override
  String get importError => 'Import failed';

  @override
  String get searchOrAddItem => 'Search or add item';

  @override
  String get startTyping => 'Start typing...';

  @override
  String get custom => 'Custom';

  @override
  String addAsCustomItem(String name) {
    return 'Add \"$name\" as custom item';
  }

  @override
  String get cars => 'Cars';

  @override
  String get myCars => 'My Cars';

  @override
  String get addCar => 'Add Car';

  @override
  String get newCar => 'New Car';

  @override
  String get editCar => 'Edit Car';

  @override
  String get deleteCar => 'Delete Car';

  @override
  String get carName => 'Car Name';

  @override
  String get plateNumber => 'Plate Number';

  @override
  String get selectCar => 'Select Car';

  @override
  String get deleteCarConfirm =>
      'Are you sure you want to delete this car? All associated data will be deleted.';

  @override
  String get cannotDeleteLastCar => 'Cannot delete the last car';

  @override
  String get enterCarName => 'Enter car name';

  @override
  String get enterPlateNumber => 'Enter plate number (optional)';

  @override
  String get carNameRequired => 'Car name is required';

  @override
  String get brand => 'Brand';

  @override
  String get selectBrand => 'Select Brand';

  @override
  String get searchBrands => 'Search brands...';

  @override
  String get noBrand => 'No brand';

  @override
  String get nickname => 'Nickname';

  @override
  String get enterNickname => 'Enter nickname (optional)';

  @override
  String get nicknameHint => 'e.g., Polo, Home car';

  @override
  String get webdavSync => 'WebDAV Sync';

  @override
  String get webdavSettings => 'WebDAV Settings';

  @override
  String get webdavUrl => 'WebDAV URL';

  @override
  String get webdavUsername => 'Username';

  @override
  String get webdavPassword => 'Password';

  @override
  String get webdavConnected => 'Connected';

  @override
  String get webdavNotConnected => 'Not connected';

  @override
  String get webdavLogin => 'Login';

  @override
  String get webdavLogout => 'Logout';

  @override
  String get webdavValidating => 'Validating connection...';

  @override
  String get webdavValidationSuccess => 'Connection successful';

  @override
  String get webdavValidationFailed =>
      'Connection failed. Please check your credentials.';

  @override
  String get webdavAutoSync => 'Auto-sync';

  @override
  String get webdavAutoSyncDesc => 'Automatically sync data after each change';

  @override
  String get webdavExport => 'Export to Server';

  @override
  String get webdavImport => 'Import from Server';

  @override
  String get webdavExporting => 'Exporting...';

  @override
  String get webdavImporting => 'Importing...';

  @override
  String get webdavExportSuccess => 'Export successful';

  @override
  String get webdavImportSuccess => 'Import successful';

  @override
  String get webdavExportFailed => 'Export failed';

  @override
  String get webdavImportFailed => 'Import failed';

  @override
  String get webdavSyncStatus => 'Sync Status';

  @override
  String get webdavFilesOnServer => 'Files on server';

  @override
  String get enterWebdavUrl =>
      'Enter WebDAV URL (e.g., https://your-server.com/remote.php/dav/files/username/)';

  @override
  String get enterUsername => 'Enter username';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get webdavUrlRequired => 'WebDAV URL is required';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get logoutConfirm =>
      'Are you sure you want to logout? This will not delete any local data.';
}

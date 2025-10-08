import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hu')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Tracker'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @currentMileage.
  ///
  /// In en, this message translates to:
  /// **'Current Mileage'**
  String get currentMileage;

  /// No description provided for @updateMileage.
  ///
  /// In en, this message translates to:
  /// **'Update Mileage'**
  String get updateMileage;

  /// No description provided for @registerMileage.
  ///
  /// In en, this message translates to:
  /// **'Register Mileage'**
  String get registerMileage;

  /// No description provided for @mileage.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get mileage;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @place.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get place;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @addService.
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get addService;

  /// No description provided for @newService.
  ///
  /// In en, this message translates to:
  /// **'New Service'**
  String get newService;

  /// No description provided for @editService.
  ///
  /// In en, this message translates to:
  /// **'Edit Service'**
  String get editService;

  /// No description provided for @deleteService.
  ///
  /// In en, this message translates to:
  /// **'Delete Service'**
  String get deleteService;

  /// No description provided for @serviceHistory.
  ///
  /// In en, this message translates to:
  /// **'Service History'**
  String get serviceHistory;

  /// No description provided for @serviceDone.
  ///
  /// In en, this message translates to:
  /// **'Service Done'**
  String get serviceDone;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @newReminder.
  ///
  /// In en, this message translates to:
  /// **'New Reminder'**
  String get newReminder;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get editReminder;

  /// No description provided for @deleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder'**
  String get deleteReminder;

  /// No description provided for @reminderName.
  ///
  /// In en, this message translates to:
  /// **'Reminder Name'**
  String get reminderName;

  /// No description provided for @everyKm.
  ///
  /// In en, this message translates to:
  /// **'Every (km)'**
  String get everyKm;

  /// No description provided for @everyMonths.
  ///
  /// In en, this message translates to:
  /// **'Every (months)'**
  String get everyMonths;

  /// No description provided for @selectItems.
  ///
  /// In en, this message translates to:
  /// **'Select Items'**
  String get selectItems;

  /// No description provided for @serviceItems.
  ///
  /// In en, this message translates to:
  /// **'Service Items'**
  String get serviceItems;

  /// No description provided for @manageItems.
  ///
  /// In en, this message translates to:
  /// **'Manage Items'**
  String get manageItems;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New Item'**
  String get newItem;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteServiceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this service?'**
  String get deleteServiceConfirm;

  /// No description provided for @deleteReminderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reminder?'**
  String get deleteReminderConfirm;

  /// No description provided for @deleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteItemConfirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @upcomingServices.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Services'**
  String get upcomingServices;

  /// No description provided for @noUpcomingServices.
  ///
  /// In en, this message translates to:
  /// **'No upcoming services'**
  String get noUpcomingServices;

  /// No description provided for @noServices.
  ///
  /// In en, this message translates to:
  /// **'No services yet'**
  String get noServices;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get noReminders;

  /// No description provided for @dueIn.
  ///
  /// In en, this message translates to:
  /// **'Due in'**
  String get dueIn;

  /// No description provided for @dueAt.
  ///
  /// In en, this message translates to:
  /// **'Due at'**
  String get dueAt;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hungarian.
  ///
  /// In en, this message translates to:
  /// **'Hungarian'**
  String get hungarian;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @enterMileage.
  ///
  /// In en, this message translates to:
  /// **'Enter mileage'**
  String get enterMileage;

  /// No description provided for @enterPlace.
  ///
  /// In en, this message translates to:
  /// **'Enter place (e.g., mechanic shop)'**
  String get enterPlace;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @addItemToService.
  ///
  /// In en, this message translates to:
  /// **'Add Item to Service'**
  String get addItemToService;

  /// No description provided for @selectedItems.
  ///
  /// In en, this message translates to:
  /// **'Selected Items'**
  String get selectedItems;

  /// No description provided for @noItemsSelected.
  ///
  /// In en, this message translates to:
  /// **'No items selected'**
  String get noItemsSelected;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get invalidNumber;

  /// No description provided for @mileageMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Mileage must be positive'**
  String get mileageMustBePositive;

  /// No description provided for @atLeastOneCondition.
  ///
  /// In en, this message translates to:
  /// **'At least one condition (km or months) is required'**
  String get atLeastOneCondition;

  /// No description provided for @lastService.
  ///
  /// In en, this message translates to:
  /// **'Last Service'**
  String get lastService;

  /// No description provided for @nextDue.
  ///
  /// In en, this message translates to:
  /// **'Next Due'**
  String get nextDue;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable them.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied. Please enable it in settings.'**
  String get locationPermissionDeniedForever;

  /// No description provided for @locationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not determine location'**
  String get locationNotFound;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @importDrivvo.
  ///
  /// In en, this message translates to:
  /// **'Import from Drivvo'**
  String get importDrivvo;

  /// No description provided for @importDrivvoDesc.
  ///
  /// In en, this message translates to:
  /// **'Import service history from Drivvo CSV export'**
  String get importDrivvoDesc;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importing;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import successful'**
  String get importSuccess;

  /// No description provided for @servicesImported.
  ///
  /// In en, this message translates to:
  /// **'services imported'**
  String get servicesImported;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importError;

  /// No description provided for @searchOrAddItem.
  ///
  /// In en, this message translates to:
  /// **'Search or add item'**
  String get searchOrAddItem;

  /// No description provided for @startTyping.
  ///
  /// In en, this message translates to:
  /// **'Start typing...'**
  String get startTyping;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @addAsCustomItem.
  ///
  /// In en, this message translates to:
  /// **'Add \"{name}\" as custom item'**
  String addAsCustomItem(String name);

  /// No description provided for @cars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get cars;

  /// No description provided for @myCars.
  ///
  /// In en, this message translates to:
  /// **'My Cars'**
  String get myCars;

  /// No description provided for @addCar.
  ///
  /// In en, this message translates to:
  /// **'Add Car'**
  String get addCar;

  /// No description provided for @newCar.
  ///
  /// In en, this message translates to:
  /// **'New Car'**
  String get newCar;

  /// No description provided for @editCar.
  ///
  /// In en, this message translates to:
  /// **'Edit Car'**
  String get editCar;

  /// No description provided for @deleteCar.
  ///
  /// In en, this message translates to:
  /// **'Delete Car'**
  String get deleteCar;

  /// No description provided for @carName.
  ///
  /// In en, this message translates to:
  /// **'Car Name'**
  String get carName;

  /// No description provided for @plateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get plateNumber;

  /// No description provided for @selectCar.
  ///
  /// In en, this message translates to:
  /// **'Select Car'**
  String get selectCar;

  /// No description provided for @deleteCarConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this car? All associated data will be deleted.'**
  String get deleteCarConfirm;

  /// No description provided for @cannotDeleteLastCar.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete the last car'**
  String get cannotDeleteLastCar;

  /// No description provided for @enterCarName.
  ///
  /// In en, this message translates to:
  /// **'Enter car name'**
  String get enterCarName;

  /// No description provided for @enterPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter plate number (optional)'**
  String get enterPlateNumber;

  /// No description provided for @carNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Car name is required'**
  String get carNameRequired;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @selectBrand.
  ///
  /// In en, this message translates to:
  /// **'Select Brand'**
  String get selectBrand;

  /// No description provided for @searchBrands.
  ///
  /// In en, this message translates to:
  /// **'Search brands...'**
  String get searchBrands;

  /// No description provided for @noBrand.
  ///
  /// In en, this message translates to:
  /// **'No brand'**
  String get noBrand;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @enterNickname.
  ///
  /// In en, this message translates to:
  /// **'Enter nickname (optional)'**
  String get enterNickname;

  /// No description provided for @nicknameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Polo, Home car'**
  String get nicknameHint;

  /// No description provided for @webdavSync.
  ///
  /// In en, this message translates to:
  /// **'WebDAV Sync'**
  String get webdavSync;

  /// No description provided for @webdavSettings.
  ///
  /// In en, this message translates to:
  /// **'WebDAV Settings'**
  String get webdavSettings;

  /// No description provided for @webdavUrl.
  ///
  /// In en, this message translates to:
  /// **'WebDAV URL'**
  String get webdavUrl;

  /// No description provided for @webdavUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get webdavUsername;

  /// No description provided for @webdavPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get webdavPassword;

  /// No description provided for @webdavConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get webdavConnected;

  /// No description provided for @webdavNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get webdavNotConnected;

  /// No description provided for @webdavLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get webdavLogin;

  /// No description provided for @webdavLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get webdavLogout;

  /// No description provided for @webdavValidating.
  ///
  /// In en, this message translates to:
  /// **'Validating connection...'**
  String get webdavValidating;

  /// No description provided for @webdavValidationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection successful'**
  String get webdavValidationSuccess;

  /// No description provided for @webdavValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed. Please check your credentials.'**
  String get webdavValidationFailed;

  /// No description provided for @webdavAutoSync.
  ///
  /// In en, this message translates to:
  /// **'Auto-sync'**
  String get webdavAutoSync;

  /// No description provided for @webdavAutoSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically sync data after each change'**
  String get webdavAutoSyncDesc;

  /// No description provided for @webdavExport.
  ///
  /// In en, this message translates to:
  /// **'Export to Server'**
  String get webdavExport;

  /// No description provided for @webdavImport.
  ///
  /// In en, this message translates to:
  /// **'Import from Server'**
  String get webdavImport;

  /// No description provided for @webdavExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get webdavExporting;

  /// No description provided for @webdavImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get webdavImporting;

  /// No description provided for @webdavExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get webdavExportSuccess;

  /// No description provided for @webdavImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import successful'**
  String get webdavImportSuccess;

  /// No description provided for @webdavExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get webdavExportFailed;

  /// No description provided for @webdavImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get webdavImportFailed;

  /// No description provided for @webdavSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get webdavSyncStatus;

  /// No description provided for @webdavFilesOnServer.
  ///
  /// In en, this message translates to:
  /// **'Files on server'**
  String get webdavFilesOnServer;

  /// No description provided for @enterWebdavUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter WebDAV URL (e.g., https://your-server.com/remote.php/dav/files/username/)'**
  String get enterWebdavUrl;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUsername;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @webdavUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'WebDAV URL is required'**
  String get webdavUrlRequired;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout? This will not delete any local data.'**
  String get logoutConfirm;

  /// No description provided for @selectReminderTemplate.
  ///
  /// In en, this message translates to:
  /// **'Select Reminder Template'**
  String get selectReminderTemplate;

  /// No description provided for @customReminder.
  ///
  /// In en, this message translates to:
  /// **'Custom Reminder'**
  String get customReminder;

  /// No description provided for @createFromScratch.
  ///
  /// In en, this message translates to:
  /// **'Create from scratch'**
  String get createFromScratch;

  /// No description provided for @addServiceForReminder.
  ///
  /// In en, this message translates to:
  /// **'Add service for \"{reminderName}\" now?'**
  String addServiceForReminder(String reminderName);

  /// No description provided for @tapToAddService.
  ///
  /// In en, this message translates to:
  /// **'Tap to add service event'**
  String get tapToAddService;

  /// No description provided for @skipPeriod.
  ///
  /// In en, this message translates to:
  /// **'Skip Next Period'**
  String get skipPeriod;

  /// No description provided for @undoSkip.
  ///
  /// In en, this message translates to:
  /// **'Undo Skip'**
  String get undoSkip;

  /// No description provided for @periodSkipped.
  ///
  /// In en, this message translates to:
  /// **'Period skipped - reminder pushed to next interval'**
  String get periodSkipped;

  /// No description provided for @skipUndone.
  ///
  /// In en, this message translates to:
  /// **'Skip undone - reminder restored'**
  String get skipUndone;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hu':
      return AppLocalizationsHu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

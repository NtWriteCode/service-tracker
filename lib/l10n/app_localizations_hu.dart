// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'Szerviz Nyilvántartó';

  @override
  String get home => 'Főoldal';

  @override
  String get services => 'Szervizek';

  @override
  String get reminders => 'Emlékeztetők';

  @override
  String get settings => 'Beállítások';

  @override
  String get currentMileage => 'Jelenlegi kilométeróra állás';

  @override
  String get updateMileage => 'Kilométeróra frissítése';

  @override
  String get registerMileage => 'Kilométeróra rögzítése';

  @override
  String get mileage => 'Kilométeróra állás';

  @override
  String get km => 'km';

  @override
  String get date => 'Dátum';

  @override
  String get place => 'Hely';

  @override
  String get items => 'Tételek';

  @override
  String get addService => 'Szerviz hozzáadása';

  @override
  String get newService => 'Új szerviz';

  @override
  String get editService => 'Szerviz szerkesztése';

  @override
  String get deleteService => 'Szerviz törlése';

  @override
  String get serviceHistory => 'Szerviz előzmények';

  @override
  String get serviceDone => 'Szerviz elvégezve';

  @override
  String get addReminder => 'Emlékeztető hozzáadása';

  @override
  String get newReminder => 'Új emlékeztető';

  @override
  String get editReminder => 'Emlékeztető szerkesztése';

  @override
  String get deleteReminder => 'Emlékeztető törlése';

  @override
  String get reminderName => 'Emlékeztető neve';

  @override
  String get everyKm => 'Minden (km)';

  @override
  String get everyMonths => 'Minden (hónap)';

  @override
  String get selectItems => 'Tételek kiválasztása';

  @override
  String get serviceItems => 'Szerviz tételek';

  @override
  String get manageItems => 'Tételek kezelése';

  @override
  String get addItem => 'Tétel hozzáadása';

  @override
  String get newItem => 'Új tétel';

  @override
  String get editItem => 'Tétel szerkesztése';

  @override
  String get deleteItem => 'Tétel törlése';

  @override
  String get itemName => 'Tétel neve';

  @override
  String get save => 'Mentés';

  @override
  String get cancel => 'Mégse';

  @override
  String get delete => 'Törlés';

  @override
  String get edit => 'Szerkesztés';

  @override
  String get confirmDelete => 'Törlés megerősítése';

  @override
  String get deleteServiceConfirm =>
      'Biztosan törölni szeretnéd ezt a szervízt?';

  @override
  String get deleteReminderConfirm =>
      'Biztosan törölni szeretnéd ezt az emlékeztetőt?';

  @override
  String get deleteItemConfirm => 'Biztosan törölni szeretnéd ezt a tételt?';

  @override
  String get yes => 'Igen';

  @override
  String get no => 'Nem';

  @override
  String get upcomingServices => 'Közelgő szervizek';

  @override
  String get noUpcomingServices => 'Nincsenek közelgő szervizek';

  @override
  String get noServices => 'Még nincsenek szervizek';

  @override
  String get noReminders => 'Még nincsenek emlékeztetők';

  @override
  String get dueIn => 'Esedékes';

  @override
  String get dueAt => 'Esedékes';

  @override
  String get overdue => 'Lejárt';

  @override
  String get language => 'Nyelv';

  @override
  String get english => 'Angol';

  @override
  String get hungarian => 'Magyar';

  @override
  String get selectLanguage => 'Nyelv kiválasztása';

  @override
  String get enterMileage => 'Add meg a kilométeróra állást';

  @override
  String get enterPlace => 'Add meg a helyet (pl. szerviz neve)';

  @override
  String get selectDate => 'Dátum kiválasztása';

  @override
  String get quantity => 'Mennyiség';

  @override
  String get price => 'Ár';

  @override
  String get total => 'Összesen';

  @override
  String get currency => 'Pénznem';

  @override
  String get selectCurrency => 'Pénznem kiválasztása';

  @override
  String get addItemToService => 'Tétel hozzáadása a szervizhez';

  @override
  String get selectedItems => 'Kiválasztott tételek';

  @override
  String get noItemsSelected => 'Nincsenek kiválasztott tételek';

  @override
  String get requiredField => 'Ez a mező kötelező';

  @override
  String get invalidNumber => 'Kérlek adj meg egy érvényes számot';

  @override
  String get mileageMustBePositive =>
      'A kilométeróra állásnak pozitívnak kell lennie';

  @override
  String get atLeastOneCondition =>
      'Legalább egy feltétel (km vagy hónap) szükséges';

  @override
  String get lastService => 'Utolsó szerviz';

  @override
  String get nextDue => 'Következő esedékesség';

  @override
  String get or => 'vagy';

  @override
  String get useCurrentLocation => 'Jelenlegi hely használata';

  @override
  String get locationServicesDisabled =>
      'A helymeghatározás ki van kapcsolva. Kérlek kapcsold be.';

  @override
  String get locationPermissionDenied =>
      'Helymeghatározási engedély megtagadva';

  @override
  String get locationPermissionDeniedForever =>
      'Helymeghatározási engedély véglegesen megtagadva. Kérlek engedélyezd a beállításokban.';

  @override
  String get locationNotFound => 'Nem sikerült meghatározni a helyet';

  @override
  String get error => 'Hiba';

  @override
  String get dataManagement => 'Adatkezelés';

  @override
  String get importDrivvo => 'Importálás Drivvo-ból';

  @override
  String get importDrivvoDesc =>
      'Szerviz előzmények importálása Drivvo CSV exportból';

  @override
  String get importing => 'Importálás folyamatban...';

  @override
  String get importSuccess => 'Sikeres importálás';

  @override
  String get servicesImported => 'szerviz importálva';

  @override
  String get importError => 'Importálás sikertelen';

  @override
  String get searchOrAddItem => 'Keresés vagy tétel hozzáadása';

  @override
  String get startTyping => 'Kezdj el gépelni...';

  @override
  String get custom => 'Egyedi';

  @override
  String addAsCustomItem(String name) {
    return '\"$name\" hozzáadása egyedi tételként';
  }

  @override
  String get cars => 'Autók';

  @override
  String get myCars => 'Autóim';

  @override
  String get addCar => 'Autó hozzáadása';

  @override
  String get newCar => 'Új autó';

  @override
  String get editCar => 'Autó szerkesztése';

  @override
  String get deleteCar => 'Autó törlése';

  @override
  String get carName => 'Autó neve';

  @override
  String get plateNumber => 'Rendszám';

  @override
  String get selectCar => 'Autó kiválasztása';

  @override
  String get deleteCarConfirm =>
      'Biztosan törölni szeretnéd ezt az autót? Minden kapcsolódó adat törlésre kerül.';

  @override
  String get cannotDeleteLastCar => 'Az utolsó autót nem lehet törölni';

  @override
  String get enterCarName => 'Add meg az autó nevét';

  @override
  String get enterPlateNumber => 'Add meg a rendszámot (opcionális)';

  @override
  String get carNameRequired => 'Az autó neve kötelező';
}

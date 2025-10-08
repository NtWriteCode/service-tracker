class AppSettings {
  final int currentMileage;
  final String languageCode; // 'en' or 'hu', or 'system'
  final String currency; // Currency code like 'USD', 'EUR', 'HUF'
  
  // WebDAV sync settings
  final String? webdavUrl;
  final String? webdavUsername;
  final String? webdavPassword;
  final bool autoSync;

  AppSettings({
    required this.currentMileage,
    this.languageCode = 'system',
    this.currency = 'EUR',
    this.webdavUrl,
    this.webdavUsername,
    this.webdavPassword,
    this.autoSync = true,
  });

  bool get hasWebdavCredentials =>
      webdavUrl != null &&
      webdavUrl!.isNotEmpty &&
      webdavUsername != null &&
      webdavUsername!.isNotEmpty &&
      webdavPassword != null &&
      webdavPassword!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'currentMileage': currentMileage,
      'languageCode': languageCode,
      'currency': currency,
      'webdavUrl': webdavUrl,
      'webdavUsername': webdavUsername,
      'webdavPassword': webdavPassword,
      'autoSync': autoSync,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      currentMileage: json['currentMileage'] as int? ?? 0,
      languageCode: json['languageCode'] as String? ?? 'system',
      currency: json['currency'] as String? ?? 'EUR',
      webdavUrl: json['webdavUrl'] as String?,
      webdavUsername: json['webdavUsername'] as String?,
      webdavPassword: json['webdavPassword'] as String?,
      autoSync: json['autoSync'] as bool? ?? true,
    );
  }

  AppSettings copyWith({
    int? currentMileage,
    String? languageCode,
    String? currency,
    String? webdavUrl,
    String? webdavUsername,
    String? webdavPassword,
    bool? autoSync,
  }) {
    return AppSettings(
      currentMileage: currentMileage ?? this.currentMileage,
      languageCode: languageCode ?? this.languageCode,
      currency: currency ?? this.currency,
      webdavUrl: webdavUrl ?? this.webdavUrl,
      webdavUsername: webdavUsername ?? this.webdavUsername,
      webdavPassword: webdavPassword ?? this.webdavPassword,
      autoSync: autoSync ?? this.autoSync,
    );
  }

  AppSettings clearWebdavCredentials() {
    return AppSettings(
      currentMileage: currentMileage,
      languageCode: languageCode,
      currency: currency,
      webdavUrl: null,
      webdavUsername: null,
      webdavPassword: null,
      autoSync: autoSync,
    );
  }
}


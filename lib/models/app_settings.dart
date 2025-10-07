class AppSettings {
  final int currentMileage;
  final String languageCode; // 'en' or 'hu', or 'system'
  final String currency; // Currency code like 'USD', 'EUR', 'HUF'

  AppSettings({
    required this.currentMileage,
    this.languageCode = 'system',
    this.currency = 'EUR',
  });

  Map<String, dynamic> toJson() {
    return {
      'currentMileage': currentMileage,
      'languageCode': languageCode,
      'currency': currency,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      currentMileage: json['currentMileage'] as int? ?? 0,
      languageCode: json['languageCode'] as String? ?? 'system',
      currency: json['currency'] as String? ?? 'EUR',
    );
  }

  AppSettings copyWith({
    int? currentMileage,
    String? languageCode,
    String? currency,
  }) {
    return AppSettings(
      currentMileage: currentMileage ?? this.currentMileage,
      languageCode: languageCode ?? this.languageCode,
      currency: currency ?? this.currency,
    );
  }
}


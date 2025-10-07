class ServiceItem {
  final String id;
  final String nameEn;
  final String nameHu;
  final bool isCustom;
  final String? customName; // For user-created items

  ServiceItem({
    required this.id,
    required this.nameEn,
    required this.nameHu,
    this.isCustom = false,
    this.customName,
  });

  String getName(String languageCode) {
    if (isCustom && customName != null) {
      return customName!;
    }
    return languageCode == 'hu' ? nameHu : nameEn;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameEn': nameEn,
      'nameHu': nameHu,
      'isCustom': isCustom,
      'customName': customName,
    };
  }

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameHu: json['nameHu'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
      customName: json['customName'] as String?,
    );
  }

  ServiceItem copyWith({
    String? id,
    String? nameEn,
    String? nameHu,
    bool? isCustom,
    String? customName,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameHu: nameHu ?? this.nameHu,
      isCustom: isCustom ?? this.isCustom,
      customName: customName ?? this.customName,
    );
  }
}


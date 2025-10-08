class Reminder {
  final String id;
  final String name;
  final List<String> itemIds;
  final int? intervalKm; // null if not used
  final int? intervalMonths; // null if not used
  final int skippedPeriods; // Number of periods skipped (max 1)

  Reminder({
    required this.id,
    required this.name,
    required this.itemIds,
    this.intervalKm,
    this.intervalMonths,
    this.skippedPeriods = 0,
  });

  bool get hasKmInterval => intervalKm != null && intervalKm! > 0;
  bool get hasTimeInterval => intervalMonths != null && intervalMonths! > 0;
  bool get isSkipped => skippedPeriods > 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'itemIds': itemIds,
      'intervalKm': intervalKm,
      'intervalMonths': intervalMonths,
      'skippedPeriods': skippedPeriods,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      name: json['name'] as String,
      itemIds: (json['itemIds'] as List).cast<String>(),
      intervalKm: json['intervalKm'] as int?,
      intervalMonths: json['intervalMonths'] as int?,
      skippedPeriods: json['skippedPeriods'] as int? ?? 0,
    );
  }

  Reminder copyWith({
    String? id,
    String? name,
    List<String>? itemIds,
    int? intervalKm,
    int? intervalMonths,
    int? skippedPeriods,
  }) {
    return Reminder(
      id: id ?? this.id,
      name: name ?? this.name,
      itemIds: itemIds ?? this.itemIds,
      intervalKm: intervalKm ?? this.intervalKm,
      intervalMonths: intervalMonths ?? this.intervalMonths,
      skippedPeriods: skippedPeriods ?? this.skippedPeriods,
    );
  }
}


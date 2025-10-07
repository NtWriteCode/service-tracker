class ServiceEventItem {
  final String itemId;
  final double price;

  ServiceEventItem({
    required this.itemId,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'price': price,
    };
  }

  factory ServiceEventItem.fromJson(Map<String, dynamic> json) {
    return ServiceEventItem(
      itemId: json['itemId'] as String,
      price: (json['price'] as num?)?.toDouble() ?? (json['quantity'] as num?)?.toDouble() ?? 0.0, // Backward compatibility
    );
  }
}

class ServiceEvent {
  final String id;
  final DateTime date;
  final int mileage;
  final String place;
  final List<ServiceEventItem> items;

  ServiceEvent({
    required this.id,
    required this.date,
    required this.mileage,
    required this.place,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mileage': mileage,
      'place': place,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory ServiceEvent.fromJson(Map<String, dynamic> json) {
    return ServiceEvent(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mileage: json['mileage'] as int,
      place: json['place'] as String,
      items: (json['items'] as List)
          .map((item) => ServiceEventItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  ServiceEvent copyWith({
    String? id,
    DateTime? date,
    int? mileage,
    String? place,
    List<ServiceEventItem>? items,
  }) {
    return ServiceEvent(
      id: id ?? this.id,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      place: place ?? this.place,
      items: items ?? this.items,
    );
  }
}


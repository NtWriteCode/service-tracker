import 'package:uuid/uuid.dart';

class Car {
  final String id;
  final String name;
  final String plateNumber;
  final String? brandSlug; // e.g., "volkswagen"

  Car({
    required this.id,
    required this.name,
    required this.plateNumber,
    this.brandSlug,
  });

  // Create a new car with generated UUID
  factory Car.create({
    required String name,
    required String plateNumber,
    String? brandSlug,
  }) {
    return Car(
      id: const Uuid().v4(),
      name: name,
      plateNumber: plateNumber,
      brandSlug: brandSlug,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plateNumber': plateNumber,
      'brandSlug': brandSlug,
    };
  }

  // Create from JSON
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as String,
      name: json['name'] as String,
      plateNumber: json['plateNumber'] as String,
      brandSlug: json['brandSlug'] as String?,
    );
  }

  // Copy with method for updates
  Car copyWith({
    String? name,
    String? plateNumber,
    String? brandSlug,
  }) {
    return Car(
      id: id,
      name: name ?? this.name,
      plateNumber: plateNumber ?? this.plateNumber,
      brandSlug: brandSlug ?? this.brandSlug,
    );
  }

  @override
  String toString() => 'Car(id: $id, name: $name, plateNumber: $plateNumber, brandSlug: $brandSlug)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Car && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}


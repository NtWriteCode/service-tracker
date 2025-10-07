import 'package:uuid/uuid.dart';

class Car {
  final String id;
  final String name;
  final String plateNumber;

  Car({
    required this.id,
    required this.name,
    required this.plateNumber,
  });

  // Create a new car with generated UUID
  factory Car.create({
    required String name,
    required String plateNumber,
  }) {
    return Car(
      id: const Uuid().v4(),
      name: name,
      plateNumber: plateNumber,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plateNumber': plateNumber,
    };
  }

  // Create from JSON
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as String,
      name: json['name'] as String,
      plateNumber: json['plateNumber'] as String,
    );
  }

  // Copy with method for updates
  Car copyWith({
    String? name,
    String? plateNumber,
  }) {
    return Car(
      id: id,
      name: name ?? this.name,
      plateNumber: plateNumber ?? this.plateNumber,
    );
  }

  @override
  String toString() => 'Car(id: $id, name: $name, plateNumber: $plateNumber)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Car && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}


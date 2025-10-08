class CarBrand {
  final String name;
  final String slug;
  final String localImagePath;

  CarBrand({
    required this.name,
    required this.slug,
    required this.localImagePath,
  });

  factory CarBrand.fromJson(Map<String, dynamic> json) {
    return CarBrand(
      name: json['name'] as String,
      slug: json['slug'] as String,
      localImagePath: 'assets/car-logos/${json['slug']}.png',
    );
  }

  @override
  String toString() => 'CarBrand(name: $name, slug: $slug)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarBrand && runtimeType == other.runtimeType && slug == other.slug;

  @override
  int get hashCode => slug.hashCode;
}


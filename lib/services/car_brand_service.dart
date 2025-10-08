import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/car_brand.dart';

class CarBrandService {
  static List<CarBrand>? _cachedBrands;

  static Future<List<CarBrand>> loadBrands() async {
    if (_cachedBrands != null) {
      return _cachedBrands!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/car-logos/brands.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      _cachedBrands = jsonData
          .map((item) => CarBrand.fromJson(item as Map<String, dynamic>))
          .toList();
      
      // Sort alphabetically by name
      _cachedBrands!.sort((a, b) => a.name.compareTo(b.name));
      
      return _cachedBrands!;
    } catch (e) {
      print('Error loading car brands: $e');
      return [];
    }
  }

  static CarBrand? getBrandBySlug(String? slug) {
    if (slug == null || _cachedBrands == null) return null;
    
    try {
      return _cachedBrands!.firstWhere((brand) => brand.slug == slug);
    } catch (e) {
      return null;
    }
  }

  static void clearCache() {
    _cachedBrands = null;
  }
}


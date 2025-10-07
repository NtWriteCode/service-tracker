import 'dart:io';
import 'package:csv/csv.dart';
import '../models/service_event.dart';
import 'package:uuid/uuid.dart';

class DrivvoImporter {
  static Future<List<ServiceEvent>> importFromCsv(String filePath) async {
    print('DrivvoImporter: Starting import from $filePath');
    final file = File(filePath);
    final contents = await file.readAsString();
    print('DrivvoImporter: File read successfully, length: ${contents.length}');
    
    // Split by sections
    final sections = contents.split('##');
    print('DrivvoImporter: Found ${sections.length} sections');
    String? serviceSection;
    
    // Find the Service section
    for (final section in sections) {
      if (section.trim().startsWith('Service')) {
        serviceSection = section;
        print('DrivvoImporter: Found Service section');
        break;
      }
    }
    
    if (serviceSection == null) {
      print('DrivvoImporter: No Service section found');
      throw Exception('No Service section found in CSV');
    }
    
    // Parse CSV
    final lines = serviceSection.split('\n');
    print('DrivvoImporter: Service section has ${lines.length} lines');
    if (lines.length < 3) {
      throw Exception('Service section is empty');
    }
    
    // Skip the first line ("Service") and parse the rest as CSV
    // Join lines from index 1 onwards (header + data rows)
    final csvContent = lines.sublist(1).where((line) => line.trim().isNotEmpty).join('\n');
    print('DrivvoImporter: First line: ${lines[0]}');
    print('DrivvoImporter: Second line: ${lines[1]}');
    print('DrivvoImporter: Third line: ${lines[2]}');
    
    // Use explicit CSV settings to handle newlines correctly
    final csvData = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(csvContent);
    
    print('DrivvoImporter: CSV parsed, ${csvData.length} rows (including header)');
    if (csvData.length < 2) {
      print('DrivvoImporter: csvData content: $csvData');
      throw Exception('No service data found');
    }
    
    // Group services by mileage and date (same service event)
    final Map<String, List<Map<String, dynamic>>> groupedServices = {};
    
    for (int i = 1; i < csvData.length; i++) {
      final row = csvData[i];
      if (row.isEmpty || row[0].toString().isEmpty) continue;
      
      try {
        final odometer = double.parse(row[0].toString()).toInt();
        final dateStr = row[1].toString();
        final totalCost = _parseDouble(row[2].toString());
        final serviceType = row[3].toString();
        final location = row[4].toString();
        
        // Create a unique key for grouping (mileage + date)
        final key = '$odometer-$dateStr';
        
        if (!groupedServices.containsKey(key)) {
          groupedServices[key] = [];
        }
        
        groupedServices[key]!.add({
          'odometer': odometer,
          'date': dateStr,
          'location': location,
          'serviceType': serviceType,
          'cost': totalCost,
        });
      } catch (e) {
        print('Error parsing row $i: $e');
        continue;
      }
    }
    
    // Convert grouped services to ServiceEvent objects
    final List<ServiceEvent> events = [];
    print('DrivvoImporter: Processing ${groupedServices.length} grouped service entries');
    
    for (final entry in groupedServices.entries) {
      final services = entry.value;
      if (services.isEmpty) continue;
      
      final firstService = services.first;
      final odometer = firstService['odometer'] as int;
      final dateStr = firstService['date'] as String;
      final location = (firstService['location'] as String).isNotEmpty 
          ? firstService['location'] as String 
          : 'Imported from Drivvo';
      
      // Parse date (format: "2025-04-04 18:31:51")
      DateTime date;
      try {
        date = DateTime.parse(dateStr);
      } catch (e) {
        print('Error parsing date: $dateStr');
        continue;
      }
      
      // Create service items
      final List<ServiceEventItem> items = [];
      for (final service in services) {
        final itemId = _mapServiceTypeToItemId(service['serviceType'] as String);
        final cost = service['cost'] as double;
        
        if (itemId != null) {
          items.add(ServiceEventItem(
            itemId: itemId,
            price: cost,
          ));
        }
      }
      
      if (items.isEmpty) continue;
      
      events.add(ServiceEvent(
        id: const Uuid().v4(),
        date: date,
        mileage: odometer,
        place: location,
        items: items,
      ));
    }
    
    print('DrivvoImporter: Successfully imported ${events.length} service events');
    return events;
  }
  
  static double _parseDouble(String value) {
    if (value.isEmpty) return 0.0;
    try {
      return double.parse(value);
    } catch (e) {
      return 0.0;
    }
  }
  
  static String? _mapServiceTypeToItemId(String serviceType) {
    final lowerType = serviceType.toLowerCase();
    
    // Map Drivvo service types to our default item IDs
    if (lowerType.contains('oil change')) {
      return 'default_1'; // Engine Oil Change
    } else if (lowerType.contains('oil filter')) {
      return 'default_2'; // Oil Filter
    } else if (lowerType.contains('air filter') && !lowerType.contains('cabin')) {
      return 'default_3'; // Air Filter
    } else if (lowerType.contains('cabin air filter') || lowerType.contains('pollen filter')) {
      return 'default_4'; // Cabin Air Filter
    } else if (lowerType.contains('fuel filter')) {
      return 'default_5'; // Fuel Filter
    } else if (lowerType.contains('brake pad')) {
      return 'default_6'; // Brake Pad
    } else if (lowerType.contains('brake disc')) {
      return 'default_7'; // Brake Disc
    } else if (lowerType.contains('brake fluid')) {
      return 'default_8'; // Brake Fluid
    } else if (lowerType.contains('coolant')) {
      return 'default_9'; // Coolant
    } else if (lowerType.contains('timing belt')) {
      return 'default_10'; // Timing Belt
    } else if (lowerType.contains('spark plug')) {
      return 'default_11'; // Spark Plug
    } else if (lowerType.contains('battery')) {
      return 'default_12'; // Battery
    } else if (lowerType.contains('tire rotation')) {
      return 'default_13'; // Tire Rotation
    } else if (lowerType.contains('new tire') || lowerType.contains('tire replacement')) {
      return 'default_14'; // Tire Replacement
    } else if (lowerType.contains('wheel alignment') || lowerType.contains('futóműállítás')) {
      return 'default_15'; // Wheel Alignment
    } else if (lowerType.contains('wheel balancing')) {
      return 'default_16'; // Wheel Balancing
    } else if (lowerType.contains('transmission') || lowerType.contains('gearbox')) {
      return 'default_17'; // Transmission Oil
    } else if (lowerType.contains('wiper') || lowerType.contains('windshield wiper')) {
      return 'default_18'; // Wiper Blades
    } else if (lowerType.contains('inspection') || lowerType.contains('check') || lowerType.contains('suspension')) {
      return 'default_19'; // Inspection
    } else if (lowerType.contains('working fee') || lowerType.contains('labor') || lowerType.contains('delivery')) {
      return 'default_20'; // Labor/Service Fee
    } else if (lowerType.contains('ribbed belt') || lowerType.contains('serpentine')) {
      return 'default_21'; // Serpentine Belt
    } else if (lowerType.contains('replace wheel season') || lowerType.contains('seasonal')) {
      return 'default_22'; // Seasonal Tire Change
    } else if (lowerType.contains('air conditioning') || lowerType.contains('ac ') || lowerType.contains('a/c')) {
      return 'default_23'; // AC System Service
    } else if (lowerType.contains('mounting tire') || lowerType.contains('tire mounting')) {
      return 'default_24'; // Tire Mounting
    } else if (lowerType.contains('oil screw') || lowerType.contains('drain plug')) {
      return 'default_25'; // Oil Drain Plug/Washer
    }
    
    // If no match found, use inspection as fallback
    return 'default_19';
  }
}


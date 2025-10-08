import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/car.dart';
import '../models/car_brand.dart';
import '../services/car_brand_service.dart';
import '../widgets/brand_selector_dialog.dart';
import '../l10n/app_localizations.dart';

class CarDrawer extends StatelessWidget {
  const CarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Drawer(
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final cars = provider.cars;
          final activeCar = provider.activeCar;
          
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 48,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.myCars,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // List of cars
              ...cars.map((car) {
                final isActive = car.id == activeCar?.id;
                final brand = CarBrandService.getBrandBySlug(car.brandSlug);
                
                return ListTile(
                  leading: brand != null
                      ? Image.asset(
                          brand.localImagePath,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.directions_car,
                            color: isActive ? Theme.of(context).colorScheme.primary : null,
                          ),
                        )
                      : Icon(
                          Icons.directions_car,
                          color: isActive ? Theme.of(context).colorScheme.primary : null,
                        ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (brand != null)
                              Text(
                                brand.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            Text(
                              car.name,
                              style: TextStyle(
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                color: isActive ? Theme.of(context).colorScheme.primary : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                    ],
                  ),
                  subtitle: car.plateNumber.isNotEmpty ? Text(car.plateNumber) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showCarOptions(context, car, isActive),
                  ),
                  onTap: () {
                    if (!isActive) {
                      provider.switchCar(car.id);
                      Navigator.pop(context);
                    }
                  },
                );
              }),
              const Divider(),
              // Add new car button
              ListTile(
                leading: Icon(
                  Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  l10n.addCar,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showAddCarDialog(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCarOptions(BuildContext context, Car car, bool isActive) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<AppProvider>(context, listen: false);
    final canDelete = provider.cars.length > 1;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.editCar),
              onTap: () {
                Navigator.pop(context);
                _showEditCarDialog(context, car);
              },
            ),
            if (canDelete)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(l10n.deleteCar, style: const TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteCarDialog(context, car);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddCarDialog(BuildContext context) {
    _showCarFormDialog(context, isEdit: false);
  }

  void _showEditCarDialog(BuildContext context, Car car) {
    _showCarFormDialog(context, isEdit: true, existingCar: car);
  }

  void _showCarFormDialog(BuildContext context, {required bool isEdit, Car? existingCar}) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: existingCar?.name);
    final plateController = TextEditingController(text: existingCar?.plateNumber);
    final formKey = GlobalKey<FormState>();
    
    String? selectedBrandSlug = existingCar?.brandSlug;
    CarBrand? selectedBrand = selectedBrandSlug != null 
        ? CarBrandService.getBrandBySlug(selectedBrandSlug)
        : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? l10n.editCar : l10n.newCar),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand selector
                  InkWell(
                    onTap: () async {
                      final result = await showDialog<CarBrand?>(
                        context: context,
                        builder: (context) => BrandSelectorDialog(
                          initialBrandSlug: selectedBrandSlug,
                        ),
                      );
                      
                      if (result != null || result == null) {
                        setState(() {
                          selectedBrand = result;
                          selectedBrandSlug = result?.slug;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.brand,
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                      child: Row(
                        children: [
                          if (selectedBrand != null) ...[
                            Image.asset(
                              selectedBrand!.localImagePath,
                              width: 30,
                              height: 30,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.car_rental, size: 30),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(selectedBrand!.name)),
                          ] else
                            Text(
                              l10n.selectBrand,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.carName,
                      hintText: l10n.enterCarName,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.carNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: plateController,
                    decoration: InputDecoration(
                      labelText: l10n.plateNumber,
                      hintText: l10n.enterPlateNumber,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final provider = Provider.of<AppProvider>(context, listen: false);
                  
                  if (isEdit && existingCar != null) {
                    final updatedCar = existingCar.copyWith(
                      name: nameController.text.trim(),
                      plateNumber: plateController.text.trim(),
                      brandSlug: selectedBrandSlug,
                    );
                    provider.updateCar(updatedCar);
                  } else {
                    final newCar = Car.create(
                      name: nameController.text.trim(),
                      plateNumber: plateController.text.trim(),
                      brandSlug: selectedBrandSlug,
                    );
                    provider.addCar(newCar);
                    provider.switchCar(newCar.id);
                  }
                  
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteCarDialog(BuildContext context, Car car) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    if (provider.cars.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotDeleteLastCar)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCar),
        content: Text(l10n.deleteCarConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteCar(car.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${car.name} ${l10n.delete.toLowerCase()}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }
}


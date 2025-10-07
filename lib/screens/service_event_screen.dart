import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../providers/app_provider.dart';
import '../models/service_event.dart';
import '../models/service_item.dart';
import '../widgets/service_item_autocomplete.dart';
import '../utils/currency_formatter.dart';

class ServiceEventScreen extends StatefulWidget {
  final ServiceEvent? event;

  const ServiceEventScreen({super.key, this.event});

  @override
  State<ServiceEventScreen> createState() => _ServiceEventScreenState();
}

class _ServiceEventScreenState extends State<ServiceEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mileageController = TextEditingController();
  final _placeController = TextEditingController();
  
  late DateTime _selectedDate;
  final List<Map<String, dynamic>> _selectedItems = []; // List of {itemId, price}
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _selectedDate = widget.event!.date;
      _mileageController.text = widget.event!.mileage.toString();
      _placeController.text = widget.event!.place;
      for (final item in widget.event!.items) {
        _selectedItems.add({'itemId': item.itemId, 'price': item.price});
      }
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.locationServicesDisabled),
            ),
          );
        }
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.locationPermissionDenied),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.locationPermissionDeniedForever),
              action: SnackBarAction(
                label: AppLocalizations.of(context)!.settings,
                onPressed: () {
                  Geolocator.openAppSettings();
                },
              ),
            ),
          );
        }
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        String location = '';
        
        // Build location string with available information
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          location = placemark.locality!;
        }
        if (placemark.subAdministrativeArea != null && 
            placemark.subAdministrativeArea!.isNotEmpty &&
            placemark.subAdministrativeArea != placemark.locality) {
          if (location.isNotEmpty) {
            location += ', ${placemark.subAdministrativeArea}';
          } else {
            location = placemark.subAdministrativeArea!;
          }
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          if (location.isNotEmpty) {
            location += ', ${placemark.country}';
          } else {
            location = placemark.country!;
          }
        }

        if (location.isNotEmpty) {
          setState(() {
            _placeController.text = location;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.locationNotFound),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noItemsSelected),
          ),
        );
        return;
      }

      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final event = ServiceEvent(
        id: widget.event?.id ?? const Uuid().v4(),
        date: _selectedDate,
        mileage: int.parse(_mileageController.text),
        place: _placeController.text,
        items: _selectedItems
            .map((item) => ServiceEventItem(
                  itemId: item['itemId'] as String,
                  price: item['price'] as double,
                ))
            .toList(),
      );

      if (widget.event != null) {
        await appProvider.updateServiceEvent(event);
      } else {
        await appProvider.addServiceEvent(event);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _deleteEvent() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteServiceConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.deleteServiceEvent(widget.event!.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? l10n.editService : l10n.newService),
        actions: widget.event != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteEvent,
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.serviceDone,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(l10n.date),
                      subtitle: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      trailing: TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text(l10n.selectDate),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mileageController,
                      decoration: InputDecoration(
                        labelText: l10n.mileage,
                        suffixText: l10n.km,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.speed),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.requiredField;
                        }
                        final mileage = int.tryParse(value);
                        if (mileage == null || mileage < 0) {
                          return l10n.mileageMustBePositive;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _placeController,
                            decoration: InputDecoration(
                              labelText: l10n.place,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.location_on),
                              hintText: l10n.enterPlace,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.requiredField;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: IconButton.filled(
                            icon: _isLoadingLocation
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.my_location),
                            onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                            tooltip: l10n.useCurrentLocation,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.selectedItems,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ServiceItemAutocomplete(
                      allItems: appProvider.serviceItems,
                      languageCode: languageCode,
                      onItemSelected: (ServiceItem item) {
                        _addItemWithPrice(item.id);
                      },
                      onCustomItemCreate: (String name) {
                        _createCustomItemAndAdd(name, languageCode);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_selectedItems.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            l10n.noItemsSelected,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ),
                      )
                    else
                      ..._buildSelectedItemsList(languageCode),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveEvent,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSelectedItemsList(String languageCode) {
    final appProvider = Provider.of<AppProvider>(context);
    final currency = appProvider.settings.currency;
    
    return _selectedItems.asMap().entries.map((entry) {
      final index = entry.key;
      final itemData = entry.value;
      final item = appProvider.getServiceItem(itemData['itemId'] as String);
      if (item == null) return const SizedBox.shrink();
      
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(item.getName(languageCode)),
        subtitle: Text('${AppLocalizations.of(context)!.price}: ${CurrencyFormatter.format(itemData['price'] as double, currency)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editItemPrice(index, itemData['price'] as double),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _selectedItems.removeAt(index);
                });
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _createCustomItemAndAdd(String name, String languageCode) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    // Create custom item
    final customItem = ServiceItem(
      id: const Uuid().v4(),
      nameEn: name,
      nameHu: name,
      isCustom: true,
      customName: name,
    );
    
    await appProvider.addServiceItem(customItem);
    
    // Then add with price
    if (mounted) {
      _addItemWithPrice(customItem.id);
    }
  }

  Future<void> _addItemWithPrice(String itemId) async {
    final l10n = AppLocalizations.of(context)!;
    final currency = Provider.of<AppProvider>(context, listen: false).settings.currency;
    final controller = TextEditingController(text: '0');

    final price = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.price),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: l10n.price,
            suffixText: currency,
            border: const OutlineInputBorder(),
            helperText: 'Enter whole numbers only',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value >= 0) {
                Navigator.pop(context, value);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (price != null) {
      setState(() {
        _selectedItems.add({'itemId': itemId, 'price': price});
      });
    }
  }

  Future<void> _editItemPrice(int index, double currentPrice) async {
    final l10n = AppLocalizations.of(context)!;
    final currency = Provider.of<AppProvider>(context, listen: false).settings.currency;
    final controller = TextEditingController(text: currentPrice.round().toString());

    final price = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.price),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: l10n.price,
            suffixText: currency,
            border: const OutlineInputBorder(),
            helperText: 'Enter whole numbers only',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value >= 0) {
                Navigator.pop(context, value);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (price != null) {
      setState(() {
        _selectedItems[index]['price'] = price;
      });
    }
  }
}


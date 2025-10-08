import 'package:flutter/material.dart';
import '../models/car_brand.dart';
import '../services/car_brand_service.dart';
import '../l10n/app_localizations.dart';

class BrandSelectorDialog extends StatefulWidget {
  final String? initialBrandSlug;

  const BrandSelectorDialog({super.key, this.initialBrandSlug});

  @override
  State<BrandSelectorDialog> createState() => _BrandSelectorDialogState();
}

class _BrandSelectorDialogState extends State<BrandSelectorDialog> {
  List<CarBrand> _allBrands = [];
  List<CarBrand> _filteredBrands = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    final brands = await CarBrandService.loadBrands();
    setState(() {
      _allBrands = brands;
      _filteredBrands = brands;
      _isLoading = false;
    });
  }

  void _filterBrands(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBrands = _allBrands;
      } else {
        _filteredBrands = _allBrands
            .where((brand) =>
                brand.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.selectBrand,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchBrands,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: _filterBrands,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.clear),
              title: Text(l10n.noBrand),
              onTap: () => Navigator.pop(context, null),
            ),
            const Divider(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filteredBrands.length,
                      itemBuilder: (context, index) {
                        final brand = _filteredBrands[index];
                        final isSelected = brand.slug == widget.initialBrandSlug;

                        return ListTile(
                          leading: Image.asset(
                            brand.localImagePath,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.car_rental),
                          ),
                          title: Text(brand.name),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () => Navigator.pop(context, brand),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


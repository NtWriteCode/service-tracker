import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/service_item.dart';

class ServiceItemsScreen extends StatelessWidget {
  const ServiceItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.serviceItems),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appProvider.serviceItems.length,
        itemBuilder: (context, index) {
          final item = appProvider.serviceItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(item.getName(languageCode)),
              subtitle: item.isCustom
                  ? Text(l10n.itemName)
                  : null,
              trailing: item.isCustom
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editItem(context, item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteItem(context, appProvider, item, l10n),
                        ),
                      ],
                    )
                  : null,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addItem(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newItem),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.itemName,
            border: const OutlineInputBorder(),
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
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (name != null && context.mounted) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final newItem = ServiceItem(
        id: const Uuid().v4(),
        nameEn: '',
        nameHu: '',
        isCustom: true,
        customName: name,
      );
      await appProvider.addServiceItem(newItem);
    }
  }

  Future<void> _editItem(BuildContext context, ServiceItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: item.customName);

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editItem),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.itemName,
            border: const OutlineInputBorder(),
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
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (name != null && context.mounted) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final updatedItem = item.copyWith(customName: name);
      await appProvider.updateServiceItem(updatedItem);
    }
  }

  Future<void> _deleteItem(
    BuildContext context,
    AppProvider appProvider,
    ServiceItem item,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteItemConfirm),
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

    if (confirm == true) {
      await appProvider.deleteServiceItem(item.id);
    }
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../services/drivvo_importer.dart';
import '../models/service_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: Text(_getLanguageName(appProvider.settings.languageCode, l10n)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context, appProvider, l10n),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.attach_money),
              title: Text(l10n.currency),
              subtitle: Text(appProvider.settings.currency),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showCurrencyDialog(context, appProvider, l10n),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.dataManagement,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.upload_file),
              title: Text(l10n.importDrivvo),
              subtitle: Text(l10n.importDrivvoDesc),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _importDrivvoData(context, appProvider, l10n),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.list_alt),
              title: Text(l10n.manageItems),
              subtitle: Text('${appProvider.serviceItems.where((i) => i.isCustom).length} ${l10n.custom.toLowerCase()}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showCustomItemsDialog(context, appProvider, l10n),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.webdavSync,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    appProvider.settings.hasWebdavCredentials
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                    color: appProvider.settings.hasWebdavCredentials
                        ? Colors.green
                        : null,
                  ),
                  title: Text(l10n.webdavSettings),
                  subtitle: Text(
                    appProvider.settings.hasWebdavCredentials
                        ? l10n.webdavConnected
                        : l10n.webdavNotConnected,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showWebdavSettingsDialog(context, appProvider, l10n),
                ),
                if (appProvider.settings.hasWebdavCredentials) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.sync),
                    title: Text(l10n.webdavAutoSync),
                    subtitle: Text(l10n.webdavAutoSyncDesc),
                    value: appProvider.settings.autoSync,
                    onChanged: (value) {
                      appProvider.updateAutoSync(value);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_upload),
                    title: Text(l10n.webdavExport),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _exportToWebdav(context, appProvider, l10n),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_download),
                    title: Text(l10n.webdavImport),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _importFromWebdav(context, appProvider, l10n),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String languageCode, AppLocalizations l10n) {
    switch (languageCode) {
      case 'en':
        return l10n.english;
      case 'hu':
        return l10n.hungarian;
      default:
        return 'System';
    }
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    AppProvider appProvider,
    AppLocalizations l10n,
  ) async {
    final currentLanguage = appProvider.settings.languageCode;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('System'),
              value: 'system',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  appProvider.updateLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.english),
              value: 'en',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  appProvider.updateLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.hungarian),
              value: 'hu',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  appProvider.updateLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _showCurrencyDialog(
    BuildContext context,
    AppProvider appProvider,
    AppLocalizations l10n,
  ) async {
    final currencies = ['EUR', 'USD', 'HUF', 'GBP', 'CHF', 'PLN', 'CZK', 'RON'];
    final currentCurrency = appProvider.settings.currency;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectCurrency),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: currencies.map((currency) => RadioListTile<String>(
              title: Text(currency),
              value: currency,
              groupValue: currentCurrency,
              onChanged: (value) {
                if (value != null) {
                  appProvider.updateCurrency(value);
                  Navigator.pop(context);
                }
              },
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _importDrivvoData(
    BuildContext context,
    AppProvider appProvider,
    AppLocalizations l10n,
  ) async {
    try {
      print('SettingsScreen: Starting Drivvo import');
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) {
        print('SettingsScreen: File picker cancelled or no path');
        return;
      }

      final filePath = result.files.single.path!;
      print('SettingsScreen: Selected file: $filePath');

      // Show loading dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(l10n.importing),
            ],
          ),
        ),
      );

      // Import data
      print('SettingsScreen: Calling DrivvoImporter.importFromCsv');
      final events = await DrivvoImporter.importFromCsv(filePath);
      print('SettingsScreen: Import returned ${events.length} events');

      // Add all events
      for (final event in events) {
        await appProvider.addServiceEvent(event);
      }
      print('SettingsScreen: All events added to provider');

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.importSuccess}: ${events.length} ${l10n.servicesImported}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('SettingsScreen: Error during import: $e');
      // Close loading dialog if open
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.importError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCustomItemsDialog(
    BuildContext context,
    AppProvider appProvider,
    AppLocalizations l10n,
  ) {
    final languageCode = Localizations.localeOf(context).languageCode;

    showDialog(
      context: context,
      builder: (context) => Consumer<AppProvider>(
        builder: (context, provider, child) {
          final customItems = provider.serviceItems.where((i) => i.isCustom).toList();
          
          return AlertDialog(
            title: Text(l10n.manageItems),
            content: customItems.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.noItemsSelected),
                  )
                : SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: customItems.length,
                      itemBuilder: (context, index) {
                        final item = customItems[index];
                        final usageCount = provider.serviceEvents
                            .where((event) =>
                                event.items.any((i) => i.itemId == item.id))
                            .length;
                        final canDelete = usageCount == 0;

                        return ListTile(
                          leading: const Icon(Icons.label, color: Colors.blue),
                          title: Text(item.getName(languageCode)),
                          subtitle: Text(
                            canDelete
                                ? 'Not used'
                                : 'Used in $usageCount event${usageCount > 1 ? 's' : ''}',
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: canDelete ? Colors.red : Colors.grey,
                            ),
                            onPressed: canDelete
                                ? () => _confirmDeleteCustomItem(
                                    context, provider, item, l10n)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteCustomItem(
    BuildContext context,
    AppProvider appProvider,
    ServiceItem item,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteItem),
        content: Text(l10n.deleteItemConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await appProvider.deleteServiceItem(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.customName} ${l10n.delete.toLowerCase()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // WebDAV Settings Dialog
  void _showWebdavSettingsDialog(
    BuildContext context,
    AppProvider appProvider,
    AppLocalizations l10n,
  ) {
    final urlController = TextEditingController(text: appProvider.settings.webdavUrl);
    final usernameController = TextEditingController(text: appProvider.settings.webdavUsername);
    final passwordController = TextEditingController(text: appProvider.settings.webdavPassword);
    final formKey = GlobalKey<FormState>();
    bool isValidating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.webdavSettings),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: urlController,
                    decoration: InputDecoration(
                      labelText: l10n.webdavUrl,
                      hintText: l10n.enterWebdavUrl,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.link),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.webdavUrlRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: l10n.webdavUsername,
                      hintText: l10n.enterUsername,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.usernameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.webdavPassword,
                      hintText: l10n.enterPassword,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.passwordRequired;
                      }
                      return null;
                    },
                  ),
                  if (isValidating) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(width: 16),
                        Text(l10n.webdavValidating),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            if (appProvider.settings.hasWebdavCredentials)
              TextButton(
                onPressed: isValidating
                    ? null
                    : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.webdavLogout),
                            content: Text(l10n.logoutConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(l10n.webdavLogout),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          await appProvider.clearWebdavCredentials();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.webdavLogout),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                child: Text(l10n.webdavLogout, style: const TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: isValidating ? null : () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: isValidating
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isValidating = true;
                        });

                        final success = await appProvider.updateWebdavCredentials(
                          url: urlController.text.trim(),
                          username: usernameController.text.trim(),
                          password: passwordController.text.trim(),
                        );

                        if (context.mounted) {
                          setState(() {
                            isValidating = false;
                          });

                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.webdavValidationSuccess),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.webdavValidationFailed),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
              child: Text(l10n.webdavLogin),
            ),
          ],
        ),
      ),
    );
  }

  // Export to WebDAV
  Future<void> _exportToWebdav(
    BuildContext context,
    AppProvider appProvider,
    AppLocalizations l10n,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(l10n.webdavExporting)),
          ],
        ),
      ),
    );

    try {
      final results = await appProvider.exportToWebdav();
      
      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog

        final successCount = results.values.where((v) => v).length;
        final totalCount = results.length;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successCount == totalCount
                  ? l10n.webdavExportSuccess
                  : '${l10n.webdavExportSuccess}: $successCount/$totalCount',
            ),
            backgroundColor: successCount > 0 ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.webdavExportFailed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Import from WebDAV
  Future<void> _importFromWebdav(
    BuildContext context,
    AppProvider appProvider,
    AppLocalizations l10n,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(l10n.webdavImporting)),
          ],
        ),
      ),
    );

    try {
      final results = await appProvider.importFromWebdav();
      
      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog

        final successCount = results.values.where((v) => v).length;
        final totalCount = results.length;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successCount == totalCount
                  ? l10n.webdavImportSuccess
                  : '${l10n.webdavImportSuccess}: $successCount/$totalCount',
            ),
            backgroundColor: successCount > 0 ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.webdavImportFailed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}


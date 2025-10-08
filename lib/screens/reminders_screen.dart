import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/reminder.dart';
import '../models/service_item.dart';
import '../utils/currency_formatter.dart';
import '../constants/default_reminders.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reminders),
      ),
      body: appProvider.reminders.isEmpty
          ? Center(
              child: Text(
                l10n.noReminders,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appProvider.reminders.length,
              itemBuilder: (context, index) {
                final reminder = appProvider.reminders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(reminder.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (reminder.hasKmInterval)
                          Text('${l10n.everyKm}: ${CurrencyFormatter.formatMileage(reminder.intervalKm!)} ${l10n.km}'),
                        if (reminder.hasTimeInterval)
                          Text('${l10n.everyMonths}: ${reminder.intervalMonths}'),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: reminder.itemIds.map((itemId) {
                            final item = appProvider.getServiceItem(itemId);
                            return Chip(
                              label: Text(
                                item?.getName(languageCode) ?? '',
                                style: const TextStyle(fontSize: 11),
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editReminder(context, reminder),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _deleteReminder(context, appProvider, reminder, l10n),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addReminder(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addReminder(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    
    // Show template selection dialog
    final template = await showDialog<ReminderTemplate?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectReminderTemplate),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              // Custom reminder option
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Colors.blue),
                title: Text(l10n.customReminder),
                subtitle: Text(l10n.createFromScratch),
                onTap: () => Navigator.pop(context, null),
              ),
              const Divider(),
              // Predefined templates
              ...defaultReminderTemplates.map((template) {
                return ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.green),
                  title: Text(template.getName(languageCode)),
                  subtitle: Text(
                    [
                      if (template.intervalKm != null)
                        '${CurrencyFormatter.formatMileage(template.intervalKm!)} ${l10n.km}',
                      if (template.intervalMonths != null)
                        '${template.intervalMonths} ${l10n.everyMonths.toLowerCase()}',
                    ].join(' ${l10n.or} '),
                  ),
                  onTap: () => Navigator.pop(context, template),
                );
              }),
            ],
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

    // Don't proceed if user cancelled
    if (!context.mounted) return;
    
    // Show reminder dialog with template pre-filled (or empty if custom)
    await _showReminderDialog(context, null, template: template);
  }

  Future<void> _editReminder(BuildContext context, Reminder reminder) async {
    await _showReminderDialog(context, reminder);
  }

  Future<void> _showReminderDialog(BuildContext context, Reminder? reminder, {ReminderTemplate? template}) async {
    final languageCode = Localizations.localeOf(context).languageCode;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ReminderEditScreen(
          reminder: reminder,
          languageCode: languageCode,
          template: template,
        ),
      ),
    );
  }

  Future<void> _deleteReminder(
    BuildContext context,
    AppProvider appProvider,
    Reminder reminder,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteReminderConfirm),
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
      await appProvider.deleteReminder(reminder.id);
    }
  }
}

class _ReminderEditScreen extends StatefulWidget {
  final Reminder? reminder;
  final String languageCode;
  final ReminderTemplate? template;

  const _ReminderEditScreen({
    this.reminder,
    required this.languageCode,
    this.template,
  });

  @override
  State<_ReminderEditScreen> createState() => _ReminderEditScreenState();
}

class _ReminderEditScreenState extends State<_ReminderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _kmController = TextEditingController();
  final _monthsController = TextEditingController();
  
  final Set<String> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      // Editing existing reminder
      _nameController.text = widget.reminder!.name;
      _kmController.text = widget.reminder!.intervalKm?.toString() ?? '';
      _monthsController.text = widget.reminder!.intervalMonths?.toString() ?? '';
      _selectedItemIds.addAll(widget.reminder!.itemIds);
    } else if (widget.template != null) {
      // Using a template
      _nameController.text = widget.template!.getName(widget.languageCode);
      _kmController.text = widget.template!.intervalKm?.toString() ?? '';
      _monthsController.text = widget.template!.intervalMonths?.toString() ?? '';
      _selectedItemIds.addAll(widget.template!.suggestedItemIds);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _kmController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final l10n = AppLocalizations.of(context)!;
      
      if (_selectedItemIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noItemsSelected)),
        );
        return;
      }

      final km = _kmController.text.trim().isNotEmpty
          ? int.tryParse(_kmController.text.trim())
          : null;
      final months = _monthsController.text.trim().isNotEmpty
          ? int.tryParse(_monthsController.text.trim())
          : null;

      if (km == null && months == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.atLeastOneCondition)),
        );
        return;
      }

      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final reminder = Reminder(
        id: widget.reminder?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        itemIds: _selectedItemIds.toList(),
        intervalKm: km,
        intervalMonths: months,
      );

      if (widget.reminder != null) {
        await appProvider.updateReminder(reminder);
      } else {
        await appProvider.addReminder(reminder);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder != null ? l10n.editReminder : l10n.newReminder),
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
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.reminderName,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.label),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.requiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _kmController,
                      decoration: InputDecoration(
                        labelText: l10n.everyKm,
                        suffixText: l10n.km,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.speed),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _monthsController,
                      decoration: InputDecoration(
                        labelText: l10n.everyMonths,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.selectItems,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _showItemSelectionDialog(appProvider),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedItemIds.isEmpty)
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedItemIds.map((itemId) {
                          final item = appProvider.getServiceItem(itemId);
                          if (item == null) return const SizedBox.shrink();
                          return Chip(
                            label: Text(item.getName(widget.languageCode)),
                            onDeleted: () {
                              setState(() {
                                _selectedItemIds.remove(itemId);
                              });
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveReminder,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showItemSelectionDialog(AppProvider appProvider) async {
    final l10n = AppLocalizations.of(context)!;

    final selectedItem = await showDialog<ServiceItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectItems),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: appProvider.serviceItems.length,
            itemBuilder: (context, index) {
              final item = appProvider.serviceItems[index];
              final isSelected = _selectedItemIds.contains(item.id);
              return ListTile(
                title: Text(item.getName(widget.languageCode)),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, item),
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
      ),
    );

    if (selectedItem != null && !_selectedItemIds.contains(selectedItem.id)) {
      setState(() {
        _selectedItemIds.add(selectedItem.id);
      });
    }
  }
}


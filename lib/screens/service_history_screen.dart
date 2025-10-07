import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../models/service_event.dart';
import 'service_event_screen.dart';
import '../utils/currency_formatter.dart';

class ServiceHistoryScreen extends StatelessWidget {
  const ServiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.serviceHistory),
      ),
      body: appProvider.serviceEvents.isEmpty
          ? Center(
              child: Text(
                l10n.noServices,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appProvider.serviceEvents.length,
              itemBuilder: (context, index) {
                final event = appProvider.serviceEvents[index];
                return _buildServiceCard(context, appProvider, event, l10n, languageCode);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ServiceEventScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    AppProvider appProvider,
    ServiceEvent event,
    AppLocalizations l10n,
    String languageCode,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceEventScreen(event: event),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${event.date.day}/${event.date.month}/${event.date.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${CurrencyFormatter.formatMileage(event.mileage)} ${l10n.km}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.place,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: event.items.map((item) {
                  final serviceItem = appProvider.getServiceItem(item.itemId);
                  if (serviceItem == null) return const SizedBox.shrink();
                  return Chip(
                    label: Text(
                      '${serviceItem.getName(languageCode)} - ${CurrencyFormatter.format(item.price, appProvider.settings.currency)}',
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
              if (event.items.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${l10n.total}: ${CurrencyFormatter.format(event.items.fold<double>(0, (sum, item) => sum + item.price), appProvider.settings.currency)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


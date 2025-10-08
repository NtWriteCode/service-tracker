import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../models/reminder.dart';
import '../services/car_brand_service.dart';
import '../widgets/info_card.dart';
import '../widgets/upcoming_service_card.dart';
import '../widgets/car_drawer.dart';
import '../utils/currency_formatter.dart';
import 'mileage_screen.dart';
import 'service_event_screen.dart';
import 'service_history_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);

    if (appProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final activeCar = appProvider.activeCar;
    final brand = CarBrandService.getBrandBySlug(activeCar?.brandSlug);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (brand != null) ...[
              Image.asset(
                brand.localImagePath,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (brand != null)
                    Text(brand.name, style: const TextStyle(fontSize: 12)),
                  if (activeCar != null)
                    Text(
                      activeCar.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: const CarDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // Reload data
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMileageCard(context, appProvider, l10n),
            const SizedBox(height: 16),
            _buildQuickActionsCard(context, l10n),
            const SizedBox(height: 16),
            _buildUpcomingServicesCard(context, appProvider, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildMileageCard(
    BuildContext context,
    AppProvider appProvider,
    AppLocalizations l10n,
  ) {
    return InfoCard(
      title: l10n.currentMileage,
      value: '${CurrencyFormatter.formatMileage(appProvider.settings.currentMileage)} ${l10n.km}',
      icon: Icons.speed,
      color: Theme.of(context).colorScheme.primary,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MileageScreen()),
        );
      },
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.home,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.build,
                    label: l10n.addService,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ServiceEventScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.history,
                    label: l10n.serviceHistory,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ServiceHistoryScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.notifications,
                    label: l10n.reminders,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RemindersScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingServicesCard(
    BuildContext context,
    AppProvider appProvider,
    AppLocalizations l10n,
  ) {
    final upcomingServices = appProvider.getUpcomingServices();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.upcomingServices,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (upcomingServices.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.noUpcomingServices,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
              )
            else
              ...upcomingServices.take(5).map((service) {
                final reminder = service['reminder'] as Reminder;
                final isOverdue = service['isOverdue'] as bool;
                final dueKm = service['dueKm'] as int?;
                final dueDate = service['dueDate'] as DateTime?;

                return UpcomingServiceCard(
                  reminder: reminder,
                  isOverdue: isOverdue,
                  dueKm: dueKm,
                  dueDate: dueDate,
                  currentMileage: appProvider.settings.currentMileage,
                );
              }),
          ],
        ),
      ),
    );
  }
}


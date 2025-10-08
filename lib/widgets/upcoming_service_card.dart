import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/reminder.dart';
import '../utils/currency_formatter.dart';
import '../screens/service_event_screen.dart';
import '../providers/app_provider.dart';

class UpcomingServiceCard extends StatefulWidget {
  final Reminder reminder;
  final String urgencyLevel;
  final int? dueKm;
  final DateTime? dueDate;
  final int currentMileage;
  final VoidCallback? onServiceAdded;

  const UpcomingServiceCard({
    super.key,
    required this.reminder,
    required this.urgencyLevel,
    this.dueKm,
    this.dueDate,
    required this.currentMileage,
    this.onServiceAdded,
  });

  @override
  State<UpcomingServiceCard> createState() => _UpcomingServiceCardState();
}

class _UpcomingServiceCardState extends State<UpcomingServiceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    
    // Determine color based on urgency level
    final Color color;
    final IconData icon;
    
    switch (widget.urgencyLevel) {
      case 'good':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'warning':
        color = Colors.orange;
        icon = Icons.schedule_rounded;
        break;
      case 'urgent':
        color = Colors.red;
        icon = Icons.warning_rounded;
        break;
      case 'overdue':
        color = Colors.red.shade900;
        icon = Icons.error_rounded;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Header (always visible) - tappable to expand/collapse
          ListTile(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            title: Text(
              widget.reminder.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.dueKm != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${CurrencyFormatter.formatMileage((widget.dueKm! - widget.currentMileage).abs())} ${l10n.km}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          
          // Expanded content (collapsible) - shows items
          if (_isExpanded)
            InkWell(
              onTap: () => _showAddServiceDialog(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Due date/mileage information with specific icons
                    if (widget.dueKm != null || widget.dueDate != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.dueKm != null) ...[
                              Row(
                                children: [
                                  Icon(Icons.speed, size: 16, color: color),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${l10n.dueAt}: ${CurrencyFormatter.formatMileage(widget.dueKm!)} ${l10n.km}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.dueDate != null) const SizedBox(height: 8),
                            ],
                            if (widget.dueDate != null)
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: color),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${l10n.dueAt}: ${widget.dueDate!.day}/${widget.dueDate!.month}/${widget.dueDate!.year}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Items section header
                    Row(
                      children: [
                        Icon(Icons.build, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          l10n.items,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.addService,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Icon(Icons.arrow_forward, size: 16, color: color),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.reminder.itemIds.map((itemId) {
                        final item = appProvider.getServiceItem(itemId);
                        if (item == null) return const SizedBox.shrink();
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.getName(languageCode),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    
                    // Skip/Undo button (skip not shown for green items, but undo always shown)
                    if (widget.reminder.isSkipped)
                      InkWell(
                        onTap: () => _undoSkip(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.undo, size: 14, color: color),
                              const SizedBox(width: 4),
                              Text(
                                l10n.undoSkip,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (widget.urgencyLevel != 'good')
                      InkWell(
                        onTap: () => _skipPeriod(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.skip_next, size: 14, color: Colors.grey.shade700),
                              const SizedBox(width: 4),
                              Text(
                                l10n.skipPeriod,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    Text(
                      l10n.tapToAddService,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _skipPeriod(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    await appProvider.skipReminderPeriod(widget.reminder.id);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.periodSkipped),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: l10n.undo,
            textColor: Colors.white,
            onPressed: () => _undoSkip(context),
          ),
        ),
      );
    }
  }

  Future<void> _undoSkip(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    await appProvider.undoSkipReminderPeriod(widget.reminder.id);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.skipUndone),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showAddServiceDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addService),
        content: Text(l10n.addServiceForReminder(widget.reminder.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.addService),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Navigate to add service screen with pre-filled items
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceEventScreen(
            prefilledItemIds: widget.reminder.itemIds,
          ),
        ),
      );
      
      // Trigger callback to refresh the home screen
      widget.onServiceAdded?.call();
    }
  }
}

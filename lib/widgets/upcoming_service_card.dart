import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/reminder.dart';
import '../utils/currency_formatter.dart';

class UpcomingServiceCard extends StatelessWidget {
  final Reminder reminder;
  final bool isOverdue;
  final int? dueKm;
  final DateTime? dueDate;
  final int currentMileage;

  const UpcomingServiceCard({
    super.key,
    required this.reminder,
    required this.isOverdue,
    this.dueKm,
    this.dueDate,
    required this.currentMileage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = isOverdue ? Colors.red : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isOverdue ? Icons.warning_rounded : Icons.schedule_rounded,
            color: color,
          ),
        ),
        title: Text(
          reminder.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (dueKm != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.speed, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dueAt,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text('${CurrencyFormatter.formatMileage(dueKm!)} ${l10n.km}'),
                      ],
                    ),
                  ),
                ],
              ),
            if (dueDate != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dueAt,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text('${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'),
                      ],
                    ),
                  ),
                ],
              ),
            if (isOverdue)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.overdue.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: dueKm != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${CurrencyFormatter.formatMileage((dueKm! - currentMileage).abs())} ${l10n.km}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}


class ReminderTemplate {
  final String nameEn;
  final String nameHu;
  final int? intervalKm;
  final int? intervalMonths;
  final List<String> suggestedItemIds;

  const ReminderTemplate({
    required this.nameEn,
    required this.nameHu,
    this.intervalKm,
    this.intervalMonths,
    this.suggestedItemIds = const [],
  });

  String getName(String languageCode) {
    switch (languageCode) {
      case 'hu':
        return nameHu;
      default:
        return nameEn;
    }
  }
}

// Predefined reminder templates
const List<ReminderTemplate> defaultReminderTemplates = [
  ReminderTemplate(
    nameEn: 'Oil Change',
    nameHu: 'Olajcsere',
    intervalKm: 10000,
    intervalMonths: 12,
    suggestedItemIds: ['default_1', 'default_2', 'default_25'], // Engine Oil + Oil Filter + Oil Drain Plug
  ),
  ReminderTemplate(
    nameEn: 'Brake Fluid',
    nameHu: 'Fékfolyadék csere',
    intervalKm: 60000,
    intervalMonths: 36,
    suggestedItemIds: ['default_8'], // Brake Fluid
  ),
  ReminderTemplate(
    nameEn: 'Transmission Fluid',
    nameHu: 'Sebességváltó folyadék csere',
    intervalKm: 100000,
    intervalMonths: 60,
    suggestedItemIds: ['default_17'], // Transmission Fluid
  ),
  ReminderTemplate(
    nameEn: 'Spark Plugs',
    nameHu: 'Gyújtógyertya csere',
    intervalKm: 100000,
    intervalMonths: null,
    suggestedItemIds: ['default_11'], // Spark Plug
  ),
  ReminderTemplate(
    nameEn: 'Air Filter',
    nameHu: 'Légszűrő csere',
    intervalKm: 30000,
    intervalMonths: 24,
    suggestedItemIds: ['default_3'], // Air Filter
  ),
  ReminderTemplate(
    nameEn: 'Cabin Filter',
    nameHu: 'Pollenszűrő csere',
    intervalKm: 20000,
    intervalMonths: 12,
    suggestedItemIds: ['default_4'], // Cabin Air Filter
  ),
  ReminderTemplate(
    nameEn: 'Brake Pads',
    nameHu: 'Fékbetét csere',
    intervalKm: 50000,
    intervalMonths: null,
    suggestedItemIds: ['default_6'], // Brake Pad
  ),
  ReminderTemplate(
    nameEn: 'Timing Belt',
    nameHu: 'Vezérlésszíj csere',
    intervalKm: 120000,
    intervalMonths: 72,
    suggestedItemIds: ['default_10'], // Timing Belt
  ),
  ReminderTemplate(
    nameEn: 'Coolant',
    nameHu: 'Hűtőfolyadék csere',
    intervalKm: 80000,
    intervalMonths: 48,
    suggestedItemIds: ['default_9'], // Coolant
  ),
  ReminderTemplate(
    nameEn: 'Battery Check',
    nameHu: 'Akkumulátor ellenőrzés',
    intervalKm: null,
    intervalMonths: 36,
    suggestedItemIds: ['default_12'], // Battery
  ),
  ReminderTemplate(
    nameEn: 'Tire Rotation',
    nameHu: 'Kerékcsere/forgatás',
    intervalKm: 15000,
    intervalMonths: 6,
    suggestedItemIds: ['default_13', 'default_22'], // Tire Rotation + Seasonal Tire Change
  ),
  ReminderTemplate(
    nameEn: 'Wheel Alignment',
    nameHu: 'Kerékbeállítás',
    intervalKm: 30000,
    intervalMonths: 24,
    suggestedItemIds: ['default_15'], // Wheel Alignment
  ),
  ReminderTemplate(
    nameEn: 'Driver\'s License Renewal',
    nameHu: 'Jogosítvány megújítás',
    intervalKm: null,
    intervalMonths: 120,
    suggestedItemIds: ['default_26'], // Driver's License Renewal (10 years)
  ),
  ReminderTemplate(
    nameEn: 'Technical Inspection',
    nameHu: 'Műszaki vizsga',
    intervalKm: null,
    intervalMonths: 24,
    suggestedItemIds: ['default_27'], // Technical Inspection
  ),
  ReminderTemplate(
    nameEn: 'Insurance Renewal',
    nameHu: 'Biztosítás megújítás',
    intervalKm: null,
    intervalMonths: 12,
    suggestedItemIds: ['default_28'], // Insurance Renewal
  ),
];


import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Non-breaking space character (U+00A0) to prevent line breaks within numbers
  static const String _nbsp = '\u00A0';

  /// Formats a price without cents and with thousand separators
  /// Examples:
  ///   25000.50 -> "25 000"
  ///   1500.99 -> "1 500"
  ///   500.00 -> "500"
  static String format(double price, String currency) {
    final formatter = NumberFormat('#,##0', 'en_US');
    final formatted = formatter.format(price.round());
    // Replace comma with non-breaking space for thousand separator
    return '${formatted.replaceAll(',', _nbsp)} $currency';
  }

  /// Formats without currency
  static String formatWithoutCurrency(double price) {
    final formatter = NumberFormat('#,##0', 'en_US');
    final formatted = formatter.format(price.round());
    return formatted.replaceAll(',', _nbsp);
  }

  /// Formats mileage with thousand separators
  /// Examples:
  ///   247007 -> "247 007"
  ///   1500 -> "1 500"
  ///   500 -> "500"
  static String formatMileage(int mileage) {
    final formatter = NumberFormat('#,##0', 'en_US');
    final formatted = formatter.format(mileage);
    return formatted.replaceAll(',', _nbsp);
  }
}


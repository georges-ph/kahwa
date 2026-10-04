import 'package:intl/intl.dart';

enum Currency {
  lbp,
  usd;

  String get code => name.toUpperCase();

  static Currency fromName(String? name) {
    return Currency.values.firstWhere(
      (currency) => currency.name == name,
      orElse: () => Currency.lbp,
    );
  }

  /// Formats [amount] the way it is shown to users, e.g. `5,000 L.L.` or `$5`.
  String format(num amount) {
    final number = NumberFormat.decimalPattern('en').format(amount);
    return switch (this) {
      Currency.lbp => '$number L.L.',
      Currency.usd => '\$$number',
    };
  }
}

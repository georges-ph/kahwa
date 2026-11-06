import 'package:intl/intl.dart';

/// The two currencies kahwa handles. Each balance, price and goal is kept in
/// one of them; they are never converted.
enum Currency {
  lbp,
  usd;

  String get code => name.toUpperCase();

  static Currency fromName(Object? name) {
    return Currency.values.firstWhere(
      (currency) => currency.name == name,
      orElse: () => Currency.lbp,
    );
  }

  /// The mark of the currency alone: `L.L.` or `$`.
  String sign({bool arabic = false}) {
    return switch (this) {
      Currency.lbp => arabic ? 'ل.ل.' : 'L.L.',
      Currency.usd => r'$',
    };
  }

  /// [amount] the way it is shown to users: `5,000 L.L.` or `$5`. Arabic
  /// keeps Western digits, as they are used on Lebanese prices.
  String format(num amount, {bool arabic = false}) {
    final number = NumberFormat.decimalPattern('en').format(amount);
    return switch (this) {
      Currency.lbp => arabic ? '$number ل.ل.' : '$number L.L.',
      Currency.usd => '\$$number',
    };
  }

  /// A short form for charts and tight spaces: `1.2M L.L.`, `$15K`.
  String compact(num amount, {bool arabic = false}) {
    final number = NumberFormat.compact(locale: 'en').format(amount);
    return switch (this) {
      Currency.lbp => arabic ? '$number ل.ل.' : '$number L.L.',
      Currency.usd => '\$$number',
    };
  }
}

/// An amount in each currency, such as a balance or a total received.
class Amounts {
  const Amounts({this.lbp = 0, this.usd = 0});

  final int lbp;
  final int usd;

  int of(Currency currency) => currency == Currency.lbp ? lbp : usd;

  bool get isZero => lbp == 0 && usd == 0;

  Amounts add(Currency currency, int amount) {
    return currency == Currency.lbp
        ? Amounts(lbp: lbp + amount, usd: usd)
        : Amounts(lbp: lbp, usd: usd + amount);
  }

  Amounts operator +(Amounts other) {
    return Amounts(lbp: lbp + other.lbp, usd: usd + other.usd);
  }
}

/// [amount] with its thousands marked, the way it is written in a field:
/// `100,000`.
String groupDigits(num amount) {
  return NumberFormat.decimalPattern('en').format(amount);
}

/// Parses a whole positive number typed by a user, null when invalid.
int? parseAmount(String text) {
  final cleaned = text.trim().replaceAll(RegExp(r'[,\s]'), '');
  final value = int.tryParse(cleaned);
  return value == null || value < 0 ? null : value;
}

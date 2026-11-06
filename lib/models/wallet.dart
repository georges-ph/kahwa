import 'package:kahwa/core/money.dart';

/// Money a user holds in kahwa, per currency. It only moves through a
/// kahwa bought or received, a top up or a withdrawal: the security rules
/// check each of them.
class Wallet {
  const Wallet({
    this.current = const Amounts(),
    this.spent = const Amounts(),
    this.received = const Amounts(),
    this.withdrawn = const Amounts(),
  });

  /// What can be spent or withdrawn now.
  final Amounts current;
  final Amounts spent;
  final Amounts received;
  final Amounts withdrawn;

  static Map<String, dynamic> emptyMap() {
    return {
      for (final kind in ['current', 'spent', 'received', 'withdrawn'])
        for (final currency in Currency.values) '${kind}_${currency.name}': 0,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    Amounts read(String kind) => Amounts(
      lbp: (map['${kind}_lbp'] as num?)?.toInt() ?? 0,
      usd: (map['${kind}_usd'] as num?)?.toInt() ?? 0,
    );
    return Wallet(
      current: read('current'),
      spent: read('spent'),
      received: read('received'),
      withdrawn: read('withdrawn'),
    );
  }
}

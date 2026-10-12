import 'package:kahwa/models/currency.dart';

class Balance {
  const Balance({
    this.currentLbp = 0,
    this.currentUsd = 0,
    this.spentLbp = 0,
    this.spentUsd = 0,
    this.receivedLbp = 0,
    this.receivedUsd = 0,
    this.withdrawnLbp = 0,
    this.withdrawnUsd = 0,
  });

  final int currentLbp;
  final int currentUsd;
  final int spentLbp;
  final int spentUsd;
  final int receivedLbp;
  final int receivedUsd;
  final int withdrawnLbp;
  final int withdrawnUsd;

  int current(Currency currency) {
    return currency == Currency.lbp ? currentLbp : currentUsd;
  }

  Map<String, dynamic> toMap() {
    return {
      'current_lbp': currentLbp,
      'current_usd': currentUsd,
      'spent_lbp': spentLbp,
      'spent_usd': spentUsd,
      'received_lbp': receivedLbp,
      'received_usd': receivedUsd,
      'withdrawn_lbp': withdrawnLbp,
      'withdrawn_usd': withdrawnUsd,
    };
  }

  factory Balance.fromMap(Map<String, dynamic> map) {
    int read(String key) => (map[key] as num?)?.toInt() ?? 0;
    return Balance(
      currentLbp: read('current_lbp'),
      currentUsd: read('current_usd'),
      spentLbp: read('spent_lbp'),
      spentUsd: read('spent_usd'),
      receivedLbp: read('received_lbp'),
      receivedUsd: read('received_usd'),
      withdrawnLbp: read('withdrawn_lbp'),
      withdrawnUsd: read('withdrawn_usd'),
    );
  }
}

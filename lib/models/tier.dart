import 'package:kahwa/core/money.dart';

/// A monthly membership a creator offers: a number of kahwas every 30 days,
/// for some perks.
class Tier {
  const Tier({
    required this.id,
    required this.name,
    required this.kahwas,
    this.perks = '',
  });

  /// At most this many tiers on a page.
  static const max = 3;

  final String id;
  final String name;

  /// Kahwas charged each month, at the creator's kahwa price.
  final int kahwas;
  final String perks;

  int monthly(int kahwaPrice) => kahwas * kahwaPrice;

  String monthlyText(
    int? kahwaPrice,
    Currency currency, {
    bool arabic = false,
  }) {
    return kahwaPrice == null
        ? ''
        : currency.format(monthly(kahwaPrice), arabic: arabic);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'kahwas': kahwas, 'perks': perks};
  }

  factory Tier.fromMap(Map<String, dynamic> map, {required String id}) {
    return Tier(
      id: id,
      name: map['name'] as String? ?? '',
      kahwas: (map['kahwas'] as num?)?.toInt() ?? 1,
      perks: map['perks'] as String? ?? '',
    );
  }
}

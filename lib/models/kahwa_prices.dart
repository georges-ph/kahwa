import 'package:kahwa/models/currency.dart';

class KahwaPrices {
  const KahwaPrices({this.lbp = 1000, this.usd = 1, this.thanksMessage});

  final int lbp;
  final int usd;
  final String? thanksMessage;

  int price(Currency currency) => currency == Currency.lbp ? lbp : usd;

  Map<String, dynamic> toMap() {
    return {'lbp': lbp, 'usd': usd, 'thanks_message': thanksMessage};
  }

  factory KahwaPrices.fromMap(Map<String, dynamic> map) {
    return KahwaPrices(
      lbp: (map['lbp'] as num?)?.toInt() ?? 1000,
      usd: (map['usd'] as num?)?.toInt() ?? 1,
      thanksMessage: map['thanks_message'],
    );
  }
}

// ignore_for_file: non_constant_identifier_names

import 'package:kahwa/enums/currency.dart';

class Donation {
  final int? kahwa_price;
  final int? kahwas;
  // enum
  final Currency? currency;
  final bool? pay_fee;
  final String? message;
  final bool? keep_private;
  final int? total;

  Donation({
    this.kahwa_price,
    this.kahwas,
    this.currency,
    this.pay_fee,
    this.message,
    this.keep_private,
    this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'kahwa_price': kahwa_price,
      'kahwas': kahwas,
      'currency': currency?.name,
      'pay_fee': pay_fee,
      'message': message,
      'keep_private': keep_private,
      'total': total,
    };
  }

  factory Donation.fromMap(Map<String, dynamic> map) {
    return Donation(
      kahwa_price: map['kahwa_price']?.toInt(),
      kahwas: map['kahwas']?.toInt(),
      currency: map['currency'] != null
          ? Currency?.values[map['currency'] ?? 0]
          : null,
      pay_fee: map['pay_fee'],
      message: map['message'],
      keep_private: map['keep_private'],
      total: map['total']?.toInt(),
    );
  }
}

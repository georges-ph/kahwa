// ignore_for_file: non_constant_identifier_names

import 'package:kahwa/enums/currency.dart';

class Donation {
  String? supported_id;
  String? creator_id;
  int? kahwa_price;
  int? kahwas;
  // enum
  Currency? currency;
  bool? pay_fee;
  String? message;
  bool? keep_private;
  num? total;

  Donation({
    this.supported_id,
    this.creator_id,
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
      'supported_id': supported_id,
      'creator_id': creator_id,
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
      supported_id: map['supported_id'],
      creator_id: map['creator_id'],
      kahwa_price: map['kahwa_price']?.toInt(),
      kahwas: map['kahwas']?.toInt(),
      currency: map['currency'] != null
          ? Currency.values[map['currency'] ?? 0]
          : null,
      pay_fee: map['pay_fee'],
      message: map['message'],
      keep_private: map['keep_private'],
      total: map['total'],
    );
  }
}

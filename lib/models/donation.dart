// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/enums/currency.dart';

class Donation {
  String? creator_id;
  int? kahwa_price;
  int? kahwas;
  // enum
  Currency? currency;
  bool? pay_fee;
  String? message;
  bool? keep_private;
  num? total;
  Timestamp? timestamp;
  String? supporter_id;

  Donation({
    this.creator_id,
    this.kahwa_price,
    this.kahwas,
    this.currency,
    this.pay_fee,
    this.message,
    this.keep_private,
    this.total,
    this.timestamp,
    this.supporter_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'creator_id': creator_id,
      'kahwa_price': kahwa_price,
      'kahwas': kahwas,
      'currency': currency?.name,
      'pay_fee': pay_fee,
      'message': message,
      'keep_private': keep_private,
      'total': total,
      'timestamp': FieldValue.serverTimestamp(),
      'supporter_id': supporter_id,
    };
  }

  factory Donation.fromMap(Map<String, dynamic> map) {
    Currency currency = Currency.values
        .firstWhere((element) => element.name == map['currency']);
    return Donation(
      creator_id: map['creator_id'],
      kahwa_price: map['kahwa_price']?.toInt(),
      kahwas: map['kahwas']?.toInt(),
      currency: map['currency'] != null ? currency : null,
      pay_fee: map['pay_fee'],
      message: map['message'],
      keep_private: map['keep_private'],
      total: map['total'],
      timestamp: map['timestamp'],
      supporter_id: map['supporter_id'],
    );
  }
}

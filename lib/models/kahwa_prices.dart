// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class KahwaPrices {
  int? lbp;
  int? usd;
  String? thanks_message;

  KahwaPrices({
    this.lbp,
    this.usd,
    this.thanks_message,
  });

  Map<String, dynamic> toMap() {
    return {
      'lbp': lbp,
      'usd': usd,
      'thanks_message': thanks_message,
    };
  }

  KahwaPrices.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options)
      : lbp = snapshot.data()?['lbp'],
        usd = snapshot.data()?['usd'],
        thanks_message = snapshot.data()?['thanks_message'];

  Map<String, dynamic> toFirestore() {
    return {
      'lbp': lbp,
      'usd': usd,
      'thanks_message': thanks_message,
    };
  }

  factory KahwaPrices.fromMap(Map<String, dynamic> map) {
    return KahwaPrices(
      lbp: map['lbp']?.toInt(),
      usd: map['usd']?.toInt(),
      thanks_message: map['thanks_message'],
    );
  }
}

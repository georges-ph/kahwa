// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Withdraw {
  int? lbp;
  int? usd;
  Timestamp? timestamp;
  String? user_id;

  Withdraw({
    this.lbp,
    this.usd,
    this.timestamp,
    this.user_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'lbp': lbp,
      'usd': usd,
      'timestamp': FieldValue.serverTimestamp(),
      'user_id': user_id,
    };
  }

  factory Withdraw.fromMap(Map<String, dynamic> map) {
    return Withdraw(
      lbp: map['lbp']?.toInt(),
      usd: map['usd']?.toInt(),
      timestamp: map['timestamp'],
      user_id: map['user_id'],
    );
  }
}

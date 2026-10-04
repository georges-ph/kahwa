import 'package:cloud_firestore/cloud_firestore.dart';

class Withdraw {
  const Withdraw({required this.userId, required this.lbp, required this.usd});

  final String userId;
  final int lbp;
  final int usd;

  Map<String, dynamic> toMap() {
    return {
      'lbp': lbp,
      'usd': usd,
      'timestamp': FieldValue.serverTimestamp(),
      'user_id': userId,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// A creator asking to be paid part of their balance. The balance only goes
/// down once an admin has sent the money and marked the request as paid.
class Withdraw {
  const Withdraw({
    this.id,
    required this.userId,
    required this.lbp,
    required this.usd,
    this.isPaid = false,
    this.timestamp,
  });

  /// Id of the document, null until the request is saved.
  final String? id;
  final String userId;
  final int lbp;
  final int usd;
  final bool isPaid;
  final DateTime? timestamp;

  static const pending = 'pending';
  static const paid = 'paid';

  Map<String, dynamic> toMap() {
    return {
      'lbp': lbp,
      'usd': usd,
      'status': pending,
      'timestamp': FieldValue.serverTimestamp(),
      'user_id': userId,
    };
  }

  factory Withdraw.fromMap(Map<String, dynamic> map, {String? id}) {
    return Withdraw(
      id: id,
      userId: map['user_id'] ?? '',
      lbp: (map['lbp'] as num?)?.toInt() ?? 0,
      usd: (map['usd'] as num?)?.toInt() ?? 0,
      isPaid: map['status'] == paid,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}

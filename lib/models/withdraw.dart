import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/models/currency.dart';

/// A creator asking to be paid part of their balance. The balance only goes
/// down once an admin has sent the money and marked the request as paid.
class Withdraw {
  const Withdraw({
    this.id,
    required this.userId,
    required this.lbp,
    required this.usd,
    this.status = pending,
    this.timestamp,
  });

  /// Id of the document, null until the request is saved.
  final String? id;
  final String userId;
  final int lbp;
  final int usd;

  /// [pending], [paid] or [refused].
  final String status;
  final DateTime? timestamp;

  static const pending = 'pending';
  static const paid = 'paid';
  static const refused = 'refused';

  bool get isPending => status == pending;
  bool get isPaid => status == paid;
  bool get isRefused => status == refused;

  /// What was asked for, such as "150,000 L.L. and 5 $".
  String get amountText => [
    if (lbp > 0) Currency.lbp.format(lbp),
    if (usd > 0) Currency.usd.format(usd),
  ].join(' and ');

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
      status: map['status'] ?? pending,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}

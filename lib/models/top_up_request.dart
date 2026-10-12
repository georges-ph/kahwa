import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/models/currency.dart';

enum TopUpStatus {
  /// The user says they sent the money, an admin has not checked yet.
  pending,

  /// An admin found the transfer and added the amount to the balance.
  approved,

  /// An admin could not find the transfer.
  rejected;

  static TopUpStatus fromName(String? name) {
    return TopUpStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => TopUpStatus.pending,
    );
  }
}

/// A user telling us they sent money to add to their balance.
///
/// It is only created after the user confirms they made the transfer, and
/// each user has at most one, so nobody can flood the admin with requests.
class TopUpRequest {
  const TopUpRequest({
    required this.userId,
    required this.amount,
    required this.currency,
    required this.reference,
    required this.senderPhone,
    this.status = TopUpStatus.pending,
    this.timestamp,
    this.resolvedAt,
  });

  /// How long the answer of an admin stays on the top up screen.
  static const resultShownFor = Duration(days: 3);

  final String userId;
  final int amount;
  final Currency currency;

  /// Random id of this request. The security rules use it so that an
  /// approval can only be applied to the balance once.
  final String reference;

  /// Number the user sent the money from.
  final String senderPhone;
  final TopUpStatus status;
  final DateTime? timestamp;

  /// When an admin approved or rejected it.
  final DateTime? resolvedAt;

  /// Whether an admin answered recently enough to still tell the user about
  /// it at [now]. The request itself stays, as the last top up of the user.
  bool hasRecentResult(DateTime now) {
    if (status == TopUpStatus.pending) return false;
    final answered = resolvedAt ?? timestamp;
    return answered == null || now.difference(answered) < resultShownFor;
  }

  /// A short random id, without characters that look alike.
  static String newReference([Random? random]) {
    const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final source = random ?? Random.secure();
    return List.generate(
      6,
      (_) => letters[source.nextInt(letters.length)],
    ).join();
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'amount': amount,
      'currency': currency.name,
      'reference': reference,
      'sender_phone': senderPhone,
      'status': TopUpStatus.pending.name,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory TopUpRequest.fromMap(Map<String, dynamic> map) {
    return TopUpRequest(
      userId: map['user_id'] ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      currency: Currency.fromName(map['currency']),
      reference: map['reference'] ?? '',
      senderPhone: map['sender_phone'] ?? '',
      status: TopUpStatus.fromName(map['status']),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      resolvedAt: (map['resolved_at'] as Timestamp?)?.toDate(),
    );
  }
}

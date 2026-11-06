import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/core/money.dart';

enum ActivityKind {
  /// Someone bought the user kahwas.
  kahwa,

  /// A member was charged for a month, or joined.
  membership,

  /// Someone became a fan of the user.
  fan,

  /// A creator answered the user's message.
  reply,

  /// An admin answered the user's top up.
  topUp,

  /// An admin answered the user's withdrawal.
  withdraw,

  /// An admin corrected the user's balance.
  adjustment,

  /// A supporter says they paid the user straight to their WHISH account.
  directPayment,

  /// The creator answered a payment the user sent them by WHISH.
  directAnswer;

  String get key => switch (this) {
    topUp => 'top_up',
    directPayment => 'direct_payment',
    directAnswer => 'direct_answer',
    _ => name,
  };

  static ActivityKind? fromKey(Object? key) {
    return ActivityKind.values.where((k) => k.key == key).firstOrNull;
  }
}

/// An entry in a user's inbox. It is written by whoever caused it, in the
/// same write, so kahwa needs no server; the security rules check it
/// matches what happened.
class Activity {
  const Activity({
    required this.id,
    required this.kind,
    this.actorId,
    this.actorName,
    this.kahwas,
    this.amount,
    this.currency,
    this.message = '',
    this.ref,
    this.ok = true,
    this.createdAt,
    this.read = false,
  });

  final String id;
  final ActivityKind kind;
  final String? actorId;
  final String? actorName;
  final int? kahwas;
  final int? amount;
  final Currency? currency;
  final String message;

  /// What the entry is about: a donation id for a reply, a creator id...
  final String? ref;

  /// For top ups and withdrawals: whether it went through.
  final bool ok;
  final DateTime? createdAt;
  final bool read;

  factory Activity.fromMap(Map<String, dynamic> map, {required String id}) {
    return Activity(
      id: id,
      kind: ActivityKind.fromKey(map['kind']) ?? ActivityKind.kahwa,
      actorId: map['actor_id'] as String?,
      actorName: map['actor_name'] as String?,
      kahwas: (map['kahwas'] as num?)?.toInt(),
      amount: (map['amount'] as num?)?.toInt(),
      currency: map['currency'] == null
          ? null
          : Currency.fromName(map['currency']),
      message: map['message'] as String? ?? '',
      ref: map['ref'] as String?,
      ok: map['ok'] != false,
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      read: map['read'] == true,
    );
  }

  /// The document for a new entry in [userId]'s inbox.
  static Map<String, dynamic> newMap({
    required String userId,
    required ActivityKind kind,
    String? actorId,
    String? actorName,
    int? kahwas,
    int? amount,
    Currency? currency,
    String message = '',
    String? ref,
    bool ok = true,
  }) {
    return {
      'user_id': userId,
      'kind': kind.key,
      'actor_id': actorId,
      'actor_name': actorName,
      'kahwas': kahwas,
      'amount': amount,
      'currency': currency?.name,
      'message': message,
      'ref': ref,
      'ok': ok,
      'created_at': FieldValue.serverTimestamp(),
      'read': false,
    };
  }
}

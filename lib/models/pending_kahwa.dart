import 'package:kahwa/models/currency.dart';

/// The kahwas a fan was buying when their balance ran short. It is kept
/// while they top up, so they can finish in one tap once the money is in.
class PendingKahwa {
  const PendingKahwa({
    required this.creatorId,
    required this.kahwas,
    required this.currency,
    this.message = '',
    this.keepPrivate = false,
  });

  final String creatorId;
  final int kahwas;
  final Currency currency;
  final String message;
  final bool keepPrivate;

  Map<String, dynamic> toMap() {
    return {
      'creator_id': creatorId,
      'kahwas': kahwas,
      'currency': currency.name,
      'message': message,
      'keep_private': keepPrivate,
    };
  }

  factory PendingKahwa.fromMap(Map<String, dynamic> map) {
    return PendingKahwa(
      creatorId: map['creator_id'] ?? '',
      kahwas: (map['kahwas'] as num?)?.toInt() ?? 1,
      currency: Currency.fromName(map['currency']),
      message: map['message'] ?? '',
      keepPrivate: map['keep_private'] ?? false,
    );
  }
}

/// How much is missing from [balance] to pay [total], or zero when it is
/// enough.
int missingAmount({required int total, required int balance}) {
  return total > balance ? total - balance : 0;
}

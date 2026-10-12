import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/models/currency.dart';

/// Kahwas bought for a creator.
///
/// Donation documents are public: anyone can see that a creator received
/// some kahwas. When [keepPrivate] is set, who bought them and their message
/// are kept out of that document and stored as separate details that only
/// the creator and the supporter can read.
class Donation {
  const Donation({
    this.id,
    required this.creatorId,
    required this.supporterId,
    required this.kahwaPrice,
    required this.kahwas,
    required this.currency,
    required this.total,
    this.payFee = false,
    this.message = '',
    this.keepPrivate = false,
    this.timestamp,
  });

  /// Id of the document, null until the donation is saved.
  final String? id;
  final String creatorId;

  /// Null on a private donation the current user is not part of.
  final String? supporterId;
  final int kahwaPrice;
  final int kahwas;
  final Currency currency;
  final num total;
  final bool payFee;
  final String message;
  final bool keepPrivate;
  final DateTime? timestamp;

  /// The part of the donation everyone can read.
  Map<String, dynamic> toMap() {
    return {
      'creator_id': creatorId,
      'kahwa_price': kahwaPrice,
      'kahwas': kahwas,
      'currency': currency.name,
      'pay_fee': payFee,
      'keep_private': keepPrivate,
      'total': total,
      'timestamp': FieldValue.serverTimestamp(),
      if (!keepPrivate) ...{'supporter_id': supporterId, 'message': message},
    };
  }

  /// The part of a private donation only its two sides can read.
  Map<String, dynamic> toDetailsMap() {
    return {
      'creator_id': creatorId,
      'supporter_id': supporterId,
      'message': message,
    };
  }

  factory Donation.fromMap(Map<String, dynamic> map, {String? id}) {
    return Donation(
      id: id,
      creatorId: map['creator_id'] ?? '',
      supporterId: map['supporter_id'],
      kahwaPrice: (map['kahwa_price'] as num?)?.toInt() ?? 0,
      kahwas: (map['kahwas'] as num?)?.toInt() ?? 0,
      currency: Currency.fromName(map['currency']),
      total: map['total'] ?? 0,
      payFee: map['pay_fee'] ?? false,
      message: map['message'] ?? '',
      keepPrivate: map['keep_private'] ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  /// This donation with the private [details] filled in.
  Donation withDetails(Map<String, dynamic> details) {
    return Donation(
      id: id,
      creatorId: creatorId,
      supporterId: details['supporter_id'],
      kahwaPrice: kahwaPrice,
      kahwas: kahwas,
      currency: currency,
      total: total,
      payFee: payFee,
      message: details['message'] ?? '',
      keepPrivate: keepPrivate,
      timestamp: timestamp,
    );
  }
}

/// A donation together with the supporter who made it. [supporter] is null
/// when the donation is private and the current user is not part of it.
class DonationSupporter {
  const DonationSupporter({required this.donation, this.supporter});

  final Donation donation;
  final AppUser? supporter;
}

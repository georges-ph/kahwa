import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/models/currency.dart';

class Donation {
  const Donation({
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

  final String creatorId;
  final String supporterId;
  final int kahwaPrice;
  final int kahwas;
  final Currency currency;
  final num total;
  final bool payFee;
  final String message;
  final bool keepPrivate;
  final DateTime? timestamp;

  /// Whether [userId] may see who made this donation and their message.
  bool isVisibleTo(String userId) {
    return !keepPrivate || userId == creatorId || userId == supporterId;
  }

  Map<String, dynamic> toMap() {
    return {
      'creator_id': creatorId,
      'kahwa_price': kahwaPrice,
      'kahwas': kahwas,
      'currency': currency.name,
      'pay_fee': payFee,
      'message': message,
      'keep_private': keepPrivate,
      'total': total,
      'timestamp': FieldValue.serverTimestamp(),
      'supporter_id': supporterId,
    };
  }

  factory Donation.fromMap(Map<String, dynamic> map) {
    return Donation(
      creatorId: map['creator_id'] ?? '',
      supporterId: map['supporter_id'] ?? '',
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
}

/// A donation together with the supporter who made it. [supporter] is null
/// when the donation is private and hidden from the current user.
class DonationSupporter {
  const DonationSupporter({required this.donation, this.supporter});

  final Donation donation;
  final AppUser? supporter;
}

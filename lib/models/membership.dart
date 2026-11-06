import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/core/money.dart';

enum MembershipStatus { active, cancelled }

/// A supporter's monthly membership to a creator, charged from their
/// balance. kahwa has no server, so a charge happens when the supporter
/// opens the app after the month is over; the security rules check the
/// dates.
class Membership {
  const Membership({
    required this.creatorId,
    required this.supporterId,
    required this.tierId,
    required this.tierName,
    required this.kahwas,
    required this.currency,
    required this.total,
    this.status = MembershipStatus.active,
    this.keepPrivate = false,
    this.startedAt,
    this.lastChargedAt,
  });

  /// How long one payment lasts.
  static const period = Duration(days: 30);

  /// Extra time a lapsed membership keeps its perks while waiting for the
  /// supporter to come back.
  static const grace = Duration(days: 1);

  static String idOf(String creatorId, String supporterId) {
    return '${creatorId}_$supporterId';
  }

  String get id => idOf(creatorId, supporterId);

  final String creatorId;
  final String supporterId;
  final String tierId;
  final String tierName;
  final int kahwas;
  final Currency currency;

  /// What one month costs.
  final int total;
  final MembershipStatus status;
  final bool keepPrivate;
  final DateTime? startedAt;
  final DateTime? lastChargedAt;

  bool get isActive => status == MembershipStatus.active;

  DateTime? get nextCharge => lastChargedAt?.add(period);

  /// Whether a new month should be charged.
  bool isDue(DateTime now) {
    final next = nextCharge;
    return isActive && next != null && !now.isBefore(next);
  }

  /// Whether this cancelled membership can be taken back for free: the
  /// month it paid for is not over yet.
  bool canResume(DateTime now) {
    final next = nextCharge;
    return !isActive && next != null && now.isBefore(next);
  }

  /// Whether the last payment still covers [now], so the perks apply. A
  /// cancelled membership keeps them until the month it paid for is over.
  bool isPaidAt(DateTime now) {
    final next = nextCharge;
    return next != null && now.isBefore(next.add(grace));
  }

  factory Membership.fromMap(Map<String, dynamic> map) {
    return Membership(
      creatorId: map['creator_id'] as String? ?? '',
      supporterId: map['supporter_id'] as String? ?? '',
      tierId: map['tier'] as String? ?? '',
      tierName: map['tier_name'] as String? ?? '',
      kahwas: (map['kahwas'] as num?)?.toInt() ?? 1,
      currency: Currency.fromName(map['currency']),
      total: (map['total'] as num?)?.toInt() ?? 0,
      status: map['status'] == 'cancelled'
          ? MembershipStatus.cancelled
          : MembershipStatus.active,
      keepPrivate: map['keep_private'] == true,
      startedAt: (map['started_at'] as Timestamp?)?.toDate(),
      lastChargedAt: (map['last_charged_at'] as Timestamp?)?.toDate(),
    );
  }
}

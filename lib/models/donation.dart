import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/core/money.dart';

enum DonationKind {
  /// Kahwas bought once.
  kahwa,

  /// A monthly charge of a membership.
  membership,

  /// Kahwas paid straight to the creator's WHISH account, confirmed by them.
  direct,
}

/// Kahwas a supporter bought a creator.
///
/// The document is public, so pages can show it to visitors. A private one
/// says nothing about who bought it: that, the message and the creator's
/// reply are in a `DonationDetails` document only the two of them can read.
class Donation {
  const Donation({
    required this.creatorId,
    required this.kahwas,
    required this.kahwaPrice,
    required this.currency,
    this.id = '',
    this.supporterId,
    this.message = '',
    this.keepPrivate = false,
    this.kind = DonationKind.kahwa,
    this.tierId,
    this.tierName,
    this.timestamp,
    this.reply = '',
    this.replyAt,
  });

  final String id;
  final String creatorId;

  /// Null on a private donation, unless the viewer may know who it was.
  final String? supporterId;
  final int kahwas;
  final int kahwaPrice;
  final Currency currency;
  final String message;
  final bool keepPrivate;
  final DonationKind kind;
  final String? tierId;
  final String? tierName;
  final DateTime? timestamp;

  /// The creator's answer to the message.
  final String reply;
  final DateTime? replyAt;

  int get total => kahwas * kahwaPrice;

  bool get hasMessage => message.trim().isNotEmpty;

  bool get hasReply => reply.trim().isNotEmpty;

  /// The public document. A private donation leaves out who made it and the
  /// message.
  Map<String, dynamic> toMap() {
    return {
      'creator_id': creatorId,
      if (!keepPrivate) 'supporter_id': supporterId,
      if (!keepPrivate) 'message': message,
      'keep_private': keepPrivate,
      'currency': currency.name,
      'kahwas': kahwas,
      'kahwa_price': kahwaPrice,
      'total': total,
      'kind': kind.name,
      if (kind == DonationKind.membership) 'tier': tierId,
      if (kind == DonationKind.membership) 'tier_name': tierName,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toDetailsMap() {
    return {
      'creator_id': creatorId,
      'supporter_id': supporterId,
      'message': message,
    };
  }

  /// This donation with what its details document says.
  Donation withDetails(Map<String, dynamic> details) {
    return _copy(
      supporterId: details['supporter_id'] as String?,
      message: details['message'] as String? ?? '',
      reply: details['reply'] as String? ?? '',
      replyAt: (details['reply_at'] as Timestamp?)?.toDate(),
    );
  }

  Donation withoutMessage() => _copy(message: '');

  Donation withReply(String reply) {
    return _copy(reply: reply, replyAt: DateTime.now());
  }

  Donation _copy({
    String? supporterId,
    String? message,
    String? reply,
    DateTime? replyAt,
  }) {
    return Donation(
      id: id,
      creatorId: creatorId,
      supporterId: supporterId ?? this.supporterId,
      kahwas: kahwas,
      kahwaPrice: kahwaPrice,
      currency: currency,
      message: message ?? this.message,
      keepPrivate: keepPrivate,
      kind: kind,
      tierId: tierId,
      tierName: tierName,
      timestamp: timestamp,
      reply: reply ?? this.reply,
      replyAt: replyAt ?? this.replyAt,
    );
  }

  factory Donation.fromMap(Map<String, dynamic> map, {required String id}) {
    return Donation(
      id: id,
      creatorId: map['creator_id'] as String? ?? '',
      supporterId: map['supporter_id'] as String?,
      kahwas: (map['kahwas'] as num?)?.toInt() ?? 1,
      kahwaPrice: (map['kahwa_price'] as num?)?.toInt() ?? 0,
      currency: Currency.fromName(map['currency']),
      message: map['message'] as String? ?? '',
      keepPrivate: map['keep_private'] == true,
      kind:
          DonationKind.values.where((k) => k.name == map['kind']).firstOrNull ??
          DonationKind.kahwa,
      tierId: map['tier'] as String?,
      tierName: map['tier_name'] as String?,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      reply: map['reply'] as String? ?? '',
      replyAt: (map['reply_at'] as Timestamp?)?.toDate(),
    );
  }
}

/// Who supported a creator and how much, for the supporters list and stats.
class SupporterSummary {
  const SupporterSummary({
    required this.supporterId,
    required this.kahwas,
    required this.count,
    required this.last,
  });

  final String supporterId;
  final int kahwas;

  /// How many times they bought.
  final int count;
  final DateTime? last;

  /// Supporters of [donations], most kahwas first. Private donations whose
  /// supporter the viewer cannot know are left out.
  static List<SupporterSummary> of(Iterable<Donation> donations) {
    final byId = <String, SupporterSummary>{};
    for (final d in donations) {
      final id = d.supporterId;
      if (id == null) continue;
      final before = byId[id];
      final last = before?.last;
      byId[id] = SupporterSummary(
        supporterId: id,
        kahwas: (before?.kahwas ?? 0) + d.kahwas,
        count: (before?.count ?? 0) + 1,
        last: last == null || (d.timestamp?.isAfter(last) ?? false)
            ? d.timestamp ?? last
            : last,
      );
    }
    return byId.values.toList()..sort((a, b) => b.kahwas.compareTo(a.kahwas));
  }
}

/// Counters shown at the top of a creator page.
class PageCounts {
  const PageCounts({required this.kahwas, required this.supporters});

  final int kahwas;

  /// Different people who bought kahwas. Each private donation counts as
  /// one, since who made it is not known.
  final int supporters;

  factory PageCounts.of(Iterable<Donation> donations) {
    var kahwas = 0;
    var anonymous = 0;
    final known = <String>{};
    for (final d in donations) {
      kahwas += d.kahwas;
      if (d.supporterId case final id?) {
        known.add(id);
      } else {
        anonymous++;
      }
    }
    return PageCounts(kahwas: kahwas, supporters: known.length + anonymous);
  }
}

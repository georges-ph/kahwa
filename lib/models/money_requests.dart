import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/core/money.dart';

/// Where users send money to top up, set by an admin in the `Config/top_up`
/// document.
class TopUpDestination {
  const TopUpDestination({this.whishQr = const {}});

  /// The text inside the admin's "Whish Me" QR codes, links such as
  /// `https://whish.money/pay/abc123`. WHISH gives one code per currency and
  /// only pays it from a balance in that currency. The sender sees the
  /// admin's name in the WHISH app, never a phone number.
  final Map<Currency, String> whishQr;

  /// False when top ups have not been set up.
  bool get isSet => whishQr.isNotEmpty;

  /// The currencies top ups can be made in: those that have a code.
  List<Currency> get currencies => [
    for (final currency in Currency.values)
      if (whishQr.containsKey(currency)) currency,
  ];

  /// Opens the payment in [currency] in the WHISH app. See [whishAppLink].
  Uri? appLink(Currency currency) => whishAppLink(whishQr[currency]);

  factory TopUpDestination.fromMap(Map<String, dynamic> map) {
    return TopUpDestination(
      whishQr: {
        for (final currency in Currency.values)
          if (map['whish_qr_${currency.name}'] case final String qr
              when qr.trim().isNotEmpty)
            currency: qr.trim(),
      },
    );
  }
}

enum RequestStatus {
  pending,
  approved,
  rejected,

  /// A withdrawal the admin sent.
  paid,

  /// A withdrawal the admin turned down.
  refused;

  static RequestStatus fromName(Object? name) {
    return RequestStatus.values.firstWhere(
      (s) => s.name == name,
      orElse: () => RequestStatus.pending,
    );
  }

  bool get isOk => this == approved || this == paid;
}

/// A user's request to add money they sent with WHISH to their balance. One
/// per user, named after them, replaced by the next one.
class TopUpRequest {
  const TopUpRequest({
    required this.userId,
    required this.amount,
    required this.currency,
    required this.reference,
    required this.senderPhone,
    this.status = RequestStatus.pending,
    this.timestamp,
    this.resolvedAt,
  });

  /// How long the answer of the last request stays on the wallet.
  static const resultShownFor = Duration(days: 3);

  final String userId;
  final int amount;
  final Currency currency;

  /// Internal id the security rules use to apply the request only once.
  final String reference;
  final String senderPhone;
  final RequestStatus status;
  final DateTime? timestamp;
  final DateTime? resolvedAt;

  bool get isPending => status == RequestStatus.pending;

  bool hasRecentResult(DateTime now) {
    final at = resolvedAt;
    return !isPending && at != null && now.difference(at) < resultShownFor;
  }

  static String newReference([Random? random]) {
    const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = random ?? Random.secure();
    return List.generate(8, (_) => letters[r.nextInt(letters.length)]).join();
  }

  Map<String, dynamic> toNewMap() {
    return {
      'user_id': userId,
      'amount': amount,
      'currency': currency.name,
      'reference': reference,
      'sender_phone': senderPhone,
      'status': RequestStatus.pending.name,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory TopUpRequest.fromMap(Map<String, dynamic> map) {
    return TopUpRequest(
      userId: map['user_id'] as String? ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      currency: Currency.fromName(map['currency']),
      reference: map['reference'] as String? ?? '',
      senderPhone: map['sender_phone'] as String? ?? '',
      status: RequestStatus.fromName(map['status']),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      resolvedAt: (map['resolved_at'] as Timestamp?)?.toDate(),
    );
  }
}

/// A user's request to get money out of their balance. One waits at a time.
class WithdrawRequest {
  const WithdrawRequest({
    required this.id,
    required this.userId,
    required this.amounts,
    this.status = RequestStatus.pending,
    this.timestamp,
    this.resolvedAt,
  });

  final String id;
  final String userId;
  final Amounts amounts;
  final RequestStatus status;
  final DateTime? timestamp;
  final DateTime? resolvedAt;

  bool get isPending => status == RequestStatus.pending;

  static Map<String, dynamic> newMap(String userId, Amounts amounts) {
    return {
      'user_id': userId,
      'lbp': amounts.lbp,
      'usd': amounts.usd,
      'status': RequestStatus.pending.name,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory WithdrawRequest.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return WithdrawRequest(
      id: id,
      userId: map['user_id'] as String? ?? '',
      amounts: Amounts(
        lbp: (map['lbp'] as num?)?.toInt() ?? 0,
        usd: (map['usd'] as num?)?.toInt() ?? 0,
      ),
      status: RequestStatus.fromName(map['status']),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      resolvedAt: (map['resolved_at'] as Timestamp?)?.toDate(),
    );
  }
}

/// An answered top up, kept for the history.
class TopUpRecord {
  const TopUpRecord({
    required this.amount,
    required this.currency,
    required this.status,
    this.resolvedAt,
  });

  final int amount;
  final Currency currency;
  final RequestStatus status;
  final DateTime? resolvedAt;

  factory TopUpRecord.fromMap(Map<String, dynamic> map) {
    return TopUpRecord(
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      currency: Currency.fromName(map['currency']),
      status: RequestStatus.fromName(map['status']),
      resolvedAt: (map['resolved_at'] as Timestamp?)?.toDate(),
    );
  }
}

/// Where withdrawals are paid to. Private to the user and admins.
class BillingDetails {
  const BillingDetails({this.fullName = '', this.whishPhone = ''});

  final String fullName;

  /// The WHISH number withdrawals are sent to.
  final String whishPhone;

  bool get isComplete =>
      fullName.trim().isNotEmpty && whishPhone.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return {'full_name': fullName.trim(), 'whish_phone': whishPhone.trim()};
  }

  factory BillingDetails.fromMap(Map<String, dynamic> map) {
    return BillingDetails(
      fullName: map['full_name'] as String? ?? '',
      whishPhone: map['whish_phone'] as String? ?? '',
    );
  }
}

/// The kahwa a user was buying when their balance ran short, kept while
/// they top up so they can finish it in one tap.
class PendingKahwa {
  const PendingKahwa({
    required this.creatorId,
    required this.kahwas,
    required this.currency,
    this.message = '',
    this.keepPrivate = false,
    this.tierId,
  });

  final String creatorId;
  final int kahwas;
  final Currency currency;
  final String message;
  final bool keepPrivate;

  /// Set when it was a membership being joined.
  final String? tierId;

  Map<String, dynamic> toMap() {
    return {
      'creator_id': creatorId,
      'kahwas': kahwas,
      'currency': currency.name,
      'message': message,
      'keep_private': keepPrivate,
      'tier': tierId,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory PendingKahwa.fromMap(Map<String, dynamic> map) {
    return PendingKahwa(
      creatorId: map['creator_id'] as String? ?? '',
      kahwas: (map['kahwas'] as num?)?.toInt() ?? 1,
      currency: Currency.fromName(map['currency']),
      message: map['message'] as String? ?? '',
      keepPrivate: map['keep_private'] == true,
      tierId: map['tier'] as String?,
    );
  }
}

/// A correction an admin made to a user's balance, with the reason. Kept
/// for good: the user sees it in their history and every admin in the log.
class Adjustment {
  const Adjustment({
    required this.id,
    required this.userId,
    required this.currency,
    required this.amount,
    required this.reason,
    required this.adminId,
    this.createdAt,
  });

  final String id;
  final String userId;
  final Currency currency;

  /// Added to the balance: negative to take money out.
  final int amount;
  final String reason;
  final String adminId;
  final DateTime? createdAt;

  factory Adjustment.fromMap(Map<String, dynamic> map, {required String id}) {
    return Adjustment(
      id: id,
      userId: map['user_id'] as String? ?? '',
      currency: Currency.fromName(map['currency']),
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      reason: map['reason'] as String? ?? '',
      adminId: map['admin_id'] as String? ?? '',
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
    );
  }
}

/// A creator's choice to be paid straight to their own WHISH account.
///
/// Like top ups to the founder, it uses the creator's "Whish Me" links, one
/// per currency: supporters open the payment in the WHISH app and see the
/// creator's name there, never their phone number.
class DirectPay {
  const DirectPay({this.enabled = false, this.whishLinks = const {}});

  final bool enabled;

  /// The creator's WHISH pay links, such as `https://whish.money/pay/abc123`.
  /// Only links [isWhishPayLink] accepts are kept.
  final Map<Currency, String> whishLinks;

  bool get isOn => enabled && whishLinks.isNotEmpty;

  /// The currencies supporters can pay this way: those that have a link.
  List<Currency> get currencies => [
    for (final currency in Currency.values)
      if (whishLinks.containsKey(currency)) currency,
  ];

  /// Opens the payment in [currency] in the WHISH app. See [whishAppLink].
  Uri? appLink(Currency currency) => whishAppLink(whishLinks[currency]);

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      for (final currency in Currency.values)
        'whish_link_${currency.name}': whishPayLink(whishLinks[currency]) ?? '',
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory DirectPay.fromMap(Map<String, dynamic> map) {
    return DirectPay(
      enabled: map['enabled'] == true,
      whishLinks: {
        for (final currency in Currency.values)
          if (map['whish_link_${currency.name}'] case final String link
              when isWhishPayLink(link))
            currency: link.trim(),
      },
    );
  }
}

/// Whether [text] is a WHISH pay link, the text inside a "Whish Me" QR code,
/// such as `https://whish.money/pay/abc123`.
bool isWhishPayLink(String? text) => whishAppLink(text) != null;

/// Address that opens the WHISH pay link [text] in the WHISH app on a phone
/// that has it installed, so nobody has to scan a code shown on their own
/// screen.
///
/// WHISH registers `whish.money/app/pay/...` as the form of the link that
/// its app opens, on Android and on iPhone. The app has to be up to date:
/// an older one leaves the link on a web page with nothing to pay on.
/// Null when [text] is not a WHISH pay link.
Uri? whishAppLink(String? text) {
  final trimmed = text?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  var uri = Uri.tryParse(trimmed);
  if (uri == null) return null;
  // A link copied without its "https://".
  if (!uri.hasScheme) uri = Uri.tryParse('https://$trimmed');
  if (uri == null) return null;
  if (uri.host != 'whish.money' && uri.host != 'www.whish.money') return null;
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  // The app form, `/app/pay/...`, is accepted too.
  if (segments.isNotEmpty && segments.first == 'app') segments.removeAt(0);
  if (segments.length != 2 || segments.first != 'pay') return null;
  return Uri.https('whish.money', '/app/pay/${segments.last}');
}

enum DirectPaymentStatus {
  /// Sent, as the supporter says, and waiting for the creator.
  pending,

  /// The creator found it: it counts as kahwas on their page.
  confirmed,

  /// The creator did not find it.
  rejected;

  static DirectPaymentStatus fromName(Object? name) {
    return values.firstWhere(
      (s) => s.name == name,
      orElse: () => DirectPaymentStatus.pending,
    );
  }
}

/// Kahwas a supporter paid straight to the creator's WHISH account. kahwa
/// cannot see that money: the creator confirms it arrived, and only then do
/// the kahwas count. Its id is also the id of the donation it becomes.
class DirectPayment {
  const DirectPayment({
    required this.id,
    required this.creatorId,
    required this.supporterId,
    required this.kahwas,
    required this.kahwaPrice,
    required this.currency,
    required this.senderPhone,
    this.message = '',
    this.keepPrivate = false,
    this.status = DirectPaymentStatus.pending,
    this.createdAt,
    this.resolvedAt,
  });

  final String id;
  final String creatorId;
  final String supporterId;
  final int kahwas;
  final int kahwaPrice;
  final Currency currency;
  final String senderPhone;
  final String message;
  final bool keepPrivate;
  final DirectPaymentStatus status;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  int get total => kahwas * kahwaPrice;

  bool get isPending => status == DirectPaymentStatus.pending;

  Map<String, dynamic> toNewMap() {
    return {
      'creator_id': creatorId,
      'supporter_id': supporterId,
      'kahwas': kahwas,
      'kahwa_price': kahwaPrice,
      'total': total,
      'currency': currency.name,
      'sender_phone': senderPhone.trim(),
      'message': message.trim(),
      'keep_private': keepPrivate,
      'status': DirectPaymentStatus.pending.name,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory DirectPayment.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return DirectPayment(
      id: id,
      creatorId: map['creator_id'] as String? ?? '',
      supporterId: map['supporter_id'] as String? ?? '',
      kahwas: (map['kahwas'] as num?)?.toInt() ?? 1,
      kahwaPrice: (map['kahwa_price'] as num?)?.toInt() ?? 0,
      currency: Currency.fromName(map['currency']),
      senderPhone: map['sender_phone'] as String? ?? '',
      message: map['message'] as String? ?? '',
      keepPrivate: map['keep_private'] == true,
      status: DirectPaymentStatus.fromName(map['status']),
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      resolvedAt: (map['resolved_at'] as Timestamp?)?.toDate(),
    );
  }
}

/// The WHISH pay link [text] in the one form kahwa keeps,
/// `https://whish.money/pay/<code>`, or null when it is not one.
String? whishPayLink(String? text) {
  final app = whishAppLink(text);
  return app == null
      ? null
      : 'https://whish.money/pay/${app.pathSegments.last}';
}

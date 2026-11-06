import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/data/db.dart';
import 'package:kahwa/models/activity.dart';
import 'package:kahwa/models/membership.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/models/wallet.dart';

/// What an admin sees first: money held for users.
class AdminOverview {
  const AdminOverview({
    required this.held,
    required this.users,
    required this.creators,
  });

  /// The sum of every balance: money in the founder's WHISH account that
  /// belongs to users. That account must never go below it.
  final Amounts held;
  final int users;
  final int creators;
}

/// One user's money, as an admin looks into it.
class UserFile {
  const UserFile({
    required this.wallet,
    required this.billing,
    required this.topUp,
    required this.memberships,
    required this.members,
  });

  final Wallet wallet;
  final BillingDetails billing;

  /// Their last top up request, waiting or answered.
  final TopUpRequest? topUp;

  /// Memberships they pay for.
  final List<Membership> memberships;

  /// Memberships others pay them, for a creator.
  final List<Membership> members;
}

/// An answered top up, with whose it was.
typedef TopUpAnswer = ({String userId, TopUpRecord record});

/// Answers and corrections made lately, for the admin log.
class AdminLog {
  const AdminLog({
    required this.topUps,
    required this.withdrawals,
    required this.adjustments,
  });

  final List<TopUpAnswer> topUps;
  final List<WithdrawRequest> withdrawals;
  final List<Adjustment> adjustments;
}

/// Admins are users with a document in `Admins`, which can only be created
/// from the Firebase console.
class AdminRepository {
  AdminRepository(this._db);

  final Db _db;

  FirebaseFirestore get _firestore => _db.firestore;

  Future<bool> isAdmin(String userId) async {
    try {
      return (await _db.admins.doc(userId).get()).exists;
    } on FirebaseException {
      return false;
    }
  }

  Future<AdminOverview> overview() async {
    final (wallets, creators, users) = await (
      _db.wallets.get(),
      _db.profiles.where('is_creator', isEqualTo: true).count().get(),
      _db.profiles.count().get(),
    ).wait;
    var held = const Amounts();
    for (final doc in wallets.docs) {
      held += Wallet.fromMap(doc.data()).current;
    }
    return AdminOverview(
      held: held,
      users: users.count ?? 0,
      creators: creators.count ?? 0,
    );
  }

  Future<List<TopUpRequest>> pendingTopUps() async {
    final snapshot = await _db.topUpRequests
        .where('status', isEqualTo: RequestStatus.pending.name)
        .get();
    final far = DateTime(0);
    return [for (final doc in snapshot.docs) TopUpRequest.fromMap(doc.data())]
      ..sort((a, b) => (b.timestamp ?? far).compareTo(a.timestamp ?? far));
  }

  Future<List<WithdrawRequest>> pendingWithdrawals() async {
    final snapshot = await _db.withdrawRequests
        .where('status', isEqualTo: RequestStatus.pending.name)
        .get();
    final far = DateTime(0);
    return [
      for (final doc in snapshot.docs)
        WithdrawRequest.fromMap(doc.data(), id: doc.id),
    ]..sort((a, b) => (b.timestamp ?? far).compareTo(a.timestamp ?? far));
  }

  /// Every profile, newest first, for looking a user up. kahwa is small
  /// enough to search them on the device.
  Future<List<Profile>> users() async {
    final snapshot = await _db.profiles.get();
    final far = DateTime(0);
    return [
      for (final doc in snapshot.docs) Profile.fromMap(doc.data(), id: doc.id),
    ]..sort((a, b) => (b.createdAt ?? far).compareTo(a.createdAt ?? far));
  }

  /// What an admin needs to look into one user's money.
  Future<UserFile> userFile(String userId) async {
    final (wallet, billing, topUp, memberships, members) = await (
      _db.wallets.doc(userId).get(),
      billingOf(userId),
      _db.topUpRequests.doc(userId).get(),
      _db.memberships.where('supporter_id', isEqualTo: userId).get(),
      _db.memberships.where('creator_id', isEqualTo: userId).get(),
    ).wait;
    final topUpData = topUp.data();
    return UserFile(
      wallet: Wallet.fromMap(wallet.data() ?? const {}),
      billing: billing,
      topUp: topUpData == null ? null : TopUpRequest.fromMap(topUpData),
      memberships: [
        for (final doc in memberships.docs) Membership.fromMap(doc.data()),
      ],
      members: [for (final doc in members.docs) Membership.fromMap(doc.data())],
    );
  }

  /// Corrects [userId]'s balance in [currency] by [amount] (negative takes
  /// money out), for [reason]. The correction is kept in Adjustments, the
  /// user's history and their inbox, and can never be edited or deleted.
  Future<void> adjust({
    required String userId,
    required String adminId,
    required Currency currency,
    required int amount,
    required String reason,
  }) {
    final ref = _db.adjustments.doc();
    final batch = _firestore.batch()
      ..set(ref, {
        'user_id': userId,
        'admin_id': adminId,
        'currency': currency.name,
        'amount': amount,
        'reason': reason.trim(),
        'created_at': FieldValue.serverTimestamp(),
      })
      ..update(_db.wallets.doc(userId), {
        'current_${currency.name}': FieldValue.increment(amount),
        'last_adjustment': ref.id,
      })
      ..set(
        _db.activity.doc(),
        Activity.newMap(
          userId: userId,
          kind: ActivityKind.adjustment,
          amount: amount,
          currency: currency,
          message: reason.trim(),
        ),
      );
    return batch.commit();
  }

  /// The latest answers and corrections, by every admin.
  Future<AdminLog> log({int limit = 50}) async {
    final (topUps, withdrawals, adjustments) = await (
      _db.topUpHistory
          .orderBy('resolved_at', descending: true)
          .limit(limit)
          .get(),
      _db.withdrawRequests
          .where(
            'status',
            whereIn: [RequestStatus.paid.name, RequestStatus.refused.name],
          )
          .get(),
      _db.adjustments
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get(),
    ).wait;
    final far = DateTime(0);
    return AdminLog(
      topUps: [
        for (final doc in topUps.docs)
          (
            userId: doc.data()['user_id'] as String? ?? '',
            record: TopUpRecord.fromMap(doc.data()),
          ),
      ],
      withdrawals: [
        for (final doc in withdrawals.docs)
          WithdrawRequest.fromMap(doc.data(), id: doc.id),
      ]..sort((a, b) => (b.resolvedAt ?? far).compareTo(a.resolvedAt ?? far)),
      adjustments: [
        for (final doc in adjustments.docs)
          Adjustment.fromMap(doc.data(), id: doc.id),
      ],
    );
  }

  /// Answers a top up: on [received], adds its amount to the user's balance
  /// in the same write. Either way the user finds the answer in their
  /// history and inbox, and the log keeps which admin answered.
  Future<void> answerTopUp(
    TopUpRequest request, {
    required bool received,
    required String adminId,
  }) {
    final status = received ? RequestStatus.approved : RequestStatus.rejected;
    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch()
      ..update(_db.topUpRequests.doc(request.userId), {
        'status': status.name,
        'resolved_at': now,
      })
      ..set(_db.topUpHistory.doc(), {
        'user_id': request.userId,
        'amount': request.amount,
        'currency': request.currency.name,
        'status': status.name,
        'sender_phone': request.senderPhone,
        'resolved_at': now,
        'resolved_by': adminId,
      })
      ..set(
        _db.activity.doc(),
        Activity.newMap(
          userId: request.userId,
          kind: ActivityKind.topUp,
          amount: request.amount,
          currency: request.currency,
          ok: received,
        ),
      );
    if (received) {
      batch.update(_db.wallets.doc(request.userId), {
        'current_${request.currency.name}': FieldValue.increment(
          request.amount,
        ),
        'last_top_up': request.reference,
      });
    }
    return batch.commit();
  }

  /// Answers a withdrawal: on [paid], takes it out of the user's balance in
  /// the same write.
  Future<void> answerWithdraw(
    WithdrawRequest request, {
    required bool paid,
    required String adminId,
  }) {
    final status = paid ? RequestStatus.paid : RequestStatus.refused;
    final amounts = request.amounts;
    final batch = _firestore.batch()
      ..update(_db.withdrawRequests.doc(request.id), {
        'status': status.name,
        'resolved_at': FieldValue.serverTimestamp(),
        'resolved_by': adminId,
      });
    for (final currency in Currency.values) {
      if (amounts.of(currency) == 0) continue;
      batch.set(
        _db.activity.doc(),
        Activity.newMap(
          userId: request.userId,
          kind: ActivityKind.withdraw,
          amount: amounts.of(currency),
          currency: currency,
          ok: paid,
        ),
      );
    }
    if (paid) {
      batch.update(_db.wallets.doc(request.userId), {
        'current_lbp': FieldValue.increment(-amounts.lbp),
        'current_usd': FieldValue.increment(-amounts.usd),
        'withdrawn_lbp': FieldValue.increment(amounts.lbp),
        'withdrawn_usd': FieldValue.increment(amounts.usd),
        'last_withdraw': request.id,
      });
    }
    return batch.commit();
  }

  Future<BillingDetails> billingOf(String userId) async {
    final data = (await _db.billing.doc(userId).get()).data();
    return data == null ? const BillingDetails() : BillingDetails.fromMap(data);
  }
}

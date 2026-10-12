import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/core/refresh.dart';
import 'package:kahwa/data/collections.dart';
import 'package:kahwa/data/user_repository.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/billing_details.dart';
import 'package:kahwa/models/top_up_request.dart';
import 'package:kahwa/models/withdraw.dart';

/// What an admin needs to keep the money straight.
class AdminOverview {
  const AdminOverview({
    required this.heldLbp,
    required this.heldUsd,
    required this.topUps,
    required this.withdrawals,
    required this.users,
    required this.billingDetails,
  });

  /// Total of every user's current balance: money that belongs to users and
  /// has to stay available.
  final int heldLbp;
  final int heldUsd;

  /// Requests waiting for a decision, newest first.
  final List<TopUpRequest> topUps;
  final List<Withdraw> withdrawals;

  /// The users behind the requests, by id.
  final Map<String, AppUser> users;

  /// Where to pay each pending withdrawal, by user id.
  final Map<String, BillingDetails> billingDetails;
}

/// Actions only admins can take. An admin is a user with a document in the
/// `Admins` collection, which can only be created from the Firebase console.
/// The security rules check it on every one of these reads and writes.
class AdminRepository {
  AdminRepository(this._collections, this._users);

  final Collections _collections;
  final UserRepository _users;

  Future<bool> isAdmin(String userId) async {
    try {
      return (await _collections.admins.doc(userId).get()).exists;
    } on FirebaseException {
      return false;
    }
  }

  Future<AdminOverview> getOverview() async {
    final (balances, topUpDocs, withdrawDocs) = await (
      _collections.balances.get(),
      _collections.topUpRequests
          .where('status', isEqualTo: TopUpStatus.pending.name)
          .get(),
      _collections.withdrawRequests
          .where('status', isEqualTo: Withdraw.pending)
          .get(),
    ).wait;

    var heldLbp = 0;
    var heldUsd = 0;
    for (final doc in balances.docs) {
      final balance = Balance.fromMap(doc.data());
      heldLbp += balance.currentLbp;
      heldUsd += balance.currentUsd;
    }

    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final topUps = [
      for (final doc in topUpDocs.docs) TopUpRequest.fromMap(doc.data()),
    ]..sort((a, b) => (b.timestamp ?? epoch).compareTo(a.timestamp ?? epoch));
    final withdrawals = [
      for (final doc in withdrawDocs.docs)
        Withdraw.fromMap(doc.data(), id: doc.id),
    ]..sort((a, b) => (b.timestamp ?? epoch).compareTo(a.timestamp ?? epoch));

    final withdrawers = withdrawals.map((w) => w.userId).toSet();
    final (users, billing) = await (
      _users.getUsers({...topUps.map((t) => t.userId), ...withdrawers}),
      Future.wait([
        for (final id in withdrawers) _collections.billingDetails.doc(id).get(),
      ]),
    ).wait;

    return AdminOverview(
      heldLbp: heldLbp,
      heldUsd: heldUsd,
      topUps: topUps,
      withdrawals: withdrawals,
      users: {for (final user in users) user.id: user},
      billingDetails: {
        for (final doc in billing)
          doc.id: BillingDetails.fromMap(doc.data() ?? {}),
      },
    );
  }

  /// Adds the amount of [request] to the balance of its user, after the
  /// admin found the transfer.
  Future<void> approveTopUp(TopUpRequest request) async {
    final batch = _collections.firestore.batch();
    batch.update(_collections.topUpRequests.doc(request.userId), {
      'status': TopUpStatus.approved.name,
      'resolved_at': FieldValue.serverTimestamp(),
    });
    batch.update(_collections.balances.doc(request.userId), {
      'current_${request.currency.name}': FieldValue.increment(request.amount),
      'last_top_up': request.reference,
    });
    await batch.commit();
    notifyDataChanged();
  }

  /// Turns [request] down when no matching transfer arrived.
  Future<void> rejectTopUp(TopUpRequest request) async {
    await _collections.topUpRequests.doc(request.userId).update({
      'status': TopUpStatus.rejected.name,
      'resolved_at': FieldValue.serverTimestamp(),
    });
    notifyDataChanged();
  }

  /// Takes [withdraw] out of the balance of its user, after the admin sent
  /// them the money.
  Future<void> markWithdrawPaid(Withdraw withdraw) async {
    final batch = _collections.firestore.batch();
    batch.update(_collections.withdrawRequests.doc(withdraw.id), {
      'status': Withdraw.paid,
      'resolved_at': FieldValue.serverTimestamp(),
    });
    batch.update(_collections.balances.doc(withdraw.userId), {
      'current_lbp': FieldValue.increment(-withdraw.lbp),
      'current_usd': FieldValue.increment(-withdraw.usd),
      'withdrawn_lbp': FieldValue.increment(withdraw.lbp),
      'withdrawn_usd': FieldValue.increment(withdraw.usd),
      'last_withdraw': withdraw.id,
    });
    await batch.commit();
    notifyDataChanged();
  }
}

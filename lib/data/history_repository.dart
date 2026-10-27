import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/data/collections.dart';
import 'package:kahwa/data/user_repository.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/history_entry.dart';
import 'package:kahwa/models/top_up_request.dart';
import 'package:kahwa/models/withdraw.dart';

/// Everything that moved the balance of a user, newest first: kahwas they
/// bought and received, top ups and withdrawals.
class HistoryRepository {
  HistoryRepository(this._collections, this._users);

  final Collections _collections;
  final UserRepository _users;

  Future<List<HistoryEntry>> getHistory(String userId) async {
    final (
      boughtPublic,
      boughtPrivate,
      received,
      receivedPrivate,
      topUps,
      lastTopUp,
      withdrawals,
    ) = await (
      _collections.donations.where('supporter_id', isEqualTo: userId).get(),
      _collections.donationDetails
          .where('supporter_id', isEqualTo: userId)
          .get(),
      _collections.donations.where('creator_id', isEqualTo: userId).get(),
      _collections.donationDetails.where('creator_id', isEqualTo: userId).get(),
      _collections.topUpHistory.where('user_id', isEqualTo: userId).get(),
      _collections.topUpRequests.doc(userId).get(),
      _collections.withdrawRequests.where('user_id', isEqualTo: userId).get(),
    ).wait;

    // Private donations only say who made them in their details.
    final boughtPrivately = await Future.wait([
      for (final doc in boughtPrivate.docs)
        _collections.donations.doc(doc.id).get(),
    ]);
    final bought = [
      for (final doc in [...boughtPublic.docs, ...boughtPrivately])
        if (doc.data() case final data?) Donation.fromMap(data, id: doc.id),
    ];
    final supporterOf = {
      for (final doc in receivedPrivate.docs)
        doc.id: doc.data()['supporter_id'] as String?,
    };
    final receivedDonations = [
      for (final doc in received.docs) Donation.fromMap(doc.data(), id: doc.id),
    ];

    final people = await _users.getUsers({
      for (final donation in bought) donation.creatorId,
      for (final donation in receivedDonations)
        ?(donation.supporterId ?? supporterOf[donation.id]),
    });
    final nameOf = {for (final user in people) user.id: user.name};

    return [
      for (final donation in bought)
        HistoryEntry(
          kind: HistoryKind.bought,
          amount: donation.currency.format(donation.total.toInt()),
          date: donation.timestamp,
          who: nameOf[donation.creatorId],
          kahwas: donation.kahwas,
        ),
      for (final donation in receivedDonations)
        HistoryEntry(
          kind: HistoryKind.received,
          amount: donation.currency.format(donation.total.toInt()),
          date: donation.timestamp,
          who: nameOf[donation.supporterId ?? supporterOf[donation.id]],
          kahwas: donation.kahwas,
        ),
      for (final doc in topUps.docs) _topUp(doc.data()),
      if (lastTopUp.data() case final data?
          when TopUpRequest.fromMap(data).status == TopUpStatus.pending)
        _waitingTopUp(TopUpRequest.fromMap(data)),
      for (final doc in withdrawals.docs)
        _withdrawal(Withdraw.fromMap(doc.data(), id: doc.id)),
    ]..sort(HistoryEntry.newestFirst);
  }

  HistoryEntry _topUp(Map<String, dynamic> data) {
    final approved = data['status'] == TopUpStatus.approved.name;
    return HistoryEntry(
      kind: HistoryKind.topUp,
      amount: Currency.fromName(
        data['currency'],
      ).format((data['amount'] as num?)?.toInt() ?? 0),
      date: (data['resolved_at'] as Timestamp?)?.toDate(),
      status: approved ? 'Added' : 'Not found',
      moved: approved,
    );
  }

  HistoryEntry _waitingTopUp(TopUpRequest request) {
    return HistoryEntry(
      kind: HistoryKind.topUp,
      amount: request.currency.format(request.amount),
      date: request.timestamp,
      status: 'Waiting',
      moved: false,
    );
  }

  HistoryEntry _withdrawal(Withdraw withdraw) {
    return HistoryEntry(
      kind: HistoryKind.withdrawal,
      amount: withdraw.amountText,
      date: withdraw.timestamp,
      status: switch (withdraw.status) {
        Withdraw.paid => 'Paid',
        Withdraw.refused => 'Refused',
        _ => 'Waiting',
      },
      moved: withdraw.isPaid,
    );
  }
}

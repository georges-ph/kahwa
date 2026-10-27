import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/core/refresh.dart';
import 'package:kahwa/data/collections.dart';
import 'package:kahwa/data/user_repository.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/models/kahwa_prices.dart';
import 'package:kahwa/models/pending_kahwa.dart';

class DonationRepository {
  DonationRepository(this._collections, this._users);

  final Collections _collections;
  final UserRepository _users;

  Future<KahwaPrices> getPrices(String creatorId) async {
    final document = await _collections.kahwaPrices.doc(creatorId).get();
    final data = document.data();
    return data == null ? const KahwaPrices() : KahwaPrices.fromMap(data);
  }

  Future<void> savePrices(String creatorId, KahwaPrices prices) {
    return _collections.kahwaPrices.doc(creatorId).set(prices.toMap());
  }

  /// Donations received by [creatorId], newest first, without the profiles
  /// of who made them: [withSupporters] loads those for the ones on screen.
  ///
  /// Everyone gets every donation. Who made a private one, and their message,
  /// are only filled in for the creator and for the supporter themselves.
  /// [viewerId] is null for a visitor who is not signed in.
  Future<List<Donation>> getDonations({
    required String creatorId,
    required String? viewerId,
  }) async {
    final (snapshot, details) = await (
      _collections.donations
          .where('creator_id', isEqualTo: creatorId)
          .orderBy('timestamp', descending: true)
          .get(),
      _getDetails(creatorId: creatorId, viewerId: viewerId),
    ).wait;

    return [
      for (final doc in snapshot.docs)
        if (details[doc.id] case final detail?)
          Donation.fromMap(doc.data(), id: doc.id).withDetails(detail)
        else
          Donation.fromMap(doc.data(), id: doc.id),
    ];
  }

  /// [donations] with the profile of who made each one, when the viewer may
  /// know it. Profiles cost a read each, so only pass the donations shown.
  Future<List<DonationSupporter>> withSupporters(
    Iterable<Donation> donations,
  ) async {
    final supporters = await _users.getUsers(
      donations.map((d) => d.supporterId).nonNulls,
    );
    final byId = {for (final user in supporters) user.id: user};

    return [
      for (final donation in donations)
        DonationSupporter(
          donation: donation,
          supporter: byId[donation.supporterId],
        ),
    ];
  }

  /// The kahwa [userId] was buying when their balance ran short, if any.
  Future<PendingKahwa?> getPending(String userId) async {
    final document = await _collections.pendingKahwas.doc(userId).get();
    final data = document.data();
    return data == null ? null : PendingKahwa.fromMap(data);
  }

  /// Keeps [pending] for [userId] while they top up. Replaces an earlier one.
  Future<void> savePending(String userId, PendingKahwa pending) async {
    await _collections.pendingKahwas.doc(userId).set(pending.toMap());
    notifyDataChanged();
  }

  Future<void> clearPending(String userId) async {
    await _collections.pendingKahwas.doc(userId).delete();
    notifyDataChanged();
  }

  /// Removes the message of a public donation from the page of its creator.
  Future<void> removeMessage(String donationId) async {
    await _collections.donations.doc(donationId).update({'message': ''});
    notifyDataChanged();
  }

  /// Private details [viewerId] may read among the donations [creatorId]
  /// received, by donation id.
  Future<Map<String, Map<String, dynamic>>> _getDetails({
    required String creatorId,
    required String? viewerId,
  }) async {
    if (viewerId == null) return {};

    var query = _collections.donationDetails.where(
      'creator_id',
      isEqualTo: creatorId,
    );
    if (viewerId != creatorId) {
      query = query.where('supporter_id', isEqualTo: viewerId);
    }
    final snapshot = await query.get();
    return {for (final doc in snapshot.docs) doc.id: doc.data()};
  }

  /// Moves the total of [donation] from the supporter to the creator and
  /// records it. Returns false when the supporter does not have enough credit.
  ///
  /// Every document touched carries the id of the donation in `last_donation`.
  /// The security rules use it to check that balances only change by the total
  /// of a donation made in the same transaction.
  Future<bool> donate(Donation donation) async {
    final total = donation.total.toInt();
    final currency = donation.currency;
    final donationRef = _collections.donations.doc();
    final supporterRef = _collections.balances.doc(donation.supporterId);
    final creatorRef = _collections.balances.doc(donation.creatorId);
    final goalRef = _collections.goals.doc(donation.creatorId);

    final success = await _collections.firestore.runTransaction((
      transaction,
    ) async {
      final goalDoc = await transaction.get(goalRef);
      final supporterDoc = await transaction.get(supporterRef);

      final supporterBalance = Balance.fromMap(supporterDoc.data() ?? {});
      if (supporterBalance.current(currency) < total) return false;

      transaction.set(donationRef, donation.toMap());
      if (donation.keepPrivate) {
        transaction.set(
          _collections.donationDetails.doc(donationRef.id),
          donation.toDetailsMap(),
        );
      }
      transaction.update(supporterRef, {
        'current_${currency.name}': FieldValue.increment(-total),
        'spent_${currency.name}': FieldValue.increment(total),
        'last_donation': donationRef.id,
      });
      // Incremented without being read: supporters cannot see the balance of
      // the creator.
      transaction.update(creatorRef, {
        'current_${currency.name}': FieldValue.increment(total),
        'received_${currency.name}': FieldValue.increment(total),
        'last_donation': donationRef.id,
      });

      // A goal only counts donations made in its own currency.
      final goalData = goalDoc.data();
      if (goalData != null && Goal.fromMap(goalData).currency == currency) {
        transaction.update(goalRef, {
          'current': FieldValue.increment(total),
          'last_donation': donationRef.id,
        });
      }

      return true;
    });

    if (success) notifyDataChanged();
    return success;
  }
}

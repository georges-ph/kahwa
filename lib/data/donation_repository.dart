import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/core/refresh.dart';
import 'package:kahwa/data/collections.dart';
import 'package:kahwa/data/user_repository.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/models/kahwa_prices.dart';

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

  /// Donations received by [creatorId], newest first. The supporter is only
  /// loaded for donations that [viewerId] is allowed to see.
  Future<List<DonationSupporter>> getDonations({
    required String creatorId,
    required String viewerId,
  }) async {
    final query = await _collections.donations
        .where('creator_id', isEqualTo: creatorId)
        .orderBy('timestamp', descending: true)
        .get();
    final donations = [
      for (final doc in query.docs) Donation.fromMap(doc.data()),
    ];

    final visible = donations.where((d) => d.isVisibleTo(viewerId));
    final supporters = await _users.getUsers(visible.map((d) => d.supporterId));
    final byId = {for (final user in supporters) user.id: user};

    return [
      for (final donation in donations)
        DonationSupporter(
          donation: donation,
          supporter: donation.isVisibleTo(viewerId)
              ? byId[donation.supporterId]
              : null,
        ),
    ];
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

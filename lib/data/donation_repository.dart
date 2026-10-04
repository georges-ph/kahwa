import 'package:kahwa/data/collections.dart';
import 'package:kahwa/data/user_repository.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/currency.dart';
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
  Future<bool> donate(Donation donation) {
    final total = donation.total.toInt();
    final currency = donation.currency;
    final supporterRef = _collections.balances.doc(donation.supporterId);
    final creatorRef = _collections.balances.doc(donation.creatorId);
    final goalRef = _collections.goals.doc(donation.creatorId);

    return _collections.firestore.runTransaction((transaction) async {
      final goalDoc = await transaction.get(goalRef);
      final supporterDoc = await transaction.get(supporterRef);
      final creatorDoc = await transaction.get(creatorRef);

      final supporterBalance = Balance.fromMap(supporterDoc.data() ?? {});
      final creatorBalance = Balance.fromMap(creatorDoc.data() ?? {});

      if (supporterBalance.current(currency) < total) return false;

      transaction.set(_collections.donations.doc(), donation.toMap());
      transaction.set(
        supporterRef,
        supporterBalance.spend(currency, total).toMap(),
      );
      transaction.set(
        creatorRef,
        creatorBalance.receive(currency, total).toMap(),
      );

      // Goals are tracked in LBP only.
      final goalData = goalDoc.data();
      if (currency == Currency.lbp && goalData != null) {
        final goal = Goal.fromMap(goalData);
        transaction.update(goalRef, {'current': goal.current + total});
      }

      return true;
    });
  }
}

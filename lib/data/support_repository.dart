import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/data/db.dart';
import 'package:kahwa/models/activity.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/models/membership.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/models/tier.dart';

/// The outcome of buying kahwas or paying a membership month.
enum BuyResult {
  done,

  /// The supporter's balance in that currency does not cover it.
  notEnough,

  /// The creator changed something meanwhile, such as their price.
  changed,
}

/// Kahwas, memberships and goals: everything that moves money between a
/// supporter and a creator.
class SupportRepository {
  SupportRepository(this._db);

  final Db _db;

  FirebaseFirestore get _firestore => _db.firestore;

  // Goals

  Future<Goal?> getGoal(String creatorId) async {
    final data = (await _db.goals.doc(creatorId).get()).data();
    return data == null ? null : Goal.fromMap(data);
  }

  /// Starts [goal]. A goal already running is moved to the past goals.
  Future<void> startGoal(String creatorId, Goal goal) async {
    final current = await getGoal(creatorId);
    final batch = _firestore.batch();
    if (current != null) {
      batch.set(_db.pastGoals(creatorId).doc(), current.toPastMap());
    }
    batch.set(_db.goals.doc(creatorId), goal.toNewMap());
    await batch.commit();
  }

  /// Changes the words of the running goal and its target, and its
  /// [currency] while no kahwa counted towards it.
  Future<void> editGoal(
    String creatorId, {
    required String title,
    required String description,
    required int target,
    Currency? currency,
  }) {
    return _db.goals.doc(creatorId).update({
      'title': title,
      'description': description,
      'target': target,
      'currency': ?currency?.name,
    });
  }

  /// Ends the running goal and keeps it in the past goals.
  Future<void> endGoal(String creatorId) async {
    final current = await getGoal(creatorId);
    if (current == null) return;
    final batch = _firestore.batch()
      ..set(_db.pastGoals(creatorId).doc(), current.toPastMap())
      ..delete(_db.goals.doc(creatorId));
    await batch.commit();
  }

  Future<List<Goal>> pastGoals(String creatorId) async {
    final snapshot = await _db.pastGoals(creatorId).get();
    return [for (final doc in snapshot.docs) Goal.fromMap(doc.data())]..sort(
      (a, b) => (b.endedAt ?? DateTime(0)).compareTo(a.endedAt ?? DateTime(0)),
    );
  }

  // Donations

  /// Kahwas [creatorId] received, newest first.
  ///
  /// Everyone gets every donation. Who made a private one, the message and
  /// the reply are only filled in for the creator and for the supporter
  /// themselves. [viewerId] is null for a visitor who is not signed in.
  Future<List<Donation>> donationsTo(
    String creatorId, {
    required String? viewerId,
  }) async {
    final (snapshot, details) = await (
      _db.donations.where('creator_id', isEqualTo: creatorId).get(),
      _detailsFor(creatorId: creatorId, viewerId: viewerId),
    ).wait;
    return _sorted([
      for (final doc in snapshot.docs)
        if (details[doc.id] case final detail?)
          Donation.fromMap(doc.data(), id: doc.id).withDetails(detail)
        else
          Donation.fromMap(doc.data(), id: doc.id),
    ]);
  }

  /// Kahwas [userId] bought, public and private, newest first.
  Future<List<Donation>> donationsBy(String userId) async {
    final (public, details) = await (
      _db.donations.where('supporter_id', isEqualTo: userId).get(),
      _db.donationDetails.where('supporter_id', isEqualTo: userId).get(),
    ).wait;
    final privateDocs = await _db.getByIds(
      _db.donations,
      details.docs.map((d) => d.id),
    );
    final detailById = {for (final d in details.docs) d.id: d.data()};
    return _sorted([
      for (final doc in public.docs) Donation.fromMap(doc.data(), id: doc.id),
      for (final doc in privateDocs)
        Donation.fromMap(
          doc.data(),
          id: doc.id,
        ).withDetails(detailById[doc.id] ?? const {}),
    ]);
  }

  Future<Map<String, Json>> _detailsFor({
    required String creatorId,
    required String? viewerId,
  }) async {
    if (viewerId == null) return {};
    var query = _db.donationDetails.where('creator_id', isEqualTo: creatorId);
    if (viewerId != creatorId) {
      query = query.where('supporter_id', isEqualTo: viewerId);
    }
    final snapshot = await query.get();
    return {for (final doc in snapshot.docs) doc.id: doc.data()};
  }

  static List<Donation> _sorted(List<Donation> donations) {
    final far = DateTime(9999);
    return donations
      ..sort((a, b) => (b.timestamp ?? far).compareTo(a.timestamp ?? far));
  }

  /// Buys [kahwas] kahwas for [creator], from [me]'s balance in [currency].
  ///
  /// Every document touched carries the id of the donation. The security
  /// rules use it to check that balances, the goal and the inbox only change
  /// by what this donation says, in this same transaction.
  Future<BuyResult> buy({
    required Profile creator,
    required Profile me,
    required int kahwas,
    required Currency currency,
    String message = '',
    bool keepPrivate = false,
  }) {
    final price = creator.price(currency);
    if (price == null) return Future.value(BuyResult.changed);
    return _charge(
      donation: Donation(
        creatorId: creator.id,
        supporterId: me.id,
        kahwas: kahwas,
        kahwaPrice: price,
        currency: currency,
        message: message.trim(),
        keepPrivate: keepPrivate,
      ),
      me: me,
    );
  }

  /// Joins [tier] of [creator], or switches to it, paying the first month.
  Future<BuyResult> join({
    required Profile creator,
    required Profile me,
    required Tier tier,
    required Currency currency,
    String message = '',
    bool keepPrivate = false,
  }) {
    final price = creator.price(currency);
    if (price == null) return Future.value(BuyResult.changed);
    return _charge(
      donation: Donation(
        creatorId: creator.id,
        supporterId: me.id,
        kahwas: tier.kahwas,
        kahwaPrice: price,
        currency: currency,
        message: message.trim(),
        keepPrivate: keepPrivate,
        kind: DonationKind.membership,
        tierId: tier.id,
        tierName: tier.name,
      ),
      me: me,
    );
  }

  Future<BuyResult> _charge({
    required Donation donation,
    required Profile me,
  }) async {
    final total = donation.total;
    final currency = donation.currency.name;
    final donationRef = _db.donations.doc();
    final id = donationRef.id;
    final myWalletRef = _db.wallets.doc(me.id);
    final creatorWalletRef = _db.wallets.doc(donation.creatorId);
    final goalRef = _db.goals.doc(donation.creatorId);
    final membershipRef = _db.memberships.doc(
      Membership.idOf(donation.creatorId, me.id),
    );
    final isMembership = donation.kind == DonationKind.membership;

    return _firestore.runTransaction((tx) async {
      final myWallet = await tx.get(myWalletRef);
      final goalDoc = await tx.get(goalRef);
      final membershipDoc = isMembership ? await tx.get(membershipRef) : null;

      final balance = (myWallet.data()?['current_$currency'] as num?) ?? 0;
      if (balance < total) return BuyResult.notEnough;

      tx.set(donationRef, donation.toMap());
      if (donation.keepPrivate) {
        tx.set(_db.donationDetails.doc(id), donation.toDetailsMap());
      }
      tx.update(myWalletRef, {
        'current_$currency': FieldValue.increment(-total),
        'spent_$currency': FieldValue.increment(total),
        'last_donation': id,
      });
      // Incremented without being read: supporters cannot see the balance of
      // the creator.
      tx.update(creatorWalletRef, {
        'current_$currency': FieldValue.increment(total),
        'received_$currency': FieldValue.increment(total),
        'last_donation': id,
      });

      // A goal only counts kahwas bought in its own currency.
      final goalData = goalDoc.data();
      if (goalData != null &&
          Goal.fromMap(goalData).currency == donation.currency) {
        tx.update(goalRef, {
          'current': FieldValue.increment(total),
          'last_donation': id,
        });
      }

      if (isMembership) {
        final fields = {
          'tier': donation.tierId,
          'tier_name': donation.tierName,
          'kahwas': donation.kahwas,
          'currency': currency,
          'total': total,
          'status': MembershipStatus.active.name,
          'keep_private': donation.keepPrivate,
          'last_charge': id,
          'last_charged_at': FieldValue.serverTimestamp(),
        };
        if (membershipDoc?.exists ?? false) {
          tx.update(membershipRef, fields);
        } else {
          tx.set(membershipRef, {
            ...fields,
            'creator_id': donation.creatorId,
            'supporter_id': me.id,
            'started_at': FieldValue.serverTimestamp(),
          });
        }
      }

      tx.set(
        _db.activity.doc(id),
        Activity.newMap(
          userId: donation.creatorId,
          kind: isMembership ? ActivityKind.membership : ActivityKind.kahwa,
          actorId: me.id,
          actorName: me.name,
          kahwas: donation.kahwas,
          amount: total,
          currency: donation.currency,
          message: donation.message,
          ref: id,
        ),
      );
      return BuyResult.done;
    });
  }

  /// Takes a public message off the creator's page.
  Future<void> removeMessage(Donation donation) {
    if (donation.keepPrivate) {
      return _db.donationDetails.doc(donation.id).update({'message': ''});
    }
    return _db.donations.doc(donation.id).update({'message': ''});
  }

  /// The creator answers the message of [donation]. The supporter sees it
  /// on the page, or privately for a private one, and in their inbox.
  Future<void> reply({
    required Donation donation,
    required Profile me,
    required String text,
  }) async {
    final supporterId = donation.supporterId;
    final fields = {
      'reply': text.trim(),
      'reply_at': FieldValue.serverTimestamp(),
    };
    final batch = _firestore.batch();
    if (donation.keepPrivate) {
      batch.update(_db.donationDetails.doc(donation.id), fields);
    } else {
      batch.update(_db.donations.doc(donation.id), fields);
    }
    // Only the first answer reaches the inbox: editing it would otherwise
    // tell the supporter twice.
    if (supporterId != null && text.trim().isNotEmpty && !donation.hasReply) {
      batch.set(
        _db.activity.doc(),
        Activity.newMap(
          userId: supporterId,
          kind: ActivityKind.reply,
          actorId: me.id,
          actorName: me.name,
          message: text.trim(),
          ref: donation.id,
        ),
      );
    }
    await batch.commit();
  }

  // Memberships

  Future<Membership?> membership(String creatorId, String supporterId) async {
    final doc = await _db.memberships
        .doc(Membership.idOf(creatorId, supporterId))
        .get();
    final data = doc.data();
    return data == null ? null : Membership.fromMap(data);
  }

  /// Memberships [userId] holds as a supporter.
  Future<List<Membership>> membershipsOf(String userId) async {
    final snapshot = await _db.memberships
        .where('supporter_id', isEqualTo: userId)
        .get();
    return [for (final doc in snapshot.docs) Membership.fromMap(doc.data())];
  }

  /// Members of [creatorId]'s page.
  Future<List<Membership>> membersOf(String creatorId) async {
    final snapshot = await _db.memberships
        .where('creator_id', isEqualTo: creatorId)
        .get();
    return [for (final doc in snapshot.docs) Membership.fromMap(doc.data())];
  }

  /// Stops [membership] from renewing. The month already paid keeps its
  /// perks.
  Future<void> cancel(Membership membership) {
    return _db.memberships.doc(membership.id).update({
      'status': MembershipStatus.cancelled.name,
    });
  }

  /// Takes back a cancelled [membership] while its month lasts: it renews
  /// again, and nothing is charged now.
  Future<void> resume(Membership membership) {
    return _db.memberships.doc(membership.id).update({
      'status': MembershipStatus.active.name,
    });
  }

  /// Charges every membership of [me] whose month is over. Run when the app
  /// opens, since kahwa has no server to do it on time. A membership whose
  /// tier was removed by the creator is cancelled.
  ///
  /// Returns how many were paid, and the memberships that could not be paid
  /// for lack of balance.
  Future<({int renewed, List<Membership> unpaid})> renewDue(
    Profile me, {
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final due = (await membershipsOf(me.id)).where((m) => m.isDue(at));
    final unpaid = <Membership>[];
    var renewed = 0;
    for (final membership in due) {
      final creator = await _getProfile(membership.creatorId);
      final tier = creator?.tier(membership.tierId);
      if (creator == null || tier == null) {
        await cancel(membership);
        continue;
      }
      final result = await join(
        creator: creator,
        me: me,
        tier: tier,
        currency: membership.currency,
        keepPrivate: membership.keepPrivate,
      );
      if (result == BuyResult.notEnough) {
        unpaid.add(membership);
      } else {
        renewed++;
      }
    }
    return (renewed: renewed, unpaid: unpaid);
  }

  Future<Profile?> _getProfile(String id) async {
    final data = (await _db.profiles.doc(id).get()).data();
    return data == null ? null : Profile.fromMap(data, id: id);
  }

  // Kahwas waiting for a top up

  Future<PendingKahwa?> pending(String userId) async {
    final data = (await _db.pendingKahwas.doc(userId).get()).data();
    return data == null ? null : PendingKahwa.fromMap(data);
  }

  Future<void> savePending(String userId, PendingKahwa pending) {
    return _db.pendingKahwas.doc(userId).set(pending.toMap());
  }

  Future<void> clearPending(String userId) {
    return _db.pendingKahwas.doc(userId).delete();
  }

  // Paying a creator straight to their WHISH account

  /// Whether [creatorId] takes payments to their own WHISH account, and the
  /// number. Only for signed in users.
  Future<DirectPay> directPay(String creatorId) async {
    final data = (await _db.directPay.doc(creatorId).get()).data();
    return data == null ? const DirectPay() : DirectPay.fromMap(data);
  }

  Future<void> saveDirectPay(String creatorId, DirectPay settings) {
    return _db.directPay.doc(creatorId).set(settings.toMap());
  }

  /// Tells [creator] that [payment] was sent to their WHISH account. It only
  /// counts once they confirm it.
  Future<void> sendDirectPayment({
    required Profile creator,
    required Profile me,
    required int kahwas,
    required Currency currency,
    required String senderPhone,
    String message = '',
    bool keepPrivate = false,
  }) {
    final price = creator.price(currency);
    if (price == null) throw StateError('No price in $currency');
    final ref = _db.directPayments.doc();
    final payment = DirectPayment(
      id: ref.id,
      creatorId: creator.id,
      supporterId: me.id,
      kahwas: kahwas,
      kahwaPrice: price,
      currency: currency,
      senderPhone: senderPhone,
      message: message,
      keepPrivate: keepPrivate,
    );
    final batch = _firestore.batch()
      ..set(ref, payment.toNewMap())
      ..set(
        _db.activity.doc(ref.id),
        Activity.newMap(
          userId: creator.id,
          kind: ActivityKind.directPayment,
          actorId: me.id,
          actorName: me.name,
          kahwas: kahwas,
          amount: payment.total,
          currency: currency,
          ref: ref.id,
        ),
      );
    return batch.commit();
  }

  /// Payments sent to [creatorId]'s WHISH account, newest first.
  Future<List<DirectPayment>> directPaymentsTo(String creatorId) async {
    final snapshot = await _db.directPayments
        .where('creator_id', isEqualTo: creatorId)
        .get();
    return _sortedPayments(snapshot.docs);
  }

  /// Payments [supporterId] sent to creators' WHISH accounts.
  Future<List<DirectPayment>> directPaymentsBy(String supporterId) async {
    final snapshot = await _db.directPayments
        .where('supporter_id', isEqualTo: supporterId)
        .get();
    return _sortedPayments(snapshot.docs);
  }

  static List<DirectPayment> _sortedPayments(
    List<QueryDocumentSnapshot<Json>> docs,
  ) {
    final far = DateTime(9999);
    return [
      for (final doc in docs) DirectPayment.fromMap(doc.data(), id: doc.id),
    ]..sort((a, b) => (b.createdAt ?? far).compareTo(a.createdAt ?? far));
  }

  /// The creator found [payment] in their WHISH account: it becomes a
  /// donation with the same id, counts on the page and towards the goal, and
  /// the supporter is told.
  Future<void> confirmDirectPayment(DirectPayment payment, Profile me) {
    final paymentRef = _db.directPayments.doc(payment.id);
    final donationRef = _db.donations.doc(payment.id);
    final goalRef = _db.goals.doc(payment.creatorId);
    final donation = Donation(
      creatorId: payment.creatorId,
      supporterId: payment.supporterId,
      kahwas: payment.kahwas,
      kahwaPrice: payment.kahwaPrice,
      currency: payment.currency,
      message: payment.message,
      keepPrivate: payment.keepPrivate,
      kind: DonationKind.direct,
    );
    return _firestore.runTransaction((tx) async {
      final goalDoc = await tx.get(goalRef);
      tx.set(donationRef, donation.toMap());
      if (payment.keepPrivate) {
        tx.set(_db.donationDetails.doc(payment.id), donation.toDetailsMap());
      }
      tx.update(paymentRef, {
        'status': DirectPaymentStatus.confirmed.name,
        'resolved_at': FieldValue.serverTimestamp(),
      });
      final goalData = goalDoc.data();
      if (goalData != null &&
          Goal.fromMap(goalData).currency == payment.currency) {
        tx.update(goalRef, {
          'current': FieldValue.increment(payment.total),
          'last_donation': payment.id,
        });
      }
      tx.set(
        _db.activity.doc(),
        Activity.newMap(
          userId: payment.supporterId,
          kind: ActivityKind.directAnswer,
          actorId: me.id,
          actorName: me.name,
          kahwas: payment.kahwas,
          amount: payment.total,
          currency: payment.currency,
          ref: payment.id,
        ),
      );
    });
  }

  /// The creator did not find [payment]: it never counts, and the supporter
  /// is told.
  Future<void> rejectDirectPayment(DirectPayment payment, Profile me) {
    final batch = _firestore.batch()
      ..update(_db.directPayments.doc(payment.id), {
        'status': DirectPaymentStatus.rejected.name,
        'resolved_at': FieldValue.serverTimestamp(),
      })
      ..set(
        _db.activity.doc(),
        Activity.newMap(
          userId: payment.supporterId,
          kind: ActivityKind.directAnswer,
          actorId: me.id,
          actorName: me.name,
          kahwas: payment.kahwas,
          amount: payment.total,
          currency: payment.currency,
          ref: payment.id,
          ok: false,
        ),
      );
    return batch.commit();
  }

  /// The supporter takes back a payment the creator has not answered.
  Future<void> cancelDirectPayment(DirectPayment payment) {
    return _db.directPayments.doc(payment.id).delete();
  }
}

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/data/admin_repository.dart';
import 'package:kahwa/data/balance_repository.dart';
import 'package:kahwa/data/collections.dart';
import 'package:kahwa/data/donation_repository.dart';
import 'package:kahwa/data/history_repository.dart';
import 'package:kahwa/data/user_repository.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/models/history_entry.dart';
import 'package:kahwa/models/top_up_request.dart';
import 'package:kahwa/models/withdraw.dart';

/// The repositories that move money, on an in-memory Firestore. The security
/// rules are not part of these tests: they are checked against Firebase by
/// the rules probe in firebase-shared.
void main() {
  late Collections collections;
  late UserRepository users;
  late DonationRepository donations;
  late BalanceRepository balances;
  late AdminRepository admin;
  late HistoryRepository history;

  setUp(() async {
    collections = Collections(FakeFirebaseFirestore());
    users = UserRepository(MockFirebaseAuth(), collections);
    donations = DonationRepository(collections, users);
    balances = BalanceRepository(collections);
    admin = AdminRepository(collections, users);
    history = HistoryRepository(collections, users);

    for (final (id, name) in [('fan', 'Rima'), ('creator', 'Nour')]) {
      await collections.users.doc(id).set(AppUser(id: id, name: name).toMap());
    }
    await collections.balances
        .doc('fan')
        .set(const Balance(currentLbp: 50000, currentUsd: 10).toMap());
    await collections.balances.doc('creator').set(const Balance().toMap());
  });

  Future<Balance> balanceOf(String id) => balances.getBalance(id);

  Donation kahwas(
    int count, {
    Currency currency = Currency.lbp,
    bool keepPrivate = false,
  }) {
    final price = currency == Currency.lbp ? 10000 : 2;
    return Donation(
      creatorId: 'creator',
      supporterId: 'fan',
      kahwaPrice: price,
      kahwas: count,
      currency: currency,
      total: price * count,
      message: 'Keep going',
      keepPrivate: keepPrivate,
    );
  }

  group('buying kahwas', () {
    test('moves the total from the fan to the creator', () async {
      expect(await donations.donate(kahwas(3)), isTrue);

      final fan = await balanceOf('fan');
      final creator = await balanceOf('creator');
      expect(fan.currentLbp, 20000);
      expect(fan.spentLbp, 30000);
      expect(creator.currentLbp, 30000);
      expect(creator.receivedLbp, 30000);
      expect(fan.currentUsd, 10);
    });

    test('changes nothing when the fan has too little', () async {
      expect(await donations.donate(kahwas(6)), isFalse);

      expect((await balanceOf('fan')).currentLbp, 50000);
      expect((await balanceOf('creator')).currentLbp, 0);
      final saved = await collections.donations.get();
      expect(saved.docs, isEmpty);
    });

    test('only counts towards a goal in the same currency', () async {
      await collections.goals
          .doc('creator')
          .set(
            const Goal(
              id: 'creator',
              title: 'Tablet',
              description: '',
              target: 100,
              currency: Currency.usd,
            ).toMap(),
          );

      await donations.donate(kahwas(1));
      await donations.donate(kahwas(2, currency: Currency.usd));

      final goal = await collections.goals.doc('creator').get();
      expect(goal.data()!['current'], 4);
    });

    test('keeps who made a private donation out of the public one', () async {
      await donations.donate(kahwas(1, keepPrivate: true));

      final saved = (await collections.donations.get()).docs.single;
      expect(saved.data().containsKey('supporter_id'), isFalse);
      expect(saved.data().containsKey('message'), isFalse);
      final details = await collections.donationDetails.doc(saved.id).get();
      expect(details.data()!['supporter_id'], 'fan');
      expect(details.data()!['message'], 'Keep going');
    });

    test('the creator can remove a public message', () async {
      await donations.donate(kahwas(1));
      final id = (await collections.donations.get()).docs.single.id;

      await donations.removeMessage(id);

      final read = await donations.getDonations(
        creatorId: 'creator',
        viewerId: null,
      );
      expect(read.single.message, isEmpty);
    });
  });

  group('top ups', () {
    Future<TopUpRequest> request(int amount) async {
      final request = TopUpRequest(
        userId: 'fan',
        amount: amount,
        currency: Currency.usd,
        reference: 'ABC234',
        senderPhone: '70123456',
      );
      await balances.requestTopUp(request);
      return (await balances.getTopUpRequest('fan'))!;
    }

    test('an approved one adds to the balance and to the history', () async {
      await admin.approveTopUp(await request(5));

      expect((await balanceOf('fan')).currentUsd, 15);
      final answered = await balances.getTopUpRequest('fan');
      expect(answered!.status, TopUpStatus.approved);
      final entries = await history.getHistory('fan');
      final topUp = entries.singleWhere((e) => e.kind == HistoryKind.topUp);
      expect(topUp.status, 'Added');
      expect(topUp.moved, isTrue);
    });

    test('a rejected one adds nothing but stays in the history', () async {
      await admin.rejectTopUp(await request(5));

      expect((await balanceOf('fan')).currentUsd, 10);
      final entries = await history.getHistory('fan');
      final topUp = entries.singleWhere((e) => e.kind == HistoryKind.topUp);
      expect(topUp.status, 'Not found');
      expect(topUp.moved, isFalse);
    });
  });

  group('withdrawals', () {
    Future<Withdraw> request() async {
      await balances.requestWithdraw(
        const Withdraw(userId: 'fan', lbp: 20000, usd: 0),
      );
      return (await balances.getWithdrawals('fan')).single;
    }

    test('a paid one leaves the balance', () async {
      await admin.markWithdrawPaid(await request());

      final fan = await balanceOf('fan');
      expect(fan.currentLbp, 30000);
      expect(fan.withdrawnLbp, 20000);
      expect((await balances.getWithdrawals('fan')).single.isPaid, isTrue);
    });

    test('a refused one leaves the balance as it was', () async {
      await admin.refuseWithdraw(await request());

      expect((await balanceOf('fan')).currentLbp, 50000);
      expect((await balances.getWithdrawals('fan')).single.isRefused, isTrue);
    });

    test('a waiting one can be cancelled', () async {
      await balances.cancelWithdraw((await request()).id!);

      expect(await balances.getWithdrawals('fan'), isEmpty);
    });
  });

  test('the history shows both sides of a kahwa', () async {
    await donations.donate(kahwas(2));

    final fan = await history.getHistory('fan');
    final creator = await history.getHistory('creator');
    final bought = fan.singleWhere((e) => e.kind == HistoryKind.bought);
    final received = creator.singleWhere((e) => e.kind == HistoryKind.received);
    expect(bought.who, 'Nour');
    expect(bought.kahwas, 2);
    expect(received.who, 'Rima');
    expect(received.isIncoming, isTrue);
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/data/admin_repository.dart';
import 'package:kahwa/data/db.dart';
import 'package:kahwa/data/post_repository.dart';
import 'package:kahwa/data/profile_repository.dart';
import 'package:kahwa/data/support_repository.dart';
import 'package:kahwa/data/wallet_repository.dart';
import 'package:kahwa/features/wallet/history_screen.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/models/membership.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/models/tier.dart';
import 'package:kahwa/models/wallet.dart';

/// The repositories that move money, on an in-memory Firestore. The security
/// rules are not part of these tests: they are checked in the emulator by
/// `tools/kahwa3_rules_probe.js` in firebase-shared.
void main() {
  late Db db;
  late SupportRepository support;
  late WalletRepository wallets;
  late AdminRepository admin;

  const tier = Tier(id: 't1', name: 'Sketch club', kahwas: 1);
  const creator = Profile(
    id: 'nour',
    name: 'Nour',
    priceLbp: 100000,
    priceUsd: 1,
    tiers: [tier],
  );
  const fan = Profile(id: 'sami', name: 'Sami');

  setUp(() async {
    db = Db(FakeFirebaseFirestore());
    support = SupportRepository(db);
    wallets = WalletRepository(db);
    admin = AdminRepository(db);
    await db.profiles.doc(creator.id).set(creator.toNewMap());
    await db.profiles.doc(fan.id).set(fan.toNewMap());
    await db.wallets.doc(creator.id).set(Wallet.emptyMap());
    await db.wallets.doc(fan.id).set({
      ...Wallet.emptyMap(),
      'current_lbp': 250000,
      'current_usd': 2,
    });
  });

  Future<Wallet> walletOf(String id) async {
    return Wallet.fromMap((await db.wallets.doc(id).get()).data()!);
  }

  Future<List<String>> activityKindsOf(String id) async {
    final snapshot = await db.activity.where('user_id', isEqualTo: id).get();
    return [for (final doc in snapshot.docs) doc.data()['kind'] as String];
  }

  group('buying kahwas', () {
    test('moves the total from the fan to the creator', () async {
      final result = await support.buy(
        creator: creator,
        me: fan,
        kahwas: 2,
        currency: Currency.lbp,
        message: ' Love your drawings! ',
      );
      expect(result, BuyResult.done);

      final fanWallet = await walletOf(fan.id);
      expect(fanWallet.current.lbp, 50000);
      expect(fanWallet.spent.lbp, 200000);
      final creatorWallet = await walletOf(creator.id);
      expect(creatorWallet.current.lbp, 200000);
      expect(creatorWallet.received.lbp, 200000);

      final donations = await support.donationsTo(
        creator.id,
        viewerId: creator.id,
      );
      expect(donations.single.total, 200000);
      expect(donations.single.message, 'Love your drawings!');
      expect(await activityKindsOf(creator.id), ['kahwa']);
    });

    test('stops when the balance is short', () async {
      final result = await support.buy(
        creator: creator,
        me: fan,
        kahwas: 3,
        currency: Currency.usd,
      );
      expect(result, BuyResult.notEnough);
      expect((await walletOf(fan.id)).current.usd, 2);
      expect((await walletOf(creator.id)).received.isZero, isTrue);
    });

    test('needs a price in the chosen currency', () async {
      const noUsd = Profile(id: 'nour', name: 'Nour', priceLbp: 100000);
      final result = await support.buy(
        creator: noUsd,
        me: fan,
        kahwas: 1,
        currency: Currency.usd,
      );
      expect(result, BuyResult.changed);
    });

    test('counts towards a goal in the same currency only', () async {
      await support.startGoal(
        creator.id,
        const Goal(title: 'Tablet', target: 1000000),
      );
      await support.buy(
        creator: creator,
        me: fan,
        kahwas: 1,
        currency: Currency.lbp,
      );
      await support.buy(
        creator: creator,
        me: fan,
        kahwas: 1,
        currency: Currency.usd,
      );
      expect((await support.getGoal(creator.id))!.current, 100000);
    });

    test('keeps a private message apart from the public donation', () async {
      await support.buy(
        creator: creator,
        me: fan,
        kahwas: 1,
        currency: Currency.lbp,
        message: 'Just for you',
        keepPrivate: true,
      );
      final visitor = await support.donationsTo(creator.id, viewerId: null);
      expect(visitor.single.message, isEmpty);
      final owner = await support.donationsTo(creator.id, viewerId: creator.id);
      expect(owner.single.message, 'Just for you');
    });
  });

  group('memberships', () {
    Future<Membership> joined() async {
      final result = await support.join(
        creator: creator,
        me: fan,
        tier: tier,
        currency: Currency.lbp,
      );
      expect(result, BuyResult.done);
      return (await support.membership(creator.id, fan.id))!;
    }

    Future<void> chargedDaysAgo(int days) {
      return db.memberships.doc(Membership.idOf(creator.id, fan.id)).update({
        'last_charged_at': DateTime.now().subtract(Duration(days: days)),
      });
    }

    test('joining pays the first month', () async {
      final membership = await joined();
      expect(membership.isActive, isTrue);
      expect(membership.total, 100000);
      expect((await walletOf(fan.id)).current.lbp, 150000);
      expect((await walletOf(creator.id)).received.lbp, 100000);
      expect(await activityKindsOf(creator.id), ['membership']);
    });

    test('renews only once the month is over', () async {
      await joined();
      var result = await support.renewDue(fan);
      expect(result.renewed, 0);

      await chargedDaysAgo(31);
      result = await support.renewDue(fan);
      expect(result.renewed, 1);
      expect(result.unpaid, isEmpty);
      expect((await walletOf(fan.id)).current.lbp, 50000);
    });

    test('reports a month it cannot pay', () async {
      await joined();
      await db.wallets.doc(fan.id).update({'current_lbp': 0});
      await chargedDaysAgo(31);
      final result = await support.renewDue(fan);
      expect(result.renewed, 0);
      expect(result.unpaid.single.tierName, 'Sketch club');
    });

    test('is cancelled when the creator removed the tier', () async {
      await joined();
      await db.profiles.doc(creator.id).update({'tiers': FieldValue.delete()});
      await chargedDaysAgo(31);
      final result = await support.renewDue(fan);
      expect(result.renewed, 0);
      final membership = await support.membership(creator.id, fan.id);
      expect(membership!.isActive, isFalse);
    });
  });

  group('top ups and withdrawals', () {
    test('an approved top up adds to the balance', () async {
      await wallets.requestTopUp(
        userId: fan.id,
        amount: 500000,
        currency: Currency.lbp,
        senderPhone: ' 70123456 ',
      );
      final request = (await admin.pendingTopUps()).single;
      expect(request.senderPhone, '70123456');

      await admin.answerTopUp(request, received: true, adminId: 'admin');
      expect((await walletOf(fan.id)).current.lbp, 750000);
      expect(await admin.pendingTopUps(), isEmpty);
      final history = await wallets.topUpHistory(fan.id);
      expect(history.single.status, RequestStatus.approved);
      expect(await activityKindsOf(fan.id), ['top_up']);
    });

    test('a refused top up leaves the balance alone', () async {
      await wallets.requestTopUp(
        userId: fan.id,
        amount: 500000,
        currency: Currency.lbp,
        senderPhone: '70123456',
      );
      final request = (await admin.pendingTopUps()).single;
      await admin.answerTopUp(request, received: false, adminId: 'admin');
      expect((await walletOf(fan.id)).current.lbp, 250000);
    });

    test('a paid withdrawal leaves the balance', () async {
      await wallets.requestWithdraw(fan.id, const Amounts(lbp: 200000, usd: 1));
      final request = (await admin.pendingWithdrawals()).single;
      await admin.answerWithdraw(request, paid: true, adminId: 'admin');

      final wallet = await walletOf(fan.id);
      expect(wallet.current.lbp, 50000);
      expect(wallet.current.usd, 1);
      expect(wallet.withdrawn.lbp, 200000);
      expect(await admin.pendingWithdrawals(), isEmpty);
      // One inbox entry per currency.
      expect(await activityKindsOf(fan.id), ['withdraw', 'withdraw']);
    });

    test('the admin sees what is held for users', () async {
      final overview = await admin.overview();
      expect(overview.held.lbp, 250000);
      expect(overview.held.usd, 2);
      expect(overview.users, 2);
    });
  });

  group('goals', () {
    test('the currency changes only when asked', () async {
      await support.startGoal(
        creator.id,
        const Goal(title: 'Tablet', target: 1000),
      );
      await support.editGoal(
        creator.id,
        title: 'Tablet',
        description: '',
        target: 2000,
      );
      expect((await support.getGoal(creator.id))!.currency, Currency.lbp);
      await support.editGoal(
        creator.id,
        title: 'Tablet',
        description: '',
        target: 2000,
        currency: Currency.usd,
      );
      expect((await support.getGoal(creator.id))!.currency, Currency.usd);
    });
  });

  group('posts', () {
    test('members-only text is kept apart and hidden from visitors', () async {
      final posts = PostRepository(db);
      await posts.create(
        creatorId: creator.id,
        text: ' The cedar study ',
        membersOnly: true,
      );
      final public = (await db.posts.get()).docs.single.data();
      expect(public['text'], isEmpty);

      final forVisitor = (await posts.postsOf(creator.id)).single;
      expect(forVisitor.locked, isTrue);
      // On the fake database every read is allowed, so a signed in viewer
      // gets the text: the rules decide who that is.
      final forMember = (await posts.postsOf(
        creator.id,
        viewerId: fan.id,
      )).single;
      expect(forMember.text, 'The cedar study');
    });

    test('a post can be opened to everyone and closed again', () async {
      final posts = PostRepository(db);
      await posts.create(
        creatorId: creator.id,
        text: 'The cedar study',
        membersOnly: true,
      );
      var post = (await posts.postsOf(creator.id, viewerId: creator.id)).single;

      await posts.edit(post, 'The cedar study', membersOnly: false);
      var stored = await db.posts.doc(post.id).get();
      expect(stored.data()!['text'], 'The cedar study');
      expect(stored.data()!['members_only'], isFalse);
      expect((await db.postBodies.doc(post.id).get()).exists, isFalse);

      post = (await posts.postsOf(creator.id, viewerId: creator.id)).single;
      await posts.edit(post, 'For members now', membersOnly: true);
      stored = await db.posts.doc(post.id).get();
      expect(stored.data()!['text'], isEmpty);
      expect(stored.data()!['members_only'], isTrue);
      final body = await db.postBodies.doc(post.id).get();
      expect(body.data()!['text'], 'For members now');
    });
  });

  group('fans', () {
    test('stopping takes back the inbox entry', () async {
      final profiles = ProfileRepository(db);
      await profiles.setFan(creatorId: creator.id, me: fan, fan: true);
      expect(await activityKindsOf(creator.id), ['fan']);
      await profiles.setFan(creatorId: creator.id, me: fan, fan: false);
      expect(await activityKindsOf(creator.id), isEmpty);
      // Becoming one again tells the creator again.
      await profiles.setFan(creatorId: creator.id, me: fan, fan: true);
      expect(await activityKindsOf(creator.id), ['fan']);
    });
  });

  group('balance corrections', () {
    test('move the balance and stay in the history with the reason', () async {
      await admin.adjust(
        userId: fan.id,
        adminId: 'admin',
        currency: Currency.usd,
        amount: -1,
        reason: 'Top up counted twice',
      );
      expect((await walletOf(fan.id)).current.usd, 1);
      final list = await wallets.adjustments(fan.id);
      expect(list.single.amount, -1);
      expect(list.single.adminId, 'admin');
      expect(await activityKindsOf(fan.id), ['adjustment']);

      final history = HistoryEntry.merge(
        userId: fan.id,
        bought: const [],
        received: const [],
        topUps: const [],
        withdrawals: const [],
        adjustments: list,
      );
      expect(history.single.kind, HistoryKind.adjustment);
      expect(history.single.isIn, isFalse);
      expect(history.single.note, 'Top up counted twice');
      final log = await admin.log();
      expect(log.adjustments.single.reason, 'Top up counted twice');
    });
  });

  group('paying a creator by WHISH', () {
    Future<DirectPayment> send() async {
      await support.saveDirectPay(
        creator.id,
        const DirectPay(
          enabled: true,
          whishLinks: {Currency.usd: 'https://whish.money/pay/abc123'},
        ),
      );
      await support.sendDirectPayment(
        creator: creator,
        me: fan,
        kahwas: 3,
        currency: Currency.usd,
        senderPhone: '71111111',
        message: 'For the paint',
      );
      return (await support.directPaymentsTo(creator.id)).single;
    }

    test('counts once the creator confirms it, without any balance', () async {
      await support.startGoal(
        creator.id,
        const Goal(title: 'Paint', target: 10, currency: Currency.usd),
      );
      final payment = await send();
      expect(payment.total, 3);
      expect(payment.isPending, isTrue);
      expect(await activityKindsOf(creator.id), ['direct_payment']);
      expect(await support.donationsTo(creator.id, viewerId: null), isEmpty);

      await support.confirmDirectPayment(payment, creator);
      final donation = (await support.donationsTo(
        creator.id,
        viewerId: creator.id,
      )).single;
      expect(donation.kind, DonationKind.direct);
      expect(donation.id, payment.id);
      expect(donation.message, 'For the paint');
      expect((await support.getGoal(creator.id))!.current, 3);
      // No balance moved.
      expect((await walletOf(fan.id)).current.usd, 2);
      expect((await walletOf(creator.id)).current.usd, 0);
      expect(await activityKindsOf(fan.id), ['direct_answer']);
    });

    test('never counts when the creator does not find it', () async {
      final payment = await send();
      await support.rejectDirectPayment(payment, creator);
      expect(await support.donationsTo(creator.id, viewerId: null), isEmpty);
      final after = (await support.directPaymentsBy(fan.id)).single;
      expect(after.status, DirectPaymentStatus.rejected);
    });
  });
}

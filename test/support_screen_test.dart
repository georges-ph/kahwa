import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/data/db.dart';
import 'package:kahwa/features/support/support_screen.dart';
import 'package:kahwa/l10n/app_localizations.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/models/tier.dart';
import 'package:kahwa/models/wallet.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';

void main() {
  const tier = Tier(id: 't1', name: 'Sketch club', kahwas: 1);
  const creator = Profile(
    id: 'nour',
    name: 'Nour',
    priceLbp: 100000,
    priceUsd: 1,
    tiers: [tier],
  );
  const fan = Profile(id: 'sami', name: 'Sami', onboarded: true);

  late FakeFirebaseFirestore firestore;
  late Db db;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    db = Db(firestore);
    await db.profiles.doc(creator.id).set(creator.toEditableMap());
    await db.profiles.doc(fan.id).set(fan.toEditableMap());
    await db.wallets.doc(creator.id).set(Wallet.emptyMap());
    await db.wallets.doc(fan.id).set({
      ...Wallet.emptyMap(),
      'current_lbp': 500000,
    });
  });

  Future<void> open(
    WidgetTester tester, {
    String? tierId,
    Currency? currency,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firestoreProvider.overrideWithValue(firestore),
          firebaseAuthProvider.overrideWithValue(
            MockFirebaseAuth(
              signedIn: true,
              mockUser: MockUser(uid: fan.id, email: 'sami@example.com'),
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildTheme(brightness: Brightness.light),
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: SupportScreen(
            creatorId: creator.id,
            tierId: tierId,
            currency: currency,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> join(WidgetTester tester) async {
    await tester.tap(
      find.widgetWithText(FilledButton, 'Join for 100,000 L.L. a month'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Join'));
    await tester.pumpAndSettle();
  }

  testWidgets('joining shows the welcome screen', (tester) async {
    await open(tester, tierId: tier.id);
    await join(tester);
    expect(find.text('Welcome to Sketch club!'), findsOneWidget);
  });

  testWidgets('joining the tier kept for a top up finishes it', (tester) async {
    await db.pendingKahwas
        .doc(fan.id)
        .set(
          PendingKahwa(
            creatorId: 'nour',
            kahwas: 1,
            currency: Currency.lbp,
            tierId: tier.id,
          ).toMap(),
        );
    await open(tester, tierId: tier.id);
    expect(find.text('Your kahwa was kept while you topped up.'), findsOne);
    await join(tester);
    expect(find.text('Welcome to Sketch club!'), findsOneWidget);
    expect((await db.pendingKahwas.doc(fan.id).get()).exists, isFalse);
  });

  testWidgets('joining while another kahwa is kept leaves that one', (
    tester,
  ) async {
    await db.pendingKahwas
        .doc(fan.id)
        .set(
          const PendingKahwa(
            creatorId: 'nour',
            kahwas: 1,
            currency: Currency.lbp,
          ).toMap(),
        );
    await open(tester, tierId: tier.id);
    expect(find.text('Your kahwa was kept while you topped up.'), findsNothing);
    await join(tester);
    expect(find.text('Welcome to Sketch club!'), findsOneWidget);
    expect((await db.pendingKahwas.doc(fan.id).get()).exists, isTrue);
  });

  testWidgets('a month already paid cannot be paid again', (tester) async {
    await db.memberships.doc('nour_sami').set({
      'creator_id': 'nour',
      'supporter_id': 'sami',
      'tier': 't1',
      'tier_name': 'Sketch club',
      'kahwas': 1,
      'currency': 'lbp',
      'total': 100000,
      'status': 'active',
      'last_charged_at': DateTime.now(),
    });
    await open(tester, tierId: tier.id);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, "You're a member"),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('a cancelled month still paid comes back for free', (
    tester,
  ) async {
    final paidAt = DateTime.now().subtract(const Duration(days: 3));
    await db.memberships.doc('nour_sami').set({
      'creator_id': 'nour',
      'supporter_id': 'sami',
      'tier': 't1',
      'tier_name': 'Sketch club',
      'kahwas': 1,
      'currency': 'lbp',
      'total': 100000,
      'status': 'cancelled',
      'last_charged_at': paidAt,
    });
    await open(tester, tierId: tier.id);
    await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
    await tester.pumpAndSettle();
    // The confirmation's button.
    await tester.tap(find.widgetWithText(FilledButton, 'Resume').last);
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Sketch club!'), findsOneWidget);
    final membership = await db.memberships.doc('nour_sami').get();
    expect(membership.data()!['status'], 'active');
    final wallet = await db.wallets.doc(fan.id).get();
    expect(wallet.data()!['current_lbp'], 500000);
  });

  testWidgets('a cancelled month comes back for free in any currency', (
    tester,
  ) async {
    // Paid in L.L., then opened from a page set to $: still free, and the
    // membership keeps its currency.
    await db.memberships.doc('nour_sami').set({
      'creator_id': 'nour',
      'supporter_id': 'sami',
      'tier': 't1',
      'tier_name': 'Sketch club',
      'kahwas': 1,
      'currency': 'lbp',
      'total': 100000,
      'status': 'cancelled',
      'last_charged_at': DateTime.now().subtract(const Duration(days: 3)),
    });
    await open(tester, tierId: tier.id, currency: Currency.usd);
    expect(find.widgetWithText(FilledButton, 'Resume'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Resume').last);
    await tester.pumpAndSettle();
    final membership = await db.memberships.doc('nour_sami').get();
    expect(membership.data()!['status'], 'active');
    expect(membership.data()!['currency'], 'lbp');
    final wallet = await db.wallets.doc(fan.id).get();
    expect(wallet.data()!['current_usd'], isNot(lessThan(0)));
    expect(wallet.data()!['current_lbp'], 500000);
  });
}

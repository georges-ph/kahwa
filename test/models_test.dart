import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/models/membership.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/models/social_link.dart';
import 'package:kahwa/models/tier.dart';
import 'package:kahwa/models/wallet.dart';
import 'package:kahwa/theme/palette.dart';

void main() {
  group('WHISH links', () {
    test('pay links open in the WHISH app', () {
      final app = Uri.https('whish.money', '/app/pay/abc123');
      expect(whishAppLink('https://whish.money/pay/abc123'), app);
      expect(whishAppLink(' whish.money/pay/abc123 '), app);
      expect(whishAppLink('https://www.whish.money/app/pay/abc123'), app);
      expect(
        whishPayLink('www.whish.money/app/pay/abc123?x=1'),
        'https://whish.money/pay/abc123',
      );
    });

    test('anything else is refused', () {
      expect(isWhishPayLink('70123456'), isFalse);
      expect(isWhishPayLink('https://evil.com/pay/abc123'), isFalse);
      expect(isWhishPayLink('https://whish.money/abc123'), isFalse);
      expect(isWhishPayLink(''), isFalse);
      expect(isWhishPayLink(null), isFalse);
    });

    test('a creator takes the currencies they have a link for', () {
      final pay = DirectPay.fromMap({
        'enabled': true,
        'whish_link_lbp': '',
        'whish_link_usd': 'https://whish.money/pay/abc123',
      });
      expect(pay.isOn, isTrue);
      expect(pay.currencies, [Currency.usd]);
      expect(const DirectPay(enabled: true).isOn, isFalse);
    });
  });

  group('Profile', () {
    test('reads a page written by the app', () {
      final profile = Profile(
        id: 'nour',
        name: 'Nour Haddad',
        username: 'nour',
        tagline: 'Illustrator in Beirut',
        color: creatorColors[3].toARGB32(),
        cover: 2,
        links: const [
          SocialLink(kind: LinkKind.instagram, url: 'instagram.com/nour'),
        ],
        priceLbp: 100000,
        priceUsd: 1,
        tiers: const [
          Tier(id: 'b', name: 'Patron', kahwas: 10),
          Tier(id: 'a', name: 'Sketch club', kahwas: 1, perks: 'Sketches'),
        ],
        onboarded: true,
      );
      final read = Profile.fromMap(profile.toEditableMap(), id: 'nour');

      expect(read.name, 'Nour Haddad');
      expect(read.username, 'nour');
      expect(read.color, creatorColors[3].toARGB32());
      expect(read.cover, 2);
      expect(read.links.single.kind, LinkKind.instagram);
      expect(read.isCreator, isTrue);
      expect(read.price(Currency.usd), 1);
      // Cheapest tier first.
      expect(read.tiers.map((t) => t.name), ['Sketch club', 'Patron']);
      expect(read.tier('a')?.perks, 'Sketches');
      expect(read.onboarded, isTrue);
    });

    test('survives missing or odd fields', () {
      final read = Profile.fromMap({
        'name': '  ',
        'color': 123,
        'links': [
          {'kind': 'instagram', 'url': 'not a link'},
        ],
        'tiers': {'x': 'broken'},
      }, id: 'u1');
      expect(read.name, 'kahwa user');
      expect(read.color, creatorColors.first.toARGB32());
      expect(read.links, isEmpty);
      expect(read.tiers, isEmpty);
      expect(read.isCreator, isFalse);
    });

    test('matches searches on name, username and tagline', () {
      const profile = Profile(
        id: 'n',
        name: 'Nour Haddad',
        username: 'nour',
        tagline: 'Illustrator in Beirut',
      );
      expect(profile.matches('haddad'), isTrue);
      expect(profile.matches('@nou'), isTrue);
      expect(profile.matches('beirut'), isTrue);
      expect(profile.matches('sami'), isFalse);
      expect(profile.matches('  '), isTrue);
    });

    test('copyWith can clear nullable fields', () {
      const profile = Profile(id: 'n', name: 'Nour', username: 'nour');
      expect(profile.copyWith(username: () => null).username, isNull);
      expect(profile.copyWith(name: 'N').username, 'nour');
    });
  });

  group('Membership', () {
    Membership charged(DateTime? at, {bool cancelled = false}) {
      return Membership(
        creatorId: 'c',
        supporterId: 's',
        tierId: 't',
        tierName: 'Sketch club',
        kahwas: 1,
        currency: Currency.lbp,
        total: 100000,
        status: cancelled
            ? MembershipStatus.cancelled
            : MembershipStatus.active,
        lastChargedAt: at,
      );
    }

    final paid = DateTime(2026, 10, 1);

    test('is named creator_supporter', () {
      expect(charged(paid).id, 'c_s');
    });

    test('is due once the month is over', () {
      expect(charged(paid).isDue(DateTime(2026, 10, 30)), isFalse);
      expect(charged(paid).isDue(DateTime(2026, 10, 31)), isTrue);
      expect(charged(paid, cancelled: true).isDue(DateTime(2026, 11)), isFalse);
      expect(charged(null).isDue(DateTime(2026, 11)), isFalse);
    });

    test('a cancelled one comes back free while its month lasts', () {
      final cancelled = charged(paid, cancelled: true);
      expect(cancelled.canResume(DateTime(2026, 10, 30)), isTrue);
      expect(cancelled.canResume(DateTime(2026, 10, 31)), isFalse);
      expect(charged(paid).canResume(DateTime(2026, 10, 10)), isFalse);
    });

    test('keeps its perks for the month paid, plus a day', () {
      expect(charged(paid).isPaidAt(DateTime(2026, 10, 31, 12)), isTrue);
      expect(charged(paid).isPaidAt(DateTime(2026, 11, 2)), isFalse);
      expect(
        charged(paid, cancelled: true).isPaidAt(DateTime(2026, 10, 20)),
        isTrue,
      );
    });

    test('reads dates from Firestore', () {
      final m = Membership.fromMap({
        'creator_id': 'c',
        'supporter_id': 's',
        'tier': 't',
        'currency': 'usd',
        'total': 3,
        'status': 'cancelled',
        'last_charged_at': Timestamp.fromDate(paid),
      });
      expect(m.currency, Currency.usd);
      expect(m.isActive, isFalse);
      expect(m.nextCharge, paid.add(Membership.period));
    });
  });

  test('a tier costs its kahwas at the page price', () {
    const tier = Tier(id: 't', name: 'Regular', kahwas: 3);
    expect(tier.monthly(100000), 300000);
    expect(tier.monthlyText(1, Currency.usd), r'$3');
    expect(tier.monthlyText(null, Currency.usd), '');
  });

  test('a wallet starts empty and reads every amount', () {
    expect(Wallet.emptyMap().values.every((v) => v == 0), isTrue);
    expect(Wallet.emptyMap().length, 8);
    final wallet = Wallet.fromMap({
      'current_lbp': 200000,
      'spent_usd': 4,
      'received_lbp': 100,
    });
    expect(wallet.current.lbp, 200000);
    expect(wallet.spent.usd, 4);
    expect(wallet.received.lbp, 100);
    expect(wallet.withdrawn.isZero, isTrue);
  });
}

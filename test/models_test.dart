import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/creator_color.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/models/kahwa_prices.dart';

void main() {
  group('AppUser', () {
    test('reads the fields stored in Firestore', () {
      final user = AppUser.fromMap({
        'id': 'u1',
        'name': 'Rima Khoury',
        'email': 'rima@example.com',
        'color': 'purple',
        'fans': ['u2', 'u3'],
        'link_id': 'abc',
      });

      expect(user.id, 'u1');
      expect(user.name, 'Rima Khoury');
      expect(user.color, CreatorColor.purple);
      expect(user.fans, ['u2', 'u3']);
      expect(user.linkId, 'abc');
      expect(user.hasFan('u2'), isTrue);
      expect(user.hasFan('u9'), isFalse);
    });

    test('falls back to defaults when fields are missing', () {
      final user = AppUser.fromMap({'id': 'u1', 'name': 'Rima'});

      expect(user.color, CreatorColor.brown);
      expect(user.fans, isEmpty);
      expect(user.image, isNull);
    });

    test('writes the same keys it reads', () {
      const user = AppUser(
        id: 'u1',
        name: 'Rima',
        color: CreatorColor.cyan,
        fans: ['u2'],
      );

      final copy = AppUser.fromMap(user.toMap());

      expect(copy.toMap(), user.toMap());
    });
  });

  group('Balance', () {
    const balance = Balance(currentLbp: 5000, currentUsd: 10);

    test('reads the balance of each currency', () {
      expect(balance.current(Currency.lbp), 5000);
      expect(balance.current(Currency.usd), 10);
    });

    test('treats missing fields as zero', () {
      final empty = Balance.fromMap({});

      expect(empty.current(Currency.lbp), 0);
      expect(empty.current(Currency.usd), 0);
    });
  });

  group('Donation', () {
    Donation donation({required bool keepPrivate}) {
      return Donation(
        creatorId: 'creator',
        supporterId: 'supporter',
        kahwaPrice: 1000,
        kahwas: 3,
        currency: Currency.lbp,
        total: 3000,
        message: 'Keep going',
        keepPrivate: keepPrivate,
      );
    }

    test('public donations store who made them and the message', () {
      final map = donation(keepPrivate: false).toMap();

      expect(map['supporter_id'], 'supporter');
      expect(map['message'], 'Keep going');
    });

    test('private donations keep them out of the public document', () {
      final private = donation(keepPrivate: true);
      final map = private.toMap();

      expect(map.containsKey('supporter_id'), isFalse);
      expect(map.containsKey('message'), isFalse);
      expect(map['kahwas'], 3);
      expect(private.toDetailsMap(), {
        'creator_id': 'creator',
        'supporter_id': 'supporter',
        'message': 'Keep going',
      });
    });

    test('a private donation read by a stranger has no supporter', () {
      final read = Donation.fromMap(
        donation(keepPrivate: true).toMap()..remove('timestamp'),
      );

      expect(read.supporterId, isNull);
      expect(read.message, isEmpty);
      expect(read.kahwas, 3);
    });

    test('details fill in the supporter and the message', () {
      final private = donation(keepPrivate: true);
      final read = Donation.fromMap(
        private.toMap()..remove('timestamp'),
        id: 'd1',
      ).withDetails(private.toDetailsMap());

      expect(read.id, 'd1');
      expect(read.supporterId, 'supporter');
      expect(read.message, 'Keep going');
    });

    test('reads the fields stored in Firestore', () {
      final read = Donation.fromMap({
        'creator_id': 'creator',
        'supporter_id': 'supporter',
        'kahwa_price': 2,
        'kahwas': 5,
        'currency': 'usd',
        'total': 10,
        'keep_private': false,
        'message': 'Keep going',
      });

      expect(read.currency, Currency.usd);
      expect(read.kahwas, 5);
      expect(read.total, 10);
      expect(read.timestamp, isNull);
    });
  });

  group('Goal', () {
    test('progress is the share of the target reached', () {
      const goal = Goal(
        id: 'u1',
        title: 'Camera',
        description: 'A new camera',
        current: 250,
        target: 1000,
      );

      expect(goal.progress, 0.25);
    });

    test('progress stays between 0 and 1', () {
      const over = Goal(
        id: 'u1',
        title: 'Camera',
        description: '',
        current: 5000,
        target: 1000,
      );
      const noTarget = Goal(id: 'u1', title: '', description: '', target: 0);

      expect(over.progress, 1);
      expect(noTarget.progress, 0);
    });
  });

  group('KahwaPrices', () {
    test('new creators start at 1,000 L.L. and 1 dollar', () {
      const prices = KahwaPrices();

      expect(prices.price(Currency.lbp), 1000);
      expect(prices.price(Currency.usd), 1);
    });
  });

  group('Currency', () {
    test('formats amounts the way they are shown', () {
      expect(Currency.lbp.format(150000), '150,000 L.L.');
      expect(Currency.usd.format(5), '\$5');
    });

    test('unknown names fall back to LBP', () {
      expect(Currency.fromName('eur'), Currency.lbp);
      expect(Currency.fromName(null), Currency.lbp);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/core/config.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/models/username.dart';

void main() {
  group('Username', () {
    test('tidies up what users type', () {
      expect(Username.normalize('  @Rima_K '), 'rima_k');
      expect(Username.normalize('rima'), 'rima');
    });

    test('accepts letters, numbers and underscores', () {
      expect(Username.validate('rima'), isNull);
      expect(Username.validate('rima_khoury_99'), isNull);
    });

    test('rejects names that are too short or too long', () {
      expect(Username.validate('ab'), isNotNull);
      expect(Username.validate('a' * 21), isNotNull);
    });

    test('rejects other characters', () {
      expect(Username.validate('Rima'), isNotNull);
      expect(Username.validate('rima khoury'), isNotNull);
      expect(Username.validate('rima-k'), isNotNull);
      expect(Username.validate('rima.k'), isNotNull);
      expect(Username.validate('ريما'), isNotNull);
    });

    test('rejects words the app uses for its own addresses', () {
      expect(Username.validate('settings'), isNotNull);
      expect(Username.validate('goal'), isNotNull);
      expect(Username.validate('admin'), isNotNull);
    });
  });

  group('creator links', () {
    test('use the username when there is one', () {
      final link = AppConfig.creatorLink(id: 'u1', username: 'rima');

      expect(link, endsWith('/rima'));
    });

    test('fall back to the id', () {
      final link = AppConfig.creatorLink(id: 'u1');

      expect(link, endsWith('/c/u1'));
    });

    test('the username is stored with the user', () {
      final user = AppUser.fromMap({'id': 'u1', 'name': 'Rima'});
      final named = AppUser.fromMap({
        'id': 'u1',
        'name': 'Rima',
        'username': 'rima',
      });

      expect(user.username, isNull);
      expect(named.username, 'rima');
      expect(named.toMap()['username'], 'rima');
    });
  });

  group('goal currency', () {
    test('goals saved before currencies are in LBP', () {
      final goal = Goal.fromMap({'id': 'u1', 'title': 'Mic', 'target': 100});

      expect(goal.currency, Currency.lbp);
    });

    test('is stored with the goal', () {
      const goal = Goal(
        id: 'u1',
        title: 'Mic',
        description: 'A microphone',
        target: 100,
        currency: Currency.usd,
      );

      expect(goal.toMap()['currency'], 'usd');
      expect(Goal.fromMap(goal.toMap()).currency, Currency.usd);
    });
  });
}

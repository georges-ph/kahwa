import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/models/app_user.dart';

void main() {
  group('searching creators', () {
    const rima = AppUser(id: 'u1', name: 'Rima Khoury', username: 'rima_draws');
    const noHandle = AppUser(id: 'u2', name: 'Karim Saab');

    test('finds a creator by part of their name, ignoring case', () {
      expect(rima.matches('khou'), isTrue);
      expect(rima.matches('RIMA'), isTrue);
      expect(noHandle.matches(' saab '), isTrue);
    });

    test('finds a creator by their username, with or without @', () {
      expect(rima.matches('draws'), isTrue);
      expect(rima.matches('@rima_d'), isTrue);
    });

    test('finds nothing for an empty search or another name', () {
      expect(rima.matches(''), isFalse);
      expect(rima.matches('@'), isFalse);
      expect(rima.matches('nour'), isFalse);
      expect(noHandle.matches('rima'), isFalse);
    });
  });
}

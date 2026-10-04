import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/core/formatters.dart';

void main() {
  group('getInitials', () {
    test('takes the first letter of the first two words', () {
      expect(getInitials('John Doe'), 'JD');
      expect(getInitials('rima'), 'R');
      expect(getInitials('Jean Pierre Haddad'), 'JP');
    });

    test('ignores extra spaces and empty names', () {
      expect(getInitials('  John   Doe '), 'JD');
      expect(getInitials(''), '');
    });
  });

  group('plural', () {
    test('adds an s unless the count is one', () {
      expect(plural(1, 'Fan'), '1 Fan');
      expect(plural(0, 'Fan'), '0 Fans');
      expect(plural(3, 'kahwa'), '3 kahwas');
    });
  });

  group('parseAmount', () {
    test('reads whole positive numbers', () {
      expect(parseAmount('1000'), 1000);
      expect(parseAmount(' 1,000 '), 1000);
      expect(parseAmount('0'), 0);
    });

    test('rejects anything else', () {
      expect(parseAmount(''), isNull);
      expect(parseAmount('abc'), isNull);
      expect(parseAmount('-5'), isNull);
      expect(parseAmount('1.5'), isNull);
    });
  });
}

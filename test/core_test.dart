import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/core/text.dart';
import 'package:kahwa/core/username.dart';
import 'package:kahwa/models/social_link.dart';
import 'package:kahwa/ui/widgets.dart';

void main() {
  group('Currency', () {
    test('formats amounts the way users read them', () {
      expect(Currency.lbp.format(100000), '100,000 L.L.');
      expect(Currency.usd.format(5), r'$5');
      expect(Currency.lbp.format(5000, arabic: true), '5,000 ل.ل.');
    });

    test('has a short form for tight spaces', () {
      expect(Currency.lbp.compact(500000), '500K L.L.');
      expect(Currency.usd.compact(1500), r'$1.5K');
    });

    test('reads unknown names as LBP', () {
      expect(Currency.fromName('usd'), Currency.usd);
      expect(Currency.fromName(null), Currency.lbp);
      expect(Currency.fromName('eur'), Currency.lbp);
    });
  });

  group('parseAmount', () {
    test('accepts whole numbers with commas and spaces', () {
      expect(parseAmount('100,000'), 100000);
      expect(parseAmount(' 2 500 '), 2500);
      expect(parseAmount('0'), 0);
    });

    test('refuses anything else', () {
      expect(parseAmount(''), isNull);
      expect(parseAmount('-5'), isNull);
      expect(parseAmount('1.5'), isNull);
      expect(parseAmount('abc'), isNull);
    });
  });

  test('Amounts add up per currency', () {
    const a = Amounts(lbp: 100, usd: 2);
    expect(a.add(Currency.usd, 3).usd, 5);
    expect(a.add(Currency.lbp, 50).lbp, 150);
    expect((a + const Amounts(lbp: 1, usd: 1)).of(Currency.lbp), 101);
    expect(const Amounts().isZero, isTrue);
  });

  group('Username', () {
    test('is tidied up from what users type', () {
      expect(Username.normalize('  @Nour_Draws '), 'nour_draws');
    });

    test('says why a username cannot be used', () {
      expect(Username.validate('nour'), isNull);
      expect(Username.validate('no'), UsernameProblem.length);
      expect(Username.validate('a' * 21), UsernameProblem.length);
      expect(Username.validate('nour-draws'), UsernameProblem.characters);
      expect(Username.validate('admin'), UsernameProblem.reserved);
      expect(Username.validate('support'), UsernameProblem.reserved);
    });
  });

  group('text', () {
    test('initials and first names', () {
      expect(initialsOf('Nour Haddad'), 'NH');
      expect(initialsOf('  sami  '), 'S');
      expect(firstNameOf('Nour Haddad'), 'Nour');
    });

    test('links get a scheme and must look like an address', () {
      expect(
        parseLink('instagram.com/nour')?.toString(),
        'https://instagram.com/nour',
      );
      expect(parseLink('http://example.com')?.scheme, 'http');
      expect(parseLink('not a link'), isNull);
      expect(parseLink('ftp://example.com'), isNull);
      expect(
        displayLink(Uri.parse('https://www.example.com/me/')),
        'example.com/me',
      );
    });

    test('phone numbers need at least 7 digits and nothing else', () {
      expect(isPhoneNumber('70 123 456'), isTrue);
      expect(isPhoneNumber('3123456'), isTrue);
      expect(isPhoneNumber('+961 70-123-456'), isTrue);
      expect(isPhoneNumber('12'), isFalse);
      expect(isPhoneNumber('my number'), isFalse);
      expect(isPhoneNumber('70 123 456 call me'), isFalse);
    });

    test('user text keeps its own direction', () {
      expect(textDirectionOf('Love your drawings!'), TextDirection.ltr);
      expect(textDirectionOf('شكراً كتير!'), TextDirection.rtl);
      // Leading digits and punctuation do not decide.
      expect(textDirectionOf('3 فناجين'), TextDirection.rtl);
      expect(textDirectionOf(''), TextDirection.ltr);
    });
  });

  test('links are recognized by their site', () {
    expect(LinkKind.guess('instagram.com/nour.draws'), LinkKind.instagram);
    expect(LinkKind.guess('https://youtu.be/abc'), LinkKind.youtube);
    expect(LinkKind.guess('twitter.com/nour'), LinkKind.x);
    expect(LinkKind.guess('nour.art'), LinkKind.website);
    expect(SocialLink.fromMap({'kind': 'tiktok', 'url': 'nope'}), isNull);
  });

  group('ThousandsFormatter', () {
    String typed(String text, {int? cursor}) {
      return const ThousandsFormatter()
          .formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: cursor ?? text.length),
            ),
          )
          .text;
    }

    test('marks thousands as they are typed', () {
      expect(typed('100000'), '100,000');
      expect(typed('1,0000'), '10,000');
      expect(typed('999'), '999');
      expect(typed('1234567'), '1,234,567');
    });

    test('keeps only digits, and reads Arabic ones', () {
      expect(typed('12a3'), '123');
      expect(typed('١٢٣٤'), '1,234');
      expect(typed('007'), '7');
      expect(typed('0'), '0');
      expect(typed(''), '');
    });

    test('keeps the cursor after the same digits', () {
      final value = const ThousandsFormatter().formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '10000',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      expect(value.text, '10,000');
      expect(value.selection.baseOffset, 4);
    });

    test('what it writes is read back as the amount', () {
      expect(parseAmount(typed('100000')), 100000);
      expect(groupDigits(5000000), '5,000,000');
    });
  });
}

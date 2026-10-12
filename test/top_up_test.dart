import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/top_up_destination.dart';
import 'package:kahwa/models/top_up_request.dart';
import 'package:kahwa/models/withdraw.dart';

void main() {
  group('TopUpRequest', () {
    test('reference codes are six characters that are easy to read', () {
      final random = Random(1);

      for (var i = 0; i < 50; i++) {
        final code = TopUpRequest.newReference(random);

        expect(code, hasLength(6));
        expect(code, matches(RegExp(r'^[A-HJ-NP-Z2-9]+$')));
      }
    });

    test('is always saved as pending', () {
      const request = TopUpRequest(
        userId: 'u1',
        amount: 50000,
        currency: Currency.lbp,
        reference: 'ABC234',
        senderPhone: '70123456',
        status: TopUpStatus.approved,
      );

      final map = request.toMap();

      expect(map['status'], 'pending');
      expect(map['amount'], 50000);
      expect(map['currency'], 'lbp');
      expect(map['reference'], 'ABC234');
    });

    test('reads the decision of the admin', () {
      final request = TopUpRequest.fromMap({
        'user_id': 'u1',
        'amount': 10,
        'currency': 'usd',
        'reference': 'ABC234',
        'sender_phone': '70123456',
        'status': 'rejected',
      });

      expect(request.status, TopUpStatus.rejected);
      expect(request.currency, Currency.usd);
    });

    test('reads when the admin answered', () {
      final answered = DateTime(2026, 10, 10, 9);
      final request = TopUpRequest.fromMap({
        'status': 'approved',
        'resolved_at': Timestamp.fromDate(answered),
      });

      expect(request.resolvedAt, answered);
    });

    group('the answer of the admin', () {
      final answered = DateTime(2026, 10, 10, 9);

      TopUpRequest request(
        TopUpStatus status, {
        DateTime? timestamp,
        DateTime? resolvedAt,
      }) {
        return TopUpRequest(
          userId: 'u1',
          amount: 10,
          currency: Currency.usd,
          reference: 'ABC234',
          senderPhone: '70123456',
          status: status,
          timestamp: timestamp,
          resolvedAt: resolvedAt,
        );
      }

      test('is shown for three days', () {
        for (final status in [TopUpStatus.approved, TopUpStatus.rejected]) {
          final answer = request(status, resolvedAt: answered);

          expect(answer.hasRecentResult(answered), isTrue);
          expect(
            answer.hasRecentResult(answered.add(const Duration(days: 2))),
            isTrue,
          );
          expect(
            answer.hasRecentResult(answered.add(const Duration(days: 3))),
            isFalse,
          );
        }
      });

      test('counts from the answer, not from the request', () {
        final answer = request(
          TopUpStatus.approved,
          timestamp: answered.subtract(const Duration(days: 10)),
          resolvedAt: answered,
        );

        expect(answer.hasRecentResult(answered), isTrue);
      });

      test('falls back to the day of the request', () {
        final old = request(TopUpStatus.approved, timestamp: answered);

        expect(old.hasRecentResult(answered), isTrue);
        expect(
          old.hasRecentResult(answered.add(const Duration(days: 4))),
          isFalse,
        );
        expect(request(TopUpStatus.approved).hasRecentResult(answered), isTrue);
      });

      test('does not exist while the request is pending', () {
        final pending = request(TopUpStatus.pending, timestamp: answered);

        expect(pending.hasRecentResult(answered), isFalse);
      });
    });
  });

  group('TopUpDestination', () {
    test('is not set until an admin fills it in', () {
      expect(TopUpDestination.fromMap({}).isSet, isFalse);
      expect(TopUpDestination.fromMap({'whish_qr_usd': ' '}).isSet, isFalse);
    });

    test('never falls back to a phone number', () {
      final destination = TopUpDestination.fromMap({
        'whish_number': '+961 70 123 456',
      });

      expect(destination.isSet, isFalse);
    });

    test('reads the text inside the Whish Me code of each currency', () {
      final destination = TopUpDestination.fromMap({
        'whish_qr_lbp': ' https://whish.money/pay/lbp123 ',
        'whish_qr_usd': 'https://whish.money/pay/usd123',
      });

      expect(destination.isSet, isTrue);
      expect(destination.currencies, [Currency.lbp, Currency.usd]);
      expect(
        destination.whishQr[Currency.lbp],
        'https://whish.money/pay/lbp123',
      );
      expect(
        destination.whishQr[Currency.usd],
        'https://whish.money/pay/usd123',
      );
    });

    test('only offers the currencies that have a code', () {
      final destination = TopUpDestination.fromMap({
        'whish_qr_usd': 'https://whish.money/pay/usd123',
      });

      expect(destination.currencies, [Currency.usd]);
      expect(destination.appLink(Currency.lbp), isNull);
    });

    test('builds the link that opens the payment in the WHISH app', () {
      const destination = TopUpDestination(
        whishQr: {
          Currency.lbp: 'https://whish.money/pay/lbp123',
          Currency.usd: 'https://whish.money/pay/usd123',
        },
      );

      expect(
        destination.appLink(Currency.lbp).toString(),
        'https://whish.money/app/pay/lbp123',
      );
      expect(
        destination.appLink(Currency.usd).toString(),
        'https://whish.money/app/pay/usd123',
      );
    });

    test('has no app link when the code is not a WHISH pay link', () {
      const destination = TopUpDestination(
        whishQr: {
          Currency.lbp: 'https://example.com/pay/abc',
          Currency.usd: 'https://whish.money/pay/abc/extra',
        },
      );
      const text = TopUpDestination(whishQr: {Currency.usd: 'some text'});

      expect(destination.appLink(Currency.lbp), isNull);
      expect(destination.appLink(Currency.usd), isNull);
      expect(text.appLink(Currency.usd), isNull);
    });
  });

  group('Withdraw', () {
    test('starts as pending', () {
      const withdraw = Withdraw(userId: 'u1', lbp: 2000, usd: 0);

      expect(withdraw.toMap()['status'], 'pending');
    });

    test('knows when it was paid', () {
      final pending = Withdraw.fromMap({
        'user_id': 'u1',
        'lbp': 2000,
      }, id: 'w1');
      final paid = Withdraw.fromMap({
        'user_id': 'u1',
        'lbp': 2000,
        'status': 'paid',
      });

      expect(pending.id, 'w1');
      expect(pending.isPaid, isFalse);
      expect(paid.isPaid, isTrue);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/ui/widgets.dart';

void main() {
  group('Routes', () {
    test('a page lives at its username, or its id', () {
      expect(Routes.page(const Profile(id: 'x1', name: 'N')), '/c/x1');
      expect(
        Routes.page(const Profile(id: 'x1', name: 'N', username: 'nour')),
        '/nour',
      );
    });

    test('buying stays under the address of the page', () {
      expect(Routes.support('x1'), '/c/x1/support');
      expect(Routes.support('x1', username: 'nour'), '/nour/support');
      expect(
        Routes.support('x1', username: 'nour', tier: 't1'),
        '/nour/support?tier=t1',
      );
      expect(
        Routes.support('x1', kahwas: 3, currency: Currency.usd),
        '/c/x1/support?kahwas=3&currency=usd',
      );
    });

    test('top up and sign in keep where to go next', () {
      expect(
        Routes.topUp(amount: 50000, currency: Currency.lbp),
        '/wallet/top-up?amount=50000&currency=lbp',
      );
      expect(
        Routes.signInThen('/nour/support?tier=t1'),
        '/sign-in?from=%2Fnour%2Fsupport%3Ftier%3Dt1',
      );
    });
  });

  testWidgets('PageFrame in a bottom bar leaves room for the page', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('body')),
          bottomNavigationBar: PageFrame(
            padding: EdgeInsets.all(8),
            child: SizedBox(height: 40),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(PageFrame)).height, 56);
    expect(find.text('body'), findsOneWidget);
  });
}

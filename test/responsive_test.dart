import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/core/responsive.dart';
import 'package:kahwa/widgets/auth_layout.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/page_body.dart';

/// Window sizes the app has to work on, from a small phone to a desktop.
const _sizes = {
  'small phone': Size(320, 568),
  'phone': Size(390, 844),
  'phone landscape': Size(844, 390),
  'tablet': Size(820, 1180),
  'desktop': Size(1440, 900),
};

Future<void> _pump(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: child));
}

void main() {
  group('AuthLayout', () {
    const layout = AuthLayout(
      title: 'Log In',
      illustration: 'assets/undraw_login.svg',
      children: [
        InputText(hint: 'Email Address', icon: Icons.mail_rounded),
        SizedBox(height: 16),
        InputText(hint: 'Password', icon: Icons.lock_rounded),
      ],
    );

    for (final MapEntry(key: name, value: size) in _sizes.entries) {
      testWidgets('fits a $name without overflowing', (tester) async {
        await _pump(tester, size, layout);

        expect(tester.takeException(), isNull);
        expect(find.text('Log In'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2));
      });
    }

    testWidgets('shows the brand panel only on wide windows', (tester) async {
      await _pump(tester, _sizes['desktop']!, layout);
      expect(find.text('kahwa'), findsOneWidget);

      await _pump(tester, _sizes['phone']!, layout);
      expect(find.text('kahwa'), findsNothing);
    });
  });

  group('PageBody', () {
    testWidgets('fills the width on phones', (tester) async {
      await _pump(
        tester,
        _sizes['phone']!,
        const Scaffold(body: PageBody(child: Placeholder())),
      );

      final width = tester.getSize(find.byType(Placeholder)).width;
      expect(width, 390 - 24 * 2);
    });

    testWidgets('stops growing and stays centered on desktops', (tester) async {
      await _pump(
        tester,
        _sizes['desktop']!,
        const Scaffold(body: PageBody(child: Placeholder())),
      );

      final rect = tester.getRect(find.byType(Placeholder));
      expect(rect.width, ContentWidth.form - 32 * 2);
      expect(rect.center.dx, 1440 / 2);
    });
  });
}

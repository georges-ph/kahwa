import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/widgets/page_body.dart';

void main() {
  group('PageBody pull to refresh', () {
    /// Pumps a phone sized page with very little on it, like the home screen
    /// of someone who is not a fan of anyone yet.
    Future<void> pumpShortPage(
      WidgetTester tester,
      Future<void> Function() onRefresh,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(),
            body: PageBody(
              onRefresh: onRefresh,
              child: const SizedBox(height: 120, child: Text('Almost empty')),
            ),
          ),
        ),
      );
    }

    Future<void> pullDownFrom(WidgetTester tester, Offset start) async {
      await tester.flingFrom(start, const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('works when pulling on the content', (tester) async {
      var refreshed = 0;
      await pumpShortPage(tester, () async => refreshed++);

      await pullDownFrom(tester, const Offset(195, 120));

      expect(refreshed, 1);
    });

    testWidgets('works when pulling on the empty space below a short page', (
      tester,
    ) async {
      var refreshed = 0;
      await pumpShortPage(tester, () async => refreshed++);

      await pullDownFrom(tester, const Offset(195, 600));

      expect(refreshed, 1);
    });
  });
}

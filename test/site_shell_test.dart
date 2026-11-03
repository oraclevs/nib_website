import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/site_shell.dart';

void main() {
  testWidgets('desktop ecosystem navigation returns to the homepage', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String? destination;
    await tester.pumpWidget(
      MaterialApp(
        home: SiteShell(
          path: '/examples',
          onNavigate: (path) => destination = path,
          child: const Center(child: Text('Page body')),
        ),
      ),
    );
    await tester.tap(find.text('Ecosystem'));
    expect(destination, '/');
  });

  testWidgets('mobile shell menu reaches the playground', (tester) async {
    tester.view.physicalSize = const Size(390, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String? destination;
    await tester.pumpWidget(
      MaterialApp(
        home: SiteShell(
          path: '/packages',
          onNavigate: (path) => destination = path,
          child: const Center(child: Text('Page body')),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Support Nib'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Payments are coming soon'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Playground'));
    await tester.pumpAndSettle();
    expect(destination, '/playground/spring-retarget');
  });
}

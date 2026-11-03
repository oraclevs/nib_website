import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/pages/docs_spring_reference.dart';

void main() {
  testWidgets('mobile contents follows the learning path and opens a lesson', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String? route;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocsSpringReference(onNavigate: (value) => route = value),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Choose documentation article'));
    await tester.pumpAndSettle();
    expect(find.text('NibMotion learning path'), findsOneWidget);
    expect(find.text('START HERE'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(ListTile, 'Keyframes'));
    await tester.tap(find.widgetWithText(ListTile, 'Keyframes'));
    await tester.pumpAndSettle();
    expect(route, '/docs/motion/keyframes');
    expect(tester.takeException(), isNull);
  });

  for (final width in [360.0, 612.0, 1280.0]) {
    testWidgets('reference springs docs renders at ${width.toInt()} px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DocsSpringReference(onNavigate: (_) {})),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Springs'), findsWidgets);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(DocsSpringReference), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('spring controls switch settings and replay locally', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(612, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DocsSpringReference(onNavigate: (_) {})),
      ),
    );
    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(find.textContaining('DocumentationSpring'), findsWidgets);
    await tester.tap(find.text('Preview'));
    await tester.pump();
    await tester.ensureVisible(find.text('Snappy'));
    await tester.tap(find.text('Snappy'));
    await tester.pump();
    await tester.ensureVisible(find.text('Replay'));
    await tester.pump();
    await tester.tap(find.text('Replay'));
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull);
  });
}

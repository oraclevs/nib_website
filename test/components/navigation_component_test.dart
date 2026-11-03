import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_components/nib_components.dart';
import 'package:nib_ember_living/components/component_settings.dart';
import 'package:nib_ember_living/components/component_theme.dart';
import 'package:nib_ember_living/components/examples/navigation_component_demo.dart';

void main() {
  testWidgets('selection updates local content and real callback', (
    tester,
  ) async {
    final events = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: componentEmberTheme(),
        home: Scaffold(
          body: NavigationComponentDemo(
            settings: const ComponentSettings(text: 'Overview'),
            onChanged: (_) {},
            onEvent: events.add,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Workspace settings'), findsOneWidget);
    expect(events.last, 'onItemSelected: settings');
    final menu = tester.widget<NibNavigationMenu>(
      find.byType(NibNavigationMenu),
    );
    expect(menu.activeItemId, 'settings');
    final theme = NibTheme.of(tester.element(find.byType(NibNavigationMenu)));
    expect(theme.primary, const Color(0xFFFFB51B));
    expect(theme.background, const Color(0xFF111210));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'vertical controller opens children and disabled leaf stays inert',
    (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: componentEmberTheme(),
          home: Scaffold(
            body: NavigationComponentDemo(
              settings: const ComponentSettings(
                text: 'Overview',
                vertical: true,
                disabled: true,
              ),
              onChanged: (_) {},
              onEvent: events.add,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Toggle Reports from controller'));
      await tester.pumpAndSettle();
      expect(find.text('Monthly'), findsOneWidget);
      await tester.tap(find.text('Monthly'));
      await tester.pump();
      expect(events.where((e) => e == 'onItemSelected: monthly'), isEmpty);
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();
      expect(find.text('This week'), findsOneWidget);
      expect(events.last, 'onItemSelected: weekly');
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('navigation is bounded at $width with larger text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: componentEmberTheme(),
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 1100),
                textScaler: const TextScaler.linear(1.5),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: NavigationComponentDemo(
                    settings: const ComponentSettings(
                      text: 'A long workspace overview label',
                    ),
                    onChanged: (_) {},
                    onEvent: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Workspace overview'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

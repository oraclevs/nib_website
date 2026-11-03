import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_pages.dart';
import 'package:nib_ember_living/components/component_theme.dart';
import 'package:nib_ember_living/search/site_search_data.dart';
import 'package:nib_ember_living/site_navigation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'exact symbols are discoverable and textarea keeps its family route',
    () {
      final search = buildSiteSearchIndex();
      for (final guide in componentGuides) {
        for (final symbol in guide.symbols) {
          expect(
            search.search(symbol).map((entry) => entry.route),
            contains(guide.route),
          );
        }
      }
      expect(componentById('textarea'), same(componentById('input')));
    },
  );
  for (final id in ['liquid-glass', 'navigation-menu', 'input']) {
    testWidgets('$id discovery opens playground and copies its actual runtime', (
      tester,
    ) async {
      tester.view.resetPhysicalSize();
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final guide = componentById(id)!;
      await tester.runAsync(() async {
        for (final path in [
          'lib/components/component_settings.dart',
          'lib/components/component_theme.dart',
          'lib/ember_material_theme.dart',
          guide.demoFile,
        ]) {
          await rootBundle.loadString(path);
        }
      });
      String? route;
      await tester.pumpWidget(
        MaterialApp(
          theme: componentEmberTheme(),
          home: Scaffold(
            body: ComponentExplorerPage(onNavigate: (value) => route = value),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField).first, guide.symbols.first);
      await tester.pumpAndSettle();
      final open = find.byKey(ValueKey('component-card-${guide.id}'));
      await tester.ensureVisible(open);
      await tester.pumpAndSettle();
      await tester.tap(open);
      expect(route, guide.playgroundRoute);
      await tester.pumpWidget(
        MaterialApp(
          theme: componentEmberTheme(),
          home: Scaffold(
            body: ComponentGuidePage(
              guide: guide,
              onNavigate: (_) {},
              playground: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(guide.summary), findsOneWidget);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final copy = find.text('Copy code');
      await tester.ensureVisible(copy);
      await tester.pumpAndSettle();
      await tester.tap(copy);
      await tester.pumpAndSettle();
      // Asset bundle reads use real I/O; allow them to complete, then flush
      // callbacks in the widget test's fake clock before inspecting clipboard.
      for (var attempt = 0; copied == null && attempt < 100; attempt++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(
        copied,
        contains(
          id == 'liquid-glass' ? 'class WaterExample' : 'class ShortExample',
        ),
      );
      expect(copied, contains('void main()'));
      expect(copied, isNot(contains("import '../")));
      copied = null;
      final full = find.byKey(const ValueKey('component-code-full'));
      await tester.ensureVisible(full);
      await tester.pumpAndSettle();
      await tester.tap(full);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('component-copy-code')));
      for (var attempt = 0; copied == null && attempt < 100; attempt++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      expect(copied, contains('class ${guide.demoClass}'));
      expect(copied, contains('void main()'));
      copied = null;
      final source = find.byKey(const ValueKey('component-code-source'));
      await tester.ensureVisible(source);
      await tester.pumpAndSettle();
      await tester.tap(source);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('component-copy-code')));
      for (var attempt = 0; copied == null && attempt < 100; attempt++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      expect(copied, contains('class ${guide.demoClass}'));
      expect(copied, isNot(contains('void main()')));
      expect(tester.takeException(), isNull);
    });
  }
  for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('registered guides and site navigation at $width / 1.5 text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final guide in componentGuides) {
        await tester.pumpWidget(
          MaterialApp(
            theme: componentEmberTheme(),
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 1000),
                textScaler: const TextScaler.linear(1.5),
              ),
              child: Scaffold(
                body: Column(
                  children: [
                    SiteNavigation(
                      path: guide.route,
                      onNavigate: (_) {},
                      onSearch: () {},
                      onSupport: () {},
                    ),
                    Expanded(
                      child: ComponentGuidePage(
                        guide: guide,
                        onNavigate: (_) {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull, reason: guide.id);
      }
    });
  }
}

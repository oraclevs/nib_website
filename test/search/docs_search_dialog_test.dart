import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/search/docs_search_dialog.dart';
import 'package:nib_ember_living/search/site_search_index.dart';
import 'package:nib_ember_living/pages/docs_page.dart';
import 'package:nib_ember_living/site_shell.dart';

void main() {
  const sample = SiteSearchIndex([
    SiteSearchEntry(
      title: 'Spring basics',
      summary: 'Read the guide.',
      route: '/docs/motion/springs',
      kind: SiteSearchKind.guide,
    ),
    SiteSearchEntry(
      title: 'Spring retarget',
      summary: 'Try the recipe.',
      route: '/playground/spring-retarget',
      kind: SiteSearchKind.recipe,
    ),
  ]);

  testWidgets('dialog query, arrow selection and Enter open a real result', (
    tester,
  ) async {
    String? destination;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                destination = await showDocsSearchDialog(
                  context,
                  index: sample,
                );
              },
              child: const Text('Open search'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'spring');
    await tester.pump();
    expect(find.text('Spring basics'), findsOneWidget);
    expect(find.text('Spring retarget'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(destination, '/playground/spring-retarget');
    expect(find.byType(DocsSearchDialog), findsNothing);
  });

  testWidgets('Escape closes the dialog without navigation', (tester) async {
    String? destination;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                destination = await showDocsSearchDialog(
                  context,
                  index: sample,
                );
              },
              child: const Text('Open search'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(destination, isNull);
    expect(find.byType(DocsSearchDialog), findsNothing);
  });

  testWidgets('docs header follows reference breakpoints and shares scroll', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    for (final width in [360.0, 612.0, 850.0, 1024.0, 1280.0]) {
      tester.view.physicalSize = Size(width, 844);
      await tester.pumpWidget(
        MaterialApp(
          home: SiteShell(
            path: '/docs/motion/springs',
            onNavigate: (_) {},
            child: const SizedBox(
              height: 1600,
              child: Align(
                alignment: Alignment.topLeft,
                child: Text('DOC BODY'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final mobile = width <= 1024;
      expect(find.textContaining('DARK-ONLY DESIGN REVIEW'), findsNothing);
      expect(
        tester.getSize(find.byKey(const ValueKey('site-navigation'))).height,
        mobile ? 68 : 84,
      );
      expect(tester.getTopLeft(find.text('DOC BODY')).dy, mobile ? 68 : 84);
      expect(
        tester.getSize(find.byKey(const ValueKey('site-search-button'))).width,
        width <= 850
            ? 40
            : width <= 1199
            ? 170
            : 190,
      );
      expect(
        find.byKey(const ValueKey('site-active-underline')),
        mobile ? findsNothing : findsOneWidget,
      );
      if (!mobile) {
        expect(
          tester
              .getBottomLeft(
                find.byKey(const ValueKey('site-active-underline')),
              )
              .dy,
          tester
                  .getBottomLeft(find.byKey(const ValueKey('site-navigation')))
                  .dy -
              1,
        );
      }
      expect(tester.takeException(), isNull, reason: 'header width $width');
    }
  });

  testWidgets(
    'docs article inherits its controller while navigation stays fixed',
    (tester) async {
      tester.view.physicalSize = const Size(612, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      ScrollController? inherited;
      await tester.pumpWidget(
        MaterialApp(
          home: SiteShell(
            path: '/docs/motion/springs',
            onNavigate: (_) {},
            child: Builder(
              builder: (context) {
                inherited = PrimaryScrollController.of(context);
                return SingleChildScrollView(
                  controller: inherited,
                  child: const SizedBox(height: 1800, child: Text('DOC BODY')),
                );
              },
            ),
          ),
        ),
      );
      expect(inherited, isNotNull);
      final progress = find.byKey(const ValueKey('docs-reading-progress'));
      expect(tester.getSize(progress).width, 0);
      expect(tester.getTopLeft(progress).dy, 0);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -420),
      );
      await tester.pumpAndSettle();
      expect(inherited!.position.pixels, greaterThan(0));
      expect(tester.getSize(progress).width, greaterThan(0));
      expect(tester.getTopLeft(progress).dy, 0);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('site-navigation'))).dy,
        0,
      );
    },
  );

  testWidgets('real docs article uses one scroll position', (tester) async {
    tester.view.physicalSize = const Size(1280, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: SiteShell(
          path: '/docs/motion/springs',
          onNavigate: (_) {},
          child: DocsPage(
            packageId: 'motion',
            sectionId: 'springs',
            onNavigate: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    final articleFinder = find.byKey(const ValueKey('docs-article-scroll'));
    final outerScroll = tester.widget<SingleChildScrollView>(articleFinder);
    expect(outerScroll.controller, isNotNull);
    expect(outerScroll.controller!.positions.length, 1);
    expect(tester.takeException(), isNull);
    await tester.drag(articleFinder, const Offset(0, -300));
    await tester.pump();
    expect(outerScroll.controller!.offset, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shared mobile navigation opens routes and search', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    String? destination;
    await tester.pumpWidget(
      MaterialApp(
        home: SiteShell(
          path: '/packages',
          onNavigate: (route) => destination = route,
          child: const SizedBox(height: 100),
        ),
      ),
    );
    expect(find.textContaining('DARK-ONLY DESIGN REVIEW'), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('site-navigation'))).width,
      345,
    );
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pump();
    expect(find.text('Docs'), findsOneWidget);
    await tester.tap(find.text('Docs'));
    await tester.pump();
    expect(destination, '/docs/motion/springs');
    expect(find.text('Docs'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('site-search-button')));
    await tester.pumpAndSettle();
    expect(find.byType(DocsSearchDialog), findsOneWidget);
  });

  testWidgets('Ctrl K opens docs search from the shared header', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: SiteShell(
          path: '/docs/motion/springs',
          onNavigate: (_) {},
          child: const SizedBox(height: 800, child: Text('DOC BODY')),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byType(DocsSearchDialog), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(find.byType(DocsSearchDialog), findsOneWidget);
  });

  testWidgets('keyboard selection scrolls long search results into view', (
    tester,
  ) async {
    final many = SiteSearchIndex([
      for (var i = 0; i < 15; i++)
        SiteSearchEntry(
          title: 'Guide $i',
          summary: 'Guide summary',
          route: '/docs/motion/guide-$i',
          kind: SiteSearchKind.guide,
        ),
    ]);
    String? destination;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => destination = await showDocsSearchDialog(
                context,
                index: many,
              ),
              child: const Text('Open search'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 9; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('Guide 9'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(destination, '/docs/motion/guide-9');
  });
}

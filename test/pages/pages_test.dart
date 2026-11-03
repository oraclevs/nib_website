import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nib_ember_living/content/site_content.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_support_guides.dart';
import 'package:nib_ember_living/pages/docs_page.dart';
import 'package:nib_ember_living/pages/package_pages.dart';

void main() {
  test(
    'content inventory has unique, valid routes and honest install status',
    () {
      final packageIds = SiteContent.packages.map((item) => item.id).toList();
      expect(packageIds.toSet().length, packageIds.length);
      expect(packageIds, containsAll(['motion', 'components', 'genui']));

      final routes = SiteContent.articles
          .map((article) => article.route)
          .toList();
      expect(
        routes,
        containsAll([
          '/docs/motion/introduction',
          '/docs/motion/first-animation',
          '/docs/components/getting-started',
          '/docs/components/forms',
          '/docs/genui/protocol-scope',
          ...componentGuides.map((guide) => guide.route),
          ...componentSupportArticles.map((article) => article.route),
        ]),
      );
      expect(routes.toSet().length, routes.length);
      for (final article in SiteContent.articles) {
        expect(packageIds, contains(article.packageId));
        expect(article.sections, isNotEmpty);
        expect(article.evidence, isNotEmpty);
        expect(article.route, '/docs/${article.packageId}/${article.id}');
      }
      expect(SiteContent.packageById('genui')!.install, isNull);
      expect(SiteContent.articleById('genui', 'protocol-scope'), isNotNull);
      expect(SiteContent.articleById('unknown', 'getting-started'), isNull);
    },
  );

  testWidgets('package overview opens the selected package', (tester) async {
    String? selected;
    await _setViewport(tester, const Size(1440, 900));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PackagesPage(onOpenPackage: (id) => selected = id),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('NibMotion').first);
    await tester.pump();
    expect(selected, 'motion');
  });

  testWidgets('package detail links into its guide', (tester) async {
    String? section;
    await _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PackageDetailPage(
            packageId: 'genui',
            onOpenDoc: (id) => section = id,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      find.text('Public installation is not available yet.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Read the guide'));
    await tester.pump();
    expect(section, 'getting-started');
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop docs navigate through shared inventory', (tester) async {
    String? route;
    await _setViewport(tester, const Size(1440, 900));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocsPage(
            packageId: 'motion',
            sectionId: 'getting-started',
            onNavigate: (path) => route = path,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Start with motion'), findsWidgets);
    await tester.tap(find.text('Springs').first);
    await tester.pump();
    expect(route, '/docs/motion/springs');
  });

  testWidgets('mobile docs remain usable at narrow width', (tester) async {
    await _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocsPage(
            packageId: 'components',
            sectionId: 'forms',
            onNavigate: (_) {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Forms and state'), findsWidgets);
    expect(find.byTooltip('Choose documentation article'), findsOneWidget);
  });

  testWidgets('package and docs bodies fit 360, 768 and 1024 widths', (
    tester,
  ) async {
    for (final width in <double>[360, 768, 1024]) {
      await _setViewport(tester, Size(width, 820));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PackagesPage(onOpenPackage: (_) {})),
        ),
      );
      expect(tester.takeException(), isNull, reason: 'packages at $width');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PackageDetailPage(packageId: 'motion', onOpenDoc: (_) {}),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: 'detail at $width');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocsPage(
              packageId: 'genui',
              sectionId: 'protocol-scope',
              onNavigate: (_) {},
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: 'docs at $width');
    }
  });
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

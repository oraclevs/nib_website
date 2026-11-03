import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/content/site_content.dart';
import 'package:nib_ember_living/pages/doc_blocks.dart';
import 'package:nib_ember_living/pages/docs_spring_reference.dart';
import 'package:nib_ember_living/site_router.dart';

import '../support/file_asset_bundle.dart';

void main() {
  testWidgets(
    'typed fixture renders nested list table and actionable link in body',
    (tester) async {
      String? route;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocBlocks(
              blocks: const [
                DocList([
                  DocListItem(
                    'Parent observation',
                    children: [DocListItem('Nested velocity observation')],
                  ),
                ], ordered: true),
                DocTable(
                  headers: ['Coefficient', 'Measured setting'],
                  rows: [
                    ['Damping', '18'],
                  ],
                ),
                DocLink(
                  'Read the exact contract',
                  '/docs/motion/springs#completion',
                ),
              ],
              onNavigate: (value) => route = value,
            ),
          ),
        ),
      );
      expect(find.text('Nested velocity observation'), findsOneWidget);
      expect(find.widgetWithText(DataTable, 'Damping'), findsOneWidget);
      await tester.tap(find.text('Read the exact contract'));
      expect(route, '/docs/motion/springs#completion');
    },
  );

  testWidgets(
    'Springs body contains real blocks and headings generate working anchors',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      String? route;
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: FileAssetBundle(),
          child: MaterialApp(
            home: Scaffold(
              body: DocsSpringReference(onNavigate: (value) => route = value),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final article = SiteContent.articleById('motion', 'springs')!;
      expect(find.text('Subtopics'), findsNothing);
      expect(find.text('ON THIS PAGE'), findsOneWidget);
      for (final section in article.sections) {
        expect(find.text(section.heading), findsWidgets);
        for (final paragraph in section.paragraphs) {
          expect(find.textContaining(paragraph), findsOneWidget);
        }
        expect(find.byKey(ValueKey('toc-${section.id}')), findsOneWidget);
      }
      expect(find.textContaining('class SpringLesson'), findsWidgets);
      expect(
        find.textContaining(
          'An animation completing is presentation feedback. Application success must come from application state.',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(DataTable, 'gentle'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('toc-retarget')));
      await tester.pumpAndSettle();
      expect(route, '/docs/motion/springs#retarget');
      final heading = find.text('Retargeting').first;
      expect(tester.getTopLeft(heading).dy, greaterThanOrEqualTo(0));
      expect(tester.getTopLeft(heading).dy, lessThan(250));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'changing package and topic replaces rendered body and breadcrumb',
    (tester) async {
      Future<void> open(String package, String id) async {
        await tester.pumpWidget(
          DefaultAssetBundle(
            bundle: FileAssetBundle(),
            child: MaterialApp(
              home: Scaffold(
                body: DocsSpringReference(
                  packageId: package,
                  sectionId: id,
                  onNavigate: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }

      await open('motion', 'springs');
      expect(
        find.textContaining('A spring follows a destination'),
        findsOneWidget,
      );
      await open('motion', 'keyframes');
      expect(
        find.textContaining('A spring follows a destination'),
        findsNothing,
      );
      expect(find.textContaining('Each tile in this example'), findsOneWidget);
      await open('components', 'forms');
      expect(find.textContaining('Each tile in this example'), findsNothing);
      final form = SiteContent.articleById('components', 'forms')!;
      expect(
        find.textContaining(form.sections.first.paragraphs.first),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  test('route parser preserves heading anchor for refresh and history', () {
    final route = SiteRoute.parse('/docs/motion/springs#completion');
    expect(route.sectionId, 'springs');
    expect(route.path, '/docs/motion/springs#completion');
    expect(
      const SiteRouteParser().restoreRouteInformation(route).uri.fragment,
      'completion',
    );
  });
}

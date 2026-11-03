import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/search/site_search_data.dart';
import 'package:nib_ember_living/content/site_content.dart';
import 'package:nib_ember_living/search/site_search_index.dart';
import 'package:nib_ember_living/search/site_search_page.dart';
import 'package:nib_ember_living/site_router.dart';

void main() {
  const sample = SiteSearchIndex([
    SiteSearchEntry(
      title: 'Spring retarget',
      summary: 'Interrupt an animation.',
      route: '/playground/spring-retarget',
      kind: SiteSearchKind.recipe,
      keywords: ['motion'],
    ),
    SiteSearchEntry(
      title: 'NibMotion',
      summary: 'Flutter animation package with springs.',
      route: '/packages/motion',
      kind: SiteSearchKind.package,
    ),
    SiteSearchEntry(
      title: 'Start with motion',
      summary: 'Read the installation guide.',
      route: '/docs/motion/getting-started',
      kind: SiteSearchKind.guide,
    ),
  ]);

  test('search requires every term and ranks exact titles first', () {
    expect(sample.search('spring retarget').map((entry) => entry.route), [
      '/playground/spring-retarget',
    ]);
    expect(sample.search('spring missing'), isEmpty);
    expect(sample.search('  NIBMOTION  ').first.route, '/packages/motion');
  });

  test('filter narrows results without changing source order', () {
    expect(sample.search('', kind: SiteSearchKind.recipe).length, 1);
    expect(sample.search('', limit: 2).length, 2);
    expect(sample.search('').length, 3);
  });

  test('built index uses current content and verified recipe inventories', () {
    final index = buildSiteSearchIndex();
    final routes = index.entries.map((entry) => entry.route).toList();
    expect(routes, contains('/packages/motion'));
    expect(routes, contains('/packages/components'));
    expect(routes, contains('/packages/genui'));
    expect(routes, contains('/docs/motion/getting-started'));
    expect(routes, contains('/playground/spring-retarget'));
    expect(routes.toSet().length, routes.length);
    expect(
      routes.where(
        (route) => SiteRoute.parse(route).kind == SiteRouteKind.notFound,
      ),
      isEmpty,
    );
    expect(
      index.search('A2UI').map((entry) => entry.route),
      contains('/packages/genui'),
    );
  });

  test(
    'guide search indexes visible body, source, callouts, and API contracts',
    () {
      const article = DocArticle(
        packageId: 'motion',
        id: 'search-fixture',
        title: 'Search fixture',
        summary: 'A fixture with deliberately different fields.',
        evidence: 'test fixture',
        sections: [
          DocSection(
            id: 'body',
            heading: 'Visible heading',
            paragraphs: [
              'Dispose the trajectory observer when the owner leaves.',
            ],
            code: 'final example = NibTransition.springSnappy;',
            note: 'Prefer a static endpoint when motion is reduced.',
            blocks: [
              DocList([
                DocListItem(
                  'Mount the listener',
                  children: [DocListItem('Check nested disposal order')],
                ),
              ]),
              DocTable(
                headers: ['Parameter', 'Meaning'],
                rows: [
                  ['springMass', 'Inertia coefficient'],
                ],
              ),
              DocLink(
                'Read the retargeting walkthrough',
                '/docs/motion/springs',
              ),
            ],
            api: [
              DocApiEntry(
                name: 'diagnosticVelocity',
                type: 'VelocityProbe',
                defaultValue: 'receiverLocal',
                description: 'Reports the current simulation speed.',
              ),
            ],
          ),
        ],
      );
      final index = SiteSearchIndex([articleSearchEntry(article)]);
      for (final query in [
        'trajectory observer',
        'NibTransition springSnappy',
        'static endpoint',
        'diagnosticVelocity',
        'VelocityProbe',
        'receiverLocal',
        'simulation speed',
        'nested disposal order',
        'springMass inertia coefficient',
        'retargeting walkthrough',
      ]) {
        expect(index.search(query).single.route, article.route, reason: query);
      }
      expect(index.search('a nonexistent contract'), isEmpty);
    },
  );

  test('every guide is reachable by its body in the built index', () {
    final index = buildSiteSearchIndex();
    for (final article in SiteContent.articles) {
      final paragraph = article.sections
          .expand((section) => section.paragraphs)
          .first;
      expect(
        index.search(paragraph).map((entry) => entry.route),
        contains(article.route),
        reason: article.route,
      );
    }
  });

  testWidgets('search page filters and opens a result at phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    String? opened;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SiteSearchPage(
            index: sample,
            onNavigate: (path) => opened = path,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'retarget');
    await tester.pump();
    expect(find.text('1 result'), findsOneWidget);
    expect(find.text('Spring retarget'), findsOneWidget);
    await tester.ensureVisible(find.text('Spring retarget'));
    await tester.tap(find.text('Spring retarget'));
    expect(opened, '/playground/spring-retarget');
    expect(tester.takeException(), isNull);
  });
}

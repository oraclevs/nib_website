import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/pages/docs_page.dart';
import 'package:nib_ember_living/site_shell.dart';
import 'package:nib_ember_living/site_router.dart';

import '../support/file_asset_bundle.dart';

void main() {
  testWidgets(
    'topics and article scroll independently and preserve topic position',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final bundle = FileAssetBundle();
      final router = SiteRouterDelegate(
        pageBuilder: (context, route, navigate) =>
            route.kind == SiteRouteKind.home
            ? const SizedBox.shrink()
            : SiteShell(
                path: route.path,
                onNavigate: navigate,
                child: DocsPage(
                  packageId: route.packageId!,
                  sectionId: route.sectionId!,
                  onNavigate: navigate,
                ),
              ),
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: bundle,
          child: MaterialApp.router(
            routerDelegate: router,
            routeInformationParser: const SiteRouteParser(),
          ),
        ),
      );
      router.go('/docs/motion/keyframes');
      await tester.pumpAndSettle();
      final topicsFinder = find.byKey(const ValueKey('docs-topics-scroll'));
      final articleFinder = find.byKey(const ValueKey('docs-article-scroll'));
      final topics = tester
          .widget<SingleChildScrollView>(topicsFinder)
          .controller!;
      final article = tester
          .widget<SingleChildScrollView>(articleFinder)
          .controller!;
      final sidebarTop = tester.getTopLeft(topicsFinder).dy;
      expect(topics.positions, hasLength(1));
      expect(article.positions, hasLength(1));
      await tester.drag(topicsFinder, const Offset(0, -360));
      await tester.pumpAndSettle();
      expect(topics.offset, greaterThan(100));
      expect(article.offset, 0);
      final topicOffset = topics.offset;
      await tester.drag(articleFinder, const Offset(0, -450));
      await tester.pumpAndSettle();
      expect(article.offset, greaterThan(100));
      expect(topics.offset, closeTo(topicOffset, .01));
      expect(tester.getTopLeft(topicsFinder).dy, sidebarTop);
      router.go('/docs/motion/controllers');
      await tester.pumpAndSettle();
      expect(article.offset, 0);
      expect(topics.offset, closeTo(topicOffset, .01));
      expect(tester.takeException(), isNull);
    },
  );
}

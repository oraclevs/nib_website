import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/site_router.dart';

void main() {
  test('public site paths parse to the intended screens', () {
    expect(SiteRoute.parse('/').kind, SiteRouteKind.home);
    expect(SiteRoute.parse('/packages').kind, SiteRouteKind.packages);
    expect(SiteRoute.parse('/packages/components').packageId, 'components');
    final docs = SiteRoute.parse('/docs/motion/getting-started');
    expect(docs.kind, SiteRouteKind.docs);
    expect(docs.packageId, 'motion');
    expect(docs.sectionId, 'getting-started');
    expect(SiteRoute.parse('/examples').kind, SiteRouteKind.examples);
    expect(
      SiteRoute.parse('/playground/spring-retarget').recipeId,
      'spring-retarget',
    );
    final shared = SiteRoute.parse('/playground/spring-retarget?value=120');
    expect(shared.recipeId, 'spring-retarget');
    expect(shared.path, '/playground/spring-retarget?value=120');
    expect(SiteRoute.parse('/search').kind, SiteRouteKind.search);
    expect(SiteRoute.parse('/anything-else').kind, SiteRouteKind.notFound);
    expect(SiteRoute.parse('/packages/unknown').kind, SiteRouteKind.notFound);
    expect(
      SiteRoute.parse('/docs/unknown/getting-started').kind,
      SiteRouteKind.notFound,
    );
  });

  testWidgets('site router changes screens and returns to the home screen', (
    tester,
  ) async {
    final delegate = SiteRouterDelegate(
      pageBuilder: (context, route, navigate) => Scaffold(
        body: Column(
          children: [
            Text(route.path),
            TextButton(
              onPressed: () => navigate('/examples'),
              child: const Text('Open examples'),
            ),
          ],
        ),
      ),
    );
    addTearDown(delegate.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: const SiteRouteParser(),
      ),
    );
    await tester.tap(find.text('Open examples').last);
    await tester.pumpAndSettle();
    expect(delegate.currentConfiguration.path, '/examples');
    expect(find.text('/examples'), findsOneWidget);

    expect(await delegate.popRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(delegate.currentConfiguration.path, '/');
    expect(find.text('/examples'), findsNothing);
  });

  testWidgets('a direct docs URL opens the docs screen', (tester) async {
    final delegate = SiteRouterDelegate(
      pageBuilder: (context, route, navigate) =>
          Scaffold(body: Text('Screen: ${route.path}')),
    );
    addTearDown(delegate.dispose);
    final provider = PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(
        uri: Uri.parse('/docs/motion/getting-started'),
      ),
    );
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationProvider: provider,
        routeInformationParser: const SiteRouteParser(),
        routerDelegate: delegate,
      ),
    );
    await tester.pump();
    expect(delegate.currentConfiguration.kind, SiteRouteKind.docs);
    expect(find.text('Screen: /docs/motion/getting-started'), findsOneWidget);
  });
}

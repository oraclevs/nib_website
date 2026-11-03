import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The public locations supported by the website. Unknown locations are kept
/// intact so a useful not-found screen can show the requested address.
@immutable
class SiteRoute {
  const SiteRoute(
    this.path,
    this.kind, {
    this.packageId,
    this.sectionId,
    this.recipeId,
  });

  final String path;
  final SiteRouteKind kind;
  final String? packageId;
  final String? sectionId;
  final String? recipeId;

  static SiteRoute parse(String location) {
    final uri = Uri.tryParse(location);
    final pathname = uri?.path.isNotEmpty == true ? uri!.path : '/';
    final path = Uri(
      path: pathname,
      query: uri?.hasQuery == true ? uri!.query : null,
      fragment: uri?.hasFragment == true ? uri!.fragment : null,
    ).toString();
    final parts = Uri.parse(pathname).pathSegments
        .where((part) => part.isNotEmpty)
        .toList();
    const packages = {'motion', 'components', 'genui'};
    if (parts.isEmpty) return const SiteRoute('/', SiteRouteKind.home);
    if (parts.length == 1) {
      switch (parts.first) {
        case 'packages':
          return const SiteRoute('/packages', SiteRouteKind.packages);
        case 'components':
          return const SiteRoute('/components', SiteRouteKind.components);
        case 'examples':
          return const SiteRoute('/examples', SiteRouteKind.examples);
        case 'search':
          return const SiteRoute('/search', SiteRouteKind.search);
      }
    }
    if (parts.length == 2 &&
        parts.first == 'packages' &&
        packages.contains(parts[1])) {
      return SiteRoute(path, SiteRouteKind.packageDetail, packageId: parts[1]);
    }
    if (parts.length == 3 &&
        parts.first == 'playground' &&
        parts[1] == 'components') {
      return SiteRoute(
        path,
        SiteRouteKind.playground,
        packageId: 'components',
        recipeId: parts[2],
      );
    }
    if (parts.length == 2 && parts.first == 'playground') {
      return SiteRoute(path, SiteRouteKind.playground, recipeId: parts[1]);
    }
    if (parts.length == 3 &&
        parts.first == 'docs' &&
        packages.contains(parts[1])) {
      return SiteRoute(
        path,
        SiteRouteKind.docs,
        packageId: parts[1],
        sectionId: parts[2],
      );
    }
    return SiteRoute(path, SiteRouteKind.notFound);
  }
}

enum SiteRouteKind {
  home,
  packages,
  packageDetail,
  components,
  docs,
  examples,
  playground,
  search,
  notFound,
}

class SiteRouteParser extends RouteInformationParser<SiteRoute> {
  const SiteRouteParser();

  @override
  Future<SiteRoute> parseRouteInformation(RouteInformation routeInformation) =>
      SynchronousFuture(SiteRoute.parse(routeInformation.uri.toString()));

  @override
  RouteInformation restoreRouteInformation(SiteRoute configuration) =>
      RouteInformation(uri: Uri.parse(configuration.path));
}

typedef SitePageBuilder = Widget Function(
  BuildContext context,
  SiteRoute route,
  ValueChanged<String> navigate,
);

/// A small Router 2.0 delegate gives page links real browser addresses and
/// lets browser back/forward restore the selected screen.
class SiteRouterDelegate extends RouterDelegate<SiteRoute>
    with PopNavigatorRouterDelegateMixin<SiteRoute>, ChangeNotifier {
  SiteRouterDelegate({required this.pageBuilder});

  final SitePageBuilder pageBuilder;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  SiteRoute _route = const SiteRoute('/', SiteRouteKind.home);

  // Lessons share a page so their topic-list scroll position survives routing.
  ValueKey<String> get _pageKey => ValueKey(
    _route.kind == SiteRouteKind.docs
        ? '/docs/${_route.packageId}'
        : _route.path,
  );

  @override
  SiteRoute get currentConfiguration => _route;

  void go(String path) {
    final next = SiteRoute.parse(path);
    if (next.path == _route.path) return;
    _route = next;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(SiteRoute configuration) {
    _route = configuration;
    notifyListeners();
    return SynchronousFuture<void>(null);
  }

  @override
  Future<bool> popRoute() {
    if (_route.kind == SiteRouteKind.home) return SynchronousFuture(false);
    go('/');
    return SynchronousFuture(true);
  }

  @override
  Widget build(BuildContext context) => Navigator(
    key: navigatorKey,
    onDidRemovePage: (page) {
      // A page can also be removed because another URL replaced it. Only a
      // removal of the current page represents an in-app back action.
      if (_route.kind != SiteRouteKind.home && page.key == _pageKey) {
        go('/');
      }
    },
    pages: [
      MaterialPage<void>(
        key: const ValueKey('/'),
        maintainState: false,
        child: pageBuilder(
          context,
          const SiteRoute('/', SiteRouteKind.home),
          go,
        ),
      ),
      if (_route.kind != SiteRouteKind.home)
        MaterialPage<void>(
          key: _pageKey,
          child: pageBuilder(context, _route, go),
        ),
    ],
  );
}

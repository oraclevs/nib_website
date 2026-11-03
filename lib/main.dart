import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'ember_material_theme.dart';
import 'components/component_theme.dart';
import 'components/component_catalog.dart';
import 'components/component_pages.dart';
import 'home.dart';
import 'recipes/recipe_favorites.dart';
import 'pages/docs_page.dart';
import 'pages/package_pages.dart';
import 'playground/examples_page.dart';
import 'playground/playground_page.dart';
import 'search/site_search_page.dart';
import 'site_router.dart';
import 'site_shell.dart';

void main() {
  usePathUrlStrategy();
  runApp(const NibEmberSite());
}

class NibEmberSite extends StatefulWidget {
  const NibEmberSite({super.key});

  @override
  State<NibEmberSite> createState() => _NibEmberSiteState();
}

class _NibEmberSiteState extends State<NibEmberSite> {
  late final SiteRouterDelegate _router = SiteRouterDelegate(
    pageBuilder: _buildPage,
  );

  @override
  void initState() {
    super.initState();
    unawaited(RecipeFavorites.shared.load());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  Widget _buildPage(
    BuildContext context,
    SiteRoute route,
    ValueChanged<String> navigate,
  ) {
    if (route.kind == SiteRouteKind.home) {
      return EmberHome(onNavigatePath: navigate);
    }
    final Widget body = switch (route.kind) {
      SiteRouteKind.packages => PackagesPage(
        onOpenPackage: (id) => navigate('/packages/$id'),
      ),
      SiteRouteKind.packageDetail => PackageDetailPage(
        packageId: route.packageId!,
        onOpenDoc: (section) => navigate('/docs/${route.packageId}/$section'),
      ),
      SiteRouteKind.components => ComponentExplorerPage(onNavigate: navigate),
      SiteRouteKind.docs => DocsPage(
        packageId: route.packageId!,
        sectionId: route.sectionId!,
        anchor: Uri.parse(route.path).fragment,
        onNavigate: navigate,
      ),
      SiteRouteKind.examples => ExamplesPage(
        favorites: RecipeFavorites.shared,
        onToggleFavorite: (id) => unawaited(RecipeFavorites.shared.toggle(id)),
        onOpenRecipe: (id) => navigate('/playground/$id'),
      ),
      SiteRouteKind.playground
          when route.packageId == 'components' &&
              componentById(route.recipeId!) != null =>
        ComponentGuidePage(
          guide: componentById(route.recipeId!)!,
          onNavigate: navigate,
          playground: true,
        ),
      SiteRouteKind.playground => PlaygroundPage(
        onNavigate: navigate,
        recipeId: route.recipeId!,
        onOpenRecipe: (id) => navigate('/playground/$id'),
      ),
      SiteRouteKind.search => SiteSearchPage(onNavigate: navigate),
      SiteRouteKind.notFound => SiteNotFoundPage(
        path: route.path,
        onNavigate: navigate,
      ),
      SiteRouteKind.home => const SizedBox.shrink(),
    };
    return SiteShell(path: route.path, onNavigate: navigate, child: body);
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Nib — Make every interaction count',
    debugShowCheckedModeBanner: false,
    routeInformationParser: const SiteRouteParser(),
    routerDelegate: _router,
    theme: componentEmberTheme().copyWith(
      textTheme: emberMaterialTheme().textTheme,
    ),
  );
}

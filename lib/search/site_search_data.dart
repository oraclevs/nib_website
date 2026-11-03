import '../components/component_catalog.dart';
import '../content/site_content.dart';
import '../recipes/recipe_catalog.dart';
import 'site_search_index.dart';

/// Builds search directly from the two reviewed inventories. A recipe that is
/// removed from [verifiedRecipes] disappears from search on the next build.
SiteSearchIndex buildSiteSearchIndex() => SiteSearchIndex([
  for (final package in SiteContent.packages)
    SiteSearchEntry(
      title: package.name,
      summary: package.description,
      route: package.route,
      kind: SiteSearchKind.package,
      keywords: [package.role, package.tagline, ...package.capabilities],
    ),
  for (final article in SiteContent.articles) articleSearchEntry(article),
  for (final recipe in verifiedRecipes)
    SiteSearchEntry(
      title: recipe.title,
      summary: recipe.summary,
      route: recipe.route,
      kind: SiteSearchKind.recipe,
      keywords: [recipe.category],
    ),
]);

/// Index the content the reader can see, including API contracts and code.
/// Titles keep their higher search weight through [SiteSearchIndex].
SiteSearchEntry articleSearchEntry(DocArticle article) => SiteSearchEntry(
  title: article.title,
  summary: article.summary,
  route: article.route,
  kind: SiteSearchKind.guide,
  keywords: [
    article.packageId,
    if (article.packageId == 'components')
      ...?componentById(article.id)?.symbols,
    for (final section in article.sections) ...[
      section.heading,
      ...section.paragraphs,
      for (final block in section.blocks) block.searchText,
      ?section.code,
      ?section.note,
      for (final entry in section.api) ...[
        entry.name,
        entry.type,
        entry.defaultValue,
        entry.description,
      ],
    ],
  ],
);

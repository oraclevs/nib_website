import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:nib_ember_living/content/site_content.dart';
import 'package:nib_ember_living/content/motion_capabilities.dart';
import 'package:nib_ember_living/content/motion_api_topics.dart';
import 'package:nib_ember_living/docs/doc_example_catalog.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/recipes/recipe_catalog.dart';

Map<String, Object?> listItem(DocListItem item) => {
  'text': item.text,
  'children': item.children.map(listItem).toList(),
};

Map<String, Object?> block(DocBlock value) => switch (value) {
  DocList() => {
    'kind': 'list',
    'ordered': value.ordered,
    'items': value.items.map(listItem).toList(),
  },
  DocTable() => {'kind': 'table', 'headers': value.headers, 'rows': value.rows},
  DocLink() => {'kind': 'link', 'label': value.label, 'route': value.route},
};

Map<String, Object?> section(DocSection value) => {
  'id': value.id,
  'heading': value.heading,
  'paragraphs': value.paragraphs,
  'code': value.code,
  'note': value.note,
  'blocks': value.blocks.map(block).toList(),
  'api': value.api
      .map(
        (a) => {
          'name': a.name,
          'type': a.type,
          'default': a.defaultValue,
          'description': a.description,
        },
      )
      .toList(),
};

void main() {
  test('export actual site content with unique public routes', () {
    final articles = SiteContent.articles;
    expect(articles.map((a) => a.route).toSet().length, articles.length);
    expect(allRecipes.map((r) => r.route).toSet().length, allRecipes.length);
    expect(
      componentGuides.map((g) => g.route).toSet().length,
      componentGuides.length,
    );
    final content = {
      'motionVersion': motionPublishedVersion,
      'motionCapabilities': motionCapabilities.map(section).toList(),
      'motionApiTopics': motionApiTopics,
      'packages': SiteContent.packages
          .map(
            (p) => {
              'id': p.id,
              'name': p.name,
              'route': p.route,
              'docsRoute': p.docsRoute,
              'tagline': p.tagline,
              'description': p.description,
              'status': p.status,
              'install': p.install,
              'capabilities': p.capabilities,
              'caution': p.caution,
            },
          )
          .toList(),
      'learningPaths': SiteContent.learningPaths,
      'articles': articles
          .map(
            (a) => {
              'route': a.route,
              'id': a.id,
              'packageId': a.packageId,
              'title': a.title,
              'summary': a.summary,
              'sections': a.sections.map(section).toList(),
              'recipe': a.relatedRecipeId,
              'evidence': a.evidence,
              'examples': docExamplesFor(a.packageId, a.id)
                  .map(
                    (e) => {
                      'route': e.playgroundRoute,
                      'source': e.sourceAsset,
                      'class': e.widgetClass,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'components': componentGuides
          .map(
            (g) => {
              'route': g.playgroundRoute,
              'docsRoute': g.route,
              'id': g.id,
              'title': g.title,
              'summary': g.summary,
              'category': g.category,
              'symbols': g.symbols,
              'limitations': g.limitations,
              'minimalCode': g.minimalCode,
              'composition': g.composition,
              'controls': g.controls
                  .map(
                    (c) => {
                      'label': c.label,
                      'kind': c.kind.name,
                      'min': c.minimum,
                      'max': c.maximum,
                      'choices': c.choices,
                      'help': c.help,
                      'advanced': c.advanced,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'recipes': allRecipes
          .map(
            (r) => {
              'route': r.route,
              'title': r.title,
              'summary': r.summary,
              'category': r.category,
              'action': r.action,
              'purpose': r.purpose,
              'docsRoute': r.docsRoute,
              'gallery': verifiedRecipes.contains(r),
              'controls': recipeControls(r)
                  .map(
                    (c) => {
                      'label': c.label,
                      'group': c.group,
                      'min': c.minimum,
                      'max': c.maximum,
                      'initial': c.initial,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };
    final output = File('build/seo/content.json');
    output.parent.createSync(recursive: true);
    output.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(content),
    );
    stdout.writeln(
      'Exported ${articles.length} guides, ${componentGuides.length} component previews, ${allRecipes.length} recipes.',
    );
  });
}

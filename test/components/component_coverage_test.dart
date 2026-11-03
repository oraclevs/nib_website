import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/components/component_catalog.dart';
import 'package:nib_ember_living/components/component_support_guides.dart';
import 'package:nib_ember_living/content/site_content.dart';

void main() {
  final inventory = jsonDecode(
    File('docs/evidence/2026-10-28-components/inventory.json')
        .readAsStringSync(),
  ) as Map<String, dynamic>;
  final reference = jsonDecode(
    File('assets/reference/public_api.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final families = (inventory['families'] as List).cast<Map<String, dynamic>>();
  final symbols = (inventory['publicSymbols'] as List)
      .cast<Map<String, dynamic>>();
  final api = (reference['packages']['components'] as List)
      .cast<Map<String, dynamic>>();
  final publicNames = symbols.map((symbol) => symbol['name'] as String).toSet();
  final byName = {for (final symbol in api) symbol['name'] as String: symbol};
  final familyGuides = componentGuides
      .where((guide) => !guide.composition)
      .toList();
  final covered = <String>{
    ...familyGuides
        .expand((guide) => guide.symbols)
        .where(publicNames.contains),
    ...componentSupportSymbols.values.expand((names) => names),
  };

  test('API reference preserves the 144-symbol baseline plus the Water Lab addition', () {
    expect(symbols.length, 144);
    expect(byName.length, api.length, reason: 'Duplicate API-reference names');
    expect(byName.keys.toSet(), {...publicNames, 'NibWaterGlass'});
    expect(
      byName['NibWaterGlass']!['source'],
      'ComponetsNib/nib_components/lib/src/liquid_glass/nib_water_glass.dart',
    );
    expect(componentById('liquid-glass')!.symbols, contains('NibWaterGlass'));
    for (final symbol in symbols) {
      final actual = byName[symbol['name']]!;
      for (final key in ['kind', 'source']) {
        expect(actual[key], symbol[key], reason: '${symbol['name']} $key');
      }
      List<Map<String, dynamic>> signatures(Map<String, dynamic> entry) => [
        for (final dynamic member in entry['members'] as List)
          {
            for (final key in ['name', 'kind', 'signature']) key: member[key],
          },
      ];
      expect(
        signatures(actual),
        signatures(symbol),
        reason: '${symbol['name']} member signatures',
      );
    }
  });

  test('every source family has its complete canonical guide or support mapping', () {
    expect(families.length, 34);
    final missing = <String>[];
    for (final family in families) {
      final id = family['id'] as String;
      final expected = (family['symbols'] as List).cast<String>().toSet();
      final Set<String> mapped;
      if (id == 'theme' || id == 'validation') {
        final articleId = id == 'theme' ? 'theming' : id;
        expect(
          componentSupportArticles.any((article) => article.id == articleId),
          isTrue,
        );
        mapped = componentSupportSymbols[articleId]!.toSet();
      } else {
        final guide = componentById(id);
        if (guide == null || guide.composition) {
          missing.add('$id: no canonical family guide');
          continue;
        }
        mapped = guide.symbols.toSet();
        expect(
          SiteContent.articleById('components', id)?.route,
          guide.route,
          reason: '$id article integration',
        );
      }
      final absent = expected.difference(mapped).toList()..sort();
      if (absent.isNotEmpty) missing.add('$id: ${absent.join(', ')}');
    }
    expect(
      missing,
      isEmpty,
      reason:
          'Incomplete family coverage remains a failing gate:\n${missing.join('\n')}',
    );
  });

  test('standalone, compound, helper and supporting declarations all have coverage', () {
    const counts = {
      'standalone_ui': 31,
      'compound_family_member': 8,
      'public_show_open_helper': 7,
      'supporting_api': 98,
    };
    final missing = <String>[];
    for (final category in counts.entries) {
      final names = symbols
          .where((symbol) => symbol['classification'] == category.key)
          .map((symbol) => symbol['name'] as String)
          .toSet();
      expect(names.length, category.value, reason: category.key);
      final absent = names.difference(covered).toList()..sort();
      if (absent.isNotEmpty) {
        missing.add('${category.key}: ${absent.join(', ')}');
      }
    }
    expect(
      missing,
      isEmpty,
      reason: 'Unmapped public API:\n${missing.join('\n')}',
    );
    expect(covered, publicNames);
  });

  test(
    'support mappings use real symbols and do not create fake demo families',
    () {
      final articleIds = componentSupportArticles
          .map((article) => article.id)
          .toSet();
      expect(componentSupportSymbols.keys.toSet(), articleIds);
      for (final mapping in componentSupportSymbols.entries) {
        expect(
          mapping.value.toSet().length,
          mapping.value.length,
          reason: mapping.key,
        );
        expect(
          mapping.value.every(publicNames.contains),
          isTrue,
          reason: mapping.key,
        );
      }
      final familyIds = families
          .map((family) => family['id'] as String)
          .toSet();
      for (final guide in familyGuides) {
        expect(
          familyIds,
          contains(guide.id),
          reason: '${guide.id} invented family',
        );
        final declared = (reference['packages'][guide.apiPackageId] as List)
            .map((dynamic symbol) => symbol['name'] as String)
            .toSet();
        // Glass documents its underlying public motion primitive explicitly.
        final allowed = {
          ...declared,
          if (guide.id == 'liquid-glass')
            ...(reference['packages']['motion'] as List)
                .map((dynamic symbol) => symbol['name'] as String)
                .where(
                  (name) =>
                      name == 'NibGlass' ||
                      name == 'NibBubbleEmitter' ||
                      name.startsWith('NibWater'),
                ),
        };
        expect(
          guide.symbols.every(allowed.contains),
          isTrue,
          reason: '${guide.id} unknown API symbol',
        );
      }
      for (final guide in componentGuides.where((guide) => guide.composition)) {
        expect(
          familyIds.contains(guide.id),
          isFalse,
          reason: 'Composition counted as a source family',
        );
        final declared = (reference['packages'][guide.apiPackageId] as List)
            .map((dynamic symbol) => symbol['name'] as String)
            .toSet();
        expect(
          guide.symbols.every(declared.contains),
          isTrue,
          reason: guide.id,
        );
      }
    },
  );

  test(
    'routes are unique, textarea aliases input, and source assets exist',
    () {
      final routes = [
        ...componentGuides.map((guide) => guide.route),
        ...componentSupportArticles.map((article) => article.route),
      ];
      expect(routes.toSet().length, routes.length);
      final articles = SiteContent.articlesFor('components');
      expect(
        articles.map((article) => article.route).toSet().length,
        articles.length,
      );
      expect(componentById('textarea'), same(componentById('input')));
      expect(componentById('textarea')!.symbols, contains('NibTextarea'));
      final manifest = File('pubspec.yaml').readAsStringSync();
      expect(manifest, contains('- lib/components/examples/'));
      expect(manifest, contains('- lib/components/component_settings.dart'));
      expect(manifest, contains('- lib/components/component_theme.dart'));
      for (final guide in componentGuides) {
        expect(
          File(guide.demoFile).existsSync(),
          isTrue,
          reason: guide.demoFile,
        );
        expect(
          File(guide.demoFile).readAsStringSync(),
          contains('class ${guide.demoClass}'),
          reason: guide.id,
        );
        expect(guide.playgroundRoute, '/playground/components/${guide.id}');
      }
    },
  );
}

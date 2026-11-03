import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/content/site_content.dart';
import 'package:nib_ember_living/docs/doc_example_catalog.dart';
import 'package:nib_ember_living/pages/docs_page.dart';
import 'package:nib_motion/nib_motion.dart';

import '../support/file_asset_bundle.dart';

void main() {
  testWidgets(
    'introduction and installation have no preview or motion toolbar',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final id in ['introduction', 'installation']) {
        await tester.pumpWidget(
          DefaultAssetBundle(
            bundle: FileAssetBundle(),
            child: MaterialApp(
              home: Scaffold(
                body: DocsPage(
                  key: ValueKey(id),
                  packageId: 'motion',
                  sectionId: id,
                  onNavigate: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('Live example'), findsNothing);
        expect(find.text('Interactive example'), findsNothing);
        expect(find.text('Reduce motion'), findsNothing);
        expect(docExamplesFor('motion', id), isEmpty);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'starter lessons have distinct interactions, repeat safely and reduce motion',
    (tester) async {
      final ids = ['getting-started', 'first-animation', 'migration'];
      expect(
        ids.map((id) => docExampleFor('motion', id)!.identity).toSet(),
        hasLength(3),
      );
      for (final reduced in [false, true]) {
        for (final id in ids.take(2)) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: NibMotionConfig(
                  reducedMotion: reduced,
                  child: Center(
                    child: SizedBox(
                      width: 280,
                      child: docExampleFor('motion', id)!.buildPreview(),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          for (var i = 0; i < 6; i++) {
            await tester.tap(
              find.text(
                id == 'getting-started'
                    ? 'Replay entrance'
                    : i.isEven
                    ? 'Save idea'
                    : 'Undo save',
              ),
            );
            await tester.pump(const Duration(milliseconds: 40));
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  test('water current docs and generated API use the stable policy', () {
    final water = SiteContent.articleById('motion', 'water')!;
    expect(water.title, 'Water surfaces');
    expect(
      water.sections.expand((s) => s.paragraphs).join(' '),
      contains('stable public API'),
    );
    final api = jsonDecode(
      File('assets/reference/public_api.json').readAsStringSync(),
    ) as Map;
    for (final symbols in (api['packages'] as Map).values) {
      for (final symbol in symbols as List) {
        if ([
          'NibWaterSurface',
          'NibWaterGlass',
          'NibWaterQuality',
        ].contains(symbol['name'])) {
          expect(
            (symbol['documentation'] as String).toLowerCase(),
            isNot(contains('experimental')),
          );
        }
      }
    }
  });
}
